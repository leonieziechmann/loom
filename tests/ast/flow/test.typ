#set page(width: auto, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#text(size: 10pt, weight: "bold", fill: eastern, tracking: 1pt, features: (
  scaps: 2,
))[
  Styled Text Node.
]

#par(leading: 1em, justify: true, first-line-indent: 1em)[
  This is a paragraph with specific leading and justification settings.
  It tests whether the engine preserves paragraph formatting during reconstruction.
]

#link("https://typst.app")[Link to Typst] --- Visible #hide[Invisible] Visible.
