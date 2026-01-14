---
sidebar_position: 7
---

# Contributing to Loom

**Help us weave the future of Typst.**

First of all, thank you! Loom is an ambitious project trying to push the boundaries of what is possible in Typst. However, to maintain the quality and stability of the core library with limited maintainer bandwidth, **we adhere to very strict contribution guidelines.**

Please read this document carefully. **Contributions that do not follow these rules will be closed without review.**

## Reporting Bugs

Loom is complex. To save everyone time, we require a high standard for bug reports.

1.  **Strictly Minimal Reproductions:** You must provide a minimal code snippet that reproduces the error. If we cannot copy-paste your code and see the error immediately, the issue will be closed.
2.  **No External Packages:** Issues must be reproduced using **only** `loom` and standard Typst elements. We will **not** investigate issues caused by interactions with other packages (e.g., `codly`, `showybox`) unless you can prove the bug exists in Loom's core logic in isolation.
3.  **Check the logs:** Run your reproduction with `debug: true` and include the output.
4.  **Version:** State clearly which version of Loom and Typst you are using.

**Good Issue Title:** _"Infinite loop when nesting `data-motif` inside `table` header"_
**Bad Issue Title:** _"My document doesn't compile"_

## Development Setup

We use **Nix** to manage our development environment and dependencies strictly. This ensures that every contributor uses the exact same version of Typst, the test runner, and the formatter.

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/leonieziechmann/loom.git
    cd loom
    ```

2.  **Enter the Environment:**
    You must use the Nix flake to get the required tools (`tytanic`, `typstyle`, `pre-commit`, etc.).
    - **Option A (Recommended):** If you have `nix direnv` installed:
      ```bash
      direnv allow
      ```
    - **Option B:** Using Nix directly:
      ```bash
      nix develop
      ```

3.  **Pre-commit Hooks:**
    We enforce strict code formatting using pre-commit hooks.
    The environment handles this automatically, but you can verify it by running:
    ```bash
    pre-commit run --all-files
    ```
    **PRs with styling errors will be rejected automatically.**

## Testing

We use **[Tytanic](https://github.com/typst-community/tytanic)** for testing.
New features **must** include tests. PRs without tests will be closed.

```bash
# Run the complete test suite
tt run
```

## Core Philosophy

When contributing code, adhere to these principles. Code that violates them will be rejected.

1. **Defensive Programming:**
   Loom runs in a hostile environment. Assume the user will pass `none`, invalid keys, or try to nest things incorrectly.

- _Always_ provide helpful error messages using `assert` or `panic`.

2. **Performance First:**
   Every function in the "hot path" is executed thousands of times.

- Avoid deep copies of Context.
- Avoid unnecessary loop allocations.

3. **Backward Compatibility:**
   Do not break the public API.

## Pull Request Process

1. **Fork** the repo and create your branch from `main`.
2. **Add Tests** covering your changes.
3. **Format** your code. The pre-commit hooks enforce **Typstyle** for `.typ` files and **Prettier** for Markdown.
4. **Submit** the PR.

**Note:** If your PR fails the CI checks (formatting or tests), do not expect a review until they are fixed.

## Documentation

Documentation is required for new features. The Nix environment provides the Node.js runtime needed for Docusaurus.

```bash
cd docs
npm install
npm start
```
