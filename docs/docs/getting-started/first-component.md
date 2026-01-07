---
sidebar_position: 2
---

# Your First Component

**From Functions to Motifs**

In standard Typst, you create reusable UI elements using **functions**.
In Loom, you create them using **Motifs**.

A Motif is just a function wrapped in a special container that allows it to participate in the reactive Weave Loop.

## The Goal

We will build a simple **Note Box** component that:

1.  Accepts a title.
2.  Wraps its content in a styled block.
3.  Is reactive (though we won't use the reactivity just yet!).

## 1. The Blueprint

Open your `main.typ` file. Ensure you have imported your wrapper as described in the [Installation](./installation) guide.

To define a visual component, we use the `content-motif` constructor. This is the simplest type of Motif—it just takes a `draw` function.

```typ
#import "loom-wrapper.typ": *

// Define the component
#let note(title, body) = content-motif(
  // The 'draw' phase determines how the component looks.
  draw: (ctx, body) => {
    block(
      fill: luma(240),
      stroke: (left: 4pt + blue),
      inset: 1em,
      width: 100%
    )[
      *#title* \
      #body
    ]
  }
)
```

### Understanding the Signature

Look at the `draw` function: `(ctx, body) => ...`.

- **`ctx` (Context):** This is the "Magic Backpack" containing all global state, theme configuration, and parent data. We aren't using it yet, but it's always there.
- **`body`:** This is the content the user puts inside the square brackets `[...]`.

## 2. Using the Component

You use a Motif exactly like a standard Typst function.

```typ
// Start the engine (Required!)
#show: weave.with()

// Use your component
#note("Tip")[
  Loom components look just like normal Typst functions,
  but they are much more powerful under the hood.
]

#note("Warning")[
  Always remember to initialize the engine with `#show: weave.with()`,
  otherwise your motifs will print generic object representations!
]

```

## 3. Adding Props (Arguments)

Because `content-motif` returns a standard Typst function, you can add as many arguments as you like.

Let's add a `color` argument with a default value.

```typ
#let note(title, color: blue, body) = content-motif(
  draw: (ctx, body) => {
    block(
      fill: color.lighten(90%),
      stroke: (left: 4pt + color),
      inset: 1em
    )[
      #text(fill: color, weight: "bold")[#title] \
      #body
    ]
  }
)

// Usage
#note("Success", color: green)[System is operational.]
#note("Error", color: red)[Connection failed.]

```

## Summary

- **`content-motif`** is the tool for building visual components.
- The **`draw`** function receives the `ctx` and the `body`.
- You pass arguments (props) to the wrapper function, and they are available inside `draw` via closure capturing.

---

### Why not just use a normal function?

You might be thinking: _"I could have done this with a normal `#let` function in 3 lines of code. Why the extra wrapper?"_

If you only care about styling, a normal function is fine!
But by wrapping it in `content-motif`, you unlock Loom's superpowers:

1. **Context Access:** Your note could automatically read `ctx.theme-color` without you passing it.
2. **Signals:** Your note could emit a signal saying "I am a Warning", and a parent could count how many warnings are on the page.
3. **Guards:** You could enforce that "Error" notes only appear in the "Appendix".
