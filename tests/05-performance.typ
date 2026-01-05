// =============================================================================
// LOOM ENGINE: PERFORMANCE & SCALABILITY
// =============================================================================
// Author: Leonie
// Target: Engine Overhead, Memory Allocation, Recursion Limits
// Warning: This file may take significantly longer to compile!
// =============================================================================
#import "test-wrapper.typ"
#import "test-template.typ": *

#show: loom-test.with(
  title: [Loom Engine Performance Suite],
  description: [Stress Testing Throughput & Memory],
  abstract: [
    This suite pushes the engine to its limits regarding object count and context mutations.
    We intentionally use simple visual primitives (squares, short text) to ensure
    that the bottleneck is the Loom Engine's traversal logic (`intertwine`), 
    not Typst's paragraph layout or shaping engine.
  ],
)

// =============================================================================
// SECTION 1: HORIZONTAL SCALING (WIDTH)
// =============================================================================
= Horizontal Scaling

Testing the engine's ability to handle massive flat lists of components.

#test-case(
  "The Legion (Flat List Throughput)",
  tags: ("Perf", "List", "Memory"),
  task: [Process a list of 2,000 simple motifs.],
  abstract: [
    We generate 2,000 minimal motifs in a single flow.
    *Stress Factor:* Iteration overhead in `intertwine` and array allocations for `children`.
    If this times out or crashes, the overhead per-node is too high.
  ],
)[
  #show: test-wrapper.weave.with()
  
  // Wir nutzen boxen statt text, um Typst-Layouting zu minimieren.
  // Einfach nur "da sein".
  #let soldier = test-wrapper.motif(
    draw: (..) => box(width: 5pt, height: 5pt, fill: black, radius: 1pt),
    none
  )

  // 2000 Soldaten
  #block(breakable: false)[
    *Rendering 2,000 Nodes...* \
    #stack(
      dir: ltr, 
      spacing: 1pt, 
      ..range(2000).map(_ => soldier)
    )
  ]
]

// =============================================================================
// SECTION 2: CONTEXT THRASHING
// =============================================================================
= Context Mutation Stress

Testing the cost of context immutability.

#test-case(
  "The Mutator (Scope Thrashing)",
  tags: ("Perf", "Context", "Copying"),
  task: [Render 500 elements that EACH modify the context.],
  abstract: [
    Every single element injects a variable into the scope.
    *Stress Factor:* Typst dictionaries are immutable. Modifying the scope 
    forces a copy of the context object for every single child. 
    This tests the efficiency of `intertwine`'s scope handling.
  ],
)[
  #show: test-wrapper.weave.with()

  #let mutator(i) = test-wrapper.motif(
    // Jedes Element verändert den Context
    scope: (ctx) => ctx + ((("var-" + str(i)): i)),
    draw: (..) => box(width: 4pt, height: 10pt, fill: purple.lighten(20%)),
    none
  )

  #block(breakable: false)[
    *Processing 500 Context Mutations...* \
    #stack(
      dir: ltr, 
      spacing: 1pt,
      ..range(500).map(i => mutator(i))
    )
  ]
]

// =============================================================================
// SECTION 3: PATH & SIGNALS
// =============================================================================
= Managed Overhead

Managed Motifs have higher overhead due to path tracking (`sys.path`).

#test-case(
  "Grid of Doom (Managed Motifs)",
  tags: ("Perf", "Path", "Managed"),
  task: [Render a 40x40 Grid (1,600 items) of Managed Motifs.],
  abstract: [
    Managed motifs push/pop to `sys.path` and create a `frame` object.
    We verify that this extra bookkeeping remains performant at scale.
  ],
)[
  #show: test-wrapper.weave.with()

  #let cell = test-wrapper.managed-motif("cell",
    draw: (..) => rect(width: 100%, height: 100%, fill: luma(240), stroke: 0.5pt + gray)[.],
    none
  )

  *Building 40x40 Grid (1,600 Managed Paths)...*
  #v(1em)
  
  #box(height: 10cm, columns(2)[
    #grid(
      columns: (1fr,) * 20, // 20 Spalten
      gutter: 2pt,
      ..range(800).map(_ => cell)
    )
    #colbreak()
    #grid(
      columns: (1fr,) * 20,
      gutter: 2pt,
      ..range(800).map(_ => cell)
    )
  ])
]

#pagebreak()
// =============================================================================
// SECTION 4: DEEP RECURSION (THE ABYSS - ITERATIVE BUILD)
// =============================================================================
= Vertical Scaling (The Abyss)

Testing the recursion limits and context stack depth.

#test-case(
  "The Abyss (Iterative Build)",
  tags: ("Perf", "Recursion", "Context"),
  task: [Recursively nest Loom Motifs (built iteratively) to test Engine traversal.],
  abstract: [
    We construct the nested structure using `fold` to avoid hitting the recursion limit
    during the *instantiation* phase. The recursion stress applies purely to the 
    Loom Engine's `intertwine` traversal.
    
    *Goal:* Verify Engine stability at depth 50+.
  ],
)[
  #show: test-wrapper.weave.with()

  #let max-depth = 50
  
  #let core = box(width: 1cm, height: 1cm, fill: red, radius: 50%, align(center+horizon)[Core])
  
  // Wir bauen den Zwiebel-Ring von Innen nach Außen auf.
  // range(0, max-depth) erzeugt 0..149.
  // Wir wollen, dass der äußerste Ring "depth-val-1" ist.
  #let abyss = range(0, max-depth).fold(core, (inner-content, i) => {
    let current-depth = max-depth - i
    
    test-wrapper.content-motif(
      // 1. MUTATION
      scope: (ctx) => ctx + (("depth-val-" + str(current-depth)): current-depth),
      
      // 2. FORCED EVALUATION
      draw: (ctx, body) => {
        let my-depth = ctx.at("depth-val-" + str(current-depth))
        // Je tiefer, desto dunkler/roter
        let color = black.mix((teal, (my-depth / max-depth * 100%)))
        
        box(
          inset: 1pt, 
          stroke: 0.5pt + color,
          body
        )
      },
      inner-content
    )
  })

  #abyss
]