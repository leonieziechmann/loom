
// =============================================================================
// LOOM ENGINE: EXTERNAL PACKAGE INTEGRATION
// =============================================================================
// Author: Leonie & Gemini
// Target: Compatibility with heavy-duty packages (Codly, CeTZ)
// Mode: Visual Inspection (Side-by-Side)
// =============================================================================
#import "test-wrapper.typ"
#import "test-template.typ": *

// Externe Pakete laden
#import "@preview/codly:1.3.0": *
#import "@preview/cetz:0.4.2"

#show: loom-test.with(
  title: [External Package Stress Test],
  description: [Visual Comparison of Native Typst vs. Loom Engine],
  abstract: [
    This suite validates the integration of complex third-party packages.
    Since automated assertions are difficult for visual output, we use a 
    Side-by-Side comparison strategy.

    *Left:* Native Typst implementation.
    *Right:* Implementation wrapped in `loom.weave`.
  ],
)

// Helper für den Side-by-Side Vergleich
#let compare(title, height: auto, native-body, loom-body) = {
  v(1em)
  block(breakable: false)[
    #text(weight: "bold", size: 1.1em)[#title]
    #v(0.5em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      block(stroke: (right: 1pt + gray), width: 100%, inset: (right: 1em))[
        #align(center, text(style: "italic", fill: gray)[Native Typst])
        #line(length: 100%, stroke: 0.5pt + gray)
        #native-body
      ],
      block(width: 100%)[
        #align(center, text(style: "italic", fill: eastern)[Loom Engine])
        #line(length: 100%, stroke: 0.5pt + eastern)
        // Hier rufen wir Loom explizit für den rechten Teil auf
        #test-wrapper.weave(loom-body)
      ]
    )
  ]
  v(1em)
  line(length: 100%, stroke: 0.5pt + gray.lighten(50%))
}


// =============================================================================
// TEST CASE 1: CODLY (State & Show Rules)
// =============================================================================
// Codly nutzt intensives State-Management für Zeilennummern.
// Risiko: Wenn Loom den Content mehrfach evaluiert (Measure + Draw), 
// könnten Counter doppelt hochzählen oder Icons flackern.

#test-case(
  "Codly (State & Syntax Highlighting)",
  tags: ("Ext", "State", "Show-Rule"),
  task: [Render a code block with active `codly` settings.],
  abstract: [
    We activate `codly` locally. Loom must preserve the `show` rule 
    transformation and not mess up the line numbering state.
  ],
)[
  // Setup für den Test-Scope
  #let code-sample = ```rust
  pub fn main() {
    println!("Hello Loom!");
  }
  ```

  #let setup-codly(body) = {
    show: codly-init.with()
    codly(languages: (rust: (name: "Rust", icon: none, color: red)))
    body
  }
  
  #compare(
    "Codly Block",
    setup-codly(code-sample), // Native
    setup-codly(code-sample)  // Loom
  )
]

// =============================================================================
// TEST CASE 2: CETZ (Canvas & Context)
// =============================================================================
// CeTZ verlässt sich massiv auf `context` und Layout-Informationen für Koordinaten.
// Risiko: Wenn Loom den Context isoliert oder Layout-Größen (Block/Box)
// nicht korrekt propagiert, kollabiert der Canvas.

#test-case(
  "CeTZ (Canvas & Drawing)",
  tags: ("Ext", "Canvas", "Context"),
  task: [Render a vector graphic using CeTZ.],
  abstract: [
    Drawing a simple coordinate system with shapes.
Verifies that Loom allows `context`-based layout resolution inside the engine.
  ],
)[
  #let draw-diagram = {
    cetz.canvas(length: 1cm, {
      import cetz.draw: * 
      
      rect((-1, -1), (1, 1), stroke: blue, fill: blue.lighten(90%))
      circle((0, 0), radius: 0.5, fill: white)
      line((-1.5, 0), (1.5, 0), mark: (end: ">"))
      content((0, 0), [*Loom*])
    })
  }

  #compare(
    "CeTZ Diagram",
    align(center)[#draw-diagram], // Native
    align(center)[#draw-diagram]  // Loom
  )
]

// =============================================================================
// TEST CASE 3: COMPLEX NESTING (Interaction)
// =============================================================================
// Kombination: Ein Loom-Motif, das ein externes Paket nutzt.

#test-case(
  "Mixed: Managed Motif wrapping CeTZ",
  tags: ("Ext", "Integration"),
  task: [Wrap a CeTZ canvas inside a Loom `managed-motif`.],
  abstract: [
    This tests if `scope` injection from Loom works correctly with
external contexts.
  ],
)[
  #let my-drawing = cetz.canvas({
    import cetz.draw: *
    circle((0,0), radius: 0.2, fill: orange)
  })

  #let loom-motif = test-wrapper.managed-motif.with("wrapper")

  #compare(
    "CeTZ in Managed Motif",
    align(center)[#my-drawing], // Native
    loom-motif[#align(center, my-drawing)], // Loom
  )
]

