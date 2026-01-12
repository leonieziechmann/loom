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

1. Accepts a title.
2. Wraps its content in a styled block.
3. Is reactive (though we won't use the reactivity just yet!).

## 1. The Blueprint

Open your `main.typ` file. Ensure you have imported your wrapper as described in the [Installation](https://www.google.com/search?q=./installation) guide.

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

:::info The Magic Backpack
The **`ctx` (Context)** parameter is available in almost every Loom lifecycle function. It contains all global state, theme configuration, and parent data. Even if you don't use it now, it's the bridge that connects your component to the rest of the system.
:::

- **`ctx`:** The context dictionary.
- **`body`:** This is the content the user puts inside the square brackets `[...]`.

## 2. Using the Component

You use a Motif exactly like a standard Typst function.

:::danger Critical Step
You **must** initialize the Loom engine at the start of your document using `#show: weave.with()`. If you skip this, your components will not render!
:::

```typ
// Start the engine (Required!)
#show: weave.with()

// Use your component
#note("Tip")[
  Loom components look just like normal Typst functions,
  but they are much more powerful under the hood.
]

#note("Warning")[
  Always remember to initialize the engine!
]
```

## 3. Adding Props (Arguments)

Because `content-motif` returns a standard Typst function, you can add as many arguments as you like.

Let's add a `color` argument with a default value.

:::note Closure Capturing
Notice that the `draw` function doesn't need `title` or `color` passed to it explicitly. Because `draw` is defined _inside_ the `note` function, it automatically captures those variables from the parent scope.
:::

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

If you only care about styling, a normal function is fine! But by wrapping it in `content-motif`, you unlock Loom's superpowers.

:::tip The Loom Advantage
By using a Motif, your simple note box gains capabilities that standard functions lack:

1. **Context Access:** It can automatically read `ctx.theme-color` without you passing it down manually.
2. **Signals:** It could emit a signal saying "I am a Warning", allowing a parent component to count how many warnings exist in the document.
3. **Guards:** You could enforce structural rules, such as "Error notes can only appear inside the Appendix".
   :::
