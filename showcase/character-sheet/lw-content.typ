#import "@preview/loom:0.1.0": construct-loom

#let (weave, motif, prebuild-motif) = construct-loom(<character-sheet-content>)

#let managed-motif = motif.managed
#let compute-motif = motif.compute
#let content-motif = motif.content
#let data-motif = motif.data
#let motif = motif.plain

#let apply = prebuild-motif.apply
#let debug = prebuild-motif.debug
