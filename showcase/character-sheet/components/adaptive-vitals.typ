#import "../../../lib.typ": mutator, query
#import "../lw-content.typ": *
#import "primitives.typ": *

#let vital(icon: "❌", label, value, sub: none) = data-motif(
  "vital",
  measure: (ctx, _) => {
    let signal = (
      icon: icon,
      label: label,
      value: value,
      sub: sub,
    )
  },
)

#let initiative(value) = data-motif(
  "vital",
  scope: ctx => mutator.batch(ctx, {
    import mutator: *
    ensure("i18n", "vital", "initiative", "Initiative")
  }),
  measure: ctx => (
    icon: "⚡",
    label: ctx.i18n.vital.initiative,
    value: value,
    sub: none,
  ),
)

#let armor(value, type) = data-motif(
  "vital",
  scope: ctx => mutator.batch(ctx, {
    import mutator: *
    ensure("i18n", "vital", "armor", "Armor")
  }),
  measure: ctx => (
    icon: "🛡️",
    label: ctx.i18n.vital.armor,
    value: value,
    sub: type,
  ),
)

#let health(current, max) = data-motif(
  "vital",
  scope: ctx => mutator.batch(ctx, {
    import mutator: *
    ensure("i18n", "vital", "health", "TP")
  }),
  measure: ctx => (
    icon: "❤️",
    label: ctx.i18n.vital.health,
    value: current,
    sub: [Max: #max],
  ),
)

#let dice(dice, used: false) = data-motif(
  "vital",
  scope: ctx => mutator.batch(ctx, {
    import mutator: *
    ensure("i18n", "vital", "dice", "Hit Dice")
    ensure("i18n", "used", "Used: ")
  }),
  measure: ctx => (
    icon: "🎲",
    label: ctx.i18n.vital.dice,
    value: dice,
    sub: [#ctx.i18n.used: #if used [\[X\]] else [\[ \]]],
  ),
)

#let vital-box(icon, label, value, sub) = {
  box(width: 100%, inset: (y: 4pt))[
    #align(center)[
      #text(size: 14pt)[#icon] \
      #v(-4pt)
      #text(size: 14pt, weight: "bold", fill: c-primary)[#value] \
      #v(-2pt)
      #label-text(label)
      #if sub != none {
        linebreak()
        text(size: 7pt, style: "italic", fill: c-muted)[#sub]
      }
    ]
  ]
}

#let vitals(body) = managed-motif(
  "vitals",
  measure: (ctx, children) => {
    let vitals = query.collect-signals(children, kind: "vital")
    ((children: vitals), vitals)
  },
  draw: (_, _, vitals, body) => {
    layout(size => {
      let col-count = calc.max(1, calc.floor(size.width / 3cm))

      frame({
        grid(
          columns: (1fr,) * col-count,
          gutter: 0.5em,
          ..vitals.map(vital => vital-box(
            vital.icon,
            vital.label,
            vital.value,
            vital.sub,
          ))
        )

        body
      })
    })
  },
  body,
)
