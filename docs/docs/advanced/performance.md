---
sidebar_position: 1
---

# Performance & Optimization

**Understanding the Cost of Reactivity**

Loom brings powerful capabilities to Typst, but "Time Travel" comes at a cost. Because Loom runs your document logic multiple times to resolve dependencies, it will always be slower than a standard, linear Typst document.

This guide explains where that time goes and how to keep your documents fast.

## Real-World Benchmarks

To give you a realistic idea of Loom's overhead, here are compilation times from our test suite (running on standard hardware):

| Scenario              | Complexity                                     | Time        | Verdict            |
| :-------------------- | :--------------------------------------------- | :---------- | :----------------- |
| **External Wrappers** | Shallow nesting, wrapping `cetz` or `codly`.   | **~2.3ms**  | ⚡ **Negligible**  |
| **Standard Logic**    | Unit tests for signals, scope, and motifs.     | **~14.5ms** | ⚡ **Negligible**  |
| **Recipe Showcase**   | Real-world document, ~20 data nodes, 2 passes. | **~16ms**   | 🚀 **Fast**        |
| **Stress Test (AST)** | Deep recursion (50 levels), complex layouts.   | **~94ms**   | 🟢 **Perceptible** |
| **"The Legion"**      | **2,000+** nodes, 500+ context mutations.      | **~7.8s**   | 🔴 **Heavy**       |

**Takeaway:** For normal documents (Reports, Invoices, Dashboards), Loom adds milliseconds, not seconds. Performance only degrades when you treat Typst like a database engine (processing thousands of items).

---

## The Cost Model

The compilation time of a Loom document can be roughly estimated as:

**Time ≈ (Node Count + Context Complexity) × (Passes)**

### 1. The Multi-Pass Multiplier

Loom runs the `measure` phase in a loop.

- **Default:** 2 Passes (1 Measure + 1 Draw). Cost: ~2x standard Typst.
- **Complex:** If you set `max-passes: 5`, your document compiles ~5x slower.

**Tip:** Keep `max-passes` as low as possible. Most documents only need 2 or 3 passes. Only increase it if you have deep dependency chains (e.g., A needs B, which needs C, which needs D).

### 2. Context Mutation Overhead

Typst dictionaries are **immutable**. Every time you use `scope` to inject a variable (e.g., `ctx + (theme: "dark")`), the engine must create a _copy_ of the context dictionary.

- **Cheap:** Reading values (`ctx.at("key")`).
- **Expensive:** Writing values deeply nested in the tree for every single child.

**Benchmark:** In our "Legion" stress test, processing 500 sequential context mutations was the primary driver of the 7.8s runtime.

### 3. Recursion Limits (The Stack)

Loom's `intertwine` engine is recursive. Typst has a fixed stack size.

- **Limit:** Approximately **50-60 levels** of nesting.
- **Result:** If you nest components too deeply (e.g., `div > div > ... > div`), the compiler will panic with a "stack overflow".

**Best Practice:** Flatten your structure where possible. Loom is designed for document architecture (Sections, Components), not for rendering fractals or pixel-level grids.

## Optimization Strategies

### 1. Use `data-motif` for Logic

If a component exists only to calculate data (like an `ingredient` or a `metadata` tag), always use `data-motif`.

- It has no `draw` phase (returns `none` immediately), saving layout time in the final pass.
- It avoids processing a `body` content block.

### 2. Filter Early

In your `measure` function, use `query.select` or `query.find` to narrow down the children you process. Avoid mapping over _all_ `children` if you only need the "tasks".

```typ
// ✅ Fast: Only look at relevant signals
let tasks = query.select(children, "task")

// ⚠️ Slower: Iterating everything unnecessarily
let everything = children.map(c => process-heavy-logic(c))

```

### 3. Memoize Heavy Calculations

If you have a heavy function (e.g., generating a complex chart), try to ensure it only runs in the **Final Draw Pass**, not during the Measure passes.

The `measure` phase should only calculate _metadata_ (sizes, prices, counts). Leave the heavy pixel-pushing for `draw`.

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

- **Bad:** A signal that toggles between `true` and `false` every pass. This forces Loom to run until `max-passes` is hit.
- **Good:** A signal that settles on a value in Pass 2 and stays there.
