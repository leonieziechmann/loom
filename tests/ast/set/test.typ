#set page(width: auto, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#set text(fill: teal, weight: "bold")
#set block(stroke: 1pt + red, inset: 5pt)

This text should be teal and bold.
#block[This block inherits the red stroke.]

// Testing nested set rules
#block[
  #set text(fill: purple)
  This should be purple.
]
