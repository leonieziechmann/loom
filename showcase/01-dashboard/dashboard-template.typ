#import "../../lib.typ": *

// Wir initialisieren eine Loom-Instanz für unser Dashboard
#let loom = construct-loom(<dashboard>)

// --- HILFSFUNKTIONEN ---
// Einfache Datums-Addition (Typst kann das nativ mit duration)
#let add-days(date, days) = date + duration(days: days)

// --- KOMPONENTEN ---

// 1. TASK (Das kleinste Teilchen)
#let task(name, days: 1, cost: 0, body) = (loom.motif.managed)(
  "task",
  scope: (ctx) => ctx, // Ändert den Scope für Kinder nicht
  
  measure: (ctx, _) => {
    // Hole den berechneten Zeitplan aus dem Context (erst in Pass 2 verfügbar)
    let schedule = ctx.at("schedule", default: (:))
    // Wir nutzen unseren eigenen Pfad als ID
    let my-path = ctx.sys.path.map(((pk, _)) => pk).join(">")
    let my-start-offset = schedule.at(my-path, default: 0) // Tage seit Projektstart
    
    // Daten senden: Dauer und Kosten nach oben
    let signal = (
      kind: "task",
      path: my-path,
      days: days,
      cost: cost,
      name: name
    )
    
    // View Model bauen (für das eigene Rendering)
    let view = (
      days: days,
      cost: cost,
      offset: my-start-offset
    )
    
    (signal, view)
  },
  
  draw: (ctx, public, view, body) => {
    let project-start = ctx.at("project-start")
    let my-start-date = add-days(project-start, view.offset)
    let my-end-date = add-days(my-start-date, view.days)
    
    block(stroke: (left: 2pt + gray), inset: (left: 1em, y: 0.5em))[
      *#name* \
      #text(size: 0.8em, fill: gray)[
        #my-start-date.display("[day].[month].") – #my-end-date.display("[day].[month].") 
        (#view.days Tage, #view.cost €)
      ]
      #body
    ]
  },
  body
)

// 2. PHASE (Gruppierung)
#let phase(name, body) = (loom.motif.managed)(
  "phase",
  measure: (ctx, children) => {
    // Leite einfach alle Signale der Kinder (Tasks) weiter nach oben
    // Wir aggregieren hier nichts selbst, das macht das Root-Element.
    // Aber wir könnten hier "Sub-Summen" bilden, wenn wir wollten.
    let signals = children.map(c => c.signal).flatten()
    (signals, (name: name))
  },
  draw: (ctx, public, view, body) => {
    block(fill: luma(245), radius: 4pt, inset: 8pt, width: 100%)[
      #text(weight: "bold", size: 1.1em)[Phase: #view.name]
      #body
    ]
  },
  body
)

// 3. PROJECT (Der Root-Manager)
#let project-motif(title, start, budget-limit, body) = (loom.motif.managed)(
  "project",
  // Injiziert globale Konstanten
  scope: (ctx) => ctx + (project-start: start),
  
  measure: (ctx, children) => {
    // A. FLATTEN: Alle Tasks aus allen Phasen sammeln
    // children.signal ist hier ein Array von Arrays (wegen Phasen)
    let tasks = query.select(children.flatten(), "task")
    
    // B. SCHEDULING (Die Logik!)
    // Wir berechnen linear den Offset für jeden Task
    let current-offset = 0
    let schedule-map = (:)
    let total-cost = 0
    
    for t in tasks {
      schedule-map.insert(t.path, current-offset)
      current-offset += t.days
      total-cost += t.cost
    }
    
    // C. RETURN
    // Payload: Der fertige Zeitplan für den Injector
    let payload = (
      schedule: schedule-map,
      total-days: current-offset,
      total-cost: total-cost,
      tasks: tasks // Für das Gantt-Chart im View
    )
    
    (payload, payload)
  },
  
  draw: (ctx, public, view, body) => {
    let total-days = view.total-days
    let budget-percent = calc.round(view.total-cost / budget-limit * 100)
    let bar-color = if budget-percent > 100 { red } else { teal }
    
    // 1. DAS DASHBOARD
    align(center)[
      #text(2em, weight: "bold")[#title] \
      Projektstart: #start.display("[day].[month].[year]")
    ]
    v(1em)
    
    block(stroke: 1pt + black, radius: 4pt, inset: 1em, width: 100%)[
      = Projekt Status
      *Budget:* #view.total-cost € / #budget-limit €
      #box(width: 100%, height: 1em, stroke: 1pt + gray, radius: 2pt)[
        #rect(width: budget-percent * 1%, height: 100%, fill: bar-color)
      ]
      
      #v(1em)
      *Timeline (#total-days Tage):*
      // Mini Gantt-Chart
      #let unit-width = if total-days != 0 { 100% / total-days } else { 0% }
      #stack(dir: ltr, spacing: 0pt, ..view.tasks.map(t => {
          box(
            width: t.days * unit-width, 
            height: 1.5em, 
            fill: blue.lighten(60%),
            stroke: 0.5pt + white,
            align(center+horizon, text(size: 6pt)[#t.name])
          )
      }))
    ]
    
    v(2em)
    
    // 2. DER CONTENT
    body
  },
  body
)

// --- ENTRY POINT ---
// Das ist der Wrapper um loom.weave, damit der User das nicht sieht
#let project(title: "Project", start: datetime.today(), budget-limit: 10000, body) = {
  (loom.weave)(
    project-motif(title, start, budget-limit, body),
    inputs: (schedule: (:)), // Leerer Start-Schedule
    injector: (ctx, data) => {
      if data == () { return ctx;}
      
      let signal = data.first(default: (:)).at("signal", default: (:))
      let schedule = signal.at("schedule", default: (:))
      
      ctx + (schedule: schedule)
    },
  )
}