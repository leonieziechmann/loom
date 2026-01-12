#import "character-sheet.typ": *
#import "i18n.typ"

#show: character-sheet.with(
  name: "Leonie",
  level: 5,
  class: "Paladin",
  race: "Human",
  xp: 12500,
  senses: "Pass. Perc. +1",
  background: "Aristocrate",
  alignment: "Chaotic-Good",
  prof-bonus: 3,
  aura-bonus: 0,
  i18n: (
    frames: (
      stats: "Hallo",
    ),
  ),
)

#sidebar[
  #hero-stats(
    stats: (str: 16, dex: 12, con: 14, int: 10, wis: 13, cha: 15),
    proficiencies: ("wis", "cha"),
    skills: (
      "athletics",
      "persuasion",
      "insight",
      "religion",
    ),
  )

  #features({
    feature("Auro of Protection")[
      +2 buff for saves for allies within 3m.
    ]

    feature("Godly Insight")[
      Action, sense Celestial/Fiends/Undead (4x/day)
    ]
  })
]

#vitals({
  armor(18, "Plate")
  initiative[+1]
  health(32, 42)
  dice("5d10")
})

#attacks({
  attack("Holy Swoard", "+6", "1d8+3", "Hieb", notes: "Vielseitig (1d10)")
  attack("Spear", "+6", "1d6+3", "Stick", notes: "Range 9/36m")
  attack("Godly Radiate", "DC 13", "2d8", "Rad", notes: "vs. Undead +1d8")
})

== Story & Notes
_#lorem(8)_

#lorem(80)

#bottom[
  #inventory[
    #item("Shield", weight: 1)
    #item("Shield", weight: 5, quantity: 3)
    #item("Shield")
    #item("Shield", weight: 3)
  ]
]

== Background Story
#lorem(40)

#lorem(90)
