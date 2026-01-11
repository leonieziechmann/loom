#let loom-test(
  title: [title: Test Title],
  description: [description: Short Description],
  abstract: [abstract: Abstract of the test],
  body,
) = {
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    numbering: "1/1",
    header: context {
      if counter(page).get().first() > 1 {
        align(right, text(
          size: 8pt,
          style: "italic",
        )[Loom Engine Compliance Report])
        line(length: 100%, stroke: 0.5pt + gray)
      }
    },
  )

  set text(size: 11pt, lang: "en")
  set heading(numbering: "1.1")

  // --- UTILITIES & TEMPLATES ---

  let status-badge(pass) = {
    let color = if pass { green } else { red }
    let text-content = if pass { "PASS" } else { "FAIL" }
    box(fill: color.lighten(80%), stroke: color, inset: 4pt, radius: 2pt)[
      #text(fill: color.darken(20%), weight: "bold")[#text-content]
    ]
  }


  // --- REPORT HEADER ---
  align(center)[
    #text(size: 2em, weight: "bold")[#title] \
    #v(0.5em)
    #text(size: 1.2em)[#description] \
    #v(1em)
    #line(length: 50%, stroke: 1pt)
  ]

  [
    = Executive Summary

    #abstract
  ]

  body
}

/// The standard test case template.
///
/// - title (string): The name of the test.
/// - tags (array<string>): Categories (e.g., "Layout", "Recursion").
/// - task (content): Description of what the engine needs to do.
/// - abstract (content): Technical details on potential failure points.
/// - body (content): The actual Typst code to be processed.
#let test-case(title, tags: (), task: [], abstract: [], body) = {
  v(1em)
  block(
    stroke: (left: 2pt + eastern, rest: 0.5pt + gray.lighten(50%)),
    inset: (left: 1em, rest: 1em),
    width: 100%,
    breakable: false, // Keep tests atomic on pages if possible
    radius: (right: 4pt),
  )[
    #stack(
      dir: ltr,
      spacing: 1fr,
      text(weight: "bold", size: 1.1em, fill: eastern)[#title],
      // Render tags
      stack(dir: ltr, spacing: 5pt, ..tags.map(t => box(
        fill: luma(240),
        inset: 3pt,
        radius: 2pt,
        text(size: 8pt)[#upper(t)],
      ))),
    )
    #v(0.5em)
    #grid(
      columns: (auto, 1fr),
      gutter: 0.8em,
      [*Objective:*], task,
      [*Abstract:*], text(size: 0.9em, style: "italic")[#abstract],
    )
    #line(length: 100%, stroke: 0.5pt + gray.lighten(60%))
    #v(0.5em)
    // The visual boundary for the content under test
    #block(
      width: 100%,
      fill: white,
      inset: 5pt,
      stroke: (paint: gray, dash: "dashed"),
      radius: 2pt,
    )[
      #body
    ]
  ]
  v(1em)
}


// --- ASSERTION HELPER ---
#let assert-eq(val, expected, msg: "Assertion failed") = {
  if val != expected {
    panic(
      msg + ". Expected: `" + repr(expected) + "`, Got: `" + repr(val) + "`",
    )
  }
  // Visualisierung: Grüner Haken + Die Nachricht (= was wurde getestet) + Wert (grau)
  box[
    #text(fill: green, weight: "bold")[✓]
    #h(0.5em)
    #text(size: 0.9em)[#msg]
    #h(0.5em)
    #text(fill: gray, size: 0.7em)[(Val: #repr(val))]
  ]
  linebreak()
}

// Shortcuts für Boolean Checks (liest sich natürlicher)
#let assert-true(val, msg: "Should be true") = assert-eq(val, true, msg: msg)
#let assert-false(val, msg: "Should be false") = assert-eq(val, false, msg: msg)
