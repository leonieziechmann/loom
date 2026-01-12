// 1. Define the relationships
#let skill-relations = (
  athletics: "str",
  acrobatics: "dex",
  stealth: "dex",
  arcana: "int",
  history: "int",
  investigation: "int",
  nature: "int",
  religion: "int",
  insight: "wis",
  medicine: "wis",
  perception: "wis",
  survival: "wis",
  deception: "cha",
  intimidation: "cha",
  performance: "cha",
  persuasion: "cha",
)

// 2. Define the calculations
#let score-to-mod(score) = calc.floor((score - 10) / 2)

#let calc-prof(level) = 2 + calc.floor((level - 1) / 4)
