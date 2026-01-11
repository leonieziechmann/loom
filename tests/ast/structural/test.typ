#set page(width: auto, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#let depth = 50
#range(1, depth).fold(
  [Core Payload],
  (acc, i) => box(inset: 1pt, stroke: (
    thickness: 0.5pt,
    paint: black.lighten(i / depth * 100%),
  ))[#acc],
)

Start
#none
Middle
#[] // Empty content block
End
