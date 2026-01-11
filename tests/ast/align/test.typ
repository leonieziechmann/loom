#set page(width: auto, height: auto)
#import "/tests/ast/helper.typ": *
#show: weave

#rect(width: 10cm, fill: luma(240), inset: 8pt)[
  *Align Check:*
  #align(center + horizon)[Center/Horizon Aligned Text]
  #align(right)[Explicit Named Argument]
]
