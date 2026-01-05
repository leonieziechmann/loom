#import "../../lib.typ": *

#let loom = construct-loom(<cookbook>)

// --- LOGIC HELPER ---
#let format-amount(amount) = {
  // Rundet auf 1 Nachkommastelle, wenn nötig, sonst glatt
  if calc.fract(amount) == 0 { int(amount) } else { calc.round(amount, digits: 1) }
}

// --- KOMPONENTEN ---

// 1. INGREDIENT (Das Datenelement)
#let ing(name, amount, unit: "", type: "veg") = (loom.motif.managed)(
  "ing",
  measure: (ctx, _) => {
    // 1. Context lesen: Wie viele Portionen kochen wir eigentlich?
    let scale = ctx.at("scale-factor", default: 1.0)
    
    // 2. Berechnen
    let real-amount = amount * scale
    
    // 3. Signalisieren (Daten nach oben schicken)
    let signal = (
      kind: "ingredient",
      name: name,
      amount: real-amount,
      unit: unit,
      type: type
    )
    
    // View für mich selbst zurückgeben
    (signal, (amount: real-amount, unit: unit))
  },
  
  draw: (ctx, public, view, body) => {
    // Einfach im Fließtext rendern, fettgedruckt
    strong[#format-amount(view.amount)#view.unit #name]
  },
  none // Ingredients haben keinen Body
)

// 2. RECIPE (Der Context Provider)
#let recipe(name, serves: 2, base: 2, body) = (loom.motif.managed)(
  "recipe",
  // Hier injizieren wir den Scaling-Faktor für alle Kinder (Ingredients)
  scope: (ctx) => ctx + (scale-factor: serves / base),
  
  measure: (ctx, children) => {
    // Wir leiten die Signale der Zutaten einfach durch an das Cookbook
    let signals = children.map(c => c.signal).flatten()
    
    // Check auf Fleisch (Leonie-Rule)
    let has-meat = signals.any(s => s != none and s.at("type", default: "veg") == "meat")
    
    (signals, (name: name, serves: serves, has-meat: has-meat))
  },
  
  draw: (ctx, public, view, body) => {
    block(width: 100%, inset: (y: 1em))[
      #text(1.2em, weight: "bold")[#view.name] 
      #text(0.8em, style: "italic")[ (für #view.serves Pers.)]
      
      // Die Warnung, falls jemand gegen die Regeln verstößt
      #if view.has-meat {
        text(fill: red, weight: "bold")[ \u{26A0} WARNUNG: Dieses Rezept enthält Fleisch! \u{26A0}]
      }
      
      #v(0.5em)
      #body
    ]
  },
  body
)

// 3. SHOPPING LIST (Der Consumer)
// Das hier ist spannend: Ein Element, das NUR rendert, basierend auf globalen Daten.
#let shopping-list() = (loom.motif.data)(
  "shopping-list",
  scope: (ctx) => ctx, // Braucht keinen Scope
  measure: (ctx) => {
    // Wir greifen auf die globalen Daten zu, die das Cookbook gesammelt hat
    let all-ingredients = ctx.at("global-ingredients", default: ())
    
    // AGGREGATION LOGIC
    // Wir gruppieren nach Name und Unit
    let list = (:)
    for item in all-ingredients {
      let key = item.name + "|" + item.unit
      let current = list.at(key, default: 0)
      list.insert(key, current + item.amount)
    }
    
    // View bauen
    (list: list)
  }
)

// 4. COOKBOOK (Der Root Manager)
#let cookbook-motif(title, body) = (loom.motif.managed)(
  "cookbook",
  scope: (ctx) => ctx,
  
  measure: (ctx, children) => {
    // Sammle alle Zutaten aus allen Rezepten
    let all-signals = children.map(c => c.signal).flatten()
    let ingredients = all-signals.filter(s => s != none and s.kind == "ingredient")
    
    // Sende sie als Payload, damit wir sie im nächsten Pass injizieren können
    let payload = (ingredients: ingredients)
    (payload, payload)
  },
  
  draw: (ctx, public, view, body) => {
    // Wir müssen den Body rendern, aber wir müssen auch die Shopping List finden
    // und ihr die Daten geben? Nein! 
    // Loom injectet die Daten in den Context, auf den die Shopping-List zugreift.
    
    align(center, text(2em, font: "Permanent Marker", weight: "bold")[#title])
    v(2em)
    body
    
    // Falls der User vergessen hat, die Liste zu platzieren, könnten wir sie hier erzwingen.
    // Aber wir haben ja eine explizite Komponente dafür gebaut.
    
    // Wir rendern die Shopping List hier manuell, falls sie nicht im Body war?
    // Besser: Die Shopping-List-Komponente holt sich die Daten selbst.
    // Dafür müssen wir aber erst den Draw-Pass für die Shopping-List verstehen.
    // Ah, wait: `shopping-list` ist ein `data-motif` im Beispiel oben. 
    // Das rendert nichts. Wir brauchen ein `content-motif` oder wir rendern es hier manuell.
    
    // FIX: Wir machen `shopping-list` zu einem normalen Motif, das rendert.
    // Siehe unten bei "Refined Implementation".
  },
  body
)

// --- REFINED SHOPPING LIST (Content Motif) ---
#let shopping-list-render() = (loom.motif.content)(
  draw: (ctx, _) => {
    let raw-list = ctx.at("global-ingredients", default: ())
    
    if raw-list.len() == 0 [
      _Noch keine Zutaten auf der Liste._
    ] else {
      // Aggregation (wiederholen oder vorbrechnet nutzen)
      let aggregated = (:)
      for item in raw-list {
        let key = item.name // Simple Key
        let entry = aggregated.at(key, default: (amount: 0, unit: item.unit))
        // Addieren
        entry.amount += item.amount
        aggregated.insert(key, entry)
      }
      
      block(fill: yellow.lighten(90%), stroke: 1pt + yellow.darken(20%), inset: 1em, radius: 2pt, width: 100%)[
        = Einkaufsliste
        #for (name, data) in aggregated {
           [- #format-amount(data.amount) #data.unit #name]
        }
      ]
    }
  }
)

// --- ENTRY POINT ---
#let cookbook(title: "Kochbuch", body) = {
  (loom.weave)(
    [#cookbook-motif(title, body)],
    inputs: (global-ingredients: ()),
    injector: (ctx, data) => {
      // Daten vom Root (data) in den globalen Context (global-ingredients) schieben
      if data == () { return ctx }
      
      let signal = data.first(default: (:)).at("signal", default: (:))
      let ings = signal.at("ingredients", default: ())
      
      ctx + (global-ingredients: ings)
    },
  )
}

#let shopping-list = shopping-list-render