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

### Types & Literals

Matches exact values or specific types.

```typ
matcher.match(10, int)       // true
matcher.match("foo", "foo")  // true
matcher.match("bar", "foo")  // false

// 'auto' matches the literal value `auto`
matcher.match(auto, auto)    // true
matcher.match("foo", auto)   // false
```

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

For logical operations, open-ended collections (lists/maps of unknown size), or wildcards, use these helper functions.

### `any` (Wildcard)

Matches **anything**. Use this when a field allows any value.

```typ
matcher.any()
```

**Example:**

```typ
matcher.match(none, matcher.any()) // true
matcher.match(100, matcher.any())  // true
```

### `choice`

Matches if **any** of the provided options match (Logic OR).

```typ
matcher.choice(..options)
```

**Example:**

```typ
// Matches an Integer OR a String
let id-schema = matcher.choice(int, str)
```

### `many`

Matches an array of **any length** where every item matches the schema (Homogeneous List).

```typ
matcher.many(schema)
```

**Example:**

```typ
// Matches a list of numbers: (1, 2, 3)
let numbers = matcher.many(int)
```

### `dict`

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

The `switch` function allows you to categorize data against a list of cases, returning a value associated with the first match.

### `switch`

Evaluates a value against a list of cases.

```typ
matcher.switch(target, cases)
```

| Parameter | Type    | Default  | Description                 |
| --------- | ------- | -------- | --------------------------- |
| `target`  | `any`   | Required | The value to classify.      |
| `cases`   | `array` | Required | An array of `case` objects. |

### `case`

Defines a single branch in a switch statement.

```typ
matcher.case(pattern, output, strict: false)
```

| Parameter | Type   | Default  | Description                                  |
| --------- | ------ | -------- | -------------------------------------------- |
| `pattern` | `any`  | Required | The schema pattern to match.                 |
| `output`  | `any`  | Required | The value to return if this case matches.    |
| `strict`  | `bool` | `false`  | Override strict mode for this specific case. |

**Example:**

```typ
#let kind = matcher.switch(signal, {
  import matcher: *

  // 1. Match a specific shape
  case((cost: int), "task")

  // 2. Match a list of items
  case(many(str), "tag-list")

  // 3. Fallback using wildcard
  case(any(), "unknown")
})
```
