#set page(width: auto, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#table(
  columns: 2,
  stroke: 0.5pt + gray,
  table.header([*Header 1*], [*Header 2*]),
  [Row 1, Col 1],
  table.cell(
    rowspan: 2,
    align: center + horizon,
    fill: teal.lighten(80%),
  )[Rowspan 2],
  [Row 2, Col 1],
  [Row 3, Col 1], [Row 3, Col 2],
)
