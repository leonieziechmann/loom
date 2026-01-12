---
sidebar_position: 3
---

# Core Concepts

**Thinking in Loom**

Loom is more than just a library; it is a **Meta-Engine** that changes how you architect Typst documents.

Standard Typst code is linear: it executes from top to bottom.
Loom code is **Cyclical**: it executes in loops (passes) to resolve dependencies that linear code cannot handle (such as calculating the total number of quotes before rendering the first page).

## The Big Picture

To master Loom, you need to understand three key pillars:

1.  **[The Mental Model](./concepts/mental-model)**
    How Loom treats your document as a tree of "Smart Components" rather than just a stream of text. Learn about the **Measure** and **Draw** phases.

2.  **[Data Flow](./concepts/data-flow)**
    How information moves through the system.
    - **Context (Down):** Configuration, Theme, State.
    - **Signals (Up):** Data, Metadata, Aggregations.

## Summary of Terms

| Term        | Definition                                                                |
| :---------- | :------------------------------------------------------------------------ |
| **Motif**   | A reactive component. The fundamental building block of a Loom document.  |
| **Weave**   | The engine loop that runs your document multiple times to stabilize data. |
| **Signal**  | A data packet emitted by a child component to its parent.                 |
| **Context** | The immutable environment passed down from parent to children.            |
| **Pass**    | A single execution of the document logic. Loom typically runs 2-3 passes. |

## Where to start?

If you are new to reactive programming, start with **[The Mental Model](./concepts/mental-model)**.
If you understand the theory and want to build, jump to the **[Showcase](./showcase/recipe-book)**.
