#import "@preview/loom:0.1.0": mutator, query
#import "lw-content.typ"
#import "components/primitives.typ": *
#import "character-sheet-layout.typ": bottom, layout-sheet, portal, sidebar
#import "i18n.typ" as locale

#let character-sheet(
  name: "",
  level: 0,
  class: "Paladin",
  race: "",
  xp: 0,
  senses: "",
  background: "",
  alignment: "",
  prof-bonus: 0,
  aura-bonus: 0,
  i18n: (:),
  body,
) = {
  let i18n = mutator.batch(i18n, {
    import mutator: *
    ensure-deep(locale.en)
  })

  let layouted-content = layout-sheet({
    portal("header-title")[
      #text(3em, weight: "black", fill: c-primary)[#name] \
      #text(1.2em, style: "italic", fill: c-muted)[Level #level #class]
    ]

    portal("header-box", {
      set text(8pt)
      frame(
        grid(
          row-gutter: 1em,
          columns: 3 * (1fr,),
          [#label-text(i18n.header.race): #race],
          [#label-text(i18n.header.xp): #xp],
          [#label-text(i18n.header.senses): #senses],

          [#label-text(i18n.header.background): #background],
          [#label-text(i18n.header.align): #alignment],
          [#label-text(i18n.header.prof): + #prof-bonus],
        ),
      )
    })

    body
  })

  let ctx = (
    aura-bonus: aura-bonus,
    prof-bouns: prof-bonus,
    i18n: i18n,
  )

  lw-content.weave(layouted-content, inputs: ctx)
}
