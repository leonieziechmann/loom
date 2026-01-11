#import "/src/core/runtime.typ" as rt

#let use-loom = true
#let weave = if use-loom { rt.weave } else { doc => doc }
