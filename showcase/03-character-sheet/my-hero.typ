#import "character-sheet-template.typ": char-sheet, stat, weapon, buff, damage-summary

#show: char-sheet.with(name: "Leonie the Paladin")
  
// 1. DER HEADER (Hängt von Daten weiter unten ab!)
// In nativem Typst wäre das hier leer oder 0, weil 'sword' noch nicht existiert.
#damage-summary() 

#line(length: 100%)

// 2. DIE STATS
= Attribute
#grid(columns: 3, gutter: 1em,
  stat("STR", 16), // Mod: +3
  stat("DEX", 12), // Mod: +1
)

// 3. DAS EQUIPMENT (Hängt von Stats ab)
= Ausrüstung
// Scaling: "STR" bedeutet, Loom muss den STR-Wert suchen, 
// den Mod berechnen und hier addieren.
#weapon("Heiliges Langschwert", damage: "1d8", scaling: "STR")

#weapon("Dolch", damage: "1d4", scaling: "DEX")

// 4. DYNAMISCHE EFFEKTE (Verändert Stats rückwirkend!)
= Aktive Effekte
// Dieser Buff erhöht STR um 2. 
// Das bedeutet: STR wird 18 (+4). 
// Das Schwert oben muss also plötzlich mehr Schaden machen!
#buff("Göttlicher Zorn", target: "STR", value: 2)