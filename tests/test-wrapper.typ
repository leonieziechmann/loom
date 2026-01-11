#import "../lib.typ": *

#let loom = construct-loom(<loom-test>)

#let weave = loom.weave

#let motif = loom.motif.plain
#let managed-motif = loom.motif.managed
#let compute-motif = loom.motif.compute
#let data-motif = loom.motif.data
#let content-motif = loom.motif.content

#let debug = loom.prebuild-motif.debug
#let apply = loom.prebuild-motif.apply
