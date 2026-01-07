#import "../../lib.typ"
#import lib: *
#let scope = lib.context.scope

// 1. Initialize Loom
#let loom = construct-loom(<recipe-loom>)

// --- STYLING CONFIG ---
#let theme = (
  accent: rgb("#E67E22"),
  dark: rgb("#2C3E50"),
  light: rgb("#7F8C8D"),
  bg: luma(240),
)

#let format-amount(num) = {
  if num == int(num) { str(int(num)) } else { str(calc.round(num, digits: 1)) }
}

// --- COMPONENTS ---

// A. INGREDIENT
// Akzeptiert Nährwerte für die Auto-Berechnung
#let ing(name, amount, unit: "", kcal: 0, prot: 0, carbs: 0, fat: 0) = (
  loom.motif.managed
)(
  "ing",
  measure: (ctx, _) => {
    let factor = ctx.at("scale-factor", default: 1.0)
    let final-amount = amount * factor

    // Nährwerte skalieren (für die Summe im Root)
    let final-nut = (
      kcal: kcal * factor,
      prot: prot * factor,
      carbs: carbs * factor,
      fat: fat * factor,
    )

    let signal = (
      name: name,
      amount: final-amount,
      unit: unit,
      ..final-nut,
    )

    (signal, (amount: final-amount, unit: unit))
  },
  draw: (ctx, public, view, _) => {
    text(fill: theme.accent)[*#format-amount(view.amount)#view.unit #name*]
  },
  none,
)

// B. NUTRITION (Manuell) [WIEDER EINGEFÜGT]
// Erlaubt das manuelle Überschreiben der Nährwerte pro Portion.
#let nutrition(kcal, prot, carbs, fat) = (loom.motif.data)(
  "nutrition",
  measure: ctx => (
    kind: "nutrition",
    kcal: kcal,
    prot: prot,
    carbs: carbs,
    fat: fat,
  ),
)

// C. STEP
#let step(number, body) = (loom.motif.managed)(
  "step",
  measure: (ctx, children) => {
    let local-ings = query.collect(children, kind: "ing")
    (local-ings, (number: number, local-ings: local-ings.map(c => c.signal)))
  },
  draw: (ctx, public, view, body) => {
    grid(
      columns: (30%, 1fr),
      column-gutter: 15pt,
      align(right)[
        #set text(size: 9pt, fill: theme.light)
        #if view.local-ings.len() > 0 [
          *Use in this step:* \
          #for i in view.local-ings [
            #format-amount(i.amount)#i.unit #i.name \
          ]
        ]
      ],
      [
        #text(fill: theme.accent, weight: "bold", size: 14pt)[#view.number] \
        #body
        #v(1.5em)
      ],
    )
  },
  body,
)

// D. RECIPE (Logic Hub)
#let recipe-motif(title, subtitle, image-content, serves, base, body) = (
  loom.motif.managed
)(
  "recipe",
  scope: ctx => ctx + (scale-factor: serves / base),

  measure: (ctx, children) => {
    //let steps = query.select(children, "step")
    //let ingrediants = steps.map(s => s.signal).flatten()
    let ingrediants = query.collect(children, kind: "ing").map(c => c.signal)

    // 1. Check auf MANUELLE Nutrition
    let manual-nut = query.find(children, "nutrition")

    // 2. Shopping List & Auto-Nutrition berechnen
    let shopping-list = (:)
    let total-nut = (kcal: 0, prot: 0, carbs: 0, fat: 0)

    for item in ingrediants {
      let key = item.name + "|" + item.unit
      let current = shopping-list.at(key, default: (
        amount: 0,
        unit: item.unit,
        name: item.name,
      ))
      current.amount += item.amount
      shopping-list.insert(key, current)

      // Nur summieren, wenn wir KEINE manuellen Werte haben (Performance sparen)
      if manual-nut == none {
        total-nut.kcal += item.at("kcal", default: 0)
        total-nut.prot += item.at("prot", default: 0)
        total-nut.carbs += item.at("carbs", default: 0)
        total-nut.fat += item.at("fat", default: 0)
      }
    }

    // 3. Entscheidung: Manuell oder Automatisch?
    // Wir bereiten Strings für die View vor, um "4g" und 4.0 zu vereinheitlichen.
    let display-nut = none

    if manual-nut != none {
      // Fall A: Manuell (User Inputs direkt nehmen)
      display-nut = manual-nut.signal
    } else if total-nut.kcal > 0 {
      // Fall B: Automatisch (Durch Serves teilen)
      let s = if serves > 0 { serves } else { 1 }
      display-nut = (
        kcal: str(calc.round(total-nut.kcal / s)),
        prot: str(calc.round(total-nut.prot / s)) + "g",
        carbs: str(calc.round(total-nut.carbs / s)) + "g",
        fat: str(calc.round(total-nut.fat / s)) + "g",
      )
    }

    (
      none,
      (
        shopping-list: shopping-list,
        display-nut: display-nut,
        serves: serves,
      ),
    )
  },

  draw: (ctx, public, view, body) => {
    // ... Header Helper (unverändert) ...
    let render-header() = {
      v(1em)
      text(24pt, weight: "bold", fill: theme.accent, title)
      v(0.5em)
      text(14pt, style: "italic", fill: theme.light, subtitle)
      v(1.5em)
      if image-content != none {
        block(
          width: 100%,
          height: 6cm,
          fill: theme.bg,
          radius: 10pt,
          clip: true,
          align(center + horizon, image-content),
        )
      }
      v(2em)
    }

    let render-meta() = {
      block(
        width: 100%,
        stroke: (bottom: 1pt + theme.light),
        inset: (bottom: 0.5em),
      )[
        #text(
          fill: theme.dark,
          weight: "bold",
          size: 1.2em,
        )[Serves: #view.serves]
      ]
      v(1em)
    }

    let render-nutrition() = {
      let vals = view.display-nut
      if vals != none {
        rect(
          width: 100%,
          fill: theme.accent.lighten(90%),
          stroke: none,
          radius: 5pt,
          inset: 10pt,
          align(center, text(size: 9pt)[
            *Nutrition per Serving* \ #v(5pt)
            #grid(
              columns: 4,
              gutter: 5pt,
              [*#vals.kcal* \ kcal],
              [*#vals.prot* \ Prot],
              [*#vals.carbs* \ Carb],
              [*#vals.fat* \ Fat],
            )
          ]),
        )
      }
    }

    let render-shopping-list() = {
      v(2em)
      text(12pt, weight: "bold", fill: theme.accent)[Shopping List]
      line(length: 100%, stroke: 1pt + theme.accent)
      v(0.5em)
      set list(marker: [•])
      for (_, item) in view.shopping-list {
        list.item[#format-amount(item.amount)#item.unit #item.name]
      }
    }

    // --- MAIN RENDER ---
    render-header()
    grid(
      columns: (25%, 1fr),
      column-gutter: 2em,
      [
        #render-meta()
        #render-nutrition()
        #render-shopping-list()
      ],
      [
        #text(16pt, weight: "bold")[Instructions]
        #v(1em)
        #body
      ],
    )
  },
  body,
)

// --- PUBLIC ENTRY POINT ---
#let recipe(title: "", subtitle: "", image: none, serves: 2, base: 2, body) = {
  set text(font: "Linux Libertine", fill: theme.dark, size: 11pt)
  set page(margin: 2cm, numbering: "1")

  (loom.weave)(
    recipe-motif(title, subtitle, image, serves, base, body),
  )
}
