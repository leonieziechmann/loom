# Debugging & Troubleshooting

**Tools for When Things Go Wrong**

Because Loom runs logic invisibly in the background, it can be hard to see why a calculation is off.
Loom provides specific tools to expose this hidden data.

## 1. The Debug Flag

The primary way to inspect your application is to enable the debug mode in the engine.

```typ
#show: weave.with(debug: true)
```

**How it works:**
Setting `debug: true` injects a flag into the global **Context**.
When components detect this flag, they alter their behavior to be more verbose. specifically, they attach their **Children's Data** to the signal frame.

This allows you to inspect exactly what data a parent is receiving from its children, which is usually where aggregation logic fails.

## 2. Visual Inspection (`debug-motif`)

Loom ships with a pre-built component designed specifically for visual debugging: `prebuild-motif.debug`.

It is a "Transparent Wrapper". It does not change the layout or logic of your document, but it renders an overlay showing the data flowing through that specific part of the tree.

**Usage:**
Wrap any part of your code with it to see what's happening inside.

```typ
#import "loom-wrapper": prebuild-motif

// Wrap your suspicious component
#(prebuild-motif.debug)[
  #my-complex-component(..)
]
```

This will print the signals and context data associated with that node directly into the document output, allowing you to verify:

- "Did the parent receive the 'price' signal?"
- "Is the 'theme' context variable correct here?"

## 3. Common Errors & Fixes

Loom is built defensively. It tries to catch errors early with clear messages, but you can prevent them entirely by using the right tools.

### The #1 Error: Missing Data

The most frequent crash happens when you try to read a key that doesn't exist.

- _Scenario:_ You try to sum `child.price`, but one child is a text node and has no `price`.
- _Scenario:_ You try to read `ctx.theme`, but the Provider is missing.

**The Fix: Use Loom Utilities**
Never access raw dictionary keys manually if you are unsure. Use the standard modules which handle missing data gracefully:

- **For Signals:** Use `loom.query` or `loom.collection`.

```typ
// ❌ Risky
let total = children.map(c => c.price).sum()

// ✅ Safe (Ignores children without 'price')
let total = loom.query.sum-signals(children, "price")
```

- **For Context:** Use `loom.mutator` or defaults.

```typ
// ❌ Risky
let color = ctx.theme.color

// ✅ Safe
let color = ctx.at("theme", default: (:)).at("color", default: black)
```

## 4. Best Practices: "Build & Check"

Because errors in a reactive system can propagate (Pass 1 error causes Pass 2 crash), debugging a large document is hard.

**The Golden Rule:**
Implement your components iteratively.

1. Write the `measure` function.
2. Immediately wrap it in `#prebuild-motif.debug[...]` to verify the signals are correct.
3. Only then write the aggregation logic in the parent.

If you wait until the entire 50-page document is written to test your logic, you will have a hard time finding the broken link.
