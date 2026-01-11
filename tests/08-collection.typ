#import "test-template.typ": *
#import "../src/lib/collection.typ": compact, get, map, merge-deep, omit, pick

#show: doc => loom-test(
  title: "Collection Module Tests",
  description: "Unit tests for data manipulation utilities.",
  abstract: [Tests safe navigation, deep merging, and dictionary filtering.],
  doc,
)

#test-case(
  "Safe Access (Get)",
  tags: ("Collection", "Access"),
  task: [Verify safe deep retrieval.],
  abstract: [Ensures `get` handles missing keys/indices without panicking.],
  {
    let data = (user: (profile: (tags: ("a", "b"))))

    assert-eq(
      get(data, "user", "profile", "tags", 0),
      "a",
      msg: "Deep access found",
    )
    assert-eq(
      get(data, "user", "missing"),
      none,
      msg: "Missing key returns none",
    )
    assert-eq(
      get(data, "user", "missing", default: "default"),
      "default",
      msg: "Default works",
    )
    assert-eq(
      get(data, "user", "profile", "tags", 5),
      none,
      msg: "Index out of bounds safe",
    )
  },
)

#test-case(
  "Merge Deep",
  tags: ("Collection", "Merge"),
  task: [Verify recursive dictionary merging.],
  abstract: [Comparing standard `+` vs `merge-deep`.],
  {
    let base = (style: (font: "Arial", size: 10pt), meta: 1)
    let patch = (style: (size: 12pt))

    let standard = base + patch
    // Standard `+` replaces the whole 'style' dict, losing 'font'
    assert-eq(
      standard.style.at("font", default: none),
      none,
      msg: "Standard + overwrites",
    )

    let deep = merge-deep(base, patch)
    assert-eq(deep.style.size, 12pt, msg: "Deep merge updates value")
    assert-eq(deep.style.font, "Arial", msg: "Deep merge preserves siblings")
  },
)

#test-case(
  "Filtering",
  tags: ("Collection", "Filter"),
  task: [Verify `omit`, `pick`, and `compact`.],
  abstract: [Tests cleaning up dictionaries and arrays.],
  {
    let d = (a: 1, b: 2, c: none)

    // Omit / Pick
    let o = omit(d, "a")
    assert-false("a" in o, msg: "Omit removed key")
    assert-true("b" in o, msg: "Omit kept others")

    let p = pick(d, "a")
    assert-true("a" in p, msg: "Pick kept key")
    assert-false("b" in p, msg: "Pick removed others")

    // Compact
    let arr = (1, none, 2)
    assert-eq(compact(arr).len(), 2, msg: "Compact array length")

    let dict-compact = compact(d)
    assert-false("c" in dict-compact, msg: "Compact removed none-value key")
  },
)
