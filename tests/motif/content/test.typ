// =============================================================================
// LOOM ENGINE: CONTENT MOTIF INTEGRATION TEST
// =============================================================================
#import "/tests/test-wrapper.typ": *
#import "/tests/test-template.typ": *

#show: loom-test.with(
  title: [Content Motif Integration],
  description: [Validation of visual wrappers and signal propagation.],
)

#test-case(
  "Signal Propagation (Bubbling)",
  tags: ("Integration", "Flow"),
  task: [Verify `content-motif` automatically collects and bubbles up child signals.],
  abstract: [
    Structure: Root > ContentWrapper > DataNode.
    DataNode emits "Data".
    ContentWrapper should automatically emit `("Data",)` (list of children).
    Root asserts it sees the list.
  ],
)[
  #show: weave.with(max-passes: 1)

  #let data-node = data-motif("data-node", measure: (..) => "Data")

  // Content motif wraps data-node. It has no measure logic of its own,
  // so it should return its children's signals as its own signal.
  #let wrapper = content-motif(data-node)

  #let root = motif(
    measure: (ctx, children) => {
      let wrapper-signal = children.first().signal
      // wrapper-signal should be a list of its children's signals
      assert.eq(wrapper-signal, "Data", message: "Wrapper propagated Data")
      (none, [Propagation OK])
    },
    draw: (_, _, view, body) => {
      view
      parbreak()
      body
    },
    wrapper,
  )

  #root
]

#test-case(
  "Rendering Modification",
  tags: ("Integration", "Render"),
  task: [Verify `content-motif` can modify the rendering of its children.],
  abstract: [
    Wrapper puts children in a box with a stroke.
  ],
)[
  #show: weave.with(max-passes: 1)

  #let wrapper = content-motif.with(
    draw: (ctx, body) => box(stroke: 1pt + red, inset: 5pt, body),
  )

  #wrapper[I am inside a red box]
]


// Case: Signal Propagation
#{
  let m = content-motif(body: [])
  let meta = m.fields().value

  let children-signals = (1, 2, 3)
  let (pub, view) = (meta.measure)(none, children-signals)

  assert.eq(pub, children-signals, message: "Signals propagated")
  assert.eq(view, none, message: "View is none (handled by draw)")
}

// Case: Draw Execution
#{
  let m = content-motif(
    draw: (ctx, body) => [Styled: #body],
    [Text],
  )
  let meta = m.fields().value

  let result = (meta.draw)(none, none, none, [Text])
  assert.eq(result, [Styled: Text], message: "Draw applied styling")
}

// Case: Bad Draw Return
#{
  let m = content-motif(draw: (..) => "bad")
  assert-panic(
    () => { (m.children.first().value.draw)(none, none) },
    message: "Expected Panic",
  )
}
