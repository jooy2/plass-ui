---
title: PlAreaChart
order: 2
---

# PlAreaChart

<p class="plass-lede">A line with the space under it filled — which changes what the chart is about. A line says where a value went; an area says how much of something there was, and stacked it says how that amount was made up.</p>

<Demo src="area-chart/hero" :min-height="320" />

::: fw react

```tsx
import { PlAreaChart } from 'plass-ui';

<PlAreaChart series={traffic} categories={months} stacked />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAreaChart(
  series: traffic,
  categories: months,
  stacking: PlAreaStacking.total,
);
```

:::

That is the whole test for reaching for this instead of a [line chart](./line-chart): if the quantity does not add up to anything — a temperature, a rate, a score — the fill under it is decoration, and a chart with two of them is two washes fighting.

## Props

<PropsTable name="PlAreaChart" />

The data is the same [`PlassChartSeries`](./line-chart#plasschartseries) every chart takes, and a `null` is a gap here too — more visibly so, because a fill that closes across a missing month paints a made-up number over a larger part of the chart than a bridged line does.

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### stacked

Each band rides on the total of those below it, and the top edge is the sum — which is the thing a stacked area is usually drawn to show.

**A stacked band is not also given a line along its top.** The band above would then be separated from it by a coloured stroke, and a stroke between two marks is ink that is not data. What separates them is the gap below.

### Share rather than size

`'full'` normalises every category to 100%, so the chart stops being about size and starts being about **share**. The value axis becomes a percentage and says so.

<Demo src="area-chart/share" :min-height="320">

::: fw react

<<< @/.vitepress/demos/area-chart/share.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/area_chart/share.dart

:::

</Demo>

The normalising is a change to the **data**, not to the drawing, which is what lets the axis, the tooltip and the table all agree that the number is a share. The tooltip still carries the number you passed: a chart that can only tell you percentages has thrown the data away.

::: fw flutter

`stacking` is one enum with three states rather than React's `boolean | 'full'`. Dart has no union type, and three named states read better than a boolean with an exception bolted onto it.

:::

### Unstacked bands overlap

Left unstacked, each band starts from the baseline and they lie over each other. The fill is a **wash that fades downward** rather than a slab: two of them overlapping stay readable, and the line along the top is what carries the value.

<Demo src="area-chart/overlap" :min-height="320">

::: fw react

<<< @/.vitepress/demos/area-chart/overlap.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/area_chart/overlap.dart

:::

</Demo>

Stacked bands take a flatter, opaquer tint instead, because there the fill **is** the mark — a band that faded out would have no bottom edge.

### The baseline is always zero

Unlike a line, an area's fill is its magnitude, so the baseline has to be zero or the band's thickness stops meaning anything. That is the one axis rule this chart does not share with [`PlLineChart`](./line-chart), whose scale is free to crop.

## Accessibility

Everything [`PlLineChart`](./line-chart#accessibility) says applies here: the name and the per-series summary, the legend as real controls, and — on React — the hidden table that carries every number.
