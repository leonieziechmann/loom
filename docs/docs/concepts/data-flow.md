---
sidebar_position: 2
---

# Data Flow

**The Vertical Highway**

In standard Typst, data is static. In Loom, data is constantly moving.
To build effective templates, you need to understand the "Vertical Highway": **Context flows down, Signals flow up.**

## The V-Model

The easiest way to visualize a Loom component is not as a box, but as a **"V" shape**.
Data travels down the left side, hits the bottom (where children live), and travels up the right side.

```text
      (Parent)
         |
    1. Scope (Down)  [ Context -> ]
         |
         v
    +---------+
    |  Child  |  <-- 2. Children Executed
    +---------+
         |
    3. Measure (Up)  [ <- Signals ]
         |
         v
    4. Draw (Out)    [ Content ]
```

### Direction 1: Down (Context)

- **Vehicle:** The Scope Function.
- **Payload:** Configuration, Theme, Counters, Flags.
- **Behavior:** **Inheritance.**
- Data injected here is visible to the component itself **and** all its descendants.
- Think of it like CSS: If you set `color: red` at the top, it cascades down until someone overrides it.

### Direction 2: Up (Signals)

- **Vehicle:** The Measure Function.
- **Payload:** Prices, Page Numbers, TOC Entries, Metadata.
- **Behavior:** **Bubbling.**
- Data emitted here is sent to the **Parent's** measure function.
- It is **not** visible to siblings.
- It is **not** visible to children.

---

## The "Missing" Direction: Lateral Flow

A common question is: _"How do I make Component A talk to Component B next to it?"_

```typ
#item("A") // I want to know B's width!
#item("B")
```

In Loom, **siblings cannot talk directly to each other** within the same pass.

- "A" finishes executing before "B" even starts.
- "B" cannot send data back in time to "A".

### The Solution: The "Up-and-Down" Maneuver

To share data between siblings, you must route it through a common ancestor.

1. **Pass 1 (Up):** Siblings emit signals (e.g., their widths) up to the Parent.
2. **Pass 2 (Down):** The Parent collects these signals, calculates the "max width," and injects it back down via Scope.
3. **Pass 2 (Stable):** Now both siblings can read `ctx.max-width`.

This is why Loom runs multiple passes. It needs time to route the traffic.

## Data Visibility Cheatsheet

| If data is defined in...    | It is visible to...                                |
| --------------------------- | -------------------------------------------------- |
| **Parent Scope**            | Parent (Measure/Draw), **Children**, Grandchildren |
| **Child Scope**             | Child (Measure/Draw), Grandchildren                |
| **Child Measure (Public)**  | **Parent** (Measure)                               |
| **Child Measure (Private)** | Child (Draw)                                       |
| **Sibling A**               | **Nobody** (horizontally)                          |
