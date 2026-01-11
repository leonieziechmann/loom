/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/mutator.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Provides a functional, immutable API for modifying Typst dictionaries.
 * Includes operations for batch processing (put, remove, update, nest, merge)
 * to handle state changes cleanly without side effects.
 * ----------------------------------------------------------------------------
 */

#import "collection.typ"

/// Applies a sequence of operations to a target dictionary.
///
/// This function acts as the transaction runner. It takes an initial dictionary
/// (`target`) and applies a list of functional operations (`ops`) to it sequentially.
///
/// # Example
/// ```typ
/// let data = (name: "Typst", version: 1)
/// let result = batch(data, {
///   put("version", 2)
///   put("status", "active")
/// })
/// ```
///
/// The resulting dictionary after all operations have been applied.
/// -> dictionary:
#let batch(
  /// The initial dictionary to start with. If `none`, starts with an empty dictionary `(:)`
  /// -> dictionary
  target,
  /// An array of operation functions (e.g., created by `put`, `remove`, `nest`).
  /// -> array<function>
  ops,
) = {
  let state = (base: if target == none { (:) } else { target }, patch: (:))

  if ops == none { return state.base }

  let _read(s, key, default: none) = {
    if key in s.patch { s.patch.at(key) } else {
      s.base.at(key, default: default)
    }
  }

  for op in ops {
    state = op(state, _read.with(state))
  }

  return if state.patch.len() == 0 { state.base } else {
    state.base + state.patch
  }
}

/// Creates an operation to set a value for a specific key.
/// Overwrites the value if the key already exists.
///
/// -> operation
#let put(
  /// The key to assign.
  /// -> str
  key,
  /// The value to assign to the key.
  /// -> any
  value,
) = (
  (state, read) => {
    let new-path = state.patch + ((key): value)
    (base: state.base, patch: new-path)
  },
)

/// Creates an operation that sets a value only if the key does not currently exist.
/// Useful for setting default values without overwriting existing data.
///
/// -> operation
#let ensure(
  /// The key to check.
  /// -> str
  key,
  /// The value to set if the key is missing (or `none`).
  /// -> any
  default,
) = (
  (state, read) => {
    let curr = read(key)
    if curr == none {
      let new-patch = state.patch + ((key): default)
      (base: state.base, patch: new-patch)
    } else {
      state
    }
  },
)

/// Creates an operation that sets a value, inheriting the previous one if `auto`.
///
/// - If `value` is `auto`: uses the current state value.
/// - If current state is missing: uses `default`.
/// - If `value` is set: uses that value.
///
/// -> operation
#let derive(
  /// The key to update.
  /// -> str
  key,
  /// The new value (or `auto`).
  /// -> any
  value,
  /// Fallback if `value` is `auto` and key is missing in state.
  /// -> any
  default: none,
) = (
  (state, read) => {
    if value == auto {
      (ensure(key, default).first())(state, read)
    } else {
      (put(key, value).first())(state, read)
    }
  },
)

/// Creates an operation to transform an existing value using a callback function.
///
/// # Example
/// ```typ
/// update("count", c => c + 1)
/// ```
///
/// -> operation
#let update(
  /// The key to update.
  /// -> str
  key,
  /// A function that takes the current value of `key` and returns the new value.
  /// -> function
  fn,
) = (
  (state, read) => {
    if (not key in state.base) and (key in state.patch) { return state }

    let new-patch = state.patch + ((key): fn(read(key)))
    (base: state.base, patch: new-patch)
  },
)

/// Creates an operation to remove a key from the dictionary.
///
/// -> operation
#let remove(
  /// The key to remove.
  /// -> str
  key,
) = (
  (state, read) => {
    let new-patch = state.patch
    let _ = new-patch.remove(key, default: none)

    let new-base = state.base
    let _ = new-base.remove(key, default: none)

    (base: new-base, patch: new-patch)
  },
)

/// Applies a set of operations to a nested dictionary under a specific key.
/// If the key does not exist or is not a dictionary, it initializes an empty dictionary first.
///
/// # Example
/// ```typ
/// nest("metadata", (
///   put("created_at", "2024"),
///   put("author", "Me")
/// ))
/// ```
///
/// -> operation
#let nest(
  /// The key containing the nested dictionary.
  /// -> str
  key,
  /// A list of operations to apply to the nested dictionary.
  /// -> array<function>
  sub-ops,
) = (
  (state, read) => {
    let curr = read(key)
    let sub-target = if type(curr) == dictionary { curr } else { (:) }

    let new-sub-result = batch(sub-target, sub-ops)

    let new-patch = state.patch + ((key): new-sub-result)
    (base: state.base, patch: new-patch)
  },
)

#let merge(other) = (
  (state, read) => {
    let new-patch = state.patch + other
    (base: state.base, patch: new-patch)
  },
)

/// Merges a dictionary deeply into the current state.
///
/// Unlike `merge` (which is shallow), this operation recursively merges
/// nested dictionaries.
///
/// -> operation
#let merge-deep(
  /// The dictionary to merge.
  /// -> dictionary
  other,
) = (
  (state, reader) => {
    let new-patch = state.patch

    // Iterate over the keys we want to merge in
    for (key, val) in other {
      let curr = reader(key)
      let merged = collection.merge-deep(curr, val)
      new-patch.insert(key, merged)
    }

    (base: state.base, patch: new-patch)
  },
)
