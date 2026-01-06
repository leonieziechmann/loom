# State Management & Utilities

Managing state in Typst can be tricky because all data structures are immutable. If you want to update a deeply nested key in a configuration dictionary, you normally have to reconstruct the entire tree.

Loom provides two modules, `mutator` and `collection`, to make state manipulation and data access easier.

---

## 1. The Mutator (Immutable Updates)

The `mutator` module allows you to describe a series of changes ("operations") to a dictionary and apply them in a single batch. This is cleaner than chaining multiple `+` operations.

### `mutator.batch(target, ops)`

Applies a list of operations to the `target` dictionary and returns the new, modified dictionary.

**Available Operations:**

- `mutator.put(key, value)`: Sets a value (overwrites if exists).
- `mutator.ensure(key, default)`: Sets a value only if the key is missing.
- `mutator.update(key, fn)`: Modifies an existing value using a function `old => new`.
- `mutator.remove(key)`: Deletes a key.
- `mutator.merge(dict)`: Merges another dictionary at the current level.
- `mutator.nest(key, sub_ops)`: Applies operations to a nested dictionary.

**Example: Updating a Config**

```typ
#let config = (
  theme: (mode: "light"),
  users: 0
)

#let new-config = mutator.batch(config, {
  import loom.mutator: *
  // 1. Simple update
  update("users", u => u + 1),

  // 2. Nested update without rebuilding the 'theme' dict manually
  nest("theme", {
    put("mode", "dark")
    put("accent", blue)
  }),

  // 3. Conditional default
  ensure("debug", false)
})
```

---

## 2. Collection Utilities (Safe Access)

The `collection` module provides tools for reading data from nested structures safely, avoiding "Key not found" panic errors.

### `collection.get(root, ..path, default: none)`

Safely retrieves a value from a deeply nested structure of dictionaries and arrays. If any step in the path fails, it returns the default value.

```typ
#let data = (user: (profile: (settings: (theme: "dark"))))

// Safe navigation
#let theme = collection.get(data, "user", "profile", "settings", "theme", default: "light")

// Also works with array indices
#let first-item = collection.get(list, 0, default: "empty")
```

### `collection.merge-deep(base, override)`

Recursively merges two dictionaries. Unlike the standard `+` operator, which replaces nested dictionaries entirely, this merges their keys.

```typ
#let default = (font: (size: 10pt, family: "Arial"))
#let user = (font: (size: 12pt)) // User only specified size

#let result = collection.merge-deep(default, user)
// -> (font: (size: 12pt, family: "Arial"))
```

### `collection.compact(list_or_dict)`

Removes all `none` values from an array or dictionary. Useful for cleaning up data after conditional logic.

```typ
#let clean = collection.compact((1, none, 2, none))
// -> (1, 2)
```

---

## 3. Path Utilities

While `sys.path` is managed automatically by Loom, you sometimes need to convert it into a string (e.g., for HTML anchors or unique IDs).

```typ
// lib.typ
#let path = loom.path

```

### `path.to-string(ctx, separator: ">")`

Converts the current component path into a unique string identifier.

```typ
measure: (ctx, _) => {
  let my-id = path.to-string(ctx, separator: "-")
  // -> "section(0)-task(3)"
  ( (id: my-id), none )
}

```

### `path.depth(ctx)`

Returns the current nesting level (integer).

```typ
#let level = path.depth(ctx)
```
