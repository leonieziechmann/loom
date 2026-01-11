#set page(width: auto, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#circle(radius: 5mm, fill: red)
#rect(width: 1cm, height: 1cm, radius: 2mm, fill: yellow)
#line(start: (0pt, 0pt), end: (1cm, 10pt), stroke: 2pt + blue)
