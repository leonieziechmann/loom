// =============================================================================
// LOOM ENGINE: DATA MOTIF INTEGRATION TEST
// =============================================================================
#import "/tests/test-wrapper.typ": *
#import "/tests/test-template.typ": *

#show: loom-test.with(
  title: [Data Motif Integration],
  description: [Validation of leaf data injectors.],
)

#test-case(
  "Data Injection",
  tags: ("Integration", "Signal"),
  task: [Verify `data-motif` injects a named Frame into the signal stream.],
  abstract: [
    Use `data-motif(name: "config")`.
    Parent asserts received frame has `kind: "config"` and correct payload.
  ],
)[
  #show: weave.with(max-passes: 1)

  #let config-node = data-motif(
    "config",
    measure: ctx => (theme: "dark", level: 5),
  )

  #let system = motif(
    measure: (ctx, children) => {
      let frame = children.first()
      assert.eq(frame.kind, "config", message: "Frame kind is config")
      assert.eq(
        frame.signal.theme,
        "dark",
        message: "Payload theme is dark" + repr(frame.signal),
      )
      (none, [Config Loaded])
    },
    config-node,
  )

  #system
]

// Case: No Body
#{
  let m = data-motif("D", measure: _ => none)
  let meta = m.fields().value

  assert.eq(meta.body, none, message: "Body is none")
}

// Case: Signal Injection
#{
  let m = data-motif(
    "Injector",
    measure: ctx => (value: 42),
  )
  let meta = m.fields().value
  let ctx = (sys: (path: ()))

  let (frame, view) = (meta.measure)(ctx, none)

  assert.eq(frame.signal.value, 42, message: "Signal contains payload")
  assert.eq(frame.kind, "Injector", message: "Kind is set")
}

// Case: Arguments
#{
  let m = data-motif(
    "D",
    measure: ctx => {
      assert.eq(ctx, "ctx", message: "Received context")
    },
  )
  let meta = m.fields().value
  // Wrapper passes (ctx, children) but calls user func with (ctx)
  let _ = (meta.measure)("ctx", "ignored")
}

// Case: Bad Name
#assert-panic(
  () => { data-motif(name: 123, measure: _ => none) },
  message: "Expected: Panic",
)
