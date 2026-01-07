---
sidebar_position: 5
---

# API Reference

**The Loom Standard Library**

Welcome to the technical reference for the Loom engine. This section details the modules, functions, and types available in the package.

:::info
If you are looking for conceptual guides or tutorials, please check the [Concepts](./concepts/mental-model) or [Showcase](./showcase/recipe-book) sections.
:::

## Modules Overview

Loom is organized into several modules to keep the namespace clean.

| Module                                 | Description                                                         |
| :------------------------------------- | :------------------------------------------------------------------ |
| **[Engine](./api-reference/core)**     | The `weave` loop, `construct-loom`, and lifecycle hooks.            |
| **[Motifs](./api-reference/motifs)**   | The component constructors: `motif`, `content-motif`, `data-motif`. |
| **[Query](./api-reference)**           | Utilities for searching, filtering, and aggregating signals.        |
| **[Mutator](./api-reference/mutator)** | Utilities for performing immutable updates on the Context.          |
| **[Guards](./api-reference/guards)**   | Assertion functions to enforce document architecture.               |

## The `loom` Namespace

While you typically use `construct-loom` to create your own library instance, the static utilities are always available directly from the package.

```typ
#import "@preview/loom:0.1.0"

// 1. Core Constructors
#let (weave, motif, ..) = loom.construct-loom(<my-lib>)

// 2. Static Utilities (Used inside measure/scope)
#loom.query.select(..)
#loom.mutator.batch(..)
#loom.guards.assert-inside(..)

```

:::tip Pro Tip: Destructuring
You can destructure the engine components directly during construction to keep your code clean:
`#let (weave, motif) = loom.construct-loom(<id>)`
:::

## Common Types

Throughout this reference, we use the following type definitions:

- **`Context`**: `dictionary`
  The immutable state object passed down from parent to child.
- **`Signal`**: `dictionary`
  A data packet emitted by a component during the `measure` phase. It bubbles up to the parent.
- **`Motif`**: `function`
  A Loom component. Technically, it is a standard Typst function that returns a `(key, payload)` tuple.
- **`Body`**: `content` | `array`
  The content passed to a component.
