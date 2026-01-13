// =============================================================================
// LOOM ENGINE: MANAGED MOTIF TEST
// =============================================================================
// Target: Verify path management, frame creation, and integration.
// =============================================================================
#import "/tests/test-wrapper.typ": *
#import "/tests/test-template.typ": *

#show: loom-test.with(
  title: [Managed Motif Primitive],
  description: [Validation of automatic path management and frame wrapping.],
)

// =============================================================================
// SUCCESS TESTS
// =============================================================================

#test-case(
  "Path Integrity (Nested)",
  tags: ("Integration", "Path"),
  task: [Verify `sys.path` correctness in a deep nesting.],
  abstract: [
    Structure: A > B > C.
    Leaf C asserts that its path is `("A", "B", "C")`.
  ],
)[
  #show: weave.with(max-passes: 1)

  #let leaf-checker = motif(
    measure: (ctx, _) => {
      let current-path = ctx.sys.path
      assert.eq(
        current-path,
        (("A", 3), ("B", 1), ("C", 1)),
        message: "Path is A3/B1/C1",
      )
      (none, none)
    },
    [],
  )

  #managed-motif("A")[
    #managed-motif("B")[
      #managed-motif("C")[
        #leaf-checker
      ]
    ]
  ]
]

#test-case(
  "Frame Metadata",
  tags: ("Integration", "Frame"),
  task: [Verify that `managed-motif` correctly wraps signals in a Frame.],
  abstract: [
    Child returns raw signal `42`.
    Parent asserts it receives a `frame` where `frame.signal == 42`.
  ],
)[
  #show: weave.with(max-passes: 1)

  #let child = managed-motif(
    "child-node",
    measure: (ctx, _) => (42, none), // User returns raw data
    [],
  )

  #let parent = motif(
    measure: (ctx, children) => {
      let frame = children.first()
      // The engine/managed-motif should have wrapped it
      assert.eq(
        type(frame),
        dictionary,
        message: "Received a dictionary (Frame)",
      )
      assert.eq(frame.kind, "child-node", message: "Frame kind is correct")
      assert.eq(frame.signal, 42, message: "Frame signal is 42")
      (none, none)
    },
    child,
  )

  #parent
]

// Case: "Path Growth"
#{
  let check-path(expected) = motif(
    measure: (ctx, ..) => {
      let p = ctx.at("sys", default: (:)).at("path", default: ())
      assert-eq(p, expected, message: "Path is " + repr(expected))
      return (none, none)
    },
    body: [],
  )

  // We mock the weave loop by manually invoking scope chain if needed,
  // but simpler is to trust the scope function construction:
  let outer = managed-motif("A", []).fields().value
  let ctx-1 = (outer.scope)((sys: (path: ())))

  assert.eq(ctx-1.sys.path, (("A", 0),), message: "Path did not grew to ('A')")

  let inner = managed-motif("B", []).fields().value
  let ctx-2 = (inner.scope)(ctx-1)

  assert.eq(
    ctx-2.sys.path,
    (("A", 0), ("B", 0)),
    message: "Path did not grew to ('A', 'B')",
  )
}

// Case: Frame Structure
#{
  let m = managed-motif(
    "TestNode",
    key: <my-node>,
    measure: (..) => ("my-signal", none),
    [],
  )
  let meta = m.fields().value

  // Mock context with path
  let ctx = (sys: (path: (("Root", 0), ("TestNode", 0))))

  let (frame, view) = (meta.measure)(ctx, ())

  assert.eq(frame.kind, "TestNode", message: "Kind matches name")
  assert.eq(
    frame.key,
    ("TestNode", 0),
    message: "Key matches last path segment",
  )
  assert.eq(
    frame.path,
    (("Root", 0), ("TestNode", 0)),
    message: "Path stored in frame",
  )
  assert.eq(frame.signal, "my-signal", message: "Signal wrapped correctly")
}

// Case: Scope 'None'
#{
  let m = managed-motif("Node", scope: none, [])
  let meta = m.fields().value

  let ctx = (sys: (path: ()))
  let new-ctx = (meta.scope)(ctx)

  assert.eq(
    new-ctx.sys.path,
    (("Node", 0),),
    message: "Path appended despite scope=none",
  )
}

// =============================================================================
// FAILURE TESTS
// =============================================================================

// Case: Bad Name
#assert-panic(
  () => { managed-motif(123, body: []) },
  message: "Expected: Panic (Type Error)",
)

