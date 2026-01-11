#import "/src/lib/collection.typ": compact, get, map, merge-deep, omit, pick

// Test: Safe Access (Get)
#{
  let data = (user: (profile: (tags: ("a", "b"))))

  assert.eq(
    get(data, "user", "profile", "tags", 0),
    "a",
    message: "Deep access found",
  )
  assert.eq(
    get(data, "user", "missing"),
    none,
    message: "Missing key returns none",
  )
  assert.eq(
    get(data, "user", "missing", default: "default"),
    "default",
    message: "Default works",
  )
  assert.eq(
    get(data, "user", "profile", "tags", 5),
    none,
    message: "Index out of bounds safe",
  )
}

// Test: Merge Deep
#{
  let base = (style: (font: "Arial", size: 10pt), meta: 1)
  let patch = (style: (size: 12pt))

  let standard = base + patch

  assert.eq(
    standard.style.at("font", default: none),
    none,
    message: "Standard + overwrites",
  )

  let deep = merge-deep(base, patch)
  assert.eq(deep.style.size, 12pt, message: "Deep merge updates value")
  assert.eq(deep.style.font, "Arial", message: "Deep merge preserves siblings")
}

// Test: Filtering
#{
  let d = (a: 1, b: 2, c: none)

  // Omit / Pick
  let o = omit(d, "a")
  assert(not ("a" in o), message: "Omit removed key")
  assert("b" in o, message: "Omit kept others")

  let p = pick(d, "a")
  assert("a" in p, message: "Pick kept key")
  assert(not ("b" in p), message: "Pick removed others")

  // Compact
  let arr = (1, none, 2)
  assert.eq(compact(arr).len(), 2, message: "Compact array length")

  let dict-compact = compact(d)
  assert(not ("c" in dict-compact), message: "Compact removed none-value key")
}
