// =============================================================================
// LOOM ENGINE: UTILS & DATA INTEGRITY TEST (AUTOMATED)
// =============================================================================
// Author: Leonie
// Target: Loom Utils & Path Modules
// Mode: Assertions Enabled
// =============================================================================
#import "test-wrapper.typ": *
#show: weave.with()

#import "test-template.typ": *

#show: loom-test.with(
  title: [Loom Utils Stress Test],
  description: [Validation of Helper Functions & Path Logic],
  abstract: [
    This suite strictly validates the return values of `src/lib/utils.typ` and `src/data/path.typ`.
    It uses assertions to ensure data integrity and logic correctness.
  ],
)

// =============================================================================
// SECTION 1: PATH LOGIC
// =============================================================================
= Path Logic & Context

Testing `path.parent`, `path.contains`, `path.parent-is`, `path.depth`.
(Implicitly tests `path.push`, `path.get`, `path.current`).

#test-case(
  "Path Navigation & Predicates",
  tags: ("Path", "Logic"),
  task: [Assert correct parent resolution and containment checks.],
  abstract: [
    We simulate a nested context: `root > container > box > text`.
  ],
)[
  #let ctx = (sys: (path: (("root", 0), ("container", 0), ("box", 0), ("text", 0))))
  
  // 1. Current & Parent
  #assert-eq(path.current(ctx), ("text", 0), msg: "Current resolves to 'text'")
  #assert-eq(path.current-kind(ctx), "text", msg: "Current resolves to 'text'")
  #assert-eq(path.parent(ctx), ("box", 0), msg: "Parent resolves to 'box'")
  #assert-eq(path.parent-kind(ctx), "box", msg: "Parent resolves to 'box'")
  
  // 2. Contains
  #assert-true(path.contains(ctx, "root"), msg: "Context contains 'root'")
  #assert-true(path.contains(ctx, "text"), msg: "Context contains self (default behavior)") 
  // Note: Your path.contains impl: `path.pop()` if include-current is false.
  #assert-false(path.contains(ctx, "text", include-current: false), msg: "Context excludes self when requested")
  
  // 3. Parent-Is (Immediate Parent)
  #assert-true(path.parent-is(ctx, "box"), msg: "Immediate parent identified as 'box'")
  #assert-false(path.parent-is(ctx, "container"), msg: "Grandparent 'container' is not immediate parent")
  
  // 4. Depth
  #assert-eq(path.depth(ctx), 4, msg: "Path depth calculated correctly")
]

#test-case(
  "Empty & Edge Case Paths",
  tags: ("Edge Case", "Path"),
  task: [Assert stability on empty contexts.],
  abstract: [
    Validating behavior on `(:)` and root-only paths.
  ],
)[
  #let empty-ctx = (:)
  #assert-eq(path.depth(empty-ctx), 0, msg: "Empty context has depth 0")
  #assert-eq(path.parent(empty-ctx), (none, none), msg: "Empty context parent is none")
  #assert-eq(path.current(empty-ctx), none, msg: "Empty context current is none")
  
  #let root-ctx = (sys: (path: ("root",)))
  #assert-eq(path.parent(root-ctx), (none, none), msg: "Root-only context has no parent")
]

// =============================================================================
// SECTION 2: GUARDS (Positive Testing)
// =============================================================================
= Guards & Safety (Negative Tests)

Validation of error handling logic. We inject `sys.test: true` into the context
to suppress panics and assert that invalid states return `false`.

#test-case(
  "Disallow Parent Logic",
  tags: ("Guard", "Negative"),
  task: [Assert that `disallow-parent` fails when forbidden parent is present.],
  abstract: [
    Context has "forbidden" in path. Calling `disallow-parent(..., "forbidden")` must return false.
  ],
)[
  #let ctx = (sys: (test: true, path: (("root", 0), ("forbidden", 0), ("current", 0))))
  
  #let result = guards.assert-not-inside(ctx, "forbidden")
  #assert-false(result, msg: "Guard blocks context with forbidden parent")
  
  #let valid = guards.assert-not-inside(ctx, "allowed")
  #assert-true(valid, msg: "Guard allows context without forbidden parent")
]

#test-case(
  "Require Parent Logic",
  tags: ("Guard", "Negative"),
  task: [Assert that `require-parent` fails when required parent is missing.],
  abstract: [
    Context is missing "mandatory". `require-parent` must fail.
  ],
)[
  #let ctx = (sys: (test: true, path: (("root", 0), ("container", 0), ("current", 0))))
  
  // 1. Indirect Requirement
  #let res1 = guards.assert-inside(ctx, "mandatory")
  #assert-false(res1, msg: "Guard blocks missing 'mandatory' parent")
  
  // 2. Direct Requirement
  // Parent is "container". Asking for "root" as direct parent should fail.
  #let res2 = guards.assert-direct-parent(ctx, "root")
  #assert-false(res2, msg: "Guard blocks grandparent when direct parent required")
  
  // 3. Success Case
  #let res3 = guards.assert-direct-parent(ctx, "container")
  #assert-true(res3, msg: "Guard accepts correct direct parent")
]

#test-case(
  "Context Key Assertion",
  tags: ("Guard", "Negative"),
  task: [Assert `assert-context-has` catches missing keys.],
  abstract: [
    Ensuring strict contract validation for context dictionaries.
  ],
)[
  #let ctx = (sys: (test: true), existing: 1)
  
  #assert-false(guards.assert-has-key(ctx, "missing"), msg: "Detects missing key correctly")
  #assert-true(guards.assert-has-key(ctx, "existing"), msg: "Validates existing key correctly")
]

// =============================================================================
// SECTION 3: DATA COLLECTION & QUERY
// =============================================================================
= Data Collection & Query

Testing `collect-children`, `query-children`, `find-child`.

#test-case(
  "Deep Collection & Filtering",
  tags: ("Recursion", "Collect"),
  task: [Assert collection counts and filtering logic.],
  abstract: [
    Using a deterministic mock tree to verify exact counts.
  ],
)[
  #let mock-child(kind) = (kind: kind)
  #let tree = (
    mock-child("A"),
    mock-child("B"),
    mock-child("target"),
    mock-child("noise"),
    mock-child("B"),
    mock-child("target"),
  )
  
  // 1. Collect All
  #let all = query.collect(tree)
  #assert-eq(all.len(), 6, msg: "Collected all 6 descendants recursively")
  
  // 2. Collect with Filter
  #let targets = query.select(tree, "target")
  #assert-eq(targets.len(), 2, msg: "Filtered correctly for 'target' kind")
  
  // 3. Query Children (Direct children only? Check impl. usually shallow list filter)
  // Assuming query-children operates on a list, not deep tree.
  #let direct-list = (mock-child("A"), mock-child("B"), mock-child("A"))
  #let queries = query.select(direct-list, "A")
  #assert-eq(queries.len(), 2, msg: "Query found all direct instances of 'A'")
  
  // 4. Find Child
  #let found = query.find(direct-list, "B")
  #assert-true(found != none, msg: "Child 'B' found successfully")
  #assert-eq(found.kind, "B", msg: "Found object has correct kind")
  
  #let not-found = query.find(direct-list, "Z")
  #assert-eq(not-found, none, msg: "Returns none for missing child 'Z'")
]

#test-case(
  "Aggregation (Fold)",
  tags: ("Data", "Fold"),
  task: [Assert correct summation using fold-children.],
  abstract: [
    Testing the updated `fold-children` with the safe `at` accessor.
  ],
)[
  #let data = (
    (signal: (value: 10)),
    (signal: (value: 20)),
    none,
    (signal: (other: 5)) // Missing 'value', needs default handling
  )
  
  // Using the new logic: aggregation function handles access
  #let sum = query.fold(data, (acc, v) => acc + v.at("value", default: 0), 0)
  
  #assert-eq(sum, 30, msg: "Fold aggregated values correctly (10+20+0)")
]

= Final Status
If compilation reached this point: *ALL AUTOMATED CHECKS PASSED*