---
sidebar_position: 5
---

# Pattern: The Aggregator

**Collecting Data with Signals**

In standard Typst, data usually flows one way: down. This makes it frustratingly difficult to build things like a "Total Price" at the top of an invoice, or a "Table of Contents" that reacts to dynamic content. You often have to define the data _outside_ your content, separating the "source of truth" from the "display."

Loom solves this with the **Aggregator Pattern**.

## The Problem: Separation of Data and View

Imagine you are writing a receipt. In standard Typst, if you want a list of items _and_ a total sum, you cannot just write the items. You have to create a data structure first.

**The Typst Way (The "Old" Way):**

```typ
// 1. Define Data separately
let items = (
  (name: "Apple", price: 1.2),
  (name: "Banana", price: 0.8),
)

// 2. Calculate Total separately
let total = items.map(i => i.price).sum()

// 3. Render Loop
#table(..items.map(i => [ #i.name: #i.price ]))
#strong[Total: #total]
```

This works for simple lists, but it breaks down when your document gets complex. What if "Apple" is inside a conditional? What if "Banana" is imported from another file? You lose the ability to write declarative markup.

## The Solution: Signals

In Loom, components can emit **Signals** (data packets) that bubble up to their parent. Because Loom runs the children's `measure` phase _before_ the parent's `measure` phase, the parent can aggregate this data and react to it immediately in the **same pass**.

This restores the declarative style. You write the items where they belong, and the parent figures out the total.

### Scenario 1: The Visual List (Content Aggregation)

**Goal:** The children should render themselves normally (like a list), and the parent just appends a summary line.

We use `content-motif` for the children because they have a visual presence.

```typ
// CHILD: Renders itself AND emits a signal
#let item(name, price) = content-motif(
  measure: (ctx, body) => (price: price), // Emit price signal
  draw: (ctx, body) => {
    block(width: 100%, inset: 2pt)[#name #h(1fr) #price]
  }
)

// PARENT: Renders children THEN adds total
#let receipt(body) = motif(
  measure: (ctx, children-signals) => {
    // 1. Aggregate immediately (Same-Pass)
    let total = children-signals.map(s => s.price).sum()

    // 2. Pass total to the View
    ( (total: total), (total: total) )
  },
  draw: (ctx, public, view, body) => {
    block(stroke: 1pt, inset: 1em)[
      #align(center)[*Receipt*]
      #line(length: 100%)
      #body // Render the children normally
      #line(length: 100%)
      #align(right)[*Total: #view.total*]
    ]
  },
  body
)
```

#### Usage

```typ
// USAGE: Declarative and clean
#receipt[
  #item("Apples", 1.50)
  #item("Bananas", 2.00)
]
```

### Scenario 2: The Data Builder (Data Aggregation)

**Goal:** The children should be **invisible** data points. The parent collects them and builds a completely new structure (like a Table or Chart).

We use `data-motif` for the children. This is a shorthand that skips the `draw` phase entirely, which is faster and cleaner.

```typ
// CHILD: Pure Data (No visual output)
#let entry(name, price) = data-motif(
  measure: (ctx) => (name: name, price: price)
)

// PARENT: Builds the view entirely from signals
#let price-table(body) = motif(
  measure: (ctx, children-signals) => {
    // We pass the raw signals to the view to build the table
    ( (count: children-signals.len()), children-signals )
  },
  draw: (ctx, public, signals, body) => {
    // 'body' is ignored/empty because children are data-motifs!
    table(
      columns: 2,
      [*Item*], [*Price*],
      ..signals.map(s => (s.name, str(s.price))).flatten(),
      [*Total*], [*#signals.map(s => s.price).sum()*]
    )
  },
  body
)

```

#### Usage

```typ
// USAGE
#price-table[
  #entry("Server A", 500) // Invisible
  #entry("Server B", 1200)
]
```

## Pro Tip: The Query Module

When your aggregation logic gets complex (e.g., filtering specific items or searching deeply nested trees), manual array mapping can be tedious.

Loom provides the `loom.query` module to make this easier. It works similarly to database queries for your document tree.

```typ
// Inside Parent measure(ctx, children-signals)

// 1. Summing a specific field
let total = loom.query.sum-signals(children-signals, "price")

// 2. Finding specific children
let apples = loom.query.where(children-signals, s => s.name == "Apple")

// 3. Deep Collection (Recursive)
// Useful if your items are nested inside other containers (like groups or divs)
let all-items = loom.query.collect(children-signals, "price")
```
