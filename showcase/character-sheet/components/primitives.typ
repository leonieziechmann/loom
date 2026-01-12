// --- Colors ---
#let c-primary = rgb("#6d0e0e")
#let c-secondary = rgb("#cd853f")
#let c-faint = rgb("#f2e8d5")
#let c-line = rgb("#dcdcdc")
#let c-muted = rgb("#666666")
#let c-accent = rgb("#b38600")

#let paper-base = rgb("#f4e8d4")
#let paper-edge = rgb("#e6d3b3")

// --- Building Blocks ---

#let separator(color: c-secondary) = block(width: 100%, height: .40cm, {
  align(center + horizon, box(width: 100% - 1cm)[
    #line(length: 100%, stroke: 1.25pt + color)
    #place(center, dy: -3pt, rotate(45deg, rect(
      width: 6pt,
      height: 6pt,
      fill: color,
    )))
  ])
})

#let frame-shape(width: 10cm, height: 5cm, radius: 15pt, a: 0pt, ..args) = {
  set curve.quad(relative: true)
  set curve.line(relative: true)
  curve(
    ..args,
    curve.move((0pt, radius)),
    curve.line((0pt, height - radius * 2)),
    curve.quad((-a + radius, a), (radius, radius)),
    curve.line((width - radius * 2, 0pt)),
    curve.quad((a, a - radius), (radius, 0pt - radius)),
    curve.line((0pt, -height + radius * 2)),
    curve.quad((a - radius, -a), (-radius, -radius)),
    curve.line((-width + radius * 2, 0pt)),
    curve.quad((-a, -a + radius), (-radius, radius)),
  )
}

#let frame(
  width: 100%,
  height: auto,
  radius: 8pt,
  inner: 2pt,
  stroke-color: c-secondary,
  fill-color: white,
  body,
) = {
  layout(size => {
    let body-block = block.with(width: width, inset: radius + inner)
    let (h, rendered-body) = if height != auto {
      (height, body-block(height: height, body))
    } else {
      let b = body-block(body)
      (measure(b, ..size).height, b)
    }

    block(width: width, height: height, breakable: false)[
      #place(frame-shape(
        width: width,
        height: h,
        radius: radius,
        stroke: 1.5pt + stroke-color,
        fill: fill-color,
      ))
      #place(dx: inner, dy: inner, frame-shape(
        width: width - inner * 2,
        height: h - inner * 2,
        radius: radius,
        stroke: 0.5pt + stroke-color,
        a: inner / 2,
      ))

      #rendered-body
    ]
  })
}

#let frame-header(title, color: c-primary) = {
  align(center)[
    #text(
      font: "Linux Biolinum",
      weight: "bold",
      fill: color,
      size: 10pt,
      upper(title),
    )
    #v(-6pt)
    #line(length: 100%, stroke: 0.5pt + color)
    #v(2pt)
  ]
}

#let label-text(content) = text(
  font: "Linux Biolinum",
  size: 7pt,
  weight: "bold",
  fill: c-muted,
  upper(content),
)
