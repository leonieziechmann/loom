---
sidebar_position: 7
---

# Contributing to Loom

**Help us weave the future of Typst.**

First of all, thank you! Loom is an ambitious project trying to push the boundaries of what is possible in Typst. Whether you are fixing a typo, reporting a bug, or proposing a new architecture feature, your help is welcome.

## Reporting Bugs

Loom is complex. If you encounter a crash or an infinite loop, providing a **Minimal Reproduction** is critical.

1.  **Isolate the issue:** Try to reproduce the bug with just `loom` and standard Typst elements (no external packages if possible).
2.  **Check the logs:** Run your reproduction with `debug: true` and include the output.
3.  **Version:** State clearly which version of Loom and Typst you are using.

**Good Issue Title:** _"Infinite loop when nesting `data-motif` inside `table` header"_
**Bad Issue Title:** _"My document doesn't compile"_

## Development Setup

Loom is a pure Typst package. You don't need Rust or Node.js to develop it, just the Typst CLI.

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/leonieziechmann/loom.git
    cd loom
    ```

2.  **Run the Tests:**
    We maintain a suite of tests in the `tests/` directory covering everything from basic signals to heavy load performance.
    ```bash
    # Compile a specific test
    typst compile tests/01-ast-reconstruction.typ
    ```

## Core Philosophy

When contributing code, keep these three principles in mind:

1.  **Defensive Programming:**
    Loom runs in a hostile environment (a user's document). Assume the user will pass `none`, invalid keys, or try to nest things incorrectly.
    - _Always_ check bounds.
    - _Always_ provide helpful error messages using `assert` or `panic`.

2.  **Performance First:**
    Every function you write in the "hot path" (the `intertwine` loop) will be executed thousands of times per compile.
    - Avoid deep copies of the Context dictionary where possible.
    - Avoid unnecessary `.map()` calls on large arrays.

3.  **Backward Compatibility:**
    Loom is a foundational library. Breaking the API (e.g., changing how `measure` works) breaks everyone's templates. Discuss major changes in an Issue first.

## Pull Request Process

1.  **Fork** the repo and create your branch from `main`.
2.  **Add Tests** for your new feature or bug fix.
3.  **Format** your code. Keep it clean and readable.
4.  **Submit** the PR! We will review it as soon as possible.

## Documentation

Documentation is just as important as code. If you add a feature, please add a corresponding guide in `docs/`.
We use Docusaurus for this site. You can run it locally with:

```bash
cd docs
npm install
npm start
```

Thank you for building with us!
