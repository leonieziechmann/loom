---
sidebar_position: 4
---

# Guards API

**Defensive Architecture**

The `guards` module provides a set of assertion functions to enforce the structural integrity of your document. You use these inside the `measure` or `draw` functions of your components to ensure they are being used in the correct context.

:::danger Critical Behavior
If a guard fails, it will **panic** with a helpful error message, stopping the compilation immediately. Use guards only for requirements that are non-negotiable for your component's logic.
:::

## Hierarchy Guards

These functions check the **Path** of the current component to ensure it is nested correctly.

### `assert-inside`

Asserts that the component is nested within at least one of the specified ancestors.

```typ
guards.assert-inside(ctx, ..ancestors)
```

| Parameter     | Type         | Default  | Description                                             |
| ------------- | ------------ | -------- | ------------------------------------------------------- |
| `ctx`         | `dictionary` | Required | The current context object.                             |
| `..ancestors` | `str`        | Required | A list of component kinds (names) allowed as ancestors. |

### `assert-not-inside`

Asserts that the component is **not** nested within any of the specified ancestors.

```typ
guards.assert-not-inside(ctx, ..ancestors)
```

| Parameter     | Type         | Default  | Description                                   |
| ------------- | ------------ | -------- | --------------------------------------------- |
| `ctx`         | `dictionary` | Required | The current context object.                   |
| `..ancestors` | `str`        | Required | A list of forbidden ancestor component kinds. |

### `assert-direct-parent`

Asserts that the **immediate** parent matches one of the specified kinds. This is stricter than `assert-inside`.

```typ
guards.assert-direct-parent(ctx, ..parents)
```

| Parameter   | Type         | Default  | Description                                      |
| ----------- | ------------ | -------- | ------------------------------------------------ |
| `ctx`       | `dictionary` | Required | The current context object.                      |
| `..parents` | `str`        | Required | A list of allowed direct parent component kinds. |

### `assert-root`

Asserts that the component is at the root of the Loom tree (it has no Loom parents).

```typ
guards.assert-root(ctx)
```

| Parameter | Type         | Default  | Description                 |
| --------- | ------------ | -------- | --------------------------- |
| `ctx`     | `dictionary` | Required | The current context object. |

### `assert-max-depth`

Asserts that the current nesting depth does not exceed a limit.

```typ
guards.assert-max-depth(ctx, max)
```

| Parameter | Type         | Default  | Description                                  |
| --------- | ------------ | -------- | -------------------------------------------- |
| `ctx`     | `dictionary` | Required | The current context object.                  |
| `max`     | `int`        | Required | The maximum allowable nesting depth integer. |

---

## Context Guards

These functions validate the data present in the `ctx` dictionary.

### `assert-has-key`

Asserts that a specific key exists in the context.

```typ
guards.assert-has-key(ctx, key, msg: none)
```

| Parameter | Type         | Default  | Description                                                         |
| --------- | ------------ | -------- | ------------------------------------------------------------------- |
| `ctx`     | `dictionary` | Required | The current context object.                                         |
| `key`     | `str`        | Required | The dictionary key to check for existence.                          |
| `msg`     | `str`        | `none`   | An optional custom error message to display if the assertion fails. |

### `assert-value`

Asserts that a context key exists and its value matches one of the allowed options.

```typ
guards.assert-value(ctx, key, ..allowed)
```

| Parameter   | Type         | Default  | Description                                                     |
| ----------- | ------------ | -------- | --------------------------------------------------------------- |
| `ctx`       | `dictionary` | Required | The current context object.                                     |
| `key`       | `str`        | Required | The context key to retrieve and check.                          |
| `..allowed` | `any`        | Required | A list of valid values that the context key is allowed to hold. |
