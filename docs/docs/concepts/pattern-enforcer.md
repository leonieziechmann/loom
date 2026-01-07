---
sidebar_position: 6
---

# Pattern: The Enforcer

**Building Crash-Proof Templates with Guards**

So far, we have talked about how to share data (Providers) and collect data (Aggregators). But what happens when a user uses your components **wrong**?

What if they put a `TableCell` inside a `Footnote`? Or try to use a `Chapter` without a `Book` wrapper? In standard Typst, this often leads to "Silent Failures"—the content just renders weirdly, or variables are missing, and the user has no idea why.

Loom solves this with the **Enforcer Pattern**.

## The Problem: "Silent Failures"

Imagine you are building a slideshow template. You have a `slide` component that expects to be inside a `presentation`.

**The Unsafe Way:**
If a user pastes a `#slide[...]` into a normal document, it might try to read `ctx.page-width` (which doesn't exist) and crash with a cryptic error: _"key 'page-width' not found in dictionary."_

Or worse, it might render perfectly fine, but look completely broken because it's missing the styling from the root.

## The Solution: Guards

Loom provides a `guards` module that allows your components to assert where they are allowed to live. If the rules are violated, Loom stops the compilation with a **clear, helpful error message**.

This turns a "runtime bug" into a "usage instruction."

### 1. Hierarchy Guards (Strict Nesting)

The most common check is enforcing parent-child relationships.

```typ
#import "@preview/loom:0.1.0": *
#let (motif, weave, context, guards) = construct-loom(<my-lib>)

// CHILD: Ingredient
#let ingredient(name) = motif(
  measure: (ctx, _) => {
    // RULE: I MUST be inside a 'recipe' component.
    // If not, stop compilation immediately.
    guards.assert-inside(ctx, "recipe")

    ( (name: name), none )
  },
  draw: (ctx, public, view, body) => [ - #name ]
)

// PARENT: Recipe
// We give this component the specific name "recipe"
#let recipe(name, body) = motif(name: "recipe",
  draw: (ctx, public, view, body) => block(body),
  body
)
```

Now, if a user tries this:

```typ
#ingredient("Salt") // ❌ ERROR: Component must be inside 'recipe'.
```

They get a clear message telling them exactly what they did wrong.

### 2. Context Guards (Required Data)

Sometimes, you don't care _where_ a component is, but you care _what_ data it has.
While the **Provider Pattern** suggests using defaults (`auto`), some components simply cannot function without specific data.

```typ
#let plot-point(x, y) = motif(
  measure: (ctx, _) => {
    // RULE: The coordinate system MUST be defined.
    // We can't default this; if it's missing, the plot is invalid.
    guards.assert-has-key(ctx, "plot-axis-x")
    guards.assert-has-key(ctx, "plot-axis-y")

    ( (x: x, y: y), none )
  },
  // ...
)
```

### 3. Root Guards (Singletons)

Some components only make sense if they are the **Director** (the root of the Loom weave). For example, a `book` or `presentation` wrapper.

```typ
#let presentation(body) = motif(
  measure: (ctx, _) => {
    // RULE: I must be the top-level component.
    guards.assert-root(ctx)
    // ...
  },
  body
)
```

## Available Guards

The `loom.guards` module covers the most common architectural constraints:

| Guard                                | Checks For...      | Use Case                              |
| ------------------------------------ | ------------------ | ------------------------------------- |
| `assert-inside(ctx, ..names)`        | Ancestor existence | "Slide must be in Presentation"       |
| `assert-not-inside(ctx, ..names)`    | Ancestor absence   | "Don't put a Chapter inside a Footer" |
| `assert-direct-parent(ctx, ..names)` | Immediate parent   | "Tab Item must be directly in Tabs"   |
| `assert-root(ctx)`                   | Being the root     | Top-level wrappers                    |
| `assert-has-key(ctx, key)`           | Context data       | Mandatory configuration               |
| `assert-max-depth(ctx, n)`           | Nesting limits     | Preventing infinite recursion         |

## Best Practices

### "Fail Loud" vs. "Adapt"

You now have two opposing patterns:

1. **Provider Pattern:** "If data is missing, use a default." (Adapt)
2. **Enforcer Pattern:** "If data is missing, crash." (Fail Loud)

**When to use which?**

- **Use Enforcers** when the usage is **invalid**. (e.g., A `TabItem` outside of `Tabs` makes no sense logically).
- **Use Providers** when the usage is **optional**. (e.g., A `Button` outside of a `Theme` should just look boring, not crash).

### Guard the `measure` phase

Always place your guards in the `measure` function, not `draw`.

1. `measure` runs first, so the error happens sooner.
2. `measure` is used for logic; `draw` should be safe and dumb.

```typ
// ✅ Good
measure: (ctx, _) => {
  guards.assert-inside(ctx, "list")
  // ...
}
```
