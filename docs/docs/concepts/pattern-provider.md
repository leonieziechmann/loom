---
sidebar_position: 4
---

# Pattern: The Provider

**Solving Parameter Drilling with Scope**

One of the biggest challenges in building complex Typst templates is **Parameter Drilling**.
If you have a document hierarchy like `Book > Chapter > Section > Component`, and the Component needs to know the "Primary Color" or the "Current Theme," you traditionally have to pass that variable manually through every single function call.

Loom solves this with the **Provider Pattern**.

## The Problem: Brittle Templates

In standard Typst, your code often looks like this. You are forced to be a "data courier," carrying variables down to places that need them.

```typ
// ❌ The old way: Passing state manually everywhere
#let my-chapter(number, theme-color, body) = {
  // You have to accept 'theme-color' just to pass it down...
  block(body(number, theme-color))
}

#let my-section(chapter-num, theme-color, body) = {
  // ...and pass it down again...
  text(fill: theme-color)[#chapter-num.1]
}
```

This is brittle. If you want to add a "font-size" setting later, you have to update every single function signature in the chain.

## The Solution: Context Injection

Loom components (Motifs) have a built-in mechanism called **Scope**. It works remarkably like **CSS variables**.

Any component can act as a **Provider**, injecting data into a shared context (`ctx`) that automatically "cascades" down to all descendants. The descendants act as **Consumers**, reading from that context without knowing who provided it.

### Implementing a "Smart" Component

The most robust way to use Scope is to handle three cases at once:

1. **Override:** The user specifically passed a value (`color: red`).
2. **Inherit:** The user passed `auto`, so we look up the tree.
3. **Default:** No one defined it, so we fallback to a safe value (`black`).

Loom makes this easy with `loom.context.scope`.

```typ
#import "@preview/loom:0.1.0": *
#let (motif, weave, context) = construct-loom(<my-lib>)

// THE COMPONENT
#let my-button(label, color: auto) = motif(
  // 1. THE SCOPE PHASE (Logic)
  // We determine the final value BEFORE we draw.
  // The syntax is: key: (override_value, fallback_default)
  scope: (ctx) => context.scope(ctx,
    my-btn-color: (color, black)
  ),

  // 2. THE DRAW PHASE (Render)
  // We can now safely assume 'ctx.my-btn-color' exists.
  draw: (ctx, public, view, body) => {
    box(fill: ctx.my-btn-color, inset: 10pt)[#label]
  },
  none
)
```

### Using the Component

Because we implemented the Provider pattern, this single component is now incredibly flexible:

```typ
// Case 1: Explicit Override
#my-button("Danger", color: red)

// Case 2: Context Inheritance (The Provider)
// We set the color ONCE at the top...
#motif(scope: ctx => context.scope(ctx, my-btn-color: blue))[
  #stack(dir: ltr)[
    #my-button("Submit")  // ...and these automatically become Blue
    #my-button("Cancel")  // ...without passing arguments!
  ]
]

// Case 3: Robust Default
#my-button("Boring") // Defaults to Black, doesn't crash.
```

## Critical Concepts

To use this pattern effectively, you must understand two specific rules about Loom's data flow.

### 1. Scope is "Public" (Self + Children)

When you use the `scope` function, the changes you make to `ctx` are visible to:

- **The Component Itself:** You can access the new values immediately in your `draw` or `measure` functions.
- **All Descendants:** Every child, grandchild, and great-grandchild will see these values.

This is why we say it behaves like CSS. If you set a property, it propagates down until something else overrides it.

### 2. Measure is "Private" (Local Only)

In contrast, if you calculate something inside the `measure` function and return it as part of the `view` tuple, that data is **private**.

- It is visible to your `draw` function.
- It is **NOT** passed down to children.

**Rule of Thumb:**

- Use `scope` for **Shared State** (Themes, Config, Chapter Numbers).
- Use `measure` for **Local Logic** (Geometry, layout calculations).

## Best Practices

### Always Sanitize with Scope

A common mistake is assuming a key exists because "usually a parent sets it."
If a user pastes your component into an empty file, `ctx.my-key` might be missing, causing a crash.

By using the `scope: (ctx) => context.scope(ctx, key: (auto, default))` pattern shown above, you guarantee that the key **always exists** with at least a default value, making your components crash-proof.
