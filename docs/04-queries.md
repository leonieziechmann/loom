# Queries & Aggregation

When a parent component receives data from its children in the `measure` phase, it often receives a mixed list of signals from various descendants. The `query` module provides a functional API to filter, search, and aggregate this data.

## 1. Searching & Filtering

These functions help you find specific child components within the `children-data` array.

### `query.select(children, kind)`

Returns a list of all immediate children matching the specific `kind`.

* **Use Case:** You have a list of mixed content, but you only care about the "task" elements.

```typ
#let tasks = query.select(children, "task")
```

### `query.find(children, kind)`

Finds the *first* immediate child of a specific kind. Returns `none` if not found.

* **Use Case:** Looking for a specific configuration node or metadata element.

```typ
#let meta = query.find(children, "metadata")
#if meta != none { ... }
```

### `query.collect(children, kind, depth: 10)`

Recursively traverses the tree to find all descendants of a specific kind, up to the specified depth.

* **Use Case:** Your "Project" root needs to find all "Tasks", even if they are nested inside "Phases" or "Groups".

```typ
// Flatten the entire tree and get all tasks
#let all-tasks = query.collect(children, "task")
```

### `query.where(children, predicate)`

Filters children using a custom function `frame => bool`.

* **Use Case:** Complex filtering logic.

```typ
// Find all tasks that cost more than 100
#let expensive = query.where(children, c => c.signal.cost > 100)
```

---

## 2. Aggregation

Once you have selected the relevant frames, you usually want to extract or calculate values from their signals.

### `query.sum-signals(children, key)`

Sum up a numeric field from the signals of the provided children.

* **Use Case:** Calculating totals (Price, Duration, Weight).

```typ
#let total-cost = query.sum-signals(tasks, "cost")
```

### `query.pluck(children, key)`

Extracts a specific field from the signal of each child, returning an array of values.

* **Use Case:** Getting a list of all names or IDs.

```typ
#let names = query.pluck(tasks, "name")
// -> ("Task A", "Task B", "Task C")
```

### `query.group-by(children, key)`

Groups children into a dictionary based on a value in their signal.

* **Use Case:** Grouping ingredients by category or tasks by status.

```typ
#let by-status = query.group-by(tasks, "status")
// -> (pending: (...), done: (...))
```

### `query.fold(children, reducer, base)`

The most flexible aggregation tool. Reduces the children's signals into a single value using a custom function.

```typ
#let summary = query.fold(tasks, (acc, signal) => {
  acc + signal.cost
}, 0)
```

---

## Example: The "Recipe" Pattern

Here is a complete example of how these functions work together in a `measure` block.

```typ
#(
  measure: (ctx, children) => {
    // 1. Filter: We only care about ingredients, ignore layout nodes
    let ingredients = query.collect(children, "ingredient")

    // 2. Aggregate: Calculate total cost
    let total-price = query.sum-signals(ingredients, "price")

    // 3. Group: Organize by category (Veg/Meat)
    let categories = query.group-by(ingredients, "category")

    // 4. Return the calculated data
    (
      (total: total-price),
      (categories: categories, total: total-price)
    )
  }
)

```
