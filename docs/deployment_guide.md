# Tessera Protocol Validator Node: Deployment Guide

This guide provides detailed instructions for deploying and maintaining a Tessera Protocol Validator Node in various environments. It covers prerequisites, setup, running components, and considerations for production deployments.

## 1. Prerequisites

Before you begin, ensure you have the following:

*   **Operating System:** Linux (Ubuntu/Debian recommended), macOS, or Windows (with WSL2).
*   **Node.js:** Version 18.x or higher.
    *   Verify with: `node -v`
*   **npm:** Node Package Manager, usually bundled with Node.js.
    *   Verify with: `npm -v`
*   **`jq`:** A lightweight and flexible command-line JSON processor. Essential for many of the utility scripts.
    *   Installation: `sudo apt-get install jq` (Debian/Ubuntu), `brew install jq` (macOS), or via package manager for other OS.
    *   Verify with: `jq --version`
*   **`bc`:** An arbitrary precision calculator language. Used in some shell scripts for floating-point arithmetic.
    *   Installation: `sudo apt-get install bc` (Debian/Ubuntu), `brew install bc` (macOS).
*   **Cloudflare Account & `cloudflared`:**
    *   A Cloudflare account is required to set up a Tunnel for secure external access.
    *   Download the `cloudflared` client for your operating system from [Cloudflare Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/). Place the executable in your `tools/` directory (or ensure it's in your system's PATH).
*   **Base44 Account:** Access to a Base44 application with an API Key. This will serve as your cold ledger.
*   **Upstash Account:** Access to an Upstash Redis database (URL and Token). This will serve as your hot state cache.

## 2. Environment Setup

### 2.1 Clone the Repository

```bash
git clone https://github.com/your-org/tessera.git
cd tessera
```

### 2.2 Install Node.js Dependencies

Install dependencies for both the main project and the proxy:

```bash
npm install
cd tessera-proxy
npm install
cd ..
```

### 2.3 Configuration

Critical configuration parameters are managed via environment variables or `.env` files.

#### `tessera-proxy/.env`

Create a `.env` file in the `tessera-proxy/` directory:

```env
# Your Cloudflare Tunnel URL. This is the public facing URL for your proxy.
# Example: CLOUDFLARE_TUNNEL_URL=https://my-tessera-node.yourdomain.com
CLOUDFLARE_TUNNEL_URL=YOUR_CLOUDFLARE_TUNNEL_URL

# The local port the gateway.js is listening on
GATEWAY_PORT=3000
```
**Note:** Ensure the `GATEWAY_PORT` in `tessera-proxy/.env` matches the port your `bin/gateway.js` instance is listening on.

#### Gateway Environment Variables

The `bin/gateway.js` requires the following environment variables. It's recommended to set these in a `.env` file in the **root** directory (`./tessera`) or configure them directly in your deployment environment (e.g., Docker, Kubernetes).

```env
# Base44 Cold Ledger Configuration
BASE44_URL=https://app.base44.com/api/apps/YOUR_APP_ID/entities
BASE44_KEY=YOUR_BASE44_API_KEY

# Upstash Hot State Cache Configuration
UPSTASH_URL=YOUR_UPSTASH_REDIS_URL
UPSTASH_TOKEN=YOUR_UPSTASH_REDIS_TOKEN

# Gateway Server Port (should match GATEWAY_PORT in tessera-proxy/.env)
GATEWAY_SERVER_PORT=3000

# Set to 'true' to enable signature verification for transactions
SECURE_MODE_ENABLED=true
```
**Security Best Practice:** Never commit `.env` files directly to your Git repository. Ensure they are included in your `.gitignore`.

## 3. Running the Node Components

Each core component should typically run as a separate process.

### 3.1 Start the Tessera Gateway

The Gateway is the core logic handler.

```bash
node bin/gateway.js
```
You should see output similar to: `Tessera Gateway listening on port 3000`

### 3.2 Start the Tessera Proxy

The Proxy handles external requests and forwards them to the Gateway.

```bash
cd tessera-proxy
node index.js
cd ..
```
You should see output similar to: `Tessera Proxy server listening on port 8080` (or configured port)

### 3.3 Start the Cloudflare Tunnel

The Cloudflare Tunnel creates a secure connection from your local node to the Cloudflare edge, making your proxy publicly accessible.

1.  **Authenticate `cloudflared`:** If this is your first time, you'll need to authenticate.
    ```bash
    ./tools/cloudflared-linux-amd64 tunnel login
    ```
    This will open a browser window to authenticate with your Cloudflare account.

2.  **Run the Tunnel:**
    ```bash
    ./tools/cloudflared-linux-amd64 tunnel --url http://localhost:8080
    ```
    **Note:** Replace `http://localhost:8080` with the actual address your `tessera-proxy` is listening on. This is usually `http://localhost:8080` if the proxy `index.js` default port is used.

    You should see output indicating the tunnel is active and providing a public URL (e.g., `https://random-subdomain.trycloudflare.com`). This is the URL you will configure in your `tessera-proxy/.env` `CLOUDFLARE_TUNNEL_URL`.

## 4. Initializing the Network (First Deployment)

For a fresh deployment, you must initialize the blockchain's genesis state:

1.  **Reset all data:** This clears all existing accounts, transactions, and blocks from Base44 and the Upstash cache. **Use with extreme caution on a running network.**
    ```bash
    bash bin/reset.sh
    ```
2.  **Initialize Genesis:** This sets up the initial tokenomics model, creates the Treasury, Community Staking Pool, Founder, and Genesis Liquidity accounts, and mints the genesis block.
    ```bash
    node bin/genesis-init.js
    ```

## 5. Production Considerations

*   **Process Management:** Use a process manager like PM2, systemd, or Docker/Kubernetes to keep `gateway.js`, `tessera-proxy/index.js`, and `cloudflared` running reliably and to manage restarts.
*   **Logging:** Configure comprehensive logging for all components. The `cloudflared.log` file is already excluded via `.gitignore`, but ensure application logs are managed and rotated.
*   **Monitoring:** Utilize the `monitoring/monitor_network_health.sh` script or integrate with dedicated monitoring solutions to track node health, API performance, and network statistics.
*   **Security:**
    *   **API Keys/Tokens:** Securely manage `BASE44_KEY` and `UPSTASH_TOKEN`. Do not hardcode them. Use environment variables or a secrets management system.
    *   **Firewall:** Restrict direct access to the Gateway and Proxy ports (e.g., 3000, 8080) to only trusted sources, especially if not using Cloudflare Tunnel.
    *   **Regular Updates:** Keep Node.js, npm, and all dependencies updated to patch security vulnerabilities.
*   **Scalability:** For high-load environments, consider running multiple instances of the Gateway and Proxy behind a load balancer.

## 6. Maintenance

*   **Backups:** Regularly back up your Base44 data.
*   **Upgrades:** Follow specific upgrade procedures for new versions of the Tessera Protocol.
*   **Monitoring Alerts:** Set up alerts for critical events (e.g., API errors, tunnel disconnections, low validator uptime).
