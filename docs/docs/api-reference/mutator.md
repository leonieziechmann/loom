---
sidebar_position: 5
---

# Mutator API

**Immutable State Updates**

The `mutator` module provides a functional, transaction-based API for modifying Typst dictionaries. Because Typst data structures are immutable, "modifying" a dictionary actually means creating a new copy with changes applied.

This module makes complex, nested updates clean and readable, avoiding deep nesting of `dict.insert` or `+` operators.

## The Batch Transaction

The core concept is the `batch` function, which applies a sequence of operations to a target dictionary.

```typ
loom.mutator.batch(target, ops) -> dictionary
```

- **`target`** (`dictionary` | `none`): The starting state. If `none`, starts with `(:)`.
- **`ops`** (`array<function>`): A list of operations (created by `put`, `update`, etc.) to apply sequentially.

### Example

```typ
#import "@preview/loom:0.1.0": mutator

#let state = (count: 0, user: "Guest")

#let new-state = mutator.batch(state, {
  import mutator: *

  put("user", "Admin")
  update("count", c => c + 1)
  put("status", "active")
})

// Result: (count: 1, user: "Admin", status: "active")
```

---

## Operations

These functions return **Operation Objects** (functions) that are passed to `batch`. They are not meant to be called on their own.

### `put`

Sets a key to a specific value. Overwrites the value if the key already exists.

```typ
put(key, value)
```

### `ensure`

Sets a value **only if the key is missing** (or `none`). Useful for safely setting defaults without overwriting existing data.

```typ
ensure(key, default-value)
```

### `update`

Transforms an existing value using a callback function.

```typ
update(key, callback)
```

- **`callback`**: `(current-value) => new-value`

### `remove`

Deletes a key from the dictionary.

```typ
remove(key)
```

### `merge`

Merges another dictionary into the current state (shallow merge).

```typ
merge(other-dictionary)
```

---

## Nested Updates

### `nest`

Applies a batch of operations to a sub-dictionary.
If the key does not exist (or is not a dictionary), it initializes an empty dictionary at that location first.

```typ
nest(key, sub-ops)
```

- **`sub-ops`**: An array of operations to apply to the child dictionary.

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

  // Create new nested section
  nest("meta", {
    put("author", "Me")
  })
})

// Result:
// (
//   theme: (dark: true, accent: blue),
//   meta: (author: "Me")
// )
```
