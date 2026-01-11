#import "/src/public/guards.typ"

// Case 1: Disallow Parent Logic
#{
  let ctx = (sys: (path: (("root", 0), ("forbidden", 0), ("current", 0))))

  assert-panic(
    guards.assert-not-inside.with(ctx, "forbidden"),
    message: "Guard blocks context with forbidden parent",
  )

  assert(
    guards.assert-not-inside(ctx, "allowed"),
    message: "Guard allows context without forbidden parent",
  )
}

// Case 2: Require Parent Logic
#{
  let ctx = (sys: (path: (("root", 0), ("container", 0), ("current", 0))))

  // 1. Indirect Requirement
  assert-panic(
    guards.assert-inside.with(ctx, "mandatory"),
    message: "Guard blocks missing 'mandatory' parent",
  )

  // 2. Direct Requirement
  // Parent is "container". Asking for "root" as direct parent should fail.
  assert-panic(
    guards.assert-direct-parent.with(ctx, "root"),
    message: "Guard blocks grandparent when direct parent required",
  )

  // 3. Success Case
  assert(
    guards.assert-direct-parent(ctx, "container"),
    message: "Guard accepts correct direct parent",
  )
}

// Case 3: Context Key Assertion
#{
  let ctx = (sys: (:), existing: 1)

  assert-panic(
    guards.assert-has-key.with(ctx, "missing"),
    message: "Detects missing key correctly",
  )

  assert(
    guards.assert-has-key(ctx, "existing"),
    message: "Validates existing key correctly",
  )
}
