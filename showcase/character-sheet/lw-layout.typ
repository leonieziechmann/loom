#import "../../lib.typ": construct-loom

#let (weave, motif, ..) = construct-loom(<character-sheet-layout>)

#let managed-motif = motif.managed
#let compute-motif = motif.compute
#let content-motif = motif.content
#let data-motif = motif.data
#let motif = motif.plain
