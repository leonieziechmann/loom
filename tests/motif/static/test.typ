// =============================================================================
// LOOM ENGINE: STATIC MOTIF INTEGRATION TEST
// =============================================================================
#import "/tests/test-wrapper.typ": *
#import "/tests/test-template.typ": *

#show: loom-test.with(
  title: [Static Motif Integration],
  description: [Validation of the `static` abstraction and its immunity to weave loop data.],
)

#test-case(
  "Structure & Defaults",
  tags: ("Unit", "Structure"),
  task: [Verify that static correctly maps to the underlying motif primitive.],
  abstract: [
    1. Check if the default key is applied.
    2. Verify that children are explicitly set to `none`.
    3. Ensure the `draw` function ignores all incoming arguments.
  ],
)[
  #let content = [Static Text]
  #let m = static(content)
  #let meta = m.fields().value

  // 1. Key Check
  #assert.eq(m.label, <loom-test>, message: "Default key should be <loom-test>")

  // 2. Child Check
  #assert.eq(meta.body, none, message: "Static motifs should have no children")

  // 3. Draw Immunity Check
  #let result = (meta.draw)(
    (state: "complex"),
    (data: 123),
    [View Data],
    [Original Body],
  )

  #assert.eq(
    result,
    content,
    message: "Static draw must return its own body, ignoring weave arguments.",
  )

  ✔  *Primitive Mapping*: Metadata verified, children set to none, and draw-call immunity confirmed.
]

#test-case(
  "Engine Traversal Opacity",
  tags: ("Integration", "Traversal", "Flow"),
  task: [Ensure motifs inside a static block are completely ignored by the engine's measure/draw phases.],
  abstract: [
    1. Place a panicking motif inside a static block; verify the engine skips it.
    2. Nest static and active motifs under a parent.
    3. Verify the parent's `children` array only contains the active motifs outside the static block.
  ],
)[
  #show: weave.with(max-passes: 1)

  // Phase 1: The Panic Test
  // If the engine's traversal algorithm enters this block, the test fails immediately.
  #static[
    #motif(
      measure: (..) => panic("Fatal: Engine traversed into a static block!"),
      none,
    )
  ]

  // Phase 2: The Isolation Test
  #let parent = motif(
    measure: (ctx, children) => {
      // We expect exactly 1 child to emit a signal. The others are walled off.
      assert.eq(
        children.len(),
        1,
        message: "Parent should only see 1 visible child (the one outside the static block).",
      )
      // Ensure we got the correct signal, proving the static ones were skipped.
      assert.eq(
        children.first().signal.motif-id,
        "dm-3",
        message: "Parent received the wrong child signal.",
      )
      return (none, [Measured Parent])
    },
    [
      #static[
        // These should be completely invisible to the parent's measure function.
        #data-motif("data", measure: (..) => (motif-id: "dm-1"))
        #data-motif("data", measure: (..) => (motif-id: "dm-2"))
      ]

      // This is the only motif the parent should 'see'.
      #data-motif("data", measure: (..) => (motif-id: "dm-3"))
    ],
  )

  #parent

  ✔  *Wall Integrity*: Static block was successfully skipped (no panic) and signal isolation is absolute.
]

#test-case(
  "Custom Key Preservation",
  tags: ("Config", "Key"),
  task: [Verify that user-provided keys are correctly passed to the primitive.],
  abstract: [Initialize with a custom label and check the internal metadata.],
)[
  #let m = static(key: <custom-label>, [Content])
  #assert.eq(
    m.label,
    <custom-label>,
    message: "Custom key was not preserved in static-motif.",
  )

  ✔  *Key Integrity*: Custom label successfully hoisted to the underlying motif primitive.
]

// =============================================================================
// FAILURE TESTS
// =============================================================================

#{
  assert-panic(
    () => { static(key: "not-a-label", [Content]) },
    message: "Expected: Panic (Key must be a label)",
  )
}
