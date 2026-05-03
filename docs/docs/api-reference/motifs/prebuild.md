---
sidebar-position: 2
---

# Pre-built Motifs

The Loom engine provides a set of out-of-the-box, pre-built motifs. These primitives handle common structural, debugging, and state-management tasks, allowing you to bypass writing custom `measure` or `draw` functions for standard operations.

---

## `static`

The `static` motif provides a way to render Typst content directly to the page while completely hiding it from the Loom engine's weave loop. It acts as an opaque wall—any motifs placed inside a static block will not emit signals, trigger measurements, or be evaluated during the engine's traversal phases.

### API Reference

```typst
#static(key: <motif>, body)
```

- **`key`** (`label`): An optional unique identifier for the block. Defaults to `<motif>`.
- **`body`** (`content`): The visual content to be rendered. This is passed directly to the Typst output and ignored by the engine's internal `draw` logic.

### Behavior & Guarantees

1. **Traversal Opacity:** The engine's measure and draw phases will completely skip the `body` of a `static` block.
2. **Signal Isolation:** Any motifs nested inside a `static` block are rendered as plain Typst content; their `measure` functions will _never_ execute, and they will not emit signals to their parents.
3. **Immutability:** The `draw` phase of a `static` block will always return its original `body`, ignoring any state, context, or iteration data passed by the weave loop.

### Example

```typst
#motif(measure: my-measure)[
  #static[
    = Chapter 1
    This text and layout are rendered normally, but the Loom
    engine skips evaluating this entirely during the weave loop.
  ]

  // The engine only "sees" and processes this motif.
  #data-motif(measure: (..) => (signal: "active"))
]
```

---

## `apply`

The `apply` motif is a pure state-modifier. It is used to cleanly inject or modify the engine's context (`ctx`) for a specific branch of the document tree without generating any visual wrapper or intercepting signals.

### API Reference

```typst
#apply(key: <apply>, scope: (ctx) => dictionary, body)
```

- **`key`** (`label`): An optional unique identifier. Defaults to `<apply>`.
- **`scope`** (`function`): A function that takes the current context dictionary and returns a modified context dictionary.
- **`body`** (`content`): The child motifs that will receive the updated context.

### Behavior & Guarantees

1. **Context Injection:** The modified context is passed down to all nested children during the `scope` phase.
2. **Transparent Measurement:** `apply` does not aggregate or modify signals. It passes its children's signals directly up to its parent.
3. **Transparent Drawing:** `apply` does not wrap its children in any visual containers.

### Example

```typst
// Injecting a theme variable into the context for nested motifs
#apply(scope: ctx => ctx + (theme: "dark"))[
  #motif(
    draw: (ctx, ..) => [
      The current theme is: #ctx.theme // Evaluates to "dark"
    ]
  )
]
```

---

## `debug`

The `debug` motif is a diagnostic tool. When wrapped around a block of motifs, it visually intercepts and prints the engine's state (context, public data, and child signals) directly to the rendered page.

### API Reference

```typst
#debug(key: <debug>, inline: false, body)
```

- **`key`** (`label`): An optional unique identifier. Defaults to `<debug>`.
- **`inline`** (`boolean`): If `true`, the debug output is rendered inline. If `false` (default), it renders as a visual bounding box around the children.
- **`body`** (`content`): The motifs you wish to inspect.

### Behavior & Guarantees

1. **State Visualization:** Intercepts the `measure` and `draw` phases to print a formatted table of the incoming `ctx` and aggregated `children` data.
2. **Passthrough Logic:** Despite visualizing the data, `debug` does not alter it. Signals and context flow through it exactly as they would if the `debug` motif were not there.

### Example

```typst
// Wrap a problematic motif in #debug to see what data it is receiving
#debug[
  #motif(
    measure: (ctx, children) => (none, [My Motif View])
  )
]
```
