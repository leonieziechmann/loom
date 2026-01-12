#import "../../../lib.typ": mutator, query
#import "../lw-content.typ": *
#import "primitives.typ": *

#let item(name, quantity: 1, weight: 0) = data-motif(
  "item",
  measure: (..) => (
    name: name,
    quantity: quantity,
    weight: weight * quantity,
  ),
)

#let inventory(body) = managed-motif(
  "inventory",
  scope: ctx => mutator.batch(ctx, {
    import mutator: *

    nest("i18n", {
      ensure("frames", "inventory", "Inventory")
      ensure("units", "weight", "kg")
      ensure("total", "Total")
    })
  }),
  measure: (ctx, children) => {
    let items = query.collect-signals(children, kind: "item")
    let total-weight = items.map(item => item.weight).sum(default: 0)

    ((weight: total-weight), (total-weight: total-weight, items: items))
  },
  draw: (ctx, _, view, body) => {
    layout(size => {
      // Logic: 1 column if small (< 8cm), 3 columns otherwise
      let cols = if size.width < 7cm { 1 } else { 2 }

      frame({
        place(
          dx: 0pt,
          dy: 0pt,
        )[#h(1fr) _*#ctx.i18n.total: #view.total-weight #ctx.i18n.units.weight *_]
        frame-header(ctx.i18n.frames.inventory)
        grid(
          columns: cols * (1fr,),
          gutter: 2em,
          row-gutter: .75em, // Added gutter for single-column readability
          ..view.items.map(item => [
            • #item.quantity x #item.name
            #if item.weight != 0 [ #box(width: 1fr, line(length: 100%, stroke: (
                thickness: 1pt,
                dash: "loosely-dotted",
                paint: luma(40%),
              ))) #item.weight #ctx.i18n.units.weight ]
          ])
        )
        body
      })
    })
  },
  body,
)

#let adaptive-inventory(items) = {
  if items == none { return none }
}
