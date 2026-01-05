# Getting Started

Loom is a meta-engine designed to handle complex data flows in Typst documents. To keep your project maintainable, Loom encourages a specific setup pattern that separates the engine configuration from your content.

## Installation

*(Instructions to be added once the package is published)*

```typ
#import "@preview/loom:0.1.0": construct-loom

```

## The Setup Pattern (Best Practice)

Unlike standard libraries, Loom requires you to create an **Instance** bound to a specific namespace key. This prevents collisions if multiple Loom instances run in the same document.

Instead of calling `loom.motif.plain` repeatedly in your code, the recommended practice is to create a central `library.typ` (or `context.typ`) file. In this file, you initialize Loom and **destructure** the engine methods into clean, reusable variables.

### 1. Create your Library File

Create a file named `loom-wrapper.typ` (or similar) in your project root:

```typ
// loom-wrapper.typ
#import "@preview/loom:0.1.0": *

// 1. Initialize Loom with a unique project key
#let loom = construct-loom(<my-project>)

// 2. Destructure and Export Core Functions
// This allows you to use 'weave' directly instead of 'loom.weave'
#let weave = loom.weave

// 3. Destructure and Export Motif Constructors
// This makes your component definitions much cleaner
#let motif = loom.motif.plain
#let managed-motif = loom.motif.managed
#let data-motif = loom.motif.data
#let content-motif = loom.motif.content
#let compute-motif = loom.motif.compute
```

### 2. Import and Use

Now, in your main document (e.g., `main.typ`), you simply import these variables. Your code remains clean and readable.

```typ
// main.typ
#import "loom-wrapper.typ": *

// Clean definition without "loom.motif.plain"
#let my-component = motif(
  measure: (ctx, _) => (value: 10),
  draw: (ctx, public, view, body) => [Value is #view]
)

#show: weave.with()

#my-component
```

## Why this pattern?

1. **Readability:** `motif(...)` is easier to read than `loom.motif.plain(...)`.
2. **Refactoring:** If you ever need to switch the Loom instance or configuration, you only change it in one place (`lib.typ`).
3. **Namespace Safety:** By constructing Loom with a unique key (e.g., `<my-project>`), you ensure that your components don't accidentally receive signals from other libraries that might also be using Loom internally.

## Your First Loom Document

Here is a complete "Hello World" example using the setup pattern.

**File:** `loom-wrapper.typ`

```typ
#import "@preview/loom:0.1.0": construct-loom
#let loom = construct-loom(<hello-world>)

#let weave = loom.weave
#let motif = loom.motif.plain
...
```

**File:** `main.typ`

```typ
#import "loom-wrapper.typ": *

#let greeter(name) = motif(
  // The 'draw' phase renders the visual output
  draw: (ctx, public, view, body) => {
    block(stroke: 1pt + blue, inset: 1em, radius: 4pt)[
      *Hello, #name!*
      #body
    ]
  },
  none // No body content by default
)

#show: weave.with()

#stack(dir: ltr, spacing: 1em)[
  #greeter("World")
  #greeter("Loom")
]
```
