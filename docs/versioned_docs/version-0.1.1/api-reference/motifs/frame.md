---
sidebar_position: 1
---

# The Frame Object

Frames are the fundamental unit of data exchange in Loom. They act as standardized envelopes that wrap user signals with system metadata, ensuring the engine can route and normalize data regardless of the component type.

These functions are located in the module `loom.frame`.

## `loom.frame.new`

Creates a new frame instance. This is required when returning signals from a `motif.plain` or when manually constructing data nodes.

```typ
loom.frame.new(
  kind: "node",
  key: none,
  path: (),
  signal: none
)
```

### Parameters

| Parameter    | Type    | Default  | Description                                                 |
| ------------ | ------- | -------- | ----------------------------------------------------------- |
| **`kind`**   | `str`   | `"node"` | The category of the component (e.g., "task", "ingredient"). |
| **`key`**    | `str`   | `none`   | `none`                                                      |
| **`path`**   | `array` | `()`     | The absolute path to the component in the hierarchy.        |
| **`signal`** | `any`   | `none`   | The user-defined data payload.                              |

---

## `loom.frame.normalize`

Ensures that data returned by a motif is converted into a consistent `array<frame>` structure.

- `none` becomes `()`.
- A single `frame` becomes `(frame,)`.
- Arrays are flattened and non-frame items cause a panic.

```typ
loom.frame.normalize(data)
```

---

## `loom.frame.is-frame`

Verifies if a value is a valid Loom frame by checking for the internal `type: "frame"` marker and all required metadata fields.

```typ
loom.frame.is-frame(data)
```

**Returns:** `bool`
