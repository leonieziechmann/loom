# Loom

**Reactive Documents for Typst**

Loom is a meta-engine for [Typst](https://typst.app) that introduces **bidirectional data flow**, **global state management**, and **complex data aggregation** to your documents.

It transforms Typst's linear execution model into a multi-pass "weave" loop, enabling parent components to react to data from their children and allowing deep context propagation without parameter drilling.

## Why Loom?

Typst is excellent for layout, but complex logic often hits a wall:

- **One-Way Flow:** A parent usually cannot know the "total cost" of its children before rendering itself.
- **Immutable State:** You cannot easily mutate a global counter or configuration object from deeply nested content.

Loom solves this by treating your document as a component tree that is evaluated until data converges.

## Features

- **Global Context (Scope):** Inject variables that are inherited by all descendants.
- **Signals (Bottom-Up Data):** Components can emit data that bubbles up to their parents for aggregation.
- **Fixed-Point Iteration:** The engine automatically runs multiple passes to resolve dependencies (e.g., _Ingredient -> Recipe -> Shopping List_).
- **Managed Identity:** Components can track their unique path and ID within the document hierarchy.

## Installation

Import Loom directly from the package preview (once published):

```typ
#import "@preview/loom:0.1.0": construct-loom

```

## Quick Start

Loom uses a specific setup pattern to keep your code clean and prevent namespace collisions.

### 1. Create a Library File (`lib.typ`)

Initialize Loom once and export the tools you need.

```typ
// lib.typ
#import "@preview/loom:0.1.0": construct-loom

// Initialize with a unique project key
#let loom = construct-loom(<my-project>)

// Export the engine and constructors
#let weave = loom.weave
#let motif = loom.motif.plain
#let managed-motif = loom.motif.managed
```

### 2. Build your Document (`main.typ`)

Import your library and start weaving.

```typ
// main.typ
#import "loom-wrapper.typ": *

// Define a simple component
#let counter-box(value) = motif(
  // The 'draw' phase renders the output
  draw: (ctx, public, view, body) => {
    block(stroke: 1pt + blue, inset: 1em, radius: 4pt)[
      *Count:* #value
    ]
  },
  none
)

// Start the engine
#show: weave.with()

#stack(dir: ltr, spacing: 1em)[
  #counter-box(10)
  #counter-box(20)
]
```

## Documentation

Full documentation is available in the [`docs/`](https://github.com/leonieziechmann/loom/tree/main/docs) folder.

- **[Getting Started](https://github.com/leonieziechmann/loom/blob/main/docs-md/01-getting-started.md)** - Installation and setup.
- **[Core Concepts](https://github.com/leonieziechmann/loom/blob/main/docs-md/02-core-concepts.md)** - Understanding the Weave Loop, Signals, and Scope.
- **[Motif Types](https://github.com/leonieziechmann/loom/blob/main/docs-md/03-motifs.md)** - When to use `managed`, `content`, or `data` motifs.
- **[Query Module](https://github.com/leonieziechmann/loom/blob/main/docs-md/04-queries.md)** - filtering and aggregating signals.
- **[Guards & Validation](https://github.com/leonieziechmann/loom/blob/main/docs-md/05-guards.md)** - Enforcing hierarchy rules.
- **[State Management](https://github.com/leonieziechmann/loom/blob/main/docs-md/06-state-management.md)** - Working with immutable dictionaries.
- **[API Reference](https://github.com/leonieziechmann/loom/blob/main/docs-md/07-api-reference.md)** - Function signatures.

## ⚠️ Architectural Constraints & Limitations

Loom is a powerful meta-engine, but it operates within the boundaries of the Typst runtime. To ensure stability and predictable behavior, be aware of the following constraints:

### 1. Vertical-Only Communication (Sibling Latency)

Data in Loom flows vertically: **Child → Parent → Context**.

- **Constraint:** Sibling components (neighbors) cannot exchange data within the _same_ render pass.
- **Workaround:** To react to a sibling's state (e.g., "match my width to the element on the left"), the data must travel up to a common ancestor and be injected back down in a **subsequent pass**. This requires increasing `max-passes` (e.g., to 3).

### 2. Maximum Nesting Depth (~50 Levels)

- **Constraint:** The core `intertwine` traversal is recursive. Due to Typst's internal stack limits, nesting Loom components deeper than approximately 50 levels may trigger a runtime panic.
- **Best Practice:** Loom is designed for document structure (Sections > Components > Atoms), not for fractal generation or extremely deep recursion.

### 3. Opaque Named Fields

- **Constraint:** Loom only "intertwines" (processes) the primary flow content (usually `body` or `children`). Components placed inside named arguments—such as `figure(caption: ...)` or `table(header: ...)`—are treated as **atomic**.
- **Result:** A Loom component inside a `caption` will render visually, but it cannot participate in the measure loop, receive context, or emit signals.

### 4. Show Rule Invisibility

- **Constraint:** Loom operates on the Abstract Syntax Tree (AST) _before_ Typst executes standard `#show` rules.
- **Result:** If you use a show rule to transform raw content into a Loom component (e.g., `show "text": name => loom-component(name)`), the engine will not "see" that component during the measure phase. Loom components must be explicitly present in the source code.

### 5. Performance Overhead

- **Constraint:** Since Typst dictionaries are immutable, every context mutation (Scope injection) creates a copy of the state object.
- **Impact:** Compilation time scales linearly with component count and effectively multiplies by the number of passes. Loom is built for document management, not for high-frequency node generation (e.g., rendering thousands of particles).

## License

This project is licensed under the MIT License.
