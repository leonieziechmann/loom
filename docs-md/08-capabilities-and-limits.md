# Capabilities & Limitations

Loom is a specialized tool. It is not designed to replace standard Typst markup for every document, but rather to solve specific architectural challenges that arise in complex, data-driven projects.

## When to use Loom?

Loom shines in scenarios where linear top-down layouting is insufficient. If you find yourself needing "global variables" that change based on content, or if parents need to know details about their children _before_ rendering, Loom is the right choice.

### 1. Complex Aggregation (The "Shopping List" Problem)

**Scenario:** You have a document with many scattered data points (e.g., ingredients in recipes, line items in invoices) and you need to generate a summary at the beginning or end (e.g., a shopping list, a total sum).
**Loom Solution:** Use signals to send data from the leaves (ingredients) to the root. The root aggregates them and injects the result back into the context.

- _Example:_ [Cookbook Showcase]

### 2. Inter-Component Dependencies (The "RPG" Problem)

**Scenario:** Component A affects Component B, but they are in different parts of the document.
**Loom Solution:** Loom's multi-pass system allows changes to propagate. A "Buff" component can modify a value in the global context, which a "Stat" component reads in the next pass to update its display.

- _Example:_ [Character Sheet Showcase]

### 3. Dynamic Structural Logic

**Scenario:** You need to number or label items based on their actual usage or position, in ways that standard counters cannot handle (e.g., "Page 3 of Section B").
**Loom Solution:** Managed Motifs track their path and identity, allowing for complex cross-referencing logic.

---

## When NOT to use Loom?

- **Simple Documents:** If standard Typst functions (`#let`, `#show`, counters) can solve your problem, use them. Loom introduces overhead.
- **Massive Data Visualization:** Do not use Loom to render thousands of individual data points (like a scatter plot). Use packages like `cetz` or `plotst` for that. Loom is for document structure, not pixel-level control.

---

## Architectural Constraints & Limitations

Loom is a powerful meta-engine, but it operates within the boundaries of the Typst runtime. To ensure stability and predictable behavior, be aware of the following constraints:

### 1. Vertical-Only Communication (Sibling Latency)

Data in Loom flows vertically: **Child → Parent → Context**.

- **Constraint:** Sibling components (neighbors) cannot exchange data within the _same_ render pass.
- **Workaround:** To react to a sibling's state (e.g., "match my width to the element on the left"), the data must travel up to a common ancestor and be injected back down in a **subsequent pass**. This requires increasing `max-passes` (e.g., to 3).

### 2. Maximum Nesting Depth (~50 Levels)

- **Constraint:** The core `intertwine` traversal is recursive. Due to Typst's internal stack limits, nesting Loom components deeper than approximately 50 levels may trigger a runtime panic.
- **Best Practice:** Loom is designed for document structure (Sections > Components > Atoms), not for fractal generation or extremely deep recursion.

### 3. Opaque Named Fields

- **Constraint:** Loom only "intertwines" (processes) the primary flow content (usually `body` or `children`). Components placed inside named arguments—such as `figure(caption: ...)` or `table(header: ...)`—are treated as **atomic**.
- **Result:** A Loom component inside a `caption` will render visually, but it cannot participate in the measure loop, receive context, or emit signals.

### 4. Show Rule Invisibility

- **Constraint:** Loom operates on the Abstract Syntax Tree (AST) _before_ Typst executes standard `#show` rules.
- **Result:** If you use a show rule to transform raw content into a Loom component (e.g., `show "text": name => loom-component(name)`), the engine will not "see" that component during the measure phase. Loom components must be explicitly present in the source code.

### 5. Performance Overhead

- **Constraint:** Since Typst dictionaries are immutable, every context mutation (Scope injection) creates a copy of the state object.
- **Impact:** Compilation time scales linearly with component count and effectively multiplies by the number of passes. Loom is built for document management, not for high-frequency node generation.
