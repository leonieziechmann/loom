#set page(width: 10cm, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#grid(
  columns: (1fr, 2fr, auto),
  gutter: 1em,
  fill: (c, r) => if calc.even(c) { luma(240) } else { white },
  align: (c, r) => (left, center).at(calc.rem(r, 2)),
  [Fluid 1], [Fluid 2], [Auto],
  [A], [B], [C],
)
