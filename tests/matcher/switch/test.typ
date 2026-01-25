#import "/src/lib/matcher.typ" as matcher

// Test: Lazy Evaluation
#{
  let value = "hello"

  let result = matcher.switch(value, {
    matcher.case(int, x => x * 2)
    matcher.case(str, x => x + " world")
    matcher.case(matcher.any(), _ => "fallback")
  })

  assert(
    result == "hello world",
    message: "Lazy evaluation prevents panic and matches correctly",
  )
}

// Test: Basic Static Returns
#{
  let logic(v) = matcher.switch(v, {
    matcher.case(int, _ => "is-integer")
    matcher.case(str, _ => "is-string")
    matcher.case(matcher.any(), _ => "is-other")
  })

  assert(logic(10) == "is-integer", message: "Matches int case")
  assert(logic("a") == "is-string", message: "Matches str case")
  assert(logic(1.5) == "is-other", message: "Matches fallback case")
}

// Test: Structural Data Transformation
#{
  let data = (id: 105, meta: (active: true))
  let result = matcher.switch(data, {
    matcher.case(
      (meta: (active: true)),
      x => "Active ID: " + str(x.id),
    )
    matcher.case(matcher.any(), _ => "Ignored")
  })

  assert(result == "Active ID: 105", message: "Transforms structural data")
}

// Test: Strict Mode Override within Switch
#{
  let data = (x: 1, y: 2) // Has extra key 'y'
  let result = matcher.switch(data, {
    matcher.case((x: int), _ => "strict-match", strict: true)
    matcher.case((x: int), _ => "loose-match")
  })

  assert(result == "loose-match", message: "Strict mode causes fall-through")
}

// Test: No Match (Graceful Exit)
#{
  let result = matcher.switch("foo", {
    matcher.case(int, _ => 1)
    matcher.case(bool, _ => 2)
  })

  assert(result == none, message: "Returns none if no case matches")
}
