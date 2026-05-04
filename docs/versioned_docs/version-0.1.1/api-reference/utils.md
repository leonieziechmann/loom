---
sidebar_position: 8
---

# Utilities API

**Helper Tools for Data & Paths**

Loom exposes two utility modules: `collection` (for data manipulation) and `path` (for tree introspection). These are often used when building complex `measure` logic.

---

## Module: `loom.collection`

Functional utilities for manipulating standard Typst dictionaries and arrays. These helpers are "safe" by default—they tend to return `none` or default values rather than panicking.

### `get`

Safely retrieves a value from a nested structure of dictionaries and arrays.

```typ
collection.get(root, ..path, req-type: none, default: none) -> any
```

| Parameter  | Type         | Default | Description                                                                 |
| ---------- | ------------ | ------- | --------------------------------------------------------------------------- |
| `root`     | `dictionary` | `array` | _required_                                                                  |
| `..path`   | `str`        | `int`   | _required_                                                                  |
| `req-type` | `type`       | `none`  | If provided, returns `default` if the found value does not match this type. |
| `default`  | `any`        | `none`  | The value to return if the path is invalid or result is `none`.             |

### `map`

Applies a function to a value _only if_ the value is not `none`.

```typ
collection.map(value, fn, req-type: none) -> any
```

| Parameter  | Type       | Default    | Description                                                      |
| ---------- | ---------- | ---------- | ---------------------------------------------------------------- |
| `value`    | `any`      | _required_ | The value to transform.                                          |
| `fn`       | `function` | _required_ | The transformation function `v => new_v`.                        |
| `req-type` | `type`     | `none`     | If provided, returns `none` if `value` does not match this type. |

### `merge-deep`

Recursively merges two dictionaries. Unlike standard Typst `+`, this preserves nested keys in the `base` dictionary instead of overwriting the entire sub-dictionary.

```typ
collection.merge-deep(base, override) -> dictionary
```

| Parameter  | Type         | Default    | Description                                      |
| ---------- | ------------ | ---------- | ------------------------------------------------ |
| `base`     | `dictionary` | _required_ | The original dictionary (e.g., default config).  |
| `override` | `dictionary` | _required_ | The dictionary with updates (e.g., user config). |

### `omit`

Creates a new dictionary with specific keys removed.

```typ
collection.omit(dict, ..keys) -> dictionary
```

| Parameter | Type         | Default    | Description            |
| --------- | ------------ | ---------- | ---------------------- |
| `dict`    | `dictionary` | _required_ | The source dictionary. |
| `..keys`  | `str`        | _required_ | The keys to exclude.   |

### `pick`

Creates a new dictionary containing _only_ the specified keys. Keys not present in the source are ignored.

```typ
collection.pick(dict, ..keys) -> dictionary
```

| Parameter | Type         | Default    | Description            |
| --------- | ------------ | ---------- | ---------------------- |
| `dict`    | `dictionary` | _required_ | The source dictionary. |
| `..keys`  | `str`        | _required_ | The keys to keep.      |

### `compact`

Removes all `none` values from an array or dictionary.

```typ
collection.compact(collection) -> array | dictionary
```

---

## Module: `loom.path`

Utilities for inspecting the component hierarchy. These functions read the **System Path** stored in the Context (`ctx`).

### `get`

Retrieves the raw path array.

```typ
path.get(ctx) -> array<(str, int)>
```

- **Returns:** An array of tuples, e.g., `( ("root", 0), ("section", 2) )`.

### `to-string`

Serializes the path into a unique string identifier.

```typ
path.to-string(ctx, separator: ">") -> str
```

- **Returns:** A string like `"root(0)>section(2)>div(1)"`.

### `contains`

Checks if the current path contains specific component kinds.

```typ
path.contains(ctx, ..kinds, include-current: true) -> bool
```

| Parameter         | Type         | Default    | Description                                                                 |
| ----------------- | ------------ | ---------- | --------------------------------------------------------------------------- |
| `ctx`             | `dictionary` | _required_ | The current context.                                                        |
| `..kinds`         | `str`        | _required_ | One or more kinds to check for (e.g., "project").                           |
| `include-current` | `bool`       | `true`     | If `false`, checks only ancestors (parents), ignoring the component itself. |

### `parent`

Retrieves the full tuple `(kind, id)` of the immediate parent.

```typ
path.parent(ctx) -> (str, int) | none
```

### `parent-kind`

Retrieves just the "kind" string of the immediate parent.

```typ
path.parent-kind(ctx) -> str | none
```

### `parent-is`

Checks if the immediate parent matches one of the provided kinds.

```typ
path.parent-is(ctx, ..kinds) -> bool
```

### `current`

Retrieves the full tuple `(kind, id)` of the current component (the tip of the path).

```typ
path.current(ctx) -> (str, int) | none
```

### `current-kind`

Retrieves just the "kind" string of the current component.

```typ
path.current-kind(ctx) -> str | none
```

### `depth`

Returns the current nesting depth (length of the path).

```typ
path.depth(ctx) -> int
```
