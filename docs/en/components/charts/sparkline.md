---
title: PlSparkline
order: 6
---

# PlSparkline

<p class="plass-lede">A chart with everything taken away except the shape. No axes, no grid, no legend, no tooltip — a word-sized picture that goes inside a sentence and says which way something has been going.</p>

<Demo src="sparkline/hero" :min-height="200" />

::: fw react

```tsx
import { PlSparkline } from 'plass-ui';

<PlSparkline data={signups} endDot />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSparkline(data: signups, endDot: true);
```

:::

It is not a small chart, it is a different thing. Every number it could label is one the surrounding text already has, which is why it labels none of them. Put it beside a [`PlStat`](../display/stat), in a table cell, or in a line of prose.

## Props

<PropsTable name="PlSparkline" />

Unlike the full charts this one takes its colour directly. A sparkline has exactly one series and no legend, so there is nothing for a palette to hand out.

There is no `tooltip` and no `legend`, and adding either would make it a chart. A `null` is a gap here as everywhere, and the line breaks at it.

## Examples

### shape

<Demo src="sparkline/shape" :min-height="220">

::: fw react

<<< @/.vitepress/demos/sparkline/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sparkline/shape.dart

:::

</Demo>

The same three sentences the full charts say, at a size where nothing else is being said at all. A line for a trend, an area for a quantity, bars for a count of discrete things.

### min and max

<Demo src="sparkline/scale" :min-height="280">

::: fw react

<<< @/.vitepress/demos/sparkline/scale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sparkline/scale.dart

:::

</Demo>

**A sparkline scales itself to its own range, so the strip is always full.** That is what makes it readable at twenty pixels tall, and it is also the trap: two of them side by side are drawn on two different scales, so a strip that climbs steeply may be the smaller number. Give a row of them the same `min` and `max` and they become a small-multiples chart instead.

### baseline

<Demo src="sparkline/baseline" :min-height="160">

::: fw react

<<< @/.vitepress/demos/sparkline/baseline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sparkline/baseline.dart

:::

</Demo>

A target, a budget, last year's average — the one piece of context a strip this small can carry. It is pulled into the range if it sits outside the data, so the rule is always visible.

### endDot

Puts a dot on the last point that is actually a point, not on the last slot. It is the one direct label a strip this small has room for, and it says where the series ended up. Bars do not take it: a bar already ends where it ends.

## Accessibility

- Without a `label` the strip is **taken off the accessibility tree entirely.** A sparkline is decoration beside text that already carries the numbers, and an unlabelled image announced as an image is noise.
- With a `label` it becomes a named `role="img"`, and the values are written out beside it — clipped from view, never hidden from the tree. What a sparkline owes is the numbers, not a description of the shape they happen to make.
- Colour is never the only channel here either: a sparkline sits beside the name and the number it belongs to.
