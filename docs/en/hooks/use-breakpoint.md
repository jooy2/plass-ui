---
title: usePlBreakpoint
order: 2
---

# usePlBreakpoint

<p class="plass-lede">Which rung of the breakpoint ladder the window is on, and the value a <code>PlassResponsive</code> map resolves to there. The same five widths <code>PlGrid</code> uses and Tailwind's own variants use, answered in JavaScript.</p>

<Demo src="hooks/breakpoint" :min-height="320" />

::: fw react

```tsx
import { usePlBreakpoint, usePlBreakpointValue } from 'plass-ui';

const at = usePlBreakpoint(); // 'xs' | 'sm' | 'md' | 'lg' | 'xl'
const columns = usePlBreakpointValue({ xs: 1, sm: 2, lg: 4 });
```

:::

::: fw flutter

Hooks are React-only. Flutter reads the width off `MediaQuery` and compares it, which is the same arithmetic without the subscription:

```dart
final width = MediaQuery.sizeOf(context).width;
final columns = width >= 1024 ? 4 : width >= 640 ? 2 : 1;
```

:::

## Signature

```ts
function usePlBreakpoint(): PlassBreakpoint;
function usePlBreakpointValue<T>(value: PlassResponsive<T>): T | undefined;
```

The ladder is Tailwind's own, so a decision made here and a decision made in a class name change together:

| Rung | From  |
| ---- | ----- |
| `xs` | 0     |
| `sm` | 40rem |
| `md` | 48rem |
| `lg` | 64rem |
| `xl` | 80rem |

## Examples

### usePlBreakpointValue

The same shape and the same rule as a responsive prop on `PlGrid`: a bare value applies everywhere, and a map applies each entry **from its own breakpoint up**. Two entries usually describe a whole layout.

```tsx
usePlBreakpointValue(3); // 3, at every width
usePlBreakpointValue({ xs: 1, md: 3 }); // 1 on a phone, 3 from 48rem
```

An entry cascades to the rungs above it, so `{ xs: 1, md: 3 }` is `3` at `lg` and `xl` without either being written out.

### Below every rung the map named

`undefined`, rather than a guess.

```tsx
usePlBreakpointValue({ lg: 3 }); // undefined at xs, sm and md
```

A value the caller did not write would be worse than saying so. Give the map an `xs` entry when there has to be an answer everywhere.

### Deciding something CSS cannot

How many items to fetch, how many characters to truncate at, which of two components to mount.

```tsx
const perPage = usePlBreakpointValue({ xs: 10, md: 25, xl: 50 }) ?? 10;
```

## Notes

- **`xs` is the server's answer**, and the first one a browser renders — the same rule [`usePlMediaQuery`](./use-media-query) explains, and for the same reason. It is also the safe one: `xs` is the narrow layout.
- It is four media queries rather than one `innerWidth` read. A width measured in JavaScript has to be compared against a number of pixels, and the ladder is written in `rem` — so a reader who has enlarged their default font size would get a rung that disagrees with the stylesheet.
- An **object is read as a map**, exactly as it is in a responsive prop. A value that is itself an object has to be wrapped: `{ xs: { … } }`.
- `usePlBreakpointValue` calls `usePlBreakpoint`, which calls four media queries. Hooks are cheap here — the listener is shared per query across the whole page — but the value is recomputed on every render, so keep the map itself out of the render body if it is large.
