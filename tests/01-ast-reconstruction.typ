// =============================================================================
// LOOM ENGINE: COMPLIANCE & ROBUSTNESS REPORT
// =============================================================================
// Author: Leonie
// Target: Loom Engine Core (v0.1-alpha)
// Date: 2025-12-22
// =============================================================================
#import "test-wrapper.typ"
#show: test-wrapper.weave.with()

#import "test-template.typ": *
#show: loom-test.with(
  title: [Loom Engine Compliance Report],
  description: [Stress Testing, AST Reconstruction & Edge Cases],
  abstract: [
    This document serves as a rigorous stress-test suite for the Loom engine. Unlike standard unit tests, these cases are designed to provoke runtime failures during the `intertwine` phase, specifically targeting:
    
    + *Argument Reconstruction:* Mapping internal fields back to constructors.
    + *Context Mutation:* Handling `#set` rules that alter the style chain.
    + *Content Transformation:* Processing the output of `#show` rules.
    + *Structural Integrity:* Deep nesting and recursion limits.
    
    If the document compiles and renders fully, the engine is considered stable against the tested vectors.
  ],
)

// =============================================================================
// SECTION 1: LAYOUT PRIMITIVES (Wrappers)
// =============================================================================
= Layout Primitives

These elements act as wrappers around content. They are the most frequent cause of reconstruction errors due to discrepancies between internal fields and constructor arguments.

#test-case(
  "Alignment & Positioning",
  tags: ("Layout", "Align"),
  task: [Reconstruct `align` with both named and positional arguments.],
  abstract: [
    `align` is a classic failure point. It accepts content positionally but stores alignment as a field. 
    The engine must correctly separate the alignment parameter from the content body.
  ],
)[
  #rect(width: 100%, fill: luma(240), inset: 8pt)[
    *Align Check:*
    #align(center + horizon)[Center/Horizon Aligned Text]
    #align(right)[Explicit Named Argument]
  ]
]

#test-case(
  "Block & Box Properties",
  tags: ("Layout", "Block"),
  task: [Process heavy parameter lists for structural blocks.],
  abstract: [
    `block` and `box` have massive signatures (stroke, radius, inset, sticky, breakable). 
    We populate many fields to force complex dictionary unpacking during reconstruction.
  ],
)[
  #block(
    width: 90%,
    height: auto,
    fill: luma(250),
    stroke: (left: 2pt + red, rest: 0.5pt + gray),
    radius: (top-right: 5pt, bottom-left: 5pt),
    inset: 1em,
    outset: 2pt,
    spacing: 1.5em,
    breakable: false,
    clip: false,
    sticky: true
  )[
    Complex Block Content with heavy styling.
  ]
  Text before #box(baseline: 20%, stroke: 1pt + green, inset: 2pt)[Inline Box] Text after.
]

#test-case(
  "Geometric Transformations",
  tags: ("Layout", "Transform"),
  task: [Handle `scale`, `rotate`, and `move`.],
  abstract: [
    Transformations modify the coordinate system. `move` is particularly tricky as it shifts content 
    without affecting the flow layout, while `scale` and `rotate` rely on an `origin`.
  ],
)[
  #stack(dir: ltr, spacing: 2em,
    scale(x: 110%, y: 90%, origin: left + top)[*Scaled*],
    rotate(15deg, origin: center)[*Rotated*],
    move(dx: 5pt, dy: -5pt)[*Moved*]
  )
]

#test-case(
  "Padding & Spacing",
  tags: ("Layout", "Pad"),
  task: [Reconstruct `pad` with specific side overrides.],
  abstract: [
    Padding can be specified universally (`rest`) or per side (`left`, `x`, etc.). 
    The engine must preserve these specific keys.
  ],
)[
  #pad(x: 1cm, y: 5mm)[Padded content (x: 1cm, y: 5mm).]
]

// =============================================================================
// SECTION 2: CONTAINER STRUCTURES
// =============================================================================
= Container Structures

Elements that manage multiple children. The engine must recursively process children and re-inject them correctly.

#test-case(
  "Stack Layout",
  tags: ("Container", "Stack"),
  task: [Process linear layouts with multiple children.],
  abstract: [
    Stacks are the simplest container. We test directionality and spacing preservation.
  ],
)[
  #stack(dir: ltr, spacing: 1em, [Stack A], [Stack B], [Stack C])
]

#test-case(
  "Table Structures",
  tags: ("Container", "Table"),
  task: [Handle specialized table children like `cell` and `header`.],
  abstract: [
    Tables are unique because they contain `table.cell` and `table.header` wrappers. 
    The engine must be able to identify and reconstruct these specialized internal types.
  ],
)[
  #table(
    columns: 2,
    stroke: 0.5pt + gray,
    table.header([*Header 1*], [*Header 2*]),
    [Row 1, Col 1],
    table.cell(rowspan: 2, align: center + horizon, fill: teal.lighten(80%))[Rowspan 2],
    [Row 2, Col 1],
    [Row 3, Col 1], [Row 3, Col 2]
  )
]

// =============================================================================
// SECTION 3: FLOW CONTENT & TYPOGRAPHY
// =============================================================================
= Flow Content & Typography

The atomic units of document text.

#test-case(
  "Text & Paragraph Properties",
  tags: ("Flow", "Text"),
  task: [Preserve font features, tracking, and paragraph settings.],
  abstract: [
    `text` is the fundamental atom. If this fails, the document is blank.
    `par` controls block-level text flow. Both have extensive parameter lists.
  ],
)[
  #set text(font: "Linux Libertine")
  #text(size: 10pt, weight: "bold", fill: eastern, tracking: 1pt, features: (scaps: 2))[
    Styled Text Node.
  ]
  #par(leading: 1em, justify: true, first-line-indent: 1em)[
    This is a paragraph with specific leading and justification settings. 
    It tests whether the engine preserves paragraph formatting during reconstruction.
  ]
]

#test-case(
  "Interaction Elements",
  tags: ("Meta", "Link"),
  task: [Reconstruct functional wrappers like `link` and `hide`.],
  abstract: [
    `link` requires a `dest` argument which is often named differently internally.
    `hide` wraps content without removing it from the layout.
  ],
)[
  #link("https://typst.app")[Link to Typst] --- Visible #hide[Invisible] Visible.
]

// =============================================================================
// SECTION 4: VISUALS & MATH
// =============================================================================
= Visuals & Math

Non-textual elements.

#test-case(
  "Vector Shapes",
  tags: ("Visual", "Shape"),
  task: [Handle atomic visual elements.],
  abstract: [
    Shapes like `circle` or `polygon` have no content body but many fields. 
    They typically fall into the atomic case of the engine.
  ],
)[
  #stack(dir: ltr, spacing: 1cm,
    circle(radius: 5mm, fill: red),
    rect(width: 1cm, height: 1cm, radius: 2mm, fill: yellow),
    line(start: (0pt, 0pt), end: (1cm, 10pt), stroke: 2pt + blue)
  )
]

#test-case(
  "Math Mode",
  tags: ("Math", "Equation"),
  task: [Stability in Math Mode.],
  abstract: [
    Math mode uses a different syntax and structure (`equation` blocks). 
    The engine must traverse these without breaking the math context.
  ],
)[
  $ sum_(k=0)^n k = (n(n+1)) / 2 $
  The value of $pi$ is approximately $3.14$.
]

// =============================================================================
// SECTION 5: DYNAMIC RULES (Set & Show)
// =============================================================================
= Dynamic Environment & Transformation

Typst's power lies in its ability to mutate content contextually. The engine must respect these mutations without crashing during introspection.

#test-case(
  "Set Rules & Context Propagation",
  tags: ("Context", "Set Rule"),
  task: [Verify that styles set via `#set` are preserved or handled gracefully.],
  abstract: [
    `#set` rules do not produce content nodes directly but modify the context. 
    The engine typically processes the *result* of the context. 
    *Risk:* If the engine tries to reconstruct an element that relies on an implicit context 
    (like `auto` sizing), it must not crash.
  ],
)[
  #set text(fill: teal, weight: "bold")
  #set block(stroke: 1pt + red, inset: 5pt)
  
  This text should be teal and bold.
  #block[This block inherits the red stroke.]
  
  // Testing nested set rules
  #block[
    #set text(fill: purple)
    This should be purple.
  ]
]

#test-case(
  "Show Rules (Content Substitution)",
  tags: ("Transformation", "Show Rule"),
  task: [Ensure the engine handles content mutated by `#show` rules.],
  abstract: [
    `#show` rules replace an element with another. 
    *Risk:* The engine might see the *output* of the show rule (e.g., a Box instead of Text) 
    depending on where it sits in the pipeline. If the engine introspects the raw element 
    before the show rule applies, it sees the original. If after, it sees the result.
    Both must be stable.
  ],
)[
  #show "loom": name => box(fill: blue.lighten(80%), inset: 2pt, radius: 2pt)[#upper(name)]
  
  Testing the keyword loom in a sentence.
  
  #show heading: it => block(fill: luma(230), inset: 5pt)[*#it.body*]
  == Styled Heading
]

// =============================================================================
// SECTION 6: STRUCTURAL EXTREMES
// =============================================================================
= Structural Integrity

Testing the limits of the recursion stack and the handling of deeply nested structures.

#test-case(
  "Deep Nesting (The Russian Doll)",
  tags: ("Recursion", "Stack"),
  task: [Traverse a deeply nested structure without stack overflow.],
  abstract: [
    We generate 50 layers of nested boxes. 
    *Risk:* Recursive calls in `intertwine` consume stack memory. 
    The reconstruction logic must also handle `..args` correctly at depth.
  ],
)[
  #let depth = 50
  #range(1, depth).fold(
    [Core Payload], 
    (acc, i) => box(inset: 1pt, stroke: (thickness: 0.5pt, paint: black.lighten(i * 1.5%)))[#acc]
  )
]

#test-case(
  "Empty & Null Structures",
  tags: ("Edge Case", "None"),
  task: [Handle `none` values and empty sequences gracefully.],
  abstract: [
    Typst allows `none` in content sequences. `node.children` might contain `none`.
    *Risk:* Iterating over children without checking for `none` will crash.
  ],
)[
  Start
  #none
  Middle
  #([]) // Empty content block
  End
]

// =============================================================================
// SECTION 7: COMPLEX LAYOUTS & EDGE CASES
// =============================================================================
= Complex Layouts & Edge Cases

Revisiting layout primitives with advanced configurations and explicit naming conflicts.

#test-case(
  "Grid with Mixed Units & Functions",
  tags: ("Layout", "Grid"),
  task: [Reconstruct grids with mixed unit types (fr, auto) and functional parameters.],
  abstract: [
    Grids are notoriously complex. We test `columns` as arrays, and functional `fill` / `align` arguments 
    which cannot be trivially serialized.
  ],
)[
  #grid(
    columns: (1fr, 2fr, auto),
    gutter: 1em,
    fill: (c, r) => if calc.even(c) { luma(240) } else { white },
    align: (c, r) => (left, center).at(calc.rem(r, 2)),
    [Fluid 1], [Fluid 2], [Auto],
    [A], [B], [C]
  )
]

#test-case(
  "Floating & Out-of-Flow Elements",
  tags: ("Layout", "Place"),
  task: [Handle elements that do not consume space in the flow.],
  abstract: [
    `place` puts elements at specific coordinates.
    *Risk:* Reconstruction must preserve `float`, `clear`, and alignment parameters.
  ],
)[
  #place(top + right, dx: -1cm, dy: 1cm)[
    #circle(radius: 5mm, fill: red)
  ]
  #lorem(10)
  #v(6em)
]

#test-case(
  "Edge Case: Figures & Captions",
  tags: ("Edge Case", "Figure"),
  task: [Handle `figure` which has named content arguments.],
  abstract: [
    `figure` takes a `caption` argument which is content, but not the main body.
    The engine needs to ensure it doesn't try to push `caption` into the positional body args incorrectly.
  ],
)[
  #figure(
    rect(fill: lime, width: 2cm),
    caption: [A Figure Caption],
    kind: "figure",
    supplement: "Fig."
  )
]

// =============================================================================
// SECTION 8: INTROSPECTION & STATE
// =============================================================================
= State & Context Awareness

#test-case(
  "Context Expressions",
  tags: ("Context", "Modern Typst"),
  task: [Handle the `#context` keyword.],
  abstract: [
    In Typst 0.11+, `context` replaced `style` and `locate`. The content returned 
    by a context expression is opaque until evaluated.
  ],
)[
  #context {
    let size = measure[Text].width
    [The text width is approximately #size]
  }
]

= Conclusion

If you are reading this text, the *Loom Engine* has successfully:
+ Parsed the AST.
+ Traversed complex nested structures.
+ Reconstructed elements with dynamic fields.
+ Survived strict assertions.

_End of Report._