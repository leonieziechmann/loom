---
sidebar_position: 5
---

# Mutator API

**Immutable State Updates**

The `mutator` module provides a functional, transaction-based API for modifying Typst dictionaries.

:::info Why use a Mutator?
While Typst variables are mutable within their scope, updating deeply nested structures often requires verbose "copy-modify-assign" patterns. The Mutator API abstracts this complexity, allowing you to describe a **transaction** of changes cleanly without manually reconstructing the dictionary hierarchy or writing repetitive update logic.
:::

## The Batch Transaction

The core concept is the `batch` function, which applies a sequence of operations to a target dictionary and returns the new state.

### `batch`

Applies a list of operations to a target dictionary.

```typ
loom.mutator.batch(target, ops)
```

| Parameter | Type         | Default  | Description                                                                                       |
| --------- | ------------ | -------- | ------------------------------------------------------------------------------------------------- |
| `target`  | `dictionary` | `none`   | Required                                                                                          |
| `ops`     | `array`      | Required | A block or array of operation functions (created by `put`, `update`, etc.) to apply sequentially. |

:::tip Syntax Sugar
You can pass a code block `{ ... }` as the `ops` argument. Inside this block, simply call the operation functions. Typst automatically collects these calls into an array for the batch processor.
:::

**Example:**

```typ
#import "@preview/loom:0.1.0": mutator

#let state = (count: 0, user: "Guest")

#let new-state = mutator.batch(state, {
  import mutator: *
  put("user", "Admin")
  update("count", c => c + 1)
})
```

---

## Operations

These functions generate **Operation Objects**. They define _what_ to do, but the change only happens when processed by `batch`.

:::warning Context Usage
These functions are not standalone. They must be used inside the `ops` list passed to a `batch` or `nest` call.
:::

### `put`

Sets a key to a specific value. Overwrites the value if the key already exists.

```typ
put(key, value)
```

| Parameter | Type  | Default  | Description                     |
| --------- | ----- | -------- | ------------------------------- |
| `key`     | `str` | Required | The dictionary key to set.      |
| `value`   | `any` | Required | The value to assign to the key. |

### `ensure`

Sets a value **only if the key is missing** (or `none`).

```typ
ensure(key, default-value)
```

| Parameter       | Type  | Default  | Description                                    |
| --------------- | ----- | -------- | ---------------------------------------------- |
| `key`           | `str` | Required | The dictionary key to check.                   |
| `default-value` | `any` | Required | The value to assign if the key does not exist. |

### `derive`

Sets a value, inheriting the previous one if the new value is `auto`.

- If `value` is `auto`: uses the current state value.
- If current state is missing (and value is `auto`): uses `default`.
- If `value` is set: uses that value.

```typ
derive(key, value, default: none)
```

| Parameter | Type  | Default  | Description                                                                      |
| --------- | ----- | -------- | -------------------------------------------------------------------------------- |
| `key`     | `str` | Required | The dictionary key to update.                                                    |
| `value`   | `any` | Required | The new value (or `auto`).                                                       |
| `default` | `any` | `none`   | Fallback value if `value` is `auto` and the key is missing in the current state. |

### `update`

Transforms an existing value using a callback function.

:::warning Existing Keys Only
The callback is only executed if the key **already exists** in the dictionary (and is not `none`). If the key is missing, this operation does nothing. Use `put` or `ensure` if you need to initialize values.
:::

```typ
update(key, callback)
```

| Parameter  | Type       | Default  | Description                                                                            |
| ---------- | ---------- | -------- | -------------------------------------------------------------------------------------- |
| `key`      | `str`      | Required | The dictionary key to update.                                                          |
| `callback` | `function` | Required | A function `(current) => new` that receives the current value and returns the new one. |

### `remove`

Deletes a key from the dictionary.

```typ
remove(key)
```

| Parameter | Type  | Default  | Description                   |
| --------- | ----- | -------- | ----------------------------- |
| `key`     | `str` | Required | The dictionary key to remove. |

### `merge`

Merges another dictionary into the current state.

```typ
merge(other-dictionary)
```

| Parameter          | Type         | Default  | Description                                     |
| ------------------ | ------------ | -------- | ----------------------------------------------- |
| `other-dictionary` | `dictionary` | Required | The dictionary to merge into the current state. |

:::warning Shallow Merge
This operation performs a **shallow merge**. Nested dictionaries in `other-dictionary` will overwrite those in the state. For deep merging, use `merge-deep`.
:::

### `merge-deep`

Recursively merges another dictionary into the current state.

```typ
merge-deep(other-dictionary)
```

| Parameter          | Type         | Default  | Description                                                 |
| ------------------ | ------------ | -------- | ----------------------------------------------------------- |
| `other-dictionary` | `dictionary` | Required | The dictionary to merge recursively into the current state. |

:::tip Use Case
Use `merge-deep` when you want to apply a configuration patch that contains nested settings without wiping out the existing sibling keys in those nested objects.
:::

---

## Nested Updates

### `nest`

Applies a batch of operations to a sub-dictionary (a child key).

```typ
nest(key, sub-ops)
```

| Parameter | Type    | Default  | Description                                                                                     |
| --------- | ------- | -------- | ----------------------------------------------------------------------------------------------- |
| `key`     | `str`   | Required | The key of the child dictionary to modify.                                                      |
| `sub-ops` | `array` | Required | A new list of operations (`put`, `update`, etc.) to apply specifically to the child dictionary. |

:::note Auto-Initialization
If `key` does not exist in the parent, or if the value at `key` is `none`, `nest` will automatically initialize it as an empty dictionary `(:)` before applying the operations.
:::

**Example: Deeply Nested Config**

```typ
#let config = (theme: (dark: false))

#let new-config = mutator.batch(config, {
  import mutator: *

  // Update existing nested key
  nest("theme", {
    put("dark", true)
    put("accent", blue)
  })

  // Create new nested section automatically
  nest("meta", {
    put("author", "Me")
  })
})
```
