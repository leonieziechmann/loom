/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/query.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Provides traversal and aggregation utilities for the component data tree.
 * Used in `measure` functions to extract, filter, and summarize data from children.
 * ----------------------------------------------------------------------------
 */

#import "assert.typ": assert-types
#import "collection.typ"


// --- 1. SEARCH & TRAVERSAL ---

/// Filters a list of children frames by kind.
///
/// This is a shallow operation; it only checks the immediate list provided.
///
/// -> array<frame>
#let select(
  /// The list of frames to search.
  /// -> array<frame>
  children, 
  /// The component kind to match (e.g., "task").
  /// -> str
  kind
) = {
  if children == none { return () }
  children.filter(c => c != none and c.at("kind", default: none) == kind)
}

/// Filters children using a custom predicate function.
///
/// # Example
/// ```typ
/// where(children, c => c.signal.cost > 100)
/// ```
///
/// -> array<frame>
#let where(
  /// -> array<frame>
  children,
  /// Function `frame => bool`.
  /// -> function
  predicate
) = {
  if children == none { return () }
  children.filter(c => c != none and predicate(c))
}

/// Finds the first child of a specific kind.
///
/// -> frame | none
#let find(
  /// -> array<frame>
  children, 
  /// -> str
  kind, 
  /// Value to return if not found.
  /// -> any
  default: none
) = {
  select(children, kind).first(default: default)
}

/// Recursively collects all descendants of a specific kind (or all if kind is none).
///
/// Traverses the `children` array of each frame up to the specified depth.
/// Returns a flat array of frames.
///
/// -> array<frame>
#let collect(
  /// The root list of frames.
  /// -> array<frame>
  children, 
  /// The kind to filter by. If `none`, returns all nodes.
  /// -> str | none
  kind: none, 
  /// Maximum recursion depth.
  /// -> int
  depth: 10
) = {
  assert-types(depth, int)
  if depth <= 0 or children == none { return () }
  
  let result = ()

  for node in children {
    if node == none { continue }

    // 1. Add self if matching (or if no filter)
    let matches = if kind == none { true } else { node.at("kind", default: none) == kind }
    
    if matches {
      // Return a clean copy without the children array to avoid infinite dumps/cycles
      let clean-node = node
      if "children" in clean-node { let _ = clean-node.remove("children") }
      result.push(clean-node)
    }

    // 2. Recurse into children
    let inner = node.at("children", default: ())
    if inner != () {
      result += collect(inner, kind: kind, depth: depth - 1)
    }
  }

  return result
}


// --- 2. DATA EXTRACTION & AGGREGATION ---

/// Extracts a specific field from the signals of all children.
///
/// Useful for creating lists of values (e.g., all prices, all names).
///
/// -> array
#let pluck(
  /// -> array<frame>
  children,
  /// The key to look for in `child.signal`.
  /// -> str
  key,
  /// -> any
  default: none
) = {
  if children == none { return () }
  children
    .filter(c => c != none)
    .map(c => c.at("signal", default: (:)).at(key, default: default))
}

/// Sums up a specific numeric field from the signals of all children.
///
/// A shortcut for `pluck(..).sum()`.
///
/// -> int | float
#let sum-signals(
  /// -> array<frame>
  children,
  /// The key containing the number in `child.signal`.
  /// -> str
  key,
  /// -> int | float
  default: 0
) = {
   pluck(children, key, default: default).sum(default: default)
}

/// Groups children by a specific value in their signal.
///
/// Returns a dictionary where keys are the values found in the signal field `key`.
///
/// # Example
/// Grouping ingredients by category:
/// `group-by(ingredients, "category")` -> `("fruit": (..), "veg": (..))`
///
/// -> dictionary<str, array<frame>>
#let group-by(
  /// -> array<frame>
  children,
  /// The signal key to group by.
  /// -> str
  key
) = {
  let groups = (:)
  for child in children {
    if child == none { continue }
    let signal = child.at("signal", default: (:))
    
    // We convert the grouping key to string to ensure it can be a dict key
    let group-key = str(signal.at(key, default: "other"))
    
    let current = groups.at(group-key, default: ())
    current.push(child)
    groups.insert(group-key, current)
  }
  groups
}

/// Aggregates data from a list of children using a reducer function.
///
/// Operates directly on the `signal` of the children.
///
/// -> any
#let fold(
  /// The list of frames.
  /// -> array<frame>
  children, 
  /// Reducer `(accumulator, signal) => new_accumulator`.
  /// -> function
  fn, 
  /// Initial value.
  /// -> any
  base
) = {
  if children == none { return base }
  children
    .filter(c => c != none)
    .map(c => c.at("signal", default: (:)))
    .fold(base, fn)
}