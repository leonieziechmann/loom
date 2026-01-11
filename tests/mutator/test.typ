#import "/src/public/mutator.typ": *

// Test: Transaction Purity & Initialization
#{
  let original = (id: 1)

  // Case 1: Immutability
  let result = batch(original, put("id", 2))
  assert.eq(original.id, 1, message: "Original dictionary remains unchanged")
  assert.eq(result.id, 2, message: "Result dictionary reflects change")

  // Case 2: Initialization from None
  let from-void = batch(none, put("a", 1))
  assert.eq(
    from-void,
    (a: 1),
    message: "Batch accepts 'none' as empty start state",
  )

  // Case 3: Empty Ops
  let no-ops = batch(original, ())
  assert.eq(
    no-ops,
    original,
    message: "Empty operations list returns original state",
  )
}

// Test: Put & Remove Mechanics
#{
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

  assert.eq(res.a, 99, message: "Put overwrites existing key")
  assert.eq(res.c, 3, message: "Put creates new key")
  assert(not ("b" in res), message: "Remove deletes existing key")
  assert(not ("z" in res), message: "Remove is safe on missing keys")
}

// Test: Ensure Logic (Defaulting)
#{
  let state = (exists: 10, explicit-null: none)

  let res = batch(state, {
    ensure("exists", 5) // Should keep 10
    ensure("missing", 5) // Should set 5
    ensure("explicit-null", 5) // Should set 5 (treats none as missing)
  })

  assert.eq(res.exists, 10, message: "Ensure preserves existing values")
  assert.eq(res.missing, 5, message: "Ensure sets missing values")
  assert.eq(
    res.explicit-null,
    5,
    message: "Ensure treats explicit 'none' as unset",
  )
}

// Test: Update Callback Contracts
#{
  let res = batch((count: 1), {
    // Standard update
    update("count", c => c + 1)

    // Missing key update
    // The callback must handle 'none' to avoid crashing arithmetic
    update("missing", c => if c == none { 0 } else { c } + 10)
  })

  assert.eq(res.count, 2, message: "Standard update increments value")
  assert.eq(
    res.missing,
    10,
    message: "Callback received 'none' for missing key",
  )
}

// Test: Derive Logic (Inheritance)
#{
  let state = (title: "Old", draft: true)

  let res = batch(state, {
    // 1. Explicit Value: Overwrite
    derive("title", "New", default: "Err")

    // 2. Auto + Exists: Keep current
    derive("draft", auto, default: false)

    // 3. Auto + Missing: Use default
    derive("published", auto, default: "today")
  })

  assert.eq(res.title, "New", message: "Derive with value overwrites")
  assert.eq(res.draft, true, message: "Derive auto preserves existing")
  assert.eq(
    res.published,
    "today",
    message: "Derive auto uses default if missing",
  )
}

// Test: Deep Nesting & Type Coercion
#{
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
    // It resets non-dicts to empty dicts.
    nest("collision", put("recovered", true))
  })

  assert.eq(res.meta.version, 1, message: "Preserves siblings in existing nest")
  assert.eq(res.meta.author, "Loom", message: "Adds key to existing nest")

  assert.eq(
    res.new-section.enabled,
    true,
    message: "Auto-initializes missing nest",
  )

  assert.eq(
    type(res.collision),
    dictionary,
    message: "Nesting on non-dict converts to dict",
  )
  assert.eq(
    res.collision.recovered,
    true,
    message: "Nesting on non-dict applies ops",
  )
  assert(
    not ("len" in res.collision),
    message: "Nesting on non-dict discards old value",
  )
}

// Test: Merge Strategy
#{
  let base = (config: (theme: "dark", font: "arial"))
  let patch = (config: (theme: "light")) // Note: 'font' is missing here

  let res = batch(base, {
    merge(patch)
  })

  assert.eq(res.config.theme, "light", message: "Merge updates key")
  assert.eq(
    res.config.at("font", default: none),
    none,
    message: "Merge is shallow (lost sibling 'font')",
  )
}

// Test: Deep Merge Strategy
#{
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
    nest("conf", merge(update-shallow))

    // 2. Deep Merge
    merge-deep(update-deep)
  })

  // Check Shallow effect
  assert.eq(res.conf.theme, "light", message: "Shallow merge applied")

  // Check Deep Merge effect
  assert.eq(
    res.conf.font.size,
    12pt,
    message: "Deep merge updated nested value",
  )
  assert.eq(
    res.conf.font.family,
    "Arial",
    message: "Deep merge preserved sibling (base)",
  )

  // Check combined integrity
  assert.eq(res.conf.len(), 2, message: "Result has exactly expected keys")
}
