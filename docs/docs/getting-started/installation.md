---
sidebar_position: 1
---

# Installation

**Setting up the Engine**

Loom is distributed as a standard Typst package. However, because Loom is a meta-engine that manages its own memory and state, you shouldn't just import it directly into every file.

Instead, we use the **Wrapper Pattern** to create a dedicated instance for your project.

## 1. Import the Package

Loom is available on Typst Universe. You can import it using the standard package syntax.

```typ
#import "@preview/loom:0.1.0": construct-loom
```

_(Note: Check the [Typst Universe](https://typst.app/universe/package/loom) for the latest version number.)_

## 2. The Wrapper Pattern (Recommended)

To keep your code clean and prevent namespace collisions, you should initialize Loom **once** in a central library file and export the tools you need.

Create a file named `loom-wrapper.typ` (or `loomw.typ`) in your project root.

```typ title="loom-wrapper.typ"
#import "@preview/loom:0.1.0"
#import loom: guards, mutator

// 1. Construct a unique instance for your project.
// The key (<my-project>) isolates your components from other libraries.
#let (weave, motif, prebuild-motif) = loom.construct-loom(<my-project>)

// 2. Export the specific tools you want to use.
// This keeps your API clean for the rest of your document.

// The Engine
#let weave = weave

// The Component Constructors
#let motif = motif.plain
#let managed = motif.managed
#let content-motif = motif.content
#let data-motif = motif.data

// Utilities
#let scope = loom.context.scope
```

**Why do this?**

- **Isolation:** By passing `<my-project>`, you ensure that your components don't accidentally receive signals from a _different_ library that also uses Loom.
- **Convenience:** You can type `#motif(..)` instead of `#(loom.motif.plain)(..)`.
- **Control:** You decide exactly which modules (`query`, `mutator`) are exposed to your users.

## 3. Usage in Your Document

Now, in your main document (`main.typ`), you simply import your wrapper.

```typ title="main.typ"
#import "loom-wrapper.typ": *

// Now you can use the tools directly
#let my-component = content-motif(
  draw: (ctx, body) => block(stroke: 1pt, body)
)

// Start the engine
#show: weave.with(debug: false)

#my-component[
  Hello, Loom!
]
```

## Quick Start Template

If you want to copy-paste a complete setup, here is the minimal boilerplate:

```typ title="loom-wrapper.typ"
#import "@preview/loom:0.1.0"
#let (weave, motif, ..) = loom.construct-loom(<app>)

#let content-motif = motif.content
```

```typ title="main.typ"
#import "loom-wrapper.typ": *
#show: weave.with()

#content-motif(draw: (ctx, body) => [
  = Reactive Document
  #body
])[
  It works!
]
```
