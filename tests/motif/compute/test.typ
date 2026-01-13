// =============================================================================
// LOOM ENGINE: COMPUTE MOTIF INTEGRATION TEST
// =============================================================================
#import "/tests/test-wrapper.typ": *
#import "/tests/test-template.typ": *

#show: loom-test.with(
  title: [Compute Motif Integration],
  description: [Validation of calculation nodes that do not render views.],
)

#test-case(
  "Calculation & Suppression",
  tags: ("Integration", "Behavior"),
  task: [Verify `compute-motif` runs logic but suppresses default drawing.],
  abstract: [
    `compute-motif` returns a signal.
    We verify the parent gets the signal.
    We visually verify no content is output (though assert checks are hard for "no content").
  ],
)[
  #show: weave.with(max-passes: 1)

  #let calculator = compute-motif(
    name: "compute",
    measure: (ctx, _) => "secret-data",
    [This should NOT appear in final doc],
  )

  #let parent = motif(
    measure: (ctx, children) => {
      let val = children.first().signal
      assert.eq(val, "secret-data", message: "Computation received")
      (none, [Calculation Verified])
    },
    draw: (.., view, body) => {
      // We purposefully ignore `body` here to clean up test output,
      // but `compute-motif` usually returns `none` for view anyway.
      view
    },
    calculator,
  )

  #parent
]

// Case: Signature Mapping
#{
  let m = compute-motif(
    measure: (ctx, data) => "only-public",
    [],
  )
  let meta = m.fields().value
  let (pub, view) = (meta.measure)(none, none)

  assert.eq(pub, "only-public", message: "Public data mapped")
  assert.eq(view, none, message: "View is implicitly none")
}

// Case: Unmanaged Mode
#{
  let m = compute-motif([])
  let meta = m.fields().value
  let ctx = (sys: (path: ("A",)))

  let new-ctx = (meta.scope)(ctx)
  assert.eq(new-ctx.sys.path, ("A",), message: "Path unchanged")
}

// Case: Managed Mode,
#{
  let m = compute-motif(name: "Comp", [])
  let meta = m.fields().value
  let ctx = (sys: (path: (("A", 0),)))

  let new-ctx = (meta.scope)(ctx)
  assert.eq(
    new-ctx.sys.path,
    (("A", 0), ("Comp", 0)),
    message: "Path not appended" + repr(new-ctx.sys.path),
  )
}
