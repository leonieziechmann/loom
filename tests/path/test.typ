#import "/src/public/path.typ"

// Case 1: Default path behavior
#{
  let ctx = (
    sys: (path: (("root", 0), ("container", 0), ("box", 0), ("text", 0))),
  )

  // 1. Current & Parent
  assert.eq(
    path.current(ctx),
    ("text", 0),
    message: "Current resolves to 'text'",
  )
  assert.eq(
    path.current-kind(ctx),
    "text",
    message: "Current resolves to 'text'",
  )
  assert.eq(
    path.parent(ctx),
    ("box", 0),
    message: "Parent resolves to 'box'",
  )
  assert.eq(
    path.parent-kind(ctx),
    "box",
    message: "Parent resolves to 'box'",
  )

  // 2. Contains
  assert(
    path.contains(ctx, "root"),
    message: "Context contains 'root'",
  )
  assert(
    path.contains(ctx, "text"),
    message: "Context contains self (default behavior)",
  )
  // Note: Your path.contains impl: `path.pop()` if include-current is false.
  assert.eq(
    path.contains(ctx, "text", include-current: false),
    false,
    message: "Context excludes self when requested",
  )

  // 3. Parent-Is (Immediate Parent)
  assert(
    path.parent-is(ctx, "box"),
    message: "Immediate parent identified as 'box'",
  )
  assert.eq(
    path.parent-is(ctx, "container"),
    false,
    message: "Grandparent 'container' is not immediate parent",
  )

  // 4. Depth
  assert.eq(
    path.depth(ctx),
    4,
    message: "Path depth calculated incorrectly",
  )
}

// Case 2: Empty & Edge Case Paths
#{
  let empty-ctx = (:)
  assert.eq(
    path.depth(empty-ctx),
    0,
    message: "Empty context has depth 0",
  )
  assert.eq(
    path.parent(empty-ctx),
    (none, none),
    message: "Empty context parent is none",
  )
  assert.eq(
    path.current(empty-ctx),
    none,
    message: "Empty context current is none",
  )

  let root-ctx = (sys: (path: ("root",)))
  assert.eq(
    path.parent(root-ctx),
    (none, none),
    message: "Root-only context has no parent",
  )
}
