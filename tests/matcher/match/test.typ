#import "/src/lib/matcher.typ" as matcher

// Test: Primitive & Literal Matching
#{
  assert(matcher.match(10, int), message: "10 is int")
  assert(matcher.match("hello", str), message: "hello is str")
  assert(matcher.match(10, 10), message: "Literal exact match")
  assert(not matcher.match(10, "10"), message: "No coercion")
  assert(not matcher.match(none, int), message: "None is not int")
}

// Test: Structural Matching
#{
  // Arrays
  assert(matcher.match((1, "a"), (int, str)), message: "Tuple match")
  assert(not matcher.match((1, 2), (int, str)), message: "Tuple mismatch type")

  // Dictionaries
  let obj = (name: "Loom", id: 1)
  assert(matcher.match(obj, (name: str)), message: "Partial dict match")
  assert(not matcher.match(obj, (name: int)), message: "Dict value mismatch")

  // Strict Mode
  assert(
    not matcher.match(obj, (name: str), strict: true),
    message: "Strict fails on extra keys",
  )
  assert(
    matcher.match(obj, (name: str, id: int), strict: true),
    message: "Strict passes exact keys",
  )
}

// Test: Descriptors
#{
  // Any
  assert(matcher.match(none, matcher.any()), message: "Any matches none")

  // Choice
  let num-or-str = matcher.choice(int, str)
  assert(matcher.match(1, num-or-str), message: "Choice match option 1")
  assert(matcher.match("s", num-or-str), message: "Choice match option 2")
  assert(not matcher.match(1.5, num-or-str), message: "Choice mismatch")

  // Many (Array of Uniform items)
  let list-ints = matcher.many(int)
  assert(matcher.match((1, 2, 3), list-ints), message: "Many ints match")
  assert(not matcher.match((1, "a"), list-ints), message: "Many mixed fails")

  // Dict (Map of Uniform values)
  let map-ints = matcher.dict(int)
  assert(matcher.match((a: 1, b: 2), map-ints), message: "Dict ints match")
  assert(
    not matcher.match((a: 1, b: "no"), map-ints),
    message: "Dict mixed fails",
  )
}

// Test: Hybrid Type Matching (Default)
#{
  let schema = matcher.choice(int, float)

  // 1. Instance Matching
  assert(matcher.match(10, schema), message: "10 matches int")
  assert(matcher.match(1.5, schema), message: "1.5 matches float")

  // 2. Equality Matching (Meta-programming support)
  assert(matcher.match(int, schema), message: "Type 'int' matches int")
  assert(matcher.match(float, schema), message: "Type 'float' matches float")

  // 3. Mismatches
  assert(not matcher.match("s", schema), message: "String mismatches both")
  assert(not matcher.match(str, schema), message: "Type 'str' mismatches both")
}

// Test: Strict Overrides
#{
  // Case A: Strict Instance Check
  // Should reject the type object itself
  let only-instances = matcher.instance(int)
  assert(
    matcher.match(10, only-instances),
    message: "Instance accepts value",
  )
  assert(
    not matcher.match(int, only-instances),
    message: "Instance rejects type object",
  )

  // Case B: Strict Equality Check
  // Should reject instances
  let only-types = matcher.exact(int)
  assert(
    matcher.match(int, only-types),
    message: "Exact accepts type object",
  )
  assert(not matcher.match(10, only-types), message: "Exact rejects value")
}
