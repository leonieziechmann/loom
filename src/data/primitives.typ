/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/data/primitives.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Defines the core constructor primitives for creating Loom components.
 * These functions wrap user-defined logic (measure, draw, scope) into the
 * standard metadata structure required by the Engine.
 * ----------------------------------------------------------------------------
 */

#import "../lib/assert.typ": assert-types
#import "../core/context.typ"
#import "frame.typ"
#import "path.typ"


/// The base primitive for creating a Loom component.
///
/// Wraps the provided functions in a metadata block labeled with `key`.
/// This is the rawest form of a component; it does not automatically handle
/// path management or frame wrapping (see `managed-motif` for that).
///
/// -> content
#let motif(
  /// The namespace key used by the engine to identify this component.
  /// -> label
  key: <motif>,
  /// Function `ctx => ctx`. Modifies the context for children.
  /// -> function
  scope: ctx => ctx,
  /// Function `(ctx, children-data) => (public, view)`.
  /// Calculates data and prepares the view model.
  /// -> function
  measure: (ctx, children-data) => (none, none),
  /// Function `(ctx, public, view, body) => content`.
  /// Renders the component.
  /// -> function
  draw: (ctx, public, view, body) => body,
  /// The content body of the component.
  /// -> content
  body,
) = [#metadata((
    type: "component",
    scope: if scope == none { c => c } else { scope },
    measure: if measure == none { (..v) => (none, none) } else { measure },
    draw: if draw == none { (..v, body) => body } else { draw },
    body: body,
  ))#key]


/// A "Managed" motif that automatically handles path tracking.
///
/// Unlike the raw `motif`, this primitive:
/// 1. Pushes its `name` to `sys.path` in the scope.
/// 2. Wraps the result of `measure` in a `frame` object containing the current path and key.
///
/// Use this for components that need to be addressable or have an identity in the tree.
///
/// -> content
#let managed-motif(
  /// The specific name/kind of this component (e.g., "task", "section").
  /// -> str
  name,
  /// The namespace key.
  /// -> label
  key: <motif>,
  /// Function `ctx => ctx`.
  /// -> function
  scope: ctx => ctx,
  /// Function `(ctx, children-data) => (public, view)`.
  /// -> function
  measure: (ctx, children-data) => (none, none),
  /// Function `(ctx, public, view, body) => content`.
  /// -> function
  draw: (ctx, public, view, body) => body,
  /// -> content
  body,
) = motif(
  key: key,
  scope: ctx => {
    if scope == none { return ctx }

    let path-ctx = path.append(ctx, name)
    return scope(path-ctx)
  },
  measure: (ctx, children-data) => {
    if measure == none { return (none, none) }

    let (user-public, user-view) = measure(ctx, children-data)
    let current-path = path.get(ctx)

    // Auto-management: Wrap public data in a standard Frame
    let motif-frame = frame.new(
      kind: name,
      key: current-path.last(default: "unknown"),
      path: current-path,
      signal: user-public,
    )

    return (motif-frame, user-view)
  },
  draw: draw,
  body,
)

/// A helper primitive for components that primarily calculate data.
///
/// It simplifies the `measure` signature to return only the public payload (`public`).
/// The view model is automatically set to `none`.
///
/// -> content
#let compute-motif(
  /// The namespace key.
  /// -> label
  key: <motif>,
  /// If provided, creates a `managed-motif`. If `none`, creates a raw `motif`.
  /// -> str | none
  name: none,
  /// Function `ctx => ctx`.
  /// -> function
  scope: ctx => ctx,
  /// Function `(ctx, children-data) => public`.
  /// Note: Returns only the public payload.
  /// -> function
  measure: (ctx, children-data) => none,
  /// -> content
  body,
) = {
  let args = (
    scope: if scope == none { ctx => ctx } else { scope },
    measure: (ctx, children-data) => {
      if measure == none { return (none, none) }
      return (measure(ctx, children-data), none)
    },
  )

  if name == none { motif(key: key, ..args, body) } else {
    managed-motif(key: key, name, ..args, body)
  }
}

/// A specialized primitive for purely data-driven components (Leaves).
///
/// These components do not render anything (`body` is `none`) and are used
/// solely to inject data (signals) into the system.
///
/// -> content
#let data-motif(
  /// The namespace key.
  /// -> label
  key: <component>,
  /// The name/kind of the data node.
  /// -> str
  name,
  /// Function `ctx => ctx`.
  /// -> function
  scope: ctx => ctx,
  /// Function `ctx => public`.
  /// Note: Data motifs typically don't process children.
  /// -> function
  measure: ctx => none,
) = compute-motif(
  key: key,
  name: name,
  scope: if scope == none { ctx => ctx } else { scope },
  measure: (ctx, _) => {
    if measure == none { return none }
    measure(ctx)
  },
  none,
)

/// A specialized primitive for purely visual components.
///
/// These components participate in the flow but do not emit signals or manage paths.
/// They transparently propagate their children's signals.
///
/// -> content
#let content-motif(
  /// The namespace key.
  /// -> label
  key: <component>,
  /// Function `ctx => ctx`.
  /// -> function
  scope: ctx => ctx,
  /// Function `(ctx, body) => content`.
  /// -> function
  draw: (ctx, body) => body,
  /// Optional positional body argument
  /// -> ..content
  ..body,
) = motif(
  key: key,
  scope: scope,
  measure: (_, children-data) => (
    if children-data == () { none } else { children-data },
    none,
  ),
  draw: (ctx, _, _, body) => {
    if draw == none { return none }
    return draw(ctx, body)
  },
  body.pos().first(default: none),
)
