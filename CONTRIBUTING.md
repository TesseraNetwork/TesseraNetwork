# Contributing to Tessera Protocol Validator Node

We welcome contributions to the Tessera Protocol Validator Node! By participating in this project, you agree to abide by our Code of Conduct.

## Code of Conduct

[Link to Code of Conduct, or include it here]

## How Can I Contribute?

### Reporting Bugs

If you find a bug, please open an issue on our GitHub repository. When reporting a bug, please include:

-   A clear and concise description of the bug.
-   Steps to reproduce the behavior.
-   Expected behavior.
-   Actual behavior.
-   Screenshots or error messages (if applicable).
-   Your environment (OS, Node.js version, etc.).

### Suggesting Enhancements

We love new ideas! If you have a suggestion for an enhancement:

-   Open an issue to discuss your idea.
-   Clearly describe the proposed feature and its benefits.
-   Explain how it would fit into the existing architecture.

### Code Contributions

We appreciate code contributions that help improve Tessera. To contribute code:

1.  **Fork the repository:** Start by forking the official repository to your GitHub account.
2.  **Clone your fork:**
    ```bash
    git clone https://github.com/your-username/tessera.git
    cd tessera
    ```
3.  **Create a new branch:** Choose a descriptive branch name (e.g., `feature/add-staking-rewards`, `bugfix/fix-nonce-validation`).
    ```bash
    git checkout -b feature/your-feature-name
    ```
4.  **Make your changes:**
    *   Ensure your code adheres to existing coding styles and conventions.
    *   Add unit or integration tests for new features or bug fixes.
    *   Update documentation (e.g., `README.md`) as necessary.
5.  **Run tests:** Before committing, make sure all tests pass.
    ```bash
    bash test_all.sh
    # You might also want to run:
    # bash tests/api_integration_test_suite.sh
    ```
6.  **Commit your changes:** Write clear and concise commit messages.
    ```bash
    git commit -m "feat: Add new feature"
    ```
7.  **Push to your fork:**
    ```bash
    git push origin feature/your-feature-name
    ```
8.  **Open a Pull Request (PR):**
    *   Go to your fork on GitHub and open a new pull request to the `main` branch of the original repository.
    *   Provide a clear title and description for your PR, explaining the changes and linking to any relevant issues.

## Code Style

-   Follow existing JavaScript and Shell scripting conventions.
-   Use consistent indentation (2 spaces for JavaScript).
-   Keep lines reasonably short.

## Testing

-   All new features and bug fixes should ideally be accompanied by relevant tests.
-   Run `bash test_all.sh` to ensure no regressions are introduced.

Thank you for contributing to Tessera!
