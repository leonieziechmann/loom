---
sidebar_position: 3
---

# State Management & Mutators

**Immutable Data in a Loop**

If you have used Typst for a while, you are likely used to `state()` and `counter()` to manage values.
In Loom, you must be careful with these tools. Because Loom is a **Time Travel** engine (running your code multiple times until convergence), standard state management can behave unpredictably.

Loom uses a different model: **Immutable Dictionaries**.

## The Problem: The "Double-Count" Trap

Standard Typst state is based on **side effects**. When you write `counter.step()`, it modifies a global register.
Since Loom runs the **Weave Loop** multiple times, these side effects can accumulate.

**The "Old" Way (Dangerous in Loom):**
If Loom runs 3 passes to converge, a standard `counter.step()` might execute 3 times for a single item, resulting in the wrong number.

## The Solution: Functional Updates

Loom relies on **Immutable Context**. You don't "change" a variable; you calculate a **new** version of it.

- **Pass 1:** Input `0` → Output `1`
- **Pass 2:** Input `0` → Output `1` (Stable!)

This is safe, predictable, and debuggable.

---

## The Mutator Module (`loom.mutator`)

Managing deep dictionaries in Typst (e.g., `ctx + (config: (theme: (color: red)))`) is often messy and verbose.
Loom provides the `mutator` module as a general-purpose utility to handle **any** dictionary modification cleanly.

It isn't just for Context; it's for **any data transformation**.

### How it Works

The `mutator.batch(target, ops)` function takes a dictionary and applies a list of operations to it, returning a new dictionary.

```typ
#import "@preview/loom:0.1.0": *
#import loom: mutator

```

### Use Case 1: Complex Scope Updates

This is the most common usage: safely modifying the Context for children.

```typ
#let my-component(body) = motif(
  scope: (ctx) => mutator.batch(ctx, {
    import mutator: *
    // Safely update nested values without overwriting the whole 'theme'
    nest("theme", (
      put("primary", blue)
      update("scale", s => s * 1.2)
    )),
    // Ensure a flag exists
    ensure("debug-mode", false)
  }),
  body
)
```

### Use Case 2: General Data Processing

You can use `mutator` to clean up raw data (e.g., from a JSON file or CSV) before displaying it. This has nothing to do with Scope; it's just powerful data manipulation.

```typ
#let raw-user-data = (
  name: "  Alice ",
  role: "admin",
  login-count: 5
)

// Clean up the data for display
#let clean-user = mutator.batch(raw-user-data, {
  import mutator: *
  // 1. Trim whitespace
  update("name", n => n.trim())
  // 2. Remove sensitive info
  remove("login-count")
  // 3. Add derived fields
  put("display-name", "Admin Alice")
  // 4. Merge default settings
  merge((active: true, group: "staff"))
})

// Result: (name: "Alice", role: "admin", display-name: "...", active: true, ...)
```

### Use Case 3: Constructing Signals (Measure Phase)

When emitting signals in the `measure` phase, you often want to build a rich data packet.

```typ
#(measure: (ctx, children-signals) => {
  // Start with a base signal
  let signal = (source: "section")

  // Conditionally add fields based on logic
  let final-signal = mutator.batch(signal, {
    import mutator: *
    put("id", ctx.my-id)
    // Only add 'total' if we actually have children
    if children-signals.len() > 0 {
      put("total", children-signals.len())
    }
  })

  (final-signal, none)
})
```

## Available Operations

| Operation              | Description                                                |
| ---------------------- | ---------------------------------------------------------- |
| `put(key, value)`      | Sets a value, overwriting if it exists.                    |
| `ensure(key, default)` | Sets a value **only if** it is currently missing (`none`). |
| `update(key, fn)`      | Transforms a value: `fn(old_value) => new_value`.          |
| `remove(key)`          | Deletes a key.                                             |
| `nest(key, ops)`       | Applies a batch of operations to a sub-dictionary.         |
| `merge(dict)`          | Merges another dictionary into the current one.            |

**Pro Tip:** `mutator` functions are pure. They never modify the original variable; they always return a new, modified copy.
