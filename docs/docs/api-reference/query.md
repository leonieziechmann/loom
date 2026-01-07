---
sidebar_position: 3
---

# Query API

**Traversal and Aggregation**

The `query` module provides a functional API to filter, search, and aggregate data from child components. It is primarily used within the `measure` phase of a component to extract information from the `children` array.

## Search & Traversal

These functions help you navigate the component tree and locate specific elements.

For most traversal functions, there are two variants:

1. **Standard** (e.g., `select`): Returns **frames** (the component envelopes containing metadata like `path` and `kind`).
2. **Signals** (e.g., `select-signals`): Returns the **user data** directly (the `signal` payload), automatically unwrapping the frame and filtering out empty signals.

### `select` / `select-signals`

Filters the list of **immediate** children, returning only those matching a specific component kind.

```typ
query.select(children, kind)
query.select-signals(children, kind)
```

| Parameter  | Type           | Default  | Description                                   |
| ---------- | -------------- | -------- | --------------------------------------------- |
| `children` | `array<frame>` | Required | The list of frames to search.                 |
| `kind`     | `str`          | Required | The component kind to match (e.g., `"task"`). |

**Returns:**

- `select`: `array<frame>`
- `select-signals`: `array<any>`

**Example:**

```typ
// Get frames (if you need path/key)
let task-frames = query.select(children, "task")

// Get data directly (if you just need values)
let task-data = query.select-signals(children, "task")
```

### `find` / `find-signal`

Finds the **first immediate** child of a specific kind. Returns `none` (or the default) if not found.

```typ
query.find(children, kind, default: none)
query.find-signal(children, kind, default: none)
```

| Parameter  | Type           | Default  | Description                                        |
| ---------- | -------------- | -------- | -------------------------------------------------- |
| `children` | `array<frame>` | Required | The list of frames to search.                      |
| `kind`     | `str`          | Required | The component kind to find.                        |
| `default`  | `any`          | `none`   | The value to return if no matching child is found. |

**Returns:**

- `find`: `frame | none`
- `find-signal`: `any | none`

**Example:**

```typ
// Get the configuration object directly
let config = query.find-signal(children, "config", default: (:))
```

### `collect` / `collect-signals`

Recursively traverses the tree to find all descendants of a specific kind (or all nodes if `kind` is `none`).

**Traversal Logic:**
Since child components are passed via the `signal`, these functions inspect the `signal` of each node to find the next generation of children. They support three patterns:

1. **Wrapper:** The signal is a `frame` (single child).
2. **List:** The signal is an `array` (list of children).
3. **Container:** The signal is a `dictionary` with a `children` key.

```typ
query.collect(children, kind: none, depth: 10)
query.collect-signals(children, kind: none, depth: 10)
```

| Parameter  | Type           | Default  | Description                                                           |
| ---------- | -------------- | -------- | --------------------------------------------------------------------- |
| `children` | `array<frame>` | Required | The root list of frames to start searching from.                      |
| `kind`     | `str`          | `none`   | The component kind to filter by. If `none`, collects all descendants. |
| `depth`    | `int`          | `10`     | The maximum recursion depth to traverse.                              |

**Returns:**

- `collect`: `array<frame>`
- `collect-signals`: `array<any>`

:::info "Ghost" Nodes
These functions automatically filter out non-frame data found in signals (e.g., strings or config objects) during traversal to ensure they only recurse into valid component frames.
:::

**Example:**

```typ
// Flatten the tree and get all ingredient data
let all-ingredients = query.collect-signals(children, "ingredient")
```

### `where` / `where-signals`

Filters children using a custom predicate function.

```typ
query.where(children, predicate)
query.where-signals(children, predicate)
```

| Parameter   | Type           | Default  | Description                                                       |
| ----------- | -------------- | -------- | ----------------------------------------------------------------- |
| `children`  | `array<frame>` | Required | The list of frames to filter.                                     |
| `predicate` | `function`     | Required | A function `frame => bool` that returns `true` for items to keep. |

**Returns:**

- `where`: `array<frame>`
- `where-signals`: `array<any>`

**Example:**

```typ
// Find all components with a cost signal greater than 100
let expensive = query.where-signals(children, c => c.signal.cost > 100)
```

---

## Data Extraction & Aggregation

These functions operate on the `signal` data carried by the components, helping you calculate totals or extract lists of values.

### `pluck`

Extracts a specific field from the `signal` of each child, returning an array of values.

```typ
query.pluck(children, key, default: none)
```

| Parameter  | Type           | Default  | Description                                     |
| ---------- | -------------- | -------- | ----------------------------------------------- |
| `children` | `array<frame>` | Required | The list of frames to process.                  |
| `key`      | `str`          | Required | The key to look up in each child's `signal`.    |
| `default`  | `any`          | `none`   | Value to use if the key is missing in a signal. |

### `sum-signals`

Sums up a specific numeric field from the signals of all children. This is a shorthand for `pluck(..).sum()`.

```typ
query.sum-signals(children, key, default: 0)
```

| Parameter  | Type             | Default  | Description                                      |
| ---------- | ---------------- | -------- | ------------------------------------------------ |
| `children` | `array<frame>`   | Required | The list of frames to process.                   |
| `key`      | `str`            | Required | The key containing the number in `child.signal`. |
| `default`  | `int` or `float` | `0`      | Value to use if the key is missing or invalid.   |

### `group-by` / `group-signals`

Groups children into a dictionary based on a value in their signal.

```typ
query.group-by(children, key)
query.group-signals(children, key)
```

| Parameter  | Type           | Default  | Description                                     |
| ---------- | -------------- | -------- | ----------------------------------------------- |
| `children` | `array<frame>` | Required | The list of frames to group.                    |
| `key`      | `str`          | Required | The signal key to use as the grouping category. |

**Returns:**

- `group-by`: `dictionary<str, array<frame>>`
- `group-signals`: `dictionary<str, array<any>>`

**Example:**

```typ
// Group ingredient data by category
let groups = query.group-signals(ingredients, "category")
// -> (fruit: ((name: "Apple"), ...), veg: (...))
```

### `fold`

Aggregates data from a list of children using a custom reducer function. This operates directly on the `signal` of the children.

```typ
query.fold(children, fn, base)
```

| Parameter  | Type           | Default  | Description                            |
| ---------- | -------------- | -------- | -------------------------------------- |
| `children` | `array<frame>` | Required | The list of frames to process.         |
| `fn`       | `function`     | Required | Reducer `(acc, signal) => new_acc`.    |
| `base`     | `any`          | Required | The initial value for the accumulator. |

**Example:**

```typ
let total-value = query.fold(children, (acc, sig) => acc + sig.value, 0)
```
