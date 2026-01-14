---
sidebar_position: 1
---

# Performance & Optimization

**Understanding the Cost of Reactivity**

Loom brings powerful capabilities to Typst, but "Time Travel" comes at a cost. Because Loom runs your document logic multiple times to resolve dependencies, it will always be slower than a standard, linear Typst document.

This guide explains where that time goes and how to keep your documents fast.

## Real-World Benchmarks

To give you a realistic idea of Loom's overhead, here are compilation times from our test suite.

:::info The Verdict
Loom is **efficient at doing nothing** (skipping standard content) but **expensive when engaged** (processing logic).
:::

| Scenario               | Complexity                                    | Loom Overhead | Verdict           |
| :--------------------- | :-------------------------------------------- | :------------ | :---------------- |
| **Baseline Traversal** | 3,000 standard nodes, no motifs.              | **~200ms**    | 🚀 **Fast**       |
| **External Wrappers**  | Shallow nesting, wrapping `cetz` or `codly`.  | **~2.3ms**    | ⚡ **Negligible** |
| **Recipe Showcase**    | Real-world document, ~20 data nodes.          | **~16ms**     | 🚀 **Fast**       |
| **The Legion**         | 2,000+ active motifs, 500+ context mutations. | **~1.2s**     | 🟡 **Moderate**   |

## ⚠️ Performance Reality: Traversal vs. Execution

Loom's performance profile is split into two distinct categories: **Traversal Overhead** (skipping standard content) and **Reactive Cost** (processing Motifs).

### 1. Traversal is Cheap (The "Skip" Speed)

Benchmarks show that Loom can traverse **30,000+ standard nodes** (like `text`, `block`, `place`) in roughly **1.7s**.

:::tip Implication
You do not need to worry about the length of your text chapters. Loom efficiently ignores content that isn't part of its system. A 50-page thesis full of standard paragraphs will not incur a significant penalty.
:::

### 2. Reactivity is Expensive (The "Logic" Tax)

However, once you introduce a `motif`, the engine must allocate a Frame, track its path, and manage its signals. While you can have 10,000 standard nodes, you **cannot** have 10,000 Motifs. In stress tests, 2,000 active Motifs with context mutations slowed compilation to **~1.2 seconds**.

## The "Budget" Rule

Think of Loom like a game engine. You have a "polygon budget" (Motifs) and a "texture budget" (Context).

| Component Type     | Cost        | Recommended Budget                                          |
| :----------------- | :---------- | :---------------------------------------------------------- |
| **Standard Typst** | 🟢 Very Low | **Unlimited** (within Typst's own limits)                   |
| **Data Motifs**    | 🟡 Moderate | Use for structure (Sections, Ingredients), not data points. |
| **Active Motifs**  | 🔴 High     | **< 500 per document.** Use sparingly for high-level logic. |

:::warning Design Principle
Loom is designed to manage the **skeleton** of your document (Sections, Headers, Totals). Do not use it to manage the **flesh** (individual table cells, list bullets, or character primitives).
:::

---

## The Cost Model

The compilation time of a Loom document can be roughly estimated as:

> **Time ≈ (Node Count + Context Complexity) × (Passes)**

### 1. The Multi-Pass Multiplier

Loom runs the `measure` phase in a loop.

- **Default:** 2 Passes (1 Measure + 1 Draw).
- **Complex:** If you set `max-passes: 5`, loom takes ~2.5x longer.

:::tip Optimization Tip
Keep `max-passes` as low as possible. Most documents only need 2 or 3 passes. Only increase it if you have deep dependency chains (e.g., A needs B, which needs C, which needs D).
:::

### 2. Context Mutation Overhead

Typst dictionaries are **immutable**. Every time you use `scope` to inject a variable (e.g., `ctx + (theme: "dark")`), the engine must create a _copy_ of the context dictionary.

- **Cheap:** Reading values (`ctx.at("key")`).
- **Expensive:** Writing values deeply nested in the tree for every single child.

### 3. Recursion Limits (The Stack)

Loom's `intertwine` engine is recursive, and Typst has a fixed stack size. The limit is approximately **50-60 levels** of nesting.

:::danger Stack Overflow
If you nest components too deeply (e.g., `block > block > ... > block`), the compiler will panic.

**Best Practice:** Flatten your structure where possible. Loom is designed for document architecture, not for rendering fractals or pixel-level grids.
:::

## Optimization Strategies

### 1. Use `data-motif` for Logic

If a component exists only to calculate data (like an `ingredient` or a `metadata` tag), always use `data-motif`.

- It has no `draw` phase (returns `none` immediately), saving layout time in the final pass.
- It avoids processing a `body` content block.

### 2. Filter Early

In your `measure` function, use `query.select` or `query.find` to narrow down the children you process. Avoid mapping over _all_ `children` if you only need the "tasks".

```typ
// ✅ Fast: Only look at relevant signals
#let tasks = query.select(children, "task")

// ⚠️ Slower: Iterating everything unnecessarily
#let everything = children.map(c => process-heavy-logic(c))
```

### 3. Memoize Heavy Calculations

If you have a heavy function (e.g., generating a complex chart), try to ensure it only runs in the **Final Draw Pass**, not during the Measure passes. The `measure` phase should only calculate _metadata_ (sizes, prices, counts).

```typ
// ✅ Good Separation
measure: (ctx, _) => ( (price: 10), (price: 10) ), // Fast signal
draw: (ctx, _, view, _) => {
  // Expensive chart generation happens ONCE here
  cetz.canvas(...)
}
```

### 4. Stabilize Quickly (Convergence)

Ensure your signals stabilize as fast as possible.

:::note Convergence

- **Bad:** A signal that toggles between `true` and `false` every pass. This forces Loom to run until `max-passes` is hit.
- **Good:** A signal that settles on a value in Pass 2 and stays there.
  :::
