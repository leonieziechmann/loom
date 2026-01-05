#import "cook-book-template.typ": cookbook, recipe, ing, shopping-list

#cookbook(title: "Leos Power Kitchen")[
  #shopping-list()
  
  #line(length: 100%)
  
  // Feature 1: Dynamic Scaling
  // Das Basis-Rezept ist für 2 Personen, wir wollen aber heute für 4 kochen.
  #recipe("Protein Pancakes", serves: 4, base: 2)[
    Für den Teig mischen wir #ing("Hafermehl", 200, unit: "g") mit 
    #ing("Eiklar", 4, unit: "Stk") (oder veganem Ersatz).
    Dazu eine Prise #ing("Salz", 1, unit: "Prise").
    
    // Feature 2: Safety Check (Vegetarian Guard)
    // Würde man hier #ing("Speck", 50, unit: "g", type: "meat") schreiben,
    // würde Loom das Rezept rot markieren.
  ]

  #recipe("Beeren-Topping", serves: 4, base: 4)[
    Einfach #ing("Blaubeeren", 150, unit: "g") und 
    #ing("Himbeeren", 100, unit: "g") aufkochen.
    Mit #ing("Agavendicksaft", 1, unit: "EL") süßen.
  ]

  // Feature 3: Auto-Aggregation
  // Loom sammelt alles ein, rechnet die Mengen hoch und fasst Gleiches zusammen.
]