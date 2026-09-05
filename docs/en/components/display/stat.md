---
title: PlStat
order: 19
---

# PlStat

<p class="plass-lede">One figure, and what has happened to it. A number on its own says what things are; a number with a movement beside it says whether that is going anywhere.</p>

<Demo src="stat/hero" :min-height="220" />

::: fw react

```tsx
import { PlStat } from 'plass-ui';

<PlStat label="Revenue" value="£48,120" change={12.4} description="vs last month" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlStat(
  label: const Text('Revenue'),
  value: const Text('£48,120'),
  change: 12.4,
  description: const Text('vs last month'),
);
```

:::

## Props

<PropsTable name="PlStat" />

Every native `<div>` attribute passes straight through. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## improvesWhen

The one thing a naive version of this gets wrong. **The colour of a movement is decided by whether it is good news, not by its sign**. Churn going up is not good news, and a green arrow on it is a dashboard lying to somebody.

`up` is the default and is right most of the time. Set `improvesWhen="down"` on about a third of the figures a dashboard has: churn, a bounce rate, a p95 latency, a support backlog, a cost.

<Demo src="stat/direction" :min-height="200">

::: fw react

<<< @/.vitepress/demos/stat/direction.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stat/direction.dart

:::

</Demo>

## value takes a node

Not a number, and deliberately. How a figure is written (the currency, the grouping, the decimals, the locale) is the page's decision, and `Intl.NumberFormat` already makes it. A component that took a number would have to guess at all four.

```tsx
<PlStat
  label="Revenue"
  value={new Intl.NumberFormat('en-GB', { style: 'currency', currency: 'GBP' }).format(total)}
/>
```

::: fw flutter

The same, with `package:intl` doing the formatting. This package has no dependencies to do it with, which is the other half of the reason `value` is a widget.

```dart
PlStat(
  label: const Text('Revenue'),
  value: Text(NumberFormat.simpleCurrency(locale: 'en_GB').format(total)),
);
```

`PlStat.formatChange` is the one number the widget does write: at most one decimal, and a sign on a rise. Anything more particular is what `changeLabel` is for.

:::

## Examples

### changeLabel

For a figure that moved by a **count** rather than by a proportion.

```tsx
<PlStat label="Sign-ups" value="1,204" change={8.1} changeLabel="+94 this week" />
```

`change` still decides the arrow and the colour; `changeLabel` only decides the words.

### loading

Draws a skeleton where the figure will be, and holds the change back with it. A movement beside a figure nobody has yet is a movement of nothing.

```tsx
<PlStat label="Revenue" loading={pending} value={total} change={delta} />
```

## Notes

- **It draws no surface.** A figure sits in a `PlCard` or in a row of them, and a sheet inside a sheet is two sheets.
- The figure is `tabular-nums`, so a row of stats that updates on a timer does not jitter as the digits change width.

## Accessibility

- The arrow is `aria-hidden` and the sign is **in the text**. "+12.4%" reads correctly on its own, and a screen reader is not told about a triangle.
- The colour is never the only thing carrying the direction, for the same reason: the sign and the arrow both say it.
- It has no role and no heading. A row of figures is a set of `<div>`s to a screen reader unless the page says otherwise. Put them in a list, or give the row a `<h2>`, depending on what the page is.

::: fw flutter

The arrow is inside an `ExcludeSemantics` and the sign is in the text, so a screen reader hears "+12.4%" and not a triangle.

:::
