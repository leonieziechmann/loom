#import "test-template.typ": *
#import "../src/public/mutator.typ": *

#show: doc => loom-test(
  title: "Mutator Behavior Specification",
  description: "Comprehensive behavioral tests for the Mutator API.",
  abstract: [
    Verifies contract compliance, including edge cases for missing keys,
    type collisions in nesting, and strict immutability.
  ],
  doc,
)

// --- 1. CORE TRANSACTION MECHANICS ---
#test-case(
  "Transaction Purity & Initialization",
  tags: ("Core", "Immutability"),
  task: [Verify `batch` creates new states without side effects.],
  abstract: [Checks handling of `none` targets and strict variable isolation.],
  {
    let original = (id: 1)

    // Case 1: Immutability
    let result = batch(original, put("id", 2))
    assert-eq(original.id, 1, msg: "Original dictionary remains unchanged")
    assert-eq(result.id, 2, msg: "Result dictionary reflects change")

    // Case 2: Initialization from None
    let from-void = batch(none, put("a", 1))
    assert-eq(
      from-void,
      (a: 1),
      msg: "Batch accepts 'none' as empty start state",
    )

    // Case 3: Empty Ops
    let no-ops = batch(original, ())
    assert-eq(
      no-ops,
      original,
      msg: "Empty operations list returns original state",
    )
  },
)

// --- 2. ATOMIC OPERATIONS ---
#test-case(
  "Put & Remove Mechanics",
  tags: ("Ops", "Basic"),
  task: [Verify overwrite rules and removal safety.],
  abstract: [Ensures `put` always wins and `remove` is safe on missing keys.],
  {
    let state = (a: 1, b: 2)

    let res = batch(state, {
      // Overwrite existing
      put("a", 99)
      // Create new
      put("c", 3)
      // Remove existing
      remove("b")
      // Remove missing (Should not panic)
      remove("z")
    })

    assert-eq(res.a, 99, msg: "Put overwrites existing key")
    assert-eq(res.c, 3, msg: "Put creates new key")
    assert-false("b" in res, msg: "Remove deletes existing key")
    assert-false("z" in res, msg: "Remove is safe on missing keys")
  },
)

#test-case(
  "Ensure Logic (Defaulting)",
  tags: ("Ops", "Logic"),
  task: [Verify `ensure` behavior on missing vs. existing keys.],
  abstract: [
    Checks that `ensure` respects existing values (even `none`)
    unless strict missing checks apply.
    *Note: Implementation treats explicit `none` as missing.*
  ],
  {
    let state = (exists: 10, explicit-null: none)

    let res = batch(state, {
      ensure("exists", 5) // Should keep 10
      ensure("missing", 5) // Should set 5
      ensure("explicit-null", 5) // Should set 5 (treats none as missing)
    })

    assert-eq(res.exists, 10, msg: "Ensure preserves existing values")
    assert-eq(res.missing, 5, msg: "Ensure sets missing values")
    assert-eq(
      res.explicit-null,
      5,
      msg: "Ensure treats explicit 'none' as unset",
    )
  },
)

#test-case(
  "Update Callback Contracts",
  tags: ("Ops", "Callback"),
  task: [Verify `update` behavior when keys are missing.],
  abstract: [
    Crucial: Validates that the callback receives `none` if the key is missing,
    allowing the user to handle initialization logic inside the callback.
  ],
  {
    let res = batch((count: 1), {
      // Standard update
      update("count", c => c + 1)

      // Missing key update
      // The callback must handle 'none' to avoid crashing arithmetic
      update("missing", c => if c == none { 0 } else { c } + 10)
    })

    assert-eq(res.count, 2, msg: "Standard update increments value")
    assert-eq(res.missing, 10, msg: "Callback received 'none' for missing key")
  },
)

#test-case(
  "Derive Logic (Inheritance)",
  tags: ("Ops", "Logic"),
  task: [Verify `derive` auto-resolution.],
  abstract: [Tests the 3 states of derive: explicit set, auto-inherit, and auto-default.],
  {
    let state = (title: "Old", draft: true)

    let res = batch(state, {
      // 1. Explicit Value: Overwrite
      derive("title", "New", default: "Err")

      // 2. Auto + Exists: Keep current
      derive("draft", auto, default: false)

      // 3. Auto + Missing: Use default
      derive("published", auto, default: "today")
    })

    assert-eq(res.title, "New", msg: "Derive with value overwrites")
    assert-eq(res.draft, true, msg: "Derive auto preserves existing")
    assert-eq(
      res.published,
      "today",
      msg: "Derive auto uses default if missing",
    )
  },
)

// --- 3. NESTING BEHAVIOR ---
#test-case(
  "Deep Nesting & Type Coercion",
  tags: ("Nest", "Structure"),
  task: [Verify `nest` initialization and collision handling.],
  abstract: [
    Checks that `nest` creates dictionaries if missing,
    and determines behavior when nesting onto a non-dictionary.
  ],
  {
    let state = (
      meta: (version: 1),
      collision: "I am a string",
    )

    let res = batch(state, {
      // 1. Existing Nest
      nest("meta", put("author", "Loom"))

      // 2. Auto-Init Nest (Missing key)
      nest("new-section", put("enabled", true))

      // 3. Type Collision
      // "collision" is a string. nesting should likely overwrite or reset it to a dict.
      // Based on implementation: `if type(curr) == dictionary { curr } else { (:) }`
      // It resets non-dicts to empty dicts.
      nest("collision", put("recovered", true))
    })

    assert-eq(res.meta.version, 1, msg: "Preserves siblings in existing nest")
    assert-eq(res.meta.author, "Loom", msg: "Adds key to existing nest")

    assert-eq(
      res.new-section.enabled,
      true,
      msg: "Auto-initializes missing nest",
    )

    assert-eq(
      type(res.collision),
      dictionary,
      msg: "Nesting on non-dict converts to dict",
    )
    assert-eq(
      res.collision.recovered,
      true,
      msg: "Nesting on non-dict applies ops",
    )
    assert-false(
      "len" in res.collision,
      msg: "Nesting on non-dict discards old value",
    )
  },
)

// --- 4. COMPOSITION ---
#test-case(
  "Merge Strategy",
  tags: ("Merge", "Composition"),
  task: [Verify `merge` is shallow.],
  abstract: [Ensures merge does not perform deep recursive merging (use nest for that).],
  {
    let base = (config: (theme: "dark", font: "arial"))
    let patch = (config: (theme: "light")) // Note: 'font' is missing here

    let res = batch(base, {
      merge(patch)
    })

    assert-eq(res.config.theme, "light", msg: "Merge updates key")
    assert-eq(
      res.config.at("font", default: none),
      none,
      msg: "Merge is shallow (lost sibling 'font')",
    )
  },
)

#test-case(
  "Deep Merge Strategy",
  tags: ("Merge", "Deep"),
  task: [Verify `merge-deep` preserves nested structures.],
  abstract: [
    Contrasts `merge` (shallow overwrite) with `merge-deep` (recursive update).
    Critically checks that `merge-deep` correctly resolves `base` vs `patch` state.
  ],
  {
    let base = (
      conf: (
        theme: "dark",
        font: (family: "Arial", size: 10pt),
      ),
    )

    let update-shallow = (theme: "light")
    let update-deep = (conf: (font: (size: 12pt)))

    let res = batch(base, {
      // 1. Standard Merge: Shallow
      // This would wipe out 'font' because it replaces the whole 'conf' dict
      nest("conf", merge(update-shallow))

      // 2. Deep Merge
      // This should see the "light" theme from step 1,
      // AND preserve the "Arial" family from base,
      // AND update the size to 12pt.
      merge-deep(update-deep)
    })

    // Check Shallow effect
    assert-eq(res.conf.theme, "light", msg: "Shallow merge applied")

    // Check Deep Merge effect
    assert-eq(res.conf.font.size, 12pt, msg: "Deep merge updated nested value")
    assert-eq(
      res.conf.font.family,
      "Arial",
      msg: "Deep merge preserved sibling (base)",
    )

    // Check combined integrity
    assert-eq(res.conf.len(), 2, msg: "Result has exactly expected keys")
  },
)
