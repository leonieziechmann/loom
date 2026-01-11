#set page(width: 10cm, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#block(
  width: 90%,
  height: auto,
  fill: luma(250),
  stroke: (left: 2pt + red, rest: 0.5pt + gray),
  radius: (top-right: 5pt, bottom-left: 5pt),
  inset: 1em,
  outset: 2pt,
  spacing: 1.5em,
  breakable: false,
  clip: false,
  sticky: true,
)[
  Complex Block Content with heavy styling.
]
Text before #box(baseline: 20%, stroke: 1pt + green, inset: 2pt)[Inline Box] Text after.
