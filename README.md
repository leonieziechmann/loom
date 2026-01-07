# Loom

**Reactive Documents for Typst**

Loom transforms Typst from a linear typesetting system into a **reactive engine**. It enables bidirectional data flow, allowing your document to "think" before it renders.

## Why Loom?

Typst is built for speed and linear execution, which makes certain logic patterns difficult. Loom solves two specific architectural headaches:

1.  **The "Shopping List" Problem (Aggregation):**
    - _The Pain:_ A parent component (like a `Recipe`) cannot naturally calculate a total (Price, Calories) from its children (`Ingredients`) because the children typically render _after_ the parent has started.
    - _The Fix:_ Loom lets children emit **Signals** that bubble up. The parent receives this data _before_ it draws the final output.

2.  **The "Global State" Problem (Dependencies):**
    - _The Pain:_ Modifying a global counter or configuration from deep inside a nested structure is hard due to Typst's immutable state and linear flow.
    - _The Fix:_ Loom runs a **Weave Loop** (multiple passes). A component at the bottom of page 10 can emit a signal that updates a summary on page 1.

---

## ⚡ Performance: The "Budget" Rule

Loom brings "Time Travel" to Typst, but this comes at a cost. To keep your documents fast, follow the **10% Rule**:

> **Loom is for Structure, not Content.**

- **🟢 Traversal is Cheap:** Loom can traverse **30,000+ standard nodes** (paragraphs, shapes, text) in ~1.7s. You can write long theses without penalty.
- **🔴 Logic is Expensive:** "Active" Loom components (Context mutations, Signals) are heavy. In stress tests, 2,000 active components slowed compilation to ~8s.

**Verdict:** Use Loom to manage your document's skeleton (Sections, Headers, Totals), but do not use it for the flesh (individual table cells, list bullets, or thousands of data points).

## Installation

Import Loom from the package preview:

```typ
#import "@preview/loom:0.1.0": construct-loom
```

## 🚀 Quick Start (Best Practice)

To prevent namespace collisions and keep your code clean, we recommend the **Wrapper Pattern**.

### 1. Create a Library File (`lib.typ`)

Initialize Loom once with a unique project key and export the specific tools you need.

```typ
// lib.typ
#import "@preview/loom:0.1.0": construct-loom

// 1. Initialize with a unique ID
#let loom = construct-loom(<my-project>)

// 2. Export the tools
#let weave = loom.weave
#let motif = loom.motif.plain
#let managed-motif = loom.motif.managed
#let data-motif = loom.motif.data
```

### 2. Build your Document (`main.typ`)

```typ
// main.typ
#import "lib.typ": *

// A component that reports data to its parent (No visual output)
#let ingredient(price) = data-motif(
  "ingredient",
  measure: (ctx) => (price: price)
)

// A parent that sums up the data from its children
#let recipe(name, body) = motif(
  measure: (ctx, children-data) => {
    let total = children-data.map(c => c.signal.price).sum()
    ( (price: total), (price: total) )
  },
  draw: (ctx, public, view, body) => {
    block(stroke: 1pt + black, inset: 1em)[
      *#name* (Total: $#view.price)
      #body
    ]
  },
  body
)

#show: weave.with()

#recipe("Tomato Soup")[
  #ingredient(2.50)
  #ingredient(0.50)
  #ingredient(1.00)
  Ingredients listed here...
]
```

## 🧠 Core Concepts

| Concept     | Direction | Description                                                                                     |
| ----------- | --------- | ----------------------------------------------------------------------------------------------- |
| **Scope**   | ⬇️ Down   | **Context.** Parents inject variables (themes, flags) that are inherited by all descendants.    |
| **Signals** | ⬆️ Up     | **Aggregation.** Children emit data "frames" that bubble up to their parents for summarization. |
| **Weave**   | 🔄 Loop   | **Convergence.** The engine runs multiple passes (Measure → Draw) until data stabilizes.        |

## ⚠️ Capabilities & Limits

Loom operates within the boundaries of the Typst runtime.

1. **Vertical-Only Flow:** Data flows `Child -> Parent -> Context`. Sibling components cannot "see" each other in the same pass; data must go up to a common ancestor and back down in the next pass.
2. **Stack Depth:** Recursion is limited to approximately **50 levels**. Avoid deeply nested `div > div > div` structures; flatten your hierarchy where possible.
3. **Opaque Fields:** Loom cannot "see" inside named arguments like `figure(caption: [here])`. Components placed inside captions or headers will render visually but cannot participate in the logic loop.
4. **Show Rules:** Standard `#show` rules run _after_ Loom's logic. You cannot use a show rule to transform text into a Loom component.

## License

MIT License
