---
sidebar_position: 1
---

# Engine API

**The Heart of Loom**

The engine module manages the execution loop, signal propagation, and context injection.

## `construct-loom`

The entry point for using Loom. It creates a secluded instance of the engine with a unique namespace.

```typ
loom.construct-loom(key) -> dictionary
```

### Arguments

- **`key`**
  - **Type:** `label`
  - **Description:** A unique identifier for your library (e.g., `<my-lib>`). This ensures your signals don't clash with other Loom libraries used in the same document.

### Returns

A `dictionary` containing the tools pre-bound to your namespace:

| Key                  | Type         | Description                                                                               |
| -------------------- | ------------ | ----------------------------------------------------------------------------------------- |
| **`weave`**          | `function`   | The main loop runner, pre-configured with your key.                                       |
| **`motif`**          | `dictionary` | A collection of component constructors: `plain`, `managed`, `compute`, `data`, `content`. |
| **`prebuild-motif`** | `dictionary` | Ready-to-use utility components: `debug`, `apply`.                                        |

#### Example

```typ
#import "@preview/loom:0.1.0"

// 1. Construct the instance
#let my-loom = loom.construct-loom(<my-project>)

// 2. Destructure the tools you need
#let weave = my-loom.weave
#let content-motif = my-loom.motif.content
#let debug = my-loom.prebuild-motif.debug

// 3. Use them
#show: weave.with()
```

---

## `weave`

The runner function that executes the "Time Travel" loop. It should be used with a show rule at the root of your document or section.

```typ
#show: weave.with(..config)
```

### Arguments

| Parameter                   | Type             | Default                               | Description                                                                                                                         |
| --------------------------- | ---------------- | ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **`key`**                   | `label`          | `<motif>`                             | The namespace key used to identify components belonging to this engine instance.                                                    |
| **`inputs`**                | `dictionary`     | `(:)`                                 | Initial variables to inject into the root context. Use this to pass external configuration or metadata into the Loom environment.   |
| **`max-passes`**            | `int`            | `2`                                   | The maximum number of total passes (measure + draw). Increase this if you have deep dependency chains (e.g., lateral data sharing). |
| **`debug`**                 | `bool`           | `false`                               | If `true`, enables verbose console logging and injects debug flags into the context.                                                |
| **`injector`**              | `function`       | `(ctx, payload) => (global: payload)` | Defines how aggregated signals (`payload`) from the _previous_ pass are injected into the _current_ pass's context.                 |
| **`handle-nonconvergence`** | `function`       | `(..args) => ctx`                     | Callback executed if signals fail to stabilize within `max-passes`. Arguments: `(ctx, iterations, last, current)`.                  |
| **`observer`**              | `array<content>` | `()`                                  | Optional content nodes to process alongside the director. Calculated once during `draw` and ignored for fix-point calculation.      |
| **`director`**              | `content`        | _required_                            | The main content body to process. (Passed implicitly when using `#show`).                                                           |
