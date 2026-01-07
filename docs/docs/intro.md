---
slug: /
sidebar_position: 1
---

# Introduction

**Reactive Documents for Typst**

Loom is a meta-engine that brings **bidirectional data flow**, **global state management**, and **component reactivity** to Typst.

It transforms Typst from a linear typesetting system into a multi-pass application runtime, allowing you to build complex, data-driven templates that are impossible in standard Typst.

## Why Loom?

Typst is an incredible layout engine, but its execution model is strictly **linear** (top-to-bottom). This creates a fundamental limitation for complex logic: **A parent component cannot react to data produced by its children.**

### The "Linear Wall"

Imagine you are building a **Project Dashboard**. You want to list tasks and show a progress bar at the top.

- **In Standard Typst:** You must calculate the progress _before_ you draw the page. This forces you to separate your data (variables) from your view (content), breaking the nice, declarative structure.
- **In Loom:** You simply write your tasks. Each task calculates its own status and "signals" it up to the parent. The parent aggregates these signals and draws the progress bar automatically.

## How it Works

Loom wraps your document in a **Weave Loop**. It runs your code multiple times to resolve dependencies, effectively adding "Time Travel" to Typst.

1.  **Discovery:** Loom runs your document to find all components and collect their signals (e.g., "I am Task A, and I am complete").
2.  **Reaction:** Loom runs again, injecting the collected data back into the top. Now the parent knows the total status _before_ it draws.
3.  **Convergence:** The loop repeats until the data stabilizes.

## Key Features

- **⚡ Bidirectional Data Flow:**
  - **Scope (Down):** Pass configuration (Themes, Chapter Numbers) down to deep descendants without parameter drilling.
  - **Signals (Up):** Components emit data (Prices, Metadata) that bubbles up to be aggregated by parents.
- **🔄 Convergence Engine:** Automatically resolves dependencies (e.g., A needs B, B needs C) by running until stable.
- **🛡️ Architectural Guards:** Enforce structure (e.g., "This `Slide` must be inside a `Presentation`") with clear error messages.
- **📦 Component Model:** Build self-contained "Motifs" that manage their own state and logic.

## When to use Loom?

Loom is designed for **Structured Documents** where components need to talk to each other.

| Use Loom for...                                          | Do NOT use Loom for...                       |
| :------------------------------------------------------- | :------------------------------------------- |
| **Dashboards & Reports** (Aggregating totals, charts)    | **Simple Essays** (Standard Typst is fine)   |
| **Complex Templates** (RPGs, Invoices, CVs)              | **Particle Simulations** (Too much overhead) |
| **Libraries** (Providing robust, crash-proof components) | **One-off scripts**                          |

## Getting Started

Ready to change how you think about Typst?

- Check out the **[Installation & Setup](./getting-started/installation)** guide.
- Understand the **[Mental Model](./concepts/mental-model)** of the weave loop.
- Learn the **[Design Patterns](./concepts/pattern-provider)** that make Loom powerful.
