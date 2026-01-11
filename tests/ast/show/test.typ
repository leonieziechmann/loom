#set page(width: auto, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#show "loom": name => box(
  fill: blue.lighten(80%),
  inset: 2pt,
  radius: 2pt,
)[#upper(name)]

Testing the keyword loom in a sentence.

#show heading: it => block(fill: luma(230), inset: 5pt)[*#it.body*]
== Styled Heading
