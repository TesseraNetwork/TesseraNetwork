# Tessera Protocol Validator Node: Developer Guide

This guide is for developers looking to understand, modify, or extend the Tessera Protocol Validator Node. It covers the codebase structure, how to interact with the API, and how to contribute to the project.

## 1. Codebase Structure

The project is organized into several key directories:

*   **`bin/`**: Contains core executable JavaScript and shell scripts for interacting with the Tessera network (e.g., `gateway.js`, `keygen.js`, `transfer.sh`, `staking.js`).
*   **`tessera-proxy/`**: Houses the Node.js proxy server, responsible for routing requests and applying specific filtering/transformation rules.
*   **`docs/`**: Comprehensive documentation, including the White Paper and other guides.
*   **`dev_utils/`**: Utility scripts primarily used during development, testing, or debugging (e.g., `interactive_api_tester.sh`, `update_test_block_data.sh`).
*   **`tools/`**: Contains external binaries or archives used by the project (e.g., `cloudflared`).
*   **`monitoring/`**: Scripts for monitoring the network's health (e.g., `monitor_network_health.sh`).
*   **`examples/`**: Example client implementations or usage patterns (e.g., `tessera_api_client_example.py`).
*   **`tests/`**: Contains various test suites, including `test_all.sh` for end-to-end testing and `api_integration_test_suite.sh` for API-level testing.
*   **`deprecated_utils/`**: Older or superseded utility scripts kept for historical reference, not actively maintained or recommended for use.

## 2. Setting Up Your Development Environment

Refer to the [Deployment Guide](deployment_guide.md) for detailed instructions on setting up your environment, installing dependencies, and configuring API keys/tokens.

## 3. Understanding the Gateway (`bin/gateway.js`)

The `gateway.js` is the core of the Tessera Validator Node. It's a Node.js HTTP server that:

*   Handles incoming API requests (e.g., `/Account`, `/Transaction`, `/Block`, `/Staking`).
*   Validates incoming data against expected schemas (e.g., `nonce` checks, `from_address` validation).
*   Manages the dual-layer data storage:
    *   **Hot State (Upstash):** For fast reads/writes of frequently accessed data (e.g., current account balances and nonces).
    *   **Cold Ledger (Base44):** For persistent, immutable storage of all blockchain data.
*   Implements cryptographic verification (e.g., transaction signatures).

**Key areas to explore in `gateway.js`:**

*   **`findAccountByAddress(address)`:** Demonstrates how accounts are retrieved, prioritizing the hot state and falling back to the cold ledger.
*   **`verifySignature(tx)`:** Crucial for understanding transaction security, including message reconstruction and signature validation.
*   **`processTransaction(tx)`:** The main logic for applying a transaction to the network state, updating balances, nonces, and synchronizing data across hot/cold layers.
*   **HTTP Route Handlers:** Each `if (req.url.startsWith('/Account')) { ... }` block defines how a specific API endpoint is handled.

## 4. Extending the API

To add new functionality or entities to the Tessera Protocol:

1.  **Define the new Entity (Base44):** Ensure your new entity is correctly defined in your Base44 application.
2.  **Update `gateway.js`:**
    *   **New Route:** Add a new `if (req.url.startsWith('/YourNewEntity')) { ... }` block to handle requests for your new entity.
    *   **Logic:** Implement the necessary business logic for `GET`, `POST`, `PUT`, `DELETE` operations, including data validation, interaction with Base44, and potential hot state caching.
    *   **Error Handling:** Ensure robust error handling and appropriate HTTP status codes.
3.  **Create Utility Scripts:** Develop new shell or Node.js scripts in `bin/` to interact with your new API endpoints, demonstrating their usage.
4.  **Update Documentation:** Document your new entity and API endpoints in the relevant guides and potentially the White Paper.
5.  **Add Tests:** Create new test cases in `test_all.sh` or `tests/api_integration_test_suite.sh` to ensure your new functionality works as expected.

## 5. Working with Utility Scripts

The `bin/` directory contains various scripts that demonstrate how to interact with the Tessera network.

*   **`keygen.js`**: Generates a new Tessera address and private key.
    ```bash
    node bin/keygen.js
    ```
*   **`transfer.sh <to_address> <amount>`**: Transfers TES tokens from the `0xTesseraTreasury` to a specified address. Useful for funding new accounts.
    ```bash
    bash bin/transfer.sh 0xYourAddressHere 1000
    ```
*   **`sign-transfer.js <from_address> <to_address> <amount> <private_key>`**: Creates a cryptographically signed transaction and submits it to the Gateway.
    ```bash
    node bin/sign-transfer.js 0xSenderAddress 0xReceiverAddress 100 YourPrivateKey
    ```
*   **`staking.js <command> <address> [amount]`**: Manages staking operations.
    ```bash
    node bin/staking.js stake 0xYourAddress 50
    node bin/staking.js stats 0xYourAddress
    node bin/staking.js claim 0xYourAddress
    ```
*   **`reset.sh`**: **(DANGER!)** Wipes all data from the Base44 cold ledger and Upstash hot state. Use for development environments only.
    ```bash
    bash bin/reset.sh
    ```
*   **`genesis-init.js`**: Initializes the network with the default tokenomics and genesis block after a reset.
    ```bash
    node bin/genesis-init.js
    ```
*   **`finalize_latest_block.sh`**: Utility to find and finalize the most recent block.
*   **`manual_block_sealer.sh`**: Simulates a block sealing process by taking transactions from a mempool, creating a block, and updating state.

## 6. Testing Your Changes

*   **Comprehensive Test Suite (`test_all.sh`):** This script runs a full end-to-end scenario, covering account generation, funding, signed transfers, and staking.
    ```bash
    bash test_all.sh
    ```
*   **API Integration Test Suite (`tests/api_integration_test_suite.sh`):** This suite directly tests the CRUD operations of all 12 core entities via the Gateway API.
    ```bash
    bash tests/api_integration_test_suite.sh
    ```
*   **Interactive API Tester (`dev_utils/interactive_api_tester.sh`):** An interactive menu-driven script to manually test various API endpoints and complex scenarios.
    ```bash
    bash dev_utils/interactive_api_tester.sh
    ```

## 7. Contributing

Please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines on how to contribute to this project. This includes information on reporting bugs, suggesting enhancements, and submitting code contributions.
