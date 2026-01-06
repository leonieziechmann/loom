# Motif Types

Loom provides a set of primitives to build your components. While they all share the same lifecycle (Scope → Measure → Draw), they differ in how they handle data and pathing.

Choosing the right primitive reduces boilerplate code and ensures your components interact correctly with the Loom engine.

## Comparison Table

| Primitive | Use Case              | Key Feature                                                     |
| :-------- | :-------------------- | :-------------------------------------------------------------- |
| `managed` | **Logic Components**  | Automatically tracks the component's path and ID.               |
| `content` | **UI / Wrapper**      | Focuses on rendering; transparently forwards children signals.  |
| `data`    | **Data Points**       | No visual output. Used to emit raw signals (e.g., ingredients). |
| `plain`   | **Low-Level Control** | Full manual control over the entire lifecycle.                  |

---

## 1. Managed Motif (`loom.motif.managed`)

This is the standard building block for logical document structure (e.g., _Sections_, _Tasks_, _Recipes_).

**Why use it?**
When you build a system where components need to be addressable or unique (e.g., "Task A depends on Task B"), you need to track where a component sits in the hierarchy. A `managed-motif` does this automatically.

**Behavior:**

- **Path Tracking:** It pushes its `name` (and a relative ID) to the system path before processing children.
- **Frame Wrapping:** It automatically wraps the data returned by `measure` into a standard Loom `frame` object containing the `kind`, `key`, and `path`.

```typ
#let task(name) = managed-motif(
  "task", // The kind name
  measure: (ctx, children) => {
    // Return your logic payload.
    // Loom automatically wraps this in a Frame with kind="task".
    ((status: "pending"), (name: name))
  },
  draw: (ctx, public, view, body) => [Task: #view.name]
)

```

## 2. Content Motif (`loom.motif.content`)

Use this for visual wrappers that participate in the Loom flow but don't inherently change the data logic (e.g., _Card_, _Grid_, _StyledBlock_).

**Why use it?**
Standard Typst layout functions (like `block` or `align`) are "atomic" to Loom—they stop the flow of context. A `content-motif` allows the context to flow through it to its children, and ensures signals from children bubble up to the parent.

**Behavior:**

- **Signal Forwarding:** If you don't provide a `measure` function, it automatically collects all signals from children and passes them up.
- **Focus:** Designed primarily for the `draw` phase.

```typ
#let card(body) = content-motif(
  draw: (ctx, body) => {
    block(stroke: 1pt, inset: 1em, body)
  },
  body
)

```

## 3. Data Motif (`loom.motif.data`)

Use this for leaf nodes that represent pure data and should not render anything themselves (e.g., _Metadata_, _Ingredients_, _Config_).

**Why use it?**
Sometimes you need to inject data into the aggregation flow without affecting the visual layout.

**Behavior:**

- **Invisible:** The `body` is forced to `none`.
- **Calculation Only:** It only runs the `measure` phase.

```typ
#let ingredient(name, amount) = data-motif(
  "ingredient",
  measure: (ctx) => {
    // Returns data to the parent
    (name: name, amount: amount)
  }
)

```

## 4. Plain Motif (`loom.motif.plain`)

This is the raw primitive. Use it only when you need absolute control and the other types are too opinionated.

**Why use it?**
If you want to implement a custom pathing logic, or if you need to manipulate the raw `frame` structure manually.

**Behavior:**

- **Manual:** Does _not_ update the path. Does _not_ wrap your data in a frame. You must return exactly what the engine expects.

```typ
#let raw-component = motif(
  scope: (ctx) => ctx,
  measure: (ctx, children) => (none, none),
  draw: (ctx, public, view, body) => body,
  [Content]
)

```

## 5. Compute Motif (`loom.motif.compute`)

A utility wrapper for components that calculate data but don't need a View Model.

**Behavior:**

- Simplifies the `measure` signature to return _only_ the public payload. The `view` is set to `none`.
- Can be combined with `name` to act like a managed motif, or without to act like a plain motif.

```typ
#let calculator = compute-motif(
  measure: (ctx, children) => {
    // Return only the signal
    (sum: 42)
  },
  [I only calculate.]
)

```
