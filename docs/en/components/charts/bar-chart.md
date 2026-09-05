---
title: PlBarChart
order: 3
---

# PlBarChart

<p class="plass-lede">Lengths, compared. A bar says <em>how much</em>, and it says it by being longer — which is the whole reason its axis starts at zero and cannot be talked out of it.</p>

<Demo src="bar-chart/hero" :min-height="320" />

::: fw react

```tsx
import { PlBarChart } from 'plass-ui';

<PlBarChart series={revenue} categories={regions} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBarChart(series: revenue, categories: regions);
```

:::

Crop the scale and a bar twice as long stops meaning twice as much, and the reader has no way to know it happened. Reach for a [line chart](./line-chart) when what matters is the shape of a change rather than the size of each value.

## Props

<PropsTable name="PlBarChart" />

The data is the same [`PlassChartSeries`](./line-chart#plasschartseries) every chart takes. A `null` is a gap here too, and a bar is simply **not drawn** for one — which is the distinction that matters most on this chart, because a zero-length bar and a missing bar are the same picture and only one of them is honest.

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### orientation

`horizontal` is the right answer whenever the category names are words: it has a whole column for them, where a vertical chart has the width of one bar.

<Demo src="bar-chart/orientation" :min-height="320">

::: fw react

<<< @/.vitepress/demos/bar-chart/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/orientation.dart

:::

</Demo>

Everything swaps with it — which band each axis reserves, which way the grid runs, which way the crosshair goes and which end of a bar is rounded.

### stacked

Grouped bars answer "which series is bigger here". Stacked bars answer "what is this total made of". They are different questions and the chart should be asked only one of them at a time.

<Demo src="bar-chart/stacked" :min-height="400">

::: fw react

<<< @/.vitepress/demos/bar-chart/stacked.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/stacked.dart

:::

</Demo>

`'full'` makes every bar the same length, so the chart is about **share** rather than size, exactly as it does on an [area chart](./area-chart) — and for the same reason it renormalises the data rather than the drawing.

The gap between two stacked segments is taken off the far end of each, so the stack still totals the right length and the seam is the **sheet showing through** rather than a line drawn on it. A border around a bar is ink that is not data.

### Negative values

The two arms are accumulated separately, so a series that dips does not shorten the one above it, and a negative bar grows down from the baseline while the positives grow up.

<Demo src="bar-chart/negative" :min-height="320">

::: fw react

<<< @/.vitepress/demos/bar-chart/negative.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/negative.dart

:::

</Demo>

**The baseline is redrawn over the bars.** Every bar starts there and the line is what says so; under them it would be half-hidden by the first pixel of each one.

### rounded

The corners come off the **data** end of each bar only. The baseline end stays square: that is where the value starts from, and a rounded foot makes the axis look scalloped.

### barSize and density

`barSize` is a cap, not a width. The band a bar sits in is whatever the plot divided by the category count gives; below the cap the bars fill their share of it, and above it the leftover stays as air. `density` is the share of the band the bars may take at all.

## Accessibility

Everything [`PlLineChart`](./line-chart#accessibility) says applies here: the name and the per-series summary, the legend as real controls, and — on React — the hidden table that carries every number.
