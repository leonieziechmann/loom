// =============================================================================
// LOOM ENGINE: MOTIF INTEGRATION TEST
// =============================================================================
// Author: Leonie
// Target: Motif Lifecycle & Data Flow
// =============================================================================
#import "/tests/test-wrapper.typ": *
#import "/tests/test-template.typ": *

#show: loom-test.with(
  title: [Motif Integration Suite],
  description: [Validation of Lifecycle, Scoping, and Signals],
  abstract: [
    This suite verifies the interaction between the engine and the motifs.
    It validates that context updates (`scope`), data aggregation (`measure`),
    and rendering (`draw`) interlock correctly.
  ],
)

// =============================================================================
// SECTION 1: CONTEXT & SCOPE FLOW
// =============================================================================
= Context Propagation

We test whether data set within the `scope` of a parent motif is correctly
propagated to its children.

#test-case(
  "Scope Inheritance",
  tags: ("Scope", "Context"),
  task: [Assert that variables set in parent scope are visible in child.],
  abstract: [
    Parent sets `flag: true`. Child asserts `ctx.flag == true`.
  ],
)[
  #show: weave.with()

  #let parent = apply.with(test-flag: 12345)

  #let child = motif(
    measure: (ctx, _) => {
      let check1 = assert-eq(
        ctx.at("test-flag", default: none),
        12345,
        msg: "Child sees parent scope",
      )
      return (frame.new(signal: ctx), (check1,))
    },
    draw: (.., view, body) => [#view.join(parbreak()) #parbreak() #body],
    none,
  )

  // 2. Execution
  #parent[#child]
]

#test-case(
  "Scope Isolation",
  tags: ("Scope", "Context"),
  task: [Assert that sibling scopes do not leak into each other.],
  abstract: [
    Sibling A sets `A: true`. Sibling B must NOT see `A`.
  ],
)[
  #show: weave.with()

  #let setter(key, val) = motif(scope: ctx => ctx + ((key): val), none)
  #let checker(key, should-exist) = motif(
    measure: (ctx, _) => {
      let has-key = key in ctx
      let check1 = assert-eq(
        has-key,
        should-exist,
        msg: "Key `" + key + "` visibility correct",
      )
      return (none, (check1,))
    },
    draw: (.., view, _) => [#view.join(parbreak())],
    none,
  )

  // Sibling A sets 'foo', Sibling B checks for it.
  #stack(
    dir: ltr,
    setter("foo", true),
    checker("foo", false), // Must NOT see 'foo' as it is a sibling
  )
]

// =============================================================================
// SECTION 2: SIGNAL & MEASURE FLOW
// =============================================================================
= Signal Processing (Measure Phase)

We test the backflow of data from children to parents.

#test-case(
  "Data Aggregation",
  tags: ("Measure", "Signal"),
  task: [Parent collects signals from children.],
  abstract: [
    Children emit `value: 10`. Parent sums them up.
  ],
)[
  #show: weave.with()

  #let child-node(val) = motif(
    measure: (ctx, _) => (frame.new(signal: (value: val)), (value: val)),
    draw: (..) => [Child Node: #val #parbreak()],
    none,
  )

  #let aggregator(body) = motif(
    measure: (ctx, children) => {
      // Test: Did we receive child data?
      let sum = children.map(c => c.signal.value).sum()
      let check1 = assert-eq(sum, 30, msg: "Aggregated sum is 30")
      return (none, (check1,))
    },
    draw: (_, _, view, body) => [#view.join(parbreak()) #parbreak() #body],
    body,
  )

  #aggregator[
    #child-node(10)
    #child-node(20)
  ]
]

// =============================================================================
// SECTION 3: PATH INTEGRITY (MANAGED MOTIFS)
// =============================================================================
= Path Logic & Managed Motifs

Managed Motifs alter the path (`sys.path`). We must ensure proper nesting.

#test-case(
  "Nested Path Resolution",
  tags: ("Path", "Managed"),
  task: [Verify `path-current` and `path-parent` inside nested structures.],
  abstract: [
    Structure: `outer > inner`.
    Inner checks if parent is `outer`.
  ],
)[
  #show: weave.with()

  #let check-path(expected-current, expected-parent) = motif(
    measure: (ctx, _) => {
      let check1 = assert-eq(
        path.current-kind(ctx),
        expected-current,
        msg: "Current path is " + expected-current,
      )
      let check2 = assert-eq(
        path.parent-kind(ctx),
        expected-parent,
        msg: "Parent path is " + expected-parent,
      )
      return (none, (check1, check2))
    },
    draw: (.., view, _) => view.join(parbreak()),
    none,
  )

  #managed-motif("outer")[
    #managed-motif("inner")[
      #check-path("inner", "outer")
    ]
  ]
]

// =============================================================================
// SECTION 4: MOTIF TYPES SPECIALIZATION
// =============================================================================
= Motif Specializations

#test-case(
  "Data Motif vs Content Motif",
  tags: ("Type", "Behavior"),
  task: [Ensure Data Motifs don't render (or behave as expected).],
  abstract: [
    `data-motif` is purely for calculation.
  ],
)[
  #show: weave.with(max-passes: 2)

  #content-motif(draw: (ctx, body) => [
    #let data-motif = query.find(ctx.global, "my-data", default: (:))

    #assert-eq(
      data-motif.signal.at("val", default: 0),
      1,
      msg: "Data Signal was propagated correctly.",
    )

    // Rendering Logic
    Data available: #data-motif.signal.val
    #parbreak() #body
  ])[
    This is the Body of the content motif
  ]

  // -- Data Motif Below --
  #data-motif("my-data", measure: ctx => {
    return (val: 1)
  })
]

// =============================================================================
// SECTION 5: UTILITY FUNCTIONS (APPLY & DEBUG)
// =============================================================================
= Utilities & Debugging

Testing helper functions for context mutation and introspection.

#test-case(
  "Apply Functionality",
  tags: ("Utils", "Apply"),
  task: [Verify that `apply` correctly injects data into the context.],
  abstract: [
    Use `test-wrapper.apply` to inject `theme: dark`. Child verifies presence.
  ],
)[
  #show: weave.with()

  #let check-theme(expected) = motif(
    measure: (ctx, _) => {
      let actual = ctx.at("theme", default: "light")
      let check = assert-eq(
        actual,
        expected,
        msg: "Context theme is " + expected,
      )
      return (none, (check,))
    },
    draw: (.., view, _) => view.join(parbreak()),
    none,
  )

  // Default state
  #check-theme("light")

  // Modified state via Apply
  #apply(theme: "dark")[
    #check-theme("dark")
  ]
]

#test-case(
  "Debug Introspection",
  tags: ("Utils", "Debug"),
  task: [Verify that a debug component can read child signals.],
  abstract: [
    A custom `debug` motif inspects the `children` array and prints their data types.
  ],
)[
  #show: weave.with()

  #let signal-sender(msg) = data-motif("signal-sender", measure: ctx => msg)

  #debug(display: true)[
    #signal-sender("Alpha")
    #signal-sender("Omega")
  ]

  #debug(display: false)[
    #signal-sender("Beta")
  ]
]

= Final Status
*Integration Suite Completed.*
