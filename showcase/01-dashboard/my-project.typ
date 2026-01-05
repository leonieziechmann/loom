#import "dashboard-template.typ": project, phase, task

// Der User definiert nur Start & Rahmenbedingungen
#show: project.with(
  title: "Website Relaunch 2025",
  start: datetime(year: 2025, month: 12, day: 25),
  budget-limit: 15000,
)

// Der Content ist linear geschrieben...
= Phase 1: Konzeption
Die Basis für alles Weitere.

#phase("Design")[
  #task("Wireframes", days: 3, cost: 800)[
    Low-Fidelity Screens für Mobile & Desktop.
  ]
  #task("UI Kit", days: 2, cost: 600)[
    Definition von Farben, Typo und Spacings.
  ]
  #task("Final Screendesign", days: 5, cost: 2000)[
    High-Fidelity Screens für alle Key-Pages.
  ]
]

= Phase 2: Entwicklung
Hier wird es ernst.

#phase("Implementation")[
  // Loom weiß automatisch: Das startet NACH Phase 1
  #task("Frontend Core", days: 8, cost: 4000)[
    Aufsetzen von React & Tailwind.
  ]
  #task("Backend API", days: 10, cost: 4500)[
    Datenbank-Schema und Endpunkte.
  ]
]