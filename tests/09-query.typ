#import "test-template.typ": *
#import "../src/lib/query.typ": collect, find, group-by, select, sum-signals
#import "../src/data/frame.typ" as frame

#show: doc => loom-test(
  title: "Query Module Tests",
  description: "Unit tests for tree traversal and aggregation.",
  abstract: [
    Verifies `collect` recursion logic and aggregation helpers
    on a mock component tree constructed with valid frames.
  ],
  doc,
)

// We construct the tree using frame.new() to satisfy strict is-frame checks in collect()
#let mock-tree = (
  frame.new(
    kind: "section",
    signal: (
      children: (
        frame.new(kind: "item", signal: (cost: 10, cat: "A")),
        frame.new(kind: "item", signal: (cost: 20, cat: "B")),
        frame.new(
          kind: "group",
          signal: (
            children: (
              frame.new(kind: "item", signal: (cost: 5, cat: "A"))
            ),
          ),
        ),
      ),
    ),
  ),
)

#test-case(
  "Traversal (Collect)",
  tags: ("Query", "Traversal"),
  task: [Verify recursive collection of nodes.],
  abstract: [Checks if `collect` finds nested items in a tree of Frames.],
  {
    // Should find 3 items total (2 at top, 1 nested)
    let items = collect(mock-tree, kind: "item")
    assert-eq(items.len(), 3, msg: "Found all nested items")

    let groups = collect(mock-tree, kind: "group")
    assert-eq(groups.len(), 1, msg: "Found group container")
  },
)

#test-case(
  "Search (Select & Find)",
  tags: ("Query", "Search"),
  task: [Verify shallow search helpers.],
  abstract: [Tests `select` (filter) and `find` (first match).],
  {
    // Mock a flat list of frames for shallow search
    let flat = (
      frame.new(kind: "a", signal: 1),
      frame.new(kind: "b", signal: 2),
      frame.new(kind: "a", signal: 3),
    )

    let selected = select(flat, "a")
    assert-eq(selected.len(), 2, msg: "Select found all 'a' frames")

    let found = find(flat, "b")
    assert-eq(found.signal, 2, msg: "Find located 'b' frame")

    let missing = find(flat, "z")
    assert-eq(missing, none, msg: "Find returned none for missing")
  },
)

#test-case(
  "Aggregation",
  tags: ("Query", "Data"),
  task: [Verify `sum-signals` and `group-by`.],
  abstract: [Tests calculating totals and grouping data from tree.],
  {
    let all-items = collect(mock-tree, kind: "item")

    // Sum: 10 + 20 + 5 = 35
    let total = sum-signals(all-items, "cost")
    assert-eq(total, 35, msg: "Summed cost correctly")

    // Group By Category
    let groups = group-by(all-items, "cat")
    assert-eq(groups.A.len(), 2, msg: "Group A has 2 items")
    assert-eq(groups.B.len(), 1, msg: "Group B has 1 item")
  },
)
