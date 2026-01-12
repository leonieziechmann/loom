#import "../../../lib.typ": mutator
#import "../lw-content.typ": *
#import "primitives.typ": *

#let attack(name, bonus, dmg, type, notes: none) = (
  (
    name: name,
    bonus: bonus,
    dmg: dmg,
    type: type,
    notes: notes,
  ),
)

#let attacks(attacks) = content-motif(
  scope: ctx => mutator.batch(ctx, {
    import mutator: *
    nest("i18n", {
      ensure("frames", "attacks", "Attacks & Actions")
      nest("attacks", {
        ensure("weapon", "Weapon")
        ensure("attack", "ATK")
        ensure("damage", "Damage")
        ensure("notes", "Notes")
      })
    })
  }),
  draw: (ctx, ..) => {
    if attacks == none { return none }

    layout(size => {
      let is-narrow = size.width < 10cm

      frame({
        frame-header(ctx.i18n.frames.attacks)

        if is-narrow {
          // --- NARROW: Cards ---
          grid(
            columns: 1,
            gutter: 0.5em,
            ..for atk in attacks {
              (
                box(width: 100%, inset: 4pt, stroke: (bottom: 0.5pt + c-line), {
                  grid(
                    columns: (1fr, auto),
                    align: horizon,
                    text(weight: "bold", fill: c-primary, atk.name),
                    text(weight: "bold", size: 10pt, atk.bonus),
                  )
                  v(-2pt)
                  text(size: 8pt, style: "italic")[#atk.dmg #atk.type]
                  if atk.notes != none {
                    linebreak()
                    text(size: 7pt, fill: c-muted, atk.notes)
                  }
                }),
              )
            }
          )
        } else {
          // --- WIDE: Table with Header ---
          table(
            columns: (2.5fr, 0.8fr, 1.2fr, 2.5fr),
            stroke: (x, y) => if y > 0 { (top: 0.5pt + c-line) } else { none },
            inset: (y: 6pt, x: 4pt),
            align: horizon,
            // Header Row
            label-text(ctx.i18n.attacks.weapon),
            align(center, label-text(ctx.i18n.attacks.attack)),
            label-text(ctx.i18n.attacks.damage),
            label-text(ctx.i18n.attacks.notes),
            // Data Rows
            ..for atk in attacks {
              (
                text(weight: "bold", fill: c-primary)[#atk.name],
                align(center)[*#atk.bonus*],
                [#atk.dmg #text(size: 7pt)[#atk.type]],
                text(size: 8pt)[#atk.notes],
              )
            },
          )
        }
      })
    })
  },
)
