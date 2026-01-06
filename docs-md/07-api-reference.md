# API Reference

This document provides a concise reference for all public functions exposed by the Loom library.

## Core

### `construct-loom(key)`

Initializes a new Loom instance.

**Arguments:**

- `key` (Label): A unique identifier for the project namespace (e.g., `<my-project>`).

**Returns:**

- `dictionary`: An object containing the bound `weave` function and `motif` constructors.

---

### `loom.weave(director, ...)`

The main entry point that starts the evaluation loop.

**Arguments:**

- `director` (Content): The root component of your document.
- `inputs` (Dictionary, named): Initial variables to inject into the global context.
- `max-passes` (Int, named): Maximum number of evaluation loops (default: `2`).
- `injector` (Function, named): `(ctx, payload) => dictionary`. Logic to inject aggregated data from the previous pass into the next pass.
- `debug` (Bool, named): Enables verbose logging and visual debugging of frames.

---

## Motifs

### `loom.motif.managed(name, ...)`

Creates a component that tracks its path and identity.

**Arguments:**

- `name` (String, positional): The category name (e.g., "section").
- `scope` (Function, named): `ctx => ctx`. Modifies context for children.
- `measure` (Function, named): `(ctx, children) => (public, view)`.
- `draw` (Function, named): `(ctx, public, view, body) => content`.
- `body` (Content, positional): The child content.

### `loom.motif.content(...)`

A wrapper for visual components that transparently forwards signals.

**Arguments:**

- `scope` (Function, named): `ctx => ctx`.
- `draw` (Function, named): `(ctx, body) => content`.
- `body` (Content, positional).

### `loom.motif.data(name, ...)`

A non-visual component for pure data emission.

**Arguments:**

- `name` (String, positional): The category name.
- `measure` (Function, named): `ctx => signal`. Returns the signal data.

### `loom.motif.plain(...)`

The low-level primitive.

**Arguments:**

- `key` (Label, named): The namespace key.
- `scope` (Function, named): `ctx => ctx`.
- `measure` (Function, named): `(ctx, children) => (public, view)`.
- `draw` (Function, named): `(ctx, public, view, body) => content`.

---

## Query Module (`loom.query`)

Utilities for filtering and aggregating signals in the `measure` phase.

- **`select(children, kind)`**: Returns an array of direct children matching `kind`.
- **`find(children, kind)`**: Returns the first direct child matching `kind`, or `none`.
- **`collect(children, kind, depth: 10)`**: Recursively finds all descendants matching `kind`.
- **`where(children, predicate)`**: Filters children where `predicate(frame)` is true.
- **`pluck(children, key)`**: Returns an array of values for `signal[key]` from all children.
- **`sum-signals(children, key)`**: Returns the sum of `signal[key]` for all children.
- **`group-by(children, key)`**: Returns a dictionary grouping children by `signal[key]`.
- **`fold(children, fn, base)`**: Reduces children using `fn(acc, signal)`.

---

## Guards Module (`loom.guards`)

Assertions for enforcing architectural constraints.

- **`assert-inside(ctx, ..ancestors)`**: Panics if the component is not nested within one of the `ancestors`.
- **`assert-not-inside(ctx, ..ancestors)`**: Panics if the component IS nested within one of the `ancestors`.
- **`assert-direct-parent(ctx, ..parents)`**: Panics if the immediate parent is not one of `parents`.
- **`assert-root(ctx)`**: Panics if the component is not at the document root.
- **`assert-max-depth(ctx, max)`**: Panics if nesting depth exceeds `max`.
- **`assert-has-key(ctx, key)`**: Panics if `key` is missing from `ctx`.
- **`assert-value(ctx, key, ..allowed)`**: Panics if `ctx[key]` is not in the `allowed` list.

---

## Mutator Module (`loom.mutator`)

Functional updates for immutable dictionaries.

- **`batch(target, ops)`**: Applies a list of operations to `target`.
- **`put(key, value)`**: Operation to set a value.
- **`ensure(key, default)`**: Operation to set a value only if missing.
- **`update(key, fn)`**: Operation to transform a value.
- **`remove(key)`**: Operation to delete a key.
- **`merge(dict)`**: Operation to merge a dictionary.
- **`nest(key, sub_ops)`**: Operation to apply ops to a nested dictionary.

---

## Collection Module (`loom.collection`)

Safe access and manipulation of data structures.

- **`get(root, ..path, default: none)`**: Safely retrieves a nested value.
- **`merge-deep(base, override)`**: Recursively merges two dictionaries.
- **`compact(collection)`**: Removes `none` values from arrays or dictionaries.
- **`pick(dict, ..keys)`**: Returns a new dict with only the specified keys.
- **`omit(dict, ..keys)`**: Returns a new dict without the specified keys.

---

## Path Module (`loom.path`)

Utilities for inspecting the component hierarchy.

- **`to-string(ctx, separator: ">")`**: Returns the unique string ID of the current path.
- **`depth(ctx)`**: Returns the current nesting depth (int).
- **`parent(ctx)`**: Returns the `(kind, id)` tuple of the parent.
- **`current(ctx)`**: Returns the `(kind, id)` tuple of the current component.
- **`contains(ctx, ..kinds)`**: Returns `true` if the path contains any of the `kinds`.
