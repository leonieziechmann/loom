# Core Concepts

Loom transforms Typst from a linear typesetting system into a multi-pass reactive engine. To use Loom effectively, you need to understand its execution model, which differs significantly from standard Typst code.

## The Mental Model

In standard Typst, code is executed once, from top to bottom. If a component at the bottom of the page generates data (e.g., a total price), it cannot easily be displayed at the top of the page because that part has already been rendered.

Loom solves this by running your document logic multiple times. We call this the **Weave Loop**.

1.  **Pass 1 (Measure):** The engine runs through the document to collect data (Signals). Nothing is drawn.
2.  **Pass 2+ (Measure):** The collected data is injected into the context. The engine runs again to see if the data changes (Convergence).
3.  **Final Pass (Draw):** Once the data is stable, the engine runs a final time to generate the visual output.

## Phases

Every Loom component ("Motif") operates in two distinct phases.

### 1. Measure Phase
* **Goal:** Calculate data and propagate signals.
* **Input:** The current Context (`ctx`) and the signals from children (`children-data`).
* **Output:** A tuple `(public, view)`.
    * `public`: Data sent **up** to the parent (Signal).
    * `view`: Data kept **local** for the drawing phase.
* **Visuals:** No visual content is produced.

### 2. Draw Phase
* **Goal:** Render the final component.
* **Input:** Context, `public` data, `view` data, and the children's rendered content (`body`).
* **Output:** The final Typst `content` (e.g., `block`, `text`).
* **Behavior:** This phase only runs once, at the very end.

## Data Flow Directions

Loom strictly separates data flowing down the tree from data flowing up.

### Top-Down: The Scope (Context)
Data flowing from a parent to its children is called **Scope**. This works like inherited variables.

* **Mechanism:** A parent modifies the immutable `ctx` dictionary before its children are processed.
* **Usage:** Configuration, themes, global flags.
* **Example:** A `recipe` component sets a `scale-factor` in the scope. All nested `ingredient` components automatically see this factor.

```typ
// Parent sets the scope
scope: (ctx) => ctx + (theme: "dark")

// Child reads the scope
measure: (ctx, _) => {
  let theme = ctx.at("theme", default: "light")
  // ...
}

```

### Bottom-Up: Signals (Frames)

Data flowing from children to parents is called **Signals**. This is the unique feature of Loom.

* **Mechanism:** When a child finishes its `measure` phase, it returns a data packet (Frame). The engine collects these packets and passes them to the parent's `measure` function as an array.
* **Usage:** Aggregation, summaries, registration.
* **Example:** `ingredient` components return their cost. The `recipe` parent sums them up to calculate the total price.

```typ
// Child (Ingredient)
measure: (ctx, _) => ( (cost: 5.0), none )

// Parent (Recipe)
measure: (ctx, children-data) => {
  // children-data is an array of frames from the ingredients
  let total = children-data.map(c => c.signal.cost).sum()
  ( (total: total), (price: total) )
}

```

## Convergence (Fixed-Point Iteration)

Loom is a "fixed-point" engine. This means it doesn't just run twice; it runs **until the data stops changing**.

1. **Iteration 1:** Loom collects initial signals.
2. **Iteration 2:** Loom injects those signals into the context. Components might react to this (e.g., a "Buff" changes a "Stat"). This might produce *new* signals.
3. **Iteration 3:** If the signals changed, Loom runs again.

This loop continues until the output of a pass is identical to the input of the previous pass (Convergence) or the `max-passes` limit is reached.

