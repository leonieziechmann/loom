#set page(width: auto, height: auto)
#import "/tests/ast/helper.typ": weave
#show: weave

#context {
  let size = measure[Text].width
  [The text width is approximately #size]
}
