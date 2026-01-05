#import "../../lib.typ": *

#let loom = construct-loom(<rpg>)

// --- RPG LOGIC HELPER ---
#let calc-mod(score) = calc.floor((score - 10) / 2)

// --- KOMPONENTEN ---

// 1. STAT (Basiswert)
#let stat(name, value) = (loom.motif.managed)(
  "stat",
  measure: (ctx, _) => {
    // Checken, ob es Buffs für uns gibt (vom Root injiziert)
    let buffs = ctx.at("active-buffs", default: (:))
    let bonus = buffs.at(name, default: 0)
    
    let final-value = value + bonus
    let mod = calc-mod(final-value)
    
    // Signal: "Ich bin STR und habe Wert 18 (Mod +4)"
    let signal = (kind: "stat", name: name, value: final-value, mod: mod)
    
    // View: Für die Anzeige
    (signal, (name: name, value: final-value, mod: mod, is-buffed: bonus > 0))
  },
  
  draw: (ctx, public, view, body) => {
    box(stroke: 1pt + gray, inset: 8pt, radius: 3pt, width: 100%)[
      #align(center)[
        *#view.name* \
        #text(size: 2em)[#view.value] 
        #if view.is-buffed { text(fill: blue, size: 0.8em)[(+#(view.value - (view.value - view.mod*2 - 10))?)] } \ // Vereinfacht
        Mod: #if view.mod >= 0 { "+" } #view.mod
      ]
    ]
  },
  none
)

// 2. BUFF (Verändert Stats)
#let buff(name, target: "", value: 0) = (loom.motif.managed)(
  "buff",
  measure: (ctx, _) => {
    // Signalisiert einfach nur: "STR +2"
    let signal = (kind: "buff", target: target, value: value)
    (signal, (name: name, value: value, target: target))
  },
  draw: (ctx, public, view, _) => {
    text(fill: blue)[★ *#view.name*: +#view.value auf #view.target]
  },
  none
)

// 3. WEAPON (Hängt von Stats ab)
#let weapon(name, damage: "1d6", scaling: "STR") = (loom.motif.managed)(
  "weapon",
  measure: (ctx, _) => {
    // 1. Hole alle Stats aus dem Context (injiziert vom Root)
    let stats = ctx.at("global-stats", default: (:))
    
    // 2. Finde meinen Scaling-Stat
    let my-stat = stats.at(scaling, default: (mod: 0))
    let bonus = my-stat.mod
    
    // 3. Signalisiere meinen totalen Schaden
    let signal = (kind: "weapon", name: name, damage: damage, bonus: bonus)
    
    (signal, (name: name, damage: damage, bonus: bonus, scaling: scaling))
  },
  
  draw: (ctx, public, view, _) => {
    let bonus-str = if view.bonus >= 0 { "+" + str(view.bonus) } else { str(view.bonus) }
    
    block(fill: luma(240), inset: 8pt, radius: 2pt, width: 100%)[
      #stack(dir: ltr, spacing: 1fr,
        [*#view.name* (#view.scaling)],
        [#view.damage #text(weight: "bold", fill: eastern)[#bonus-str]]
      )
    ]
  },
  none
)

// 4. DAMAGE SUMMARY (Der Konsument am Anfang)
#let damage-summary() = (loom.motif.content)(
  draw: (ctx, body) => {
    // Holt sich die fertigen Waffen-Daten vom Root
    let weapons = ctx.at("global-weapons", default: ())
    
    if weapons.len() == 0 [
      _Keine Waffen ausgerüstet._
    ] else {
      block(stroke: (left: 4pt + eastern), inset: 1em, fill: eastern.lighten(90%))[
        *Kampfwerte:*
        #for w in weapons {
          let bonus = if w.bonus >= 0 { "+" + str(w.bonus) } else { str(w.bonus) }
          list(marker: [--])[#w.name: #w.damage #bonus]
        }
      ]
    }
  }
)

// 5. ROOT (Der Gehirn-Schmelz-Topf)
#let char-sheet-motif(name, body) = (loom.motif.managed)(
  "char-sheet",
  scope: (ctx) => ctx,
  
  measure: (ctx, children) => {
    let signals = children.flatten().map(c => c.signal)
    
    // A. Buffs sammeln
    let buff-signals = signals.filter(s => s != none and s.kind == "buff")
    let active-buffs = (:)
    for b in buff-signals {
      let current = active-buffs.at(b.target, default: 0)
      active-buffs.insert(b.target, current + b.value)
    }
    
    // B. Stats sammeln (Map bauen: "STR" -> {val: 18, mod: 4})
    let stat-signals = signals.filter(s => s != none and s.kind == "stat")
    let global-stats = (:)
    for s in stat-signals {
      global-stats.insert(s.name, s)
    }
    
    // C. Waffen sammeln (für Summary)
    let weapon-signals = signals.filter(s => s != none and s.kind == "weapon")
    
    // Payload für den nächsten Pass
    let payload = (
      active-buffs: active-buffs,
      global-stats: global-stats,
      global-weapons: weapon-signals
    )
    
    (payload, payload)
  },
  
  draw: (ctx, public, view, body) => {
    align(center, text(1.5em, weight: "black")[#name])
    v(1em)
    body
  },
  body
)

// --- ENTRY POINT ---
#let char-sheet(name: "Hero", body) = {
  (loom.weave)(
    char-sheet-motif(name, body),
    // Wir erlauben hier 3 Passes, weil die Abhängigkeitskette länger ist:
    // Buff -> Stat -> Weapon -> Summary
    max-passes: 4, 
    inputs: (active-buffs: (:), global-stats: (:), global-weapons: ()),
    injector: (ctx, data) => {
      if data == () { return ctx }
      
      let signal = data.first(default: (:)).at("signal", default: (:))
      ctx + (
        active-buffs: signal.at("active-buffs", default: (:)),
        global-stats: signal.at("global-stats", default: (:)),
        global-weapons: signal.at("global-weapons", default: ())
      )
    }
  )
}