# Guards & Validation

As your document system grows, you may want to enforce structural rules. For example, a "Task" component might rely on data provided by a "Project" parent. If a user places a "Task" standalone in the document, it should fail with a helpful error message rather than a cryptic "key not found" error.

Loom provides a `guards` module for this purpose.

## 1. Hierarchy Guards

These guards validate the position of the current component within the document tree. They check the `sys.path` to determine ancestry.

### `guards.assert-inside(ctx, ..ancestors)`

Ensures that the component is nested within *at least one* of the specified ancestor kinds.

* **Use Case:** A "Task" must be inside a "Project" or "Phase".

```typ
#(
  measure: (ctx, _) => {
    guards.assert-inside(ctx, "project", "phase")
    // ... safe to proceed
  }
)
```

### `guards.assert-direct-parent(ctx, ..parents)`

Stricter than `assert-inside`. Ensures that the *immediate* parent matches one of the specified kinds.

* **Use Case:** A "TableRow" must be directly inside a "Table".

```typ
#guards.assert-direct-parent(ctx, "table")
```

### `guards.assert-root(ctx)`

Ensures that the component is at the root level of the Loom tree (depth 0).

* **Use Case:** Top-level managers like "Project" or "Dashboard".

```typ
#guards.assert-root(ctx)
```

### `guards.assert-not-inside(ctx, ..ancestors)`

The inverse of `assert-inside`. Prevents nesting within specific components.

* **Use Case:** Preventing a "PageHeader" from being used inside a "Footer".

```typ
#guards.assert-not-inside(ctx, "footer")
```

---

## 2. Context Guards

These guards validate the content of the `ctx` dictionary.

### `guards.assert-has-key(ctx, key, msg: none)`

Ensures that a specific key exists in the context.

* **Use Case:** verifying that a required dependency (like a theme or configuration) has been injected by a parent.

```typ
#guards.assert-has-key(ctx, "theme-color", msg: "Missing theme! Wrap this in a ThemeProvider.")

```

### `guards.assert-value(ctx, key, ..allowed)`

Ensures that a context key exists AND matches one of the allowed values.

* **Use Case:** Validating enum-like configurations.

```typ
#guards.assert-value(ctx, "status", "active", "pending", "done")
```

---

## 3. Safety Guards

### `guards.assert-max-depth(ctx, max)`

Ensures that the nesting depth does not exceed a limit. This is useful for preventing stack overflows in recursive components.

```typ
#guards.assert-max-depth(ctx, 50)
```

---

## Example: The Strict Component

Here is a full example of a component that enforces strict usage rules.

```typ
#let strict-item(body) = motif(
  "item",
  measure: (ctx, _) => {
    // 1. Structural Check: Must be in a list
    guards.assert-inside(ctx, "list")

    // 2. Data Check: Must have a configuration
    guards.assert-has-key(ctx, "list-style")

    // Proceed
    (none, none)
  },
  draw: (ctx, public, view, body) => {
    let style = ctx.at("list-style")
    [#style #body]
  },
  body
)

```
