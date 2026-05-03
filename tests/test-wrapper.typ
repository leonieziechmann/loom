#import "/src/lib.typ" as loom
#import loom: *

// 1. Construct a unique instance for your project.
// The key (<my-project>) isolates your components from other libraries.
#let (weave, motif, prebuild-motif) = loom.construct-loom(<loom-test>)

// 2. Export the specific tools you want to use.
// This keeps your API clean for the rest of your document.

// The Engine
#let weave = weave

// The Component Constructors
#let managed-motif = motif.managed
#let compute-motif = motif.compute
#let content-motif = motif.content
#let data-motif = motif.data
#let motif = motif.plain

// Prebuild Motifs
#let apply = prebuild-motif.apply
#let debug = prebuild-motif.debug
#let static = prebuild-motif.static
