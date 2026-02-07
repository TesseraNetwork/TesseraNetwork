# Tessera Protocol Validator Node

## Project Overview

The Tessera Protocol Validator Node is a core component for interacting with and validating the state of the Tessera network. It's a robust, secure, and performance-oriented system designed to manage accounts, process transactions, and handle staking operations within a blockchain-like environment.

## Features

-   **Account Management:** Secure creation, retrieval, and updates of user accounts, including balances and transaction nonces.
-   **Secure Transactions:** Implements a "secure mode" requiring cryptographic signatures and nonce validation to ensure transaction authenticity and prevent replay attacks.
-   **Hybrid Data Storage:** Utilizes a "hot state" caching layer (Upstash) for speed and a "cold ledger" (Base44) for persistent, authoritative data storage.
-   **Staking Functionality:** Supports staking operations, including fund locking, reward calculation, and claiming mechanisms.
-   **Genesis Initialization:** Provides tools to initialize the network with a predefined tokenomics model, including treasury, community pools, and vesting schedules.
-   **Secure Network Exposure:** Designed for integration with Cloudflare Tunnels to provide secure and performant external access to the node.

## Documentation

*   **[White Paper](docs/WHITEPAPER.md):** A detailed technical overview of the Tessera Protocol, its architecture, tokenomics, and security model.
*   **[Deployment Guide](docs/deployment_guide.md):** Comprehensive instructions for setting up, configuring, and running the Tessera Validator Node in various environments.
*   **[Developer Guide](docs/developer_guide.md):** A guide for developers to understand the codebase, extend functionality, and contribute to the project.


## How it Works: Architecture Overview

The Tessera Validator Node operates with a modular architecture, leveraging several interconnected components:

1.  **Gateway (`bin/gateway.js`):** The central API server that exposes endpoints for account management, transaction processing, and staking. It orchestrates data flow between the hot state and cold ledger.
2.  **Tessera Proxy (`tessera-proxy/index.js`):** An intermediary layer that can perform tasks like scrubbing sensitive information or re-routing requests before they reach the gateway.
3.  **Cold Ledger (Base44):** The primary, persistent data store for all blockchain entities (accounts, transactions, blocks).
4.  **Hot State (Upstash):** A high-speed cache used by the Gateway to store frequently accessed account data, optimizing read/write performance.
5.  **Cloudflare Tunnel:** (Optional, but integrated) Provides a secure, public endpoint for the node, abstracting away direct server exposure.
6.  **Utility Scripts (`bin/`):** A collection of scripts for key generation, transaction signing, fund transfers, staking actions, and resetting the network state.

```mermaid
graph TD
    User --&gt; |Requests| Cloudflare_Tunnel;
    Cloudflare_Tunnel --&gt; |Routes| Tessera_Proxy;
    Tessera_Proxy --&gt; |Forwards/Modifies| Gateway;
    Gateway --&gt; |Read/Write Hot State| Upstash_Cache;
    Gateway --&gt; |Read/Write Cold Ledger| Base44_DB;
    Scripts --&gt; |Directly interact with| Gateway;
    Scripts --&gt; |Generate Keys| Keygen;

    subgraph External Services
        Upstash_Cache[Upstash (Hot State Cache)]
        Base44_DB[Base44 (Cold Ledger DB)]
    end

    subgraph Tessera Node Components
        Gateway[bin/gateway.js (API Server)]
        Tessera_Proxy[tessera-proxy/index.js]
        Scripts[Utility Scripts (bin/)]
    end
```

## Getting Started

### Prerequisites

*   Node.js (v18 or higher recommended)
*   npm
*   `cloudflared` executable (for secure tunneling)
*   Access to Base44 API (with `api_key`)
*   Access to Upstash Redis (with `UPSTASH_URL` and `UPSTASH_TOKEN`)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-org/tessera.git
    cd tessera
    ```
2.  **Install Node.js dependencies:**
    ```bash
    npm install
    cd tessera-proxy
    npm install
    cd ..
    ```

### Configuration

*   **Tessera Proxy:** Create a `.env` file in the `tessera-proxy/` directory with your Cloudflare tunnel URL:
    ```
    CLOUDFLARE_TUNNEL_URL=https://your-cloudflare-tunnel-url.trycloudflare.com
    ```
*   **Gateway:** Ensure your environment variables for `BASE44_URL`, `BASE44_KEY`, `UPSTASH_URL`, and `UPSTASH_TOKEN` are set. These are critical for the gateway to connect to the cold ledger and hot state. You might set these in a `.env` file in the root if you're not using a global environment.
    *   `BASE44_URL`: e.g., `https://app.base44.com/api/apps/YOUR_APP_ID/entities`
    *   `BASE44_KEY`: Your Base44 API Key
    *   `UPSTASH_URL`: Your Upstash Redis URL
    *   `UPSTASH_TOKEN`: Your Upstash Redis Token

### Running the Node

You'll typically run these components in separate terminal windows:

1.  **Start the Gateway:**
    ```bash
    node bin/gateway.js
    ```
2.  **Start the Tessera Proxy:**
    ```bash
    cd tessera-proxy
    node index.js
    cd ..
    ```
3.  **Start the Cloudflare Tunnel (if applicable):**
    Ensure `cloudflared-linux-amd64` (or your OS-specific binary) is in your path or current directory. Replace `http://localhost:8080` with the actual address your `tessera-proxy` is listening on (default is usually 8080 or 3000, check `tessera-proxy/index.js`).
    ```bash
    ./cloudflared-linux-amd64 tunnel --url http://localhost:8080
    ```

## Usage Examples

### Initializing the Network (First Run)

To set up a fresh Tessera network, first reset and then initialize genesis:

```bash
# Reset all data (WARNING: DELETES ALL DATA)
bash bin/reset.sh

# Initialize the tokenomics and core accounts
node bin/genesis-init.js
```

### Generating Accounts

```bash
node bin/keygen.js
# This will output a public address and private key. Save them securely!
# Example output:
# PUBLIC ADDRESS: 0x...
# PRIVATE KEY: ...
```

### Transferring Funds

Use `transfer.sh` to move funds, typically from the Treasury to a new account:

```bash
bash bin/transfer.sh <recipient_address> <amount>
# Example: bash bin/transfer.sh 0xAbcDef123... 1000
```

### Signing and Sending Transactions

Use `sign-transfer.js` to create and broadcast a signed transaction:

```bash
node bin/sign-transfer.js <from_address> <to_address> <amount> <private_key_of_from_address>
# Example: node bin/sign-transfer.js 0xAbcDef123... 0xGhijkLmno456... 100 1234abcd...
```

### Staking

```bash
# Stake funds
node bin/staking.js stake <staker_address> <amount>

# Check staking stats
node bin/staking.js stats <staker_address>

# Claim rewards
node bin/staking.js claim <staker_address>
```

## Testing

Run the comprehensive test suite to verify all core functionalities:

```bash
bash test_all.sh
```

## Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the [MIT License](LICENSE).
