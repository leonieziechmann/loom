#import "@preview/loom:0.1.0": matcher, mutator
#import "../rules.typ"
#import "primitives.typ": *
#import "../lw-content.typ": *

#let fmt-mod(val) = {
  if val >= 0 { "+" + str(val) } else { str(val) }
}

#let hero-stats(
  stats: (:),
  proficiencies: (),
  skills: (),
) = managed-motif(
  "hero-stats",
  scope: ctx => mutator.batch(ctx, {
    import mutator: *
    ensure("aura-bonus", 0)
    ensure("prof-bonus", 0)

    nest("i18n", {
      nest("stats", {
        ensure("str", "Strength")
        ensure("dex", "Dexterity")
        ensure("con", "Const.")
        ensure("int", "Intel.")
        ensure("wis", "Wisdom")
        ensure("cha", "Charisma")
      })

      nest("skills", {
        rules
          .skill-relations
          .pairs()
          .map(((skill, _)) => ensure(skill, skill))
          .flatten()
      })

      nest("frames", {
        ensure("stats", "Attributes")
        ensure("skills", "Skills")
      })
    })
  }),
  measure: (ctx, _) => {
    assert(
      matcher.match(proficiencies, matcher.many(str)),
      message: "Proficiencies must be of type str.",
    )

    let stats = mutator
      .batch(stats, {
        import mutator: *
        ensure("str", 0)
        ensure("dex", 0)
        ensure("con", 0)
        ensure("int", 0)
        ensure("wis", 0)
        ensure("cha", 0)
      })
      .pairs()
      .map(((stat, score)) => (
        stat,
        (
          score: score,
          proficient: stat in proficiencies,
          label: ctx.i18n.stats.at(stat),
        ),
      ))
      .to-dict()

    let skills = skills
      .filter(skill => skill in rules.skill-relations)
      .map(skill => {
        let stat-relation = rules.skill-relations.at(skill)
        let linked-stat = stats.at(stat-relation)
        let is-proficient = stat-relation in proficiencies
        let plain-mod = rules.score-to-mod(linked-stat.score)
        let mod = plain-mod + if is-proficient { ctx.prof-bonus } else { 0 }
        let label = ctx.i18n.skills.at(skill)

        (skill, (mod: mod, label: label))
      })
      .to-dict()

    let signal = (stats: stats, skills: skills)
    (signal, signal)
  },
  draw: (ctx, _, view, _) => {
    let clr = (
      text: c-muted,
      sub-text: rgb("#888"),
      stat-default: c-primary,
      stat-buffed: c-accent,
      vertical-seperator: c-secondary.lighten(40%),
    )

    layout(size => {
      // Determine context. Sidebars are usually ~5-7cm.
      // We use 10cm as a safe breakpoint.
      let is-narrow = size.width < 10cm

      frame({
        frame-header(ctx.i18n.frames.stats)

        // 1. Render the Stats based on width
        if not is-narrow {
          // --- WIDE MODE (Grid of Boxes) ---
          grid(
            columns: (1fr, 1fr, 1fr), // 2 columns for sidebar
            gutter: 0.8em,
            inset: (y: 5pt),
            ..view
              .stats
              .pairs()
              .map(((stat, (score, proficient, label))) => {
                let mod = rules.score-to-mod(score)
                let save = (
                  mod
                    + ctx.aura-bonus
                    + (if proficient { ctx.prof-bonus } else { 0 })
                )
                let is-buffed = ctx.aura-bonus > 0
                let color = if is-buffed { clr.stat-buffed } else {
                  clr.stat-default
                }

                box(
                  width: 100%,
                  inset: 4pt,
                  stroke: (bottom: 0.5pt + c-line),
                  align(center)[
                    #text(
                      font: "Linux Biolinum",
                      weight: "bold",
                      fill: clr.text,
                      size: 8pt,
                    )[#upper(label)] \
                    #v(0pt)
                    #text(size: 16pt, weight: "bold", fill: color)[#fmt-mod(
                      mod,
                    )] \
                    #v(-2pt)
                    #text(
                      size: 6pt,
                      fill: clr.sub-text,
                    )[Score: #score | Save: #fmt-mod(save)]
                  ],
                )
              })
          )
        } else {
          // --- NARROW MODE (Original Horizontal Strip) ---
          grid(
            columns: (1fr, auto, 1fr),
            align: horizon + center,
            inset: (y: 5pt),
            stroke: (bottom: 0.5pt + c-line),
            row-gutter: 1em,

            ..view
              .stats
              .pairs()
              .map(((stat, (score, proficient, label))) => {
                let mod = rules.score-to-mod(score)
                let save = (
                  mod
                    + ctx.aura-bonus
                    + (if proficient { ctx.prof-bonus } else { 0 })
                )
                let is-buffed = ctx.aura-bonus > 0
                let color = if is-buffed { clr.stat-buffed } else {
                  clr.stat-default
                }
                (
                  {
                    // Label & Score
                    text(
                      font: "Linux Biolinum",
                      weight: "bold",
                      fill: clr.text,
                      size: 7pt,
                    )[#upper(label) \ ]
                    v(-3pt)
                    text(size: 8pt, fill: clr.sub-text)[#score]
                  },
                )

                // Vertical Separator
                (
                  {
                    line(
                      angle: 90deg,
                      length: 2em,
                      stroke: .5pt + clr.vertical-seperator,
                    )
                  },
                )

                // Modifier & Save
                (
                  {
                    text(size: 14pt, weight: "bold", fill: color)[#fmt-mod(mod)]
                    v(-5pt)
                    text(size: 6pt, fill: clr.sub-text)[Save: #fmt-mod(save)]
                  },
                )
              })
              .flatten(),
          )
        } // end wide mode

        if view.skills.pairs().len() > 0 {
          v(0.5em)

          // 2. Render Skills (Adaptive)
          frame-header(ctx.i18n.frames.skills)
          if is-narrow {
            // Compact list for sidebar
            grid(
              columns: (1fr, auto),
              row-gutter: 0.4em,
              inset: (x: 2pt),
              ..view
                .skills
                .pairs()
                .map(((skill, (label, mod))) => {
                  (
                    text(size: 7pt)[#label],
                    text(size: 7pt, weight: "bold")[#fmt-mod(mod)],
                  )
                })
                .flatten(),
            )
          } else {
            // Spacious grid for main body
            grid(
              columns: (1fr, auto, 1fr, auto), // 2 columns of skills
              column-gutter: 2em,
              row-gutter: 0.5em,
              inset: (x: 4pt),
              ..view
                .skills
                .pairs()
                .map(((skill, (label, mod))) => {
                  (
                    text(size: 7pt)[#label],
                    text(size: 7pt, weight: "bold")[#fmt-mod(mod)],
                  )
                })
                .flatten(),
            )
          }
        }
      })
    })
  },
  none,
)
