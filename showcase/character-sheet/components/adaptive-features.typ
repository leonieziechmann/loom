#import "@preview/loom:0.1.0": mutator, query
#import "../lw-content.typ": *
#import "primitives.typ": *

#let feature(title, body) = data-motif(
  "feature",
  measure: (..) => (
    title: title,
    body: body,
  ),
)

#let feature-box(title, body) = box(width: 100%, {
  text(weight: "bold", fill: c-primary, title)
  linebreak()
  set text(size: 9pt)
  body
})

#let features(body) = managed-motif(
  "feature",
  scope: ctx => mutator.batch(ctx, {
    import mutator: *
    ensure("i18n", "frames", "features", "Features")
  }),
  measure: (ctx, children) => {
    let features = query.collect-signals(children, kind: "feature")
    (none, features)
  },
  draw: (ctx, _, features, body) => {
    layout(size => {
      // Logic: 1 column if narrow, 2 columns if wide
      let cols = if size.width < 10cm { 1 } else { 2 }

      frame({
        frame-header(ctx.i18n.frames.features)
        grid(
          columns: (1fr,) * cols,
          gutter: 1em,
          ..features.map(feature => feature-box(feature.title, feature.body))
        )
      })
    })
  },
  body,
)
