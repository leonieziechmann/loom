#import "test-template.typ": *
#import "../src/lib/matcher.typ" as matcher

#show: doc => loom-test(
  title: "Matcher Module Tests",
  description: "Unit tests for schema validation and pattern matching.",
  abstract: [
    Tests the validation engine against primitives, structural types,
    and complex descriptors like choice and many.
  ],
  doc,
)

#test-case(
  "Primitive & Literal Matching",
  tags: ("Matcher", "Types"),
  task: [Verify simple type and value matching.],
  abstract: [Checks int, str, and exact value equality.],
  {
    assert-true(matcher.match(10, int), msg: "10 is int")
    assert-true(matcher.match("hello", str), msg: "hello is str")
    assert-true(matcher.match(10, 10), msg: "Literal exact match")
    assert-false(matcher.match(10, "10"), msg: "No coercion")
    assert-false(matcher.match(none, int), msg: "None is not int")
  },
)

#test-case(
  "Structural Matching",
  tags: ("Matcher", "Structure"),
  task: [Verify Array and Dictionary schema matching.],
  abstract: [Tests tuple sequences and record shapes.],
  {
    // Arrays
    assert-true(matcher.match((1, "a"), (int, str)), msg: "Tuple match")
    assert-false(matcher.match((1, 2), (int, str)), msg: "Tuple mismatch type")

    // Dictionaries
    let obj = (name: "Loom", id: 1)
    assert-true(matcher.match(obj, (name: str)), msg: "Partial dict match")
    assert-false(matcher.match(obj, (name: int)), msg: "Dict value mismatch")

    // Strict Mode
    assert-false(
      matcher.match(obj, (name: str), strict: true),
      msg: "Strict fails on extra keys",
    )
    assert-true(
      matcher.match(obj, (name: str, id: int), strict: true),
      msg: "Strict passes exact keys",
    )
  },
)

#test-case(
  "Descriptors",
  tags: ("Matcher", "Advanced"),
  task: [Verify `any`, `choice`, `many`, and `dict`.],
  abstract: [Tests the custom descriptor objects.],
  {
    // Any
    assert-true(matcher.match(none, matcher.any()), msg: "Any matches none")

    // Choice
    let num-or-str = matcher.choice(int, str)
    assert-true(matcher.match(1, num-or-str), msg: "Choice match option 1")
    assert-true(matcher.match("s", num-or-str), msg: "Choice match option 2")
    assert-false(matcher.match(1.5, num-or-str), msg: "Choice mismatch")

    // Many (Array of Uniform items)
    let list-ints = matcher.many(int)
    assert-true(matcher.match((1, 2, 3), list-ints), msg: "Many ints match")
    assert-false(matcher.match((1, "a"), list-ints), msg: "Many mixed fails")

    // Dict (Map of Uniform values)
    let map-ints = matcher.dict(int)
    assert-true(matcher.match((a: 1, b: 2), map-ints), msg: "Dict ints match")
    assert-false(
      matcher.match((a: 1, b: "no"), map-ints),
      msg: "Dict mixed fails",
    )
  },
)
#test-case(
  "Hybrid Type Matching (Default)",
  tags: ("Matcher", "Hybrid"),
  task: [Verify the default behavior for type patterns.],
  abstract: [
    Checks that `int` matches both `10` (instance) and `int` (equality).
  ],
  {
    let schema = matcher.choice(int, float)

    // 1. Instance Matching
    assert-true(matcher.match(10, schema), msg: "10 matches int")
    assert-true(matcher.match(1.5, schema), msg: "1.5 matches float")

    // 2. Equality Matching (Meta-programming support)
    assert-true(matcher.match(int, schema), msg: "Type 'int' matches int")
    assert-true(matcher.match(float, schema), msg: "Type 'float' matches float")

    // 3. Mismatches
    assert-false(matcher.match("s", schema), msg: "String mismatches both")
    assert-false(matcher.match(str, schema), msg: "Type 'str' mismatches both")
  },
)

#test-case(
  "Strict Overrides",
  tags: ("Matcher", "Strict"),
  task: [Verify `exact` and `instance` specificity.],
  abstract: [
    Ensures that descriptors can restrict the hybrid behavior when needed.
  ],
  {
    // Case A: Strict Instance Check
    // Should reject the type object itself
    let only-instances = matcher.instance(int)
    assert-true(
      matcher.match(10, only-instances),
      msg: "Instance accepts value",
    )
    assert-false(
      matcher.match(int, only-instances),
      msg: "Instance rejects type object",
    )

    // Case B: Strict Equality Check
    // Should reject instances
    let only-types = matcher.exact(int)
    assert-true(
      matcher.match(int, only-types),
      msg: "Exact accepts type object",
    )
    assert-false(matcher.match(10, only-types), msg: "Exact rejects value")
  },
)
