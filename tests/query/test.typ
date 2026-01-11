#import "/src/lib/query.typ": collect, find, group-by, select, sum-signals
#import "/src/data/frame.typ" as frame

// Global Setup: Mock Tree
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

// Test: Traversal (Collect)
#{
  // Should find 3 items total (2 at top, 1 nested)
  let items = collect(mock-tree, kind: "item")
  assert.eq(items.len(), 3, message: "Found all nested items")

  let groups = collect(mock-tree, kind: "group")
  assert.eq(groups.len(), 1, message: "Found group container")
}

// Test: Search (Select & Find)
#{
  // Mock a flat list of frames for shallow search
  let flat = (
    frame.new(kind: "a", signal: 1),
    frame.new(kind: "b", signal: 2),
    frame.new(kind: "a", signal: 3),
  )

  let selected = select(flat, "a")
  assert.eq(selected.len(), 2, message: "Select found all 'a' frames")

  let found = find(flat, "b")
  assert.eq(found.signal, 2, message: "Find located 'b' frame")

  let missing = find(flat, "z")
  assert.eq(missing, none, message: "Find returned none for missing")
}

// Test: Aggregation
#{
  let all-items = collect(mock-tree, kind: "item")

  // Sum: 10 + 20 + 5 = 35
  let total = sum-signals(all-items, "cost")
  assert.eq(total, 35, message: "Summed cost correctly")

  // Group By Category
  let groups = group-by(all-items, "cat")
  assert.eq(groups.A.len(), 2, message: "Group A has 2 items")
  assert.eq(groups.B.len(), 1, message: "Group B has 1 item")
}
