---
sidebar_position: 7
---

# Matcher API

**Schema Validation & Pattern Matching**

The `matcher` module provides a robust structural validation system. It allows you to check if data matches a specific shape, type, or set of values using a "By Example" syntax or descriptive helpers.

:::info Mental Model
The Matcher distinguishes between **Fixed Shapes** (defined by syntax like arrays and dictionaries) and **Open Collections** (defined by helpers like `many` or `dict`).
:::

## The Match Engine

The core of the module is the `match` function, which validates a value against a pattern.

### `match`

Checks if a value satisfies a schema pattern.

```typ
matcher.match(value, expected, strict: false)
```

| Parameter  | Type   | Default  | Description                                                            |
| ---------- | ------ | -------- | ---------------------------------------------------------------------- |
| `value`    | `any`  | Required | The data to validate.                                                  |
| `expected` | `any`  | Required | The schema to match against (literal, type, structure, or descriptor). |
| `strict`   | `bool` | `false`  | If `true`, dictionaries are not allowed to have extra keys.            |

---

## Pattern Syntax ("By Example")

For fixed structures where you know the exact keys or length, use standard Typst syntax.

### Types & Literals (Hybrid Matching)

A type in the schema (e.g., `int`) performs a **Hybrid Match**. It matches:

1. **Instances** of that type (e.g., `10`).
2. The **Type Object** itself (e.g., `int`).

This flexibility supports both standard data validation and meta-programming/configuration scenarios.

```typ
// 1. Instance Matching (Standard)
matcher.match(10, int)       // true
matcher.match("foo", str)    // true

// 2. Equality Matching (Meta-programming)
matcher.match(int, int)      // true
matcher.match(int, float)    // false

// 3. Literals
matcher.match("foo", "foo")  // true
matcher.match(auto, auto)    // true
```

:::note Controlling Specificity
If you need to be more specific (e.g., "Must be a number, not the type `int`" or "Must be the type object `int` exactly"), use the **[Strict Descriptors](#strict-descriptors-types)** `instance` and `exact` documented below.
:::

### Tuples (Fixed Arrays)

A Typst array in the schema represents a **Tuple**: a list of fixed size where each position has a specific schema.

```typ
// Matches a pair: (Integer, String)
let schema = (int, str)

matcher.match((1, "a"), schema) // true
matcher.match((1, 1), schema)   // false (wrong type at index 1)
matcher.match((1,), schema)     // false (wrong length)
```

### Records (Fixed Dictionaries)

A Typst dictionary in the schema represents a **Record**: an object that must contain specific keys.

```typ
// Matches an object with specific fields
let user = (name: str, id: int)

matcher.match((name: "Alice", id: 1), user) // true
matcher.match((name: "Alice"), user)        // false (missing key)
```

:::tip Partial Matches
By default, `match` allows extra keys in dictionaries (partial matching). To forbid unknown keys, pass `strict: true` to the function or the `switch` case.
:::

---

## Descriptors ("By Description")

For logical operations, open-ended collections, or strict type constraints, use these helper functions.

### Strict Descriptors (Types)

Use these when the default Hybrid Matching behavior is too broad.

#### `instance`

Strictly enforces that the value is an **instance** of the type. Rejects the type object itself.

```typ
matcher.instance(type)
```

**Example:**

```typ
let pattern = matcher.instance(int)

matcher.match(10, pattern)   // true
matcher.match(int, pattern)  // false (Rejected!)
```

#### `exact`

Strictly enforces **equality**. Use this to match specific values or type objects exactly, bypassing instance checks.

```typ
matcher.exact(value)
```

**Example:**

```typ
let pattern = matcher.exact(int)

matcher.match(int, pattern)  // true
matcher.match(10, pattern)   // false (Rejected!)
```

### Logical & Collection Descriptors

#### `any` (Wildcard)

Matches **anything**. Use this when a field allows any value.

```typ
matcher.any()
```

#### `choice`

Matches if **any** of the provided options match (Logic OR).

```typ
matcher.choice(..options)
```

**Example:**

```typ
// Matches an Integer OR a String
let id-schema = matcher.choice(int, str)
```

#### `many`

Matches an array of **any length** where every item matches the schema (Homogeneous List).

```typ
matcher.many(schema)
```

**Example:**

```typ
// Matches a list of numbers: (1, 2, 3)
let numbers = matcher.many(int)
```

#### `dict`

Matches a dictionary of **any size** where every value matches the schema (Homogeneous Map).

```typ
matcher.dict(schema)
```

**Example:**

```typ
// Matches a map of settings: (dark: true, silent: false)
#let settings = matcher.dict(bool)
```

---

## Classification (Switch)

The `switch` function allows you to categorize data against a list of cases and **safely transform** the result.

### `switch`

Evaluates a value against a list of cases. It iterates through the cases and executes the transformation function of the first match.

```typ
matcher.switch(target, cases)
```

| Parameter | Type    | Default  | Description                 |
| --------- | ------- | -------- | --------------------------- |
| `target`  | `any`   | Required | The value to classify.      |
| `cases`   | `array` | Required | An array of `case` objects. |

### `case`

Defines a single branch in a switch statement.

:::warning Lazy Evaluation
Unlike a standard switch statement where you provide a static output value, `case` requires a **Transformation Function**.

This ensures **Lazy Evaluation**. Typst evaluates function arguments eagerly; passing a transformation function ensures code is only executed _after_ the pattern matches, preventing runtime errors on mismatched data types.
:::

```typ
matcher.case(pattern, transform, strict: false)
```

| Parameter   | Type       | Default  | Description                                                          |
| ----------- | ---------- | -------- | -------------------------------------------------------------------- |
| `pattern`   | `any`      | Required | The schema pattern to match.                                         |
| `transform` | `function` | Required | A callback `(value) => result` executed only if the pattern matches. |
| `strict`    | `bool`     | `false`  | Override strict mode for this specific case.                         |

### Usage Examples

**1. Safe Type-Dependent Logic**
Because the transformation is a callback, you can safely perform operations that would crash on other types.

```typ
#let result = matcher.switch(my-data, {
  // SAFE: This multiplication only runs if my-data is an integer
  matcher.case(matcher.instance(int), x => x * 2)

  // SAFE: "my-data" is not accessed as a string unless it matches string
  matcher.case(matcher.instance(str), x => "Value is: " + x)

  // Fallback
  matcher.case(matcher.any(), _ => "Unknown type")
})
```

**2. Static Values**
If you want to return a static value, ignore the argument in the callback using the underscore `_` syntax.

```typ
#let kind = matcher.switch(signal, {
  import matcher: *

  // Match a specific shape -> Return static string
  case((cost: int), _ => "task")

  // Match a list -> Return static string
  case(many(str), _ => "tag-list")

  // Fallback
  case(any(), _ => "unknown")
})
```
