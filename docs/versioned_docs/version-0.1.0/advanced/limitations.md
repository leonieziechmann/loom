---
sidebar_position: 2
---

# Limitations & Constraints

**Boundaries of the Engine**

Loom is a meta-engine running _inside_ Typst. While it pushes the language to its limits, it is still bound by the runtime's rules. Understanding these constraints will save you hours of debugging.

## 1. Vertical-Only Communication (Sibling Latency)

This is the most common "Gotcha" for new users.

**The Constraint:**
Data in Loom flows strictly **Vertically**:

1.  Down (Scope)
2.  Up (Signals)

**Sibling components (neighbors) cannot talk to each other directly in the same pass.**
If Component A calculates a value, Component B (sitting next to it) cannot see it immediately. A signal must travel all the way up to the **Document Root** to be collected by the engine and reinjected into the Context for the _next_ pass.

**The Workaround:**
You must rely on **Time Travel** (Multiple Passes).

1.  **Pass 1:** Sibling A emits a signal. It bubbles up through the parent to the **Root**.
2.  **Pass 2:** The `weave` function injects this signal into the Global Context.
3.  **Result:** Sibling B reads the data from `ctx`.

_Note: This "Root Round-Trip" is why complex dependencies require more passes._

## 2. Show Rule Invisibility

**The Constraint:**
Loom operates on the document structure (AST) _before_ standard Typst `#show` rules are fully resolved.
If you use a `#show` rule to transform raw text into a Loom component, the engine **will not see it** during the measure phase, meaning it won't emit signals or run logic.

**The Workaround:**
Loom components must be explicitly present in your source code. Use function calls instead of show rules for semantic elements.

```typ
// ✅ Do this
#task("Finish Documentation")
```

## 3. Opaque Named Fields

**The Constraint:**
Currently, Loom's engine does not inspect the **named arguments** of standard Typst functions (like `caption`, `header`, or `footer`).
If you place a component inside a `figure(caption: [...])`, it will be treated as opaque content. It will render, but it cannot interact with the reactive loop.

_Note: This is technically possible to implement, but it is not yet supported in the current version._

**The Workaround:**
Create a "Smart Wrapper" that handles the logic _outside_ the opaque field.

```typ
// ✅ Workaround: A custom figure component
#let smart-figure(body, caption-text) = motif(
  measure: (ctx, _) => {
    // Perform logic here (e.g., auto-numbering)
    ( (figure-count: 1), none )
  },
  draw: (ctx, _, _, body) => {
    // Construct the standard Typst figure in the draw phase
    figure(body, caption: caption-text)
  }
)
```

## 4. Nesting Depth (Stack Limits)

**The Constraint:**
Loom uses recursion to traverse the tree. Typst has a fixed stack size.
Nesting Loom components deeper than approximately **50-60 levels** will trigger a runtime panic ("stack overflow").

**The Workaround:**
**Flatten your structure.** Don't wrap every single word in a component. Use `query.collect` to gather data from a flat list rather than relying on deep nested bubbling.

## 5. Performance Overhead

**The Constraint:**
Every Context mutation creates a copy of the state dictionary.
Documents with **thousands** of reactive nodes will be slow (~seconds to compile).

_Note: Using `data-motif` does not significantly improve performance compared to `content-motif`, as the engine traversal cost is the main factor._

**The Workaround:**
**Scope the Engine.**
Instead of wrapping your entire 100-page thesis in `weave`, only wrap the specific sections that need reactivity (e.g., the "Executive Summary" or "Dashboard").

**The Trade-off:**
Loom instances are **Isolated Islands**.

- A `weave` block on Page 1 cannot share state with a `weave` block on Page 50.
- Standard Typst `state` does not work reliably across passes.
- You must choose: Either wrap the whole document (slower, shared state) or split it up (faster, isolated state).
