#import "recipe-lib.typ": recipe, step, nutrition
#import "ing.typ"

// We want to cook for 4 people, but the base recipe is for 2.
// Loom will automatically double all ingredient amounts!
#show: recipe.with(
  title: "Rustic Roasted Tomato Basil Soup",
  subtitle: "A warming comfort food perfect for autumn evenings.",
  image: image("soup.jpg", width: 100%, height: 100%, fit: "cover"),
  serves: 4, 
  base: 2
)

#step(1)[
  Preheat your oven to 200°C. Cut #ing.tomato(750) in half 
  and place them on a baking sheet. Cut the top off #ing.garlic(1) 
  and drizzle everything with #ing.oil(1). 
  Season generously with #ing.salt_pep(1).
]

#step(2)[
  Roast in the oven for 40–45 minutes until the tomatoes are charred and soft. 
  The garlic should be golden and squeezable.
]

#step(3)[
  While the tomatoes roast, chop #ing.onion(.5). In a large pot, sauté 
  the onion until translucent. Squeeze the roasted garlic out of its skins into 
  the pot and add the tomatoes and #ing.stock(250).
]

#step(4)[
  Simmer for 10 minutes. Remove from heat and stir in #ing.basil(1). 
  Use an immersion blender to blitz until smooth. Stir in #ing.cream(50) 
  and serve immediately.
]