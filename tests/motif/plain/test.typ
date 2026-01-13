// =============================================================================
// LOOM ENGINE: PLAIN MOTIF INTEGRATION TEST
// =============================================================================
#import "/tests/test-wrapper.typ": *
#import "/tests/test-template.typ": *

#show: loom-test.with(
  title: [Plain Motif Integration],
  description: [Validation of the raw `motif` primitive using the real engine.],
)

#test-case(
  "Lifecycle & Data Flow",
  tags: ("Integration", "Flow"),
  task: [Verify that scope, measure, and draw phases execute in order and pass data.],
  abstract: [
    1. Scope sets `flag: true`.
    2. Child sees `flag` and emits `signal: 1`.
    3. Parent measure sees `signal: 1` and returns `view: Check`.
    4. Parent draw renders `view`.
  ],
)[
  #show: weave.with(max-passes: 1)

  #let child = motif(
    measure: (ctx, _) => {
      // 1. Verify Scope
      assert.eq(
        ctx.at("flag", default: false),
        true,
        message: "Child sees flag",
      )
      // 2. Emit Signal
      return (
        (
          loom.frame.new(
            kind: "child",
            key: none,
            path: (),
            signal: 1,
          ),
        )
          * 2
      )
    },
    none,
  )

  #let parent = motif(
    scope: ctx => ctx + (flag: true),
    measure: (ctx, children) => {
      // 3. Verify Signal Aggregation
      let child-val = children.first().signal
      assert.eq(child-val, 1, message: "Parent received signal 1")

      // Pass assertion result to view
      return (none, [Signal OK])
    },
    draw: (ctx, pub, view, body) => {
      // 4. Verify View Reception
      [#view | Body: #body]
    },
    child,
  )

  #parent
]

#test-case(
  "Minimal Configuration",
  tags: ("Config", "Defaults"),
  task: [Call `motif` with no functions and verify defaults.],
  abstract: [Expect identity scope, no-op measure, and passthrough draw.],
)[
  #let m = motif([Content])
  #let meta = m.fields().value

  #assert.eq(meta.type, "component", message: "Type is component")
  #assert.eq((meta.scope)(1), 1, message: "Default scope is identity")
  #assert.eq(
    (meta.measure)((:), none),
    (none, none),
    message: "Default measure is no-op",
  )
  #assert.eq(
    (meta.draw)(1, 2, 3, [Body]),
    [Body],
    message: "Default draw is passthrough",
  )
]

// Case: Full Configuration
#{
  let my-scope = ctx => ctx
  let my-measure = (ctx, children) => ("pub", "view")
  let my-draw = (ctx, pub, view, body) => [Draw]

  let m = motif(
    key: <test>,
    scope: my-scope,
    measure: my-measure,
    draw: my-draw,
    [],
  )
  let meta = m.fields().value

  assert.eq(meta.scope, my-scope, message: "Scope function preserved")
  assert.eq(
    (meta.measure)((:), none),
    my-measure((:), none),
    message: "Measure function preserved",
  )
  assert.eq(
    (meta.draw)(..(none,) * 4),
    my-draw(..(none,) * 4),
    message: "Draw function preserved",
  )
}

// Case: Measure Passthrough
#{
  let m = motif(
    measure: (ctx, children) => {
      assert.eq(ctx, "ctx", message: "Received context")
      assert.eq(children, (1, 2), message: "Received children data")
      return ("public", "view")
    },
    [],
  )
  let meta = m.fields().value
  let result = (meta.measure)("ctx", (1, 2))

  assert.eq(result, ("public", "view"), message: "Returned correct tuple")
}

// Case: Draw Passthrough
#{
  let m = motif(
    draw: (ctx, pub, view, body) => {
      assert.eq(pub, "public", message: "Received public data")
      assert.eq(view, "view", message: "Received view data")
      return [Wrapped: #body]
    },
    [Original],
  )
  let meta = m.fields().value
  let result = (meta.draw)("ctx", "public", "view", [Original])

  assert.eq(result, [Wrapped: Original], message: "Rendered content matches")
}

// =============================================================================
// FAILURE TESTS (Uncomment to verify panic)
// =============================================================================

// Case: Bad Key
#{
  assert-panic(
    () => { motif(key: "string", []) },
    message: "Expected: Panic (Type Error)",
  )
}

// Case: Bad Measure Return
#{
  let m = motif(measure: (..) => "bad", [])
  assert-panic(
    () => { (m.fields().value.measure)(none, none) },
    message: "Expected: Panic (Type Error)",
  )
}

// Case: Bad Draw Return
#{
  let m = motif(draw: (..) => "bad", [])
  assert-panic(
    () => { (m.children.first().value.draw)(none, none, none, []) },
    message: "Expected: Panic (Type Error)",
  )
}
