---
sidebar_position: 2
---

# Motifs API

**The Component Constructors**

Motifs are the reactive building blocks of a Loom document. Instead of using standard Typst functions, you wrap your logic in these constructors to enable the "Measure -> Draw" cycle.

These constructors are available on the `motif` object returned by `construct-loom`.

```typ
#let (motif, ..) = loom.construct-loom(<app>)
```

---

## `motif.managed`

The "Smart" component constructor. Unlike a raw `motif`, this wrapper automatically handles **Identity** and **Path Management**.

- It pushes its `name` to the system path (`sys.path`) in the context.
- It automatically wraps your return signal in a `Frame` object containing `{ kind, key, path, signal }`.

Use this for any component that needs to be queryable (e.g., Figures, Sections, Tasks).

```typ
motif.managed(
  name,
  scope: (ctx) => ctx,
  measure: (ctx, children-data) => (signal, view),
  draw: (ctx, signal, view, body) => content,
  body
)
```

### Parameters

| Parameter     | Type            | Default                | Description                                                                                                                                                         |
| ------------- | --------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`name`**    | `str`           | _required_             | The name/kind of this component (e.g., "task"). Used for path generation and querying.                                                                              |
| **`scope`**   | `(ctx) => dict` | `id`                   | **Provider.** A function that returns a modified context for its _children_.                                                                                        |
| **`measure`** | `function`      | `(..) => (none, none)` | **Logic Phase.** `(ctx, children) => (signal, view)`. Calculates the raw data (`signal`) and view model (`view`). The signal is automatically wrapped in a `Frame`. |
| **`draw`**    | `function`      | `(..) => body`         | **Render Phase.** `(ctx, signal, view, body) => content`. Returns the final visual content.                                                                         |
| **`body`**    | `content`       | _required_             | The child content to process.                                                                                                                                       |

---

## `motif.content`

A simplified wrapper for **Visual-Only** components.
It is transparent to signals: it propagates its children's signals upward without modification, but it does not emit its own identity or manage paths.

Use this for styling wrappers (e.g., Cards, Callouts) that don't need to be queried.

```typ
motif.content(
  scope: (ctx) => ctx,
  draw: (ctx, body) => content,
  ..body
)
```

### Parameters

| Parameter   | Type            | Default               | Description                                                  |
| ----------- | --------------- | --------------------- | ------------------------------------------------------------ |
| **`scope`** | `(ctx) => dict` | `id`                  | Optional context modification for children.                  |
| **`draw`**  | `function`      | `(ctx, body) => body` | **Render Phase.** `(ctx, body) => content`.                  |
| **`body`**  | `content`       | _optional_            | The content to wrap. Can be passed as a positional argument. |

---

## `motif.data`

A specialized primitive for **Data Leaves**.
These components have **no body** (they render nothing) and exist solely to inject data into the system.

Use this for metadata, configuration, or ingredients.

```typ
motif.data(
  name,
  scope: (ctx) => ctx,
  measure: (ctx) => signal,
)
```

### Parameters

| Parameter     | Type            | Default         | Description                                                                                           |
| ------------- | --------------- | --------------- | ----------------------------------------------------------------------------------------------------- |
| **`name`**    | `str`           | _required_      | The name/kind of the data node.                                                                       |
| **`scope`**   | `(ctx) => dict` | `id`            | Optional context modification for children.                                                           |
| **`measure`** | `function`      | `(ctx) => none` | **Logic Phase.** `(ctx) => signal`. Returns the raw data payload. Note: It does not receive children. |

---

## `motif.compute`

A flexible helper for intermediate calculations. It simplifies the `measure` signature to return _only_ the public signal, automatically setting the view model to `none`.

It can behave like a `managed` motif (if `name` is provided) or a raw `motif` (if `name` is `none`).

```typ
motif.compute(
  name: none,
  scope: (ctx) => ctx,
  measure: (ctx, children-data) => signal,
  body
)

```

### Parameters

| Parameter     | Type            | Default        | Description                                                                                                            |
| ------------- | --------------- | -------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **`name`**    | `str` or `none` | `none`         | Optional name. If provided, it behaves like `motif.managed` (adding to path and wrapping in a Frame).                  |
| **`scope`**   | `(ctx) => dict` | `id`           | **Provider.** A function that returns a modified context for its _children_.                                           |
| **`measure`** | `function`      | `(..) => none` | **Logic Phase.** `(ctx, children) => signal`. Returns the raw data. Unlike `managed`, it does not return a view model. |
| **`body`**    | `content`       | _required_     | The child content to process.                                                                                          |

---

## `motif.plain`

The raw primitive. This is the low-level wrapper that creates the engine metadata block. It performs **no** automatic path management, frame wrapping, or signal propagation.

Use this only if you need to implement a completely custom protocol that doesn't fit the `managed` or `content` patterns.

```typ
motif.plain(
  key: <motif>,
  scope: (ctx) => ctx,
  measure: (ctx, children-data) => (signal, view),
  draw: (ctx, signal, view, body) => content,
  body
)
```

:::warning

Data Contract Unlike managed motifs, motif.plain does not automatically wrap your data. The signal returned by your measure function must strictly be:

1. `none`
2. A single Frame object (created via `loom.frame.new`)
3. An array of Frame objects

Returning raw data (like a string or dictionary) directly as a signal will cause a Data Contract Violation panic.

:::

### Parameters

| Parameter     | Type            | Default                | Description                                                                                                                                                       |
| ------------- | --------------- | ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`key`**     | `label`         | `<motif>`              | The internal metadata label used by the Loom engine to identify this block.                                                                                       |
| **`scope`**   | `(ctx) => dict` | `id`                   | **Provider.** Explicitly defines the context passed to children.                                                                                                  |
| **`measure`** | `function`      | `(..) => (none, none)` | **Logic Phase.** `(ctx, children) => (signal, view)`. Returns the component's public signal and internal view model. **Must return valid Frames for the signal.** |
| **`draw`**    | `function`      | `(..) => body`         | **Render Phase.** `(ctx, signal, view, body) => content`. Direct control over the final output.                                                                   |
| **`body`**    | `content`       | _required_             | The child content to process.                                                                                                                                     |
