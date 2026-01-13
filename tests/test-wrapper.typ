#import "/lib.typ" as loom
#import loom: *


#let test-loom = construct-loom(<loom-test>)

#let weave = test-loom.weave

#let motif = test-loom.motif.plain
#let managed-motif = test-loom.motif.managed
#let compute-motif = test-loom.motif.compute
#let data-motif = test-loom.motif.data
#let content-motif = test-loom.motif.content

#let debug = test-loom.prebuild-motif.debug
#let apply = test-loom.prebuild-motif.apply
