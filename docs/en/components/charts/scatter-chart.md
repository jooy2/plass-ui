---
title: PlScatterChart
order: 5
---

# PlScatterChart

<p class="plass-lede">Two numbers per point, and whether they move together. Both axes measure, which makes this the only chart in the library with no categories.</p>

<Demo src="scatter-chart/hero" :min-height="360" />

::: fw react

```tsx
import { PlScatterChart } from 'plass-ui';

<PlScatterChart series={stores} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlScatterChart(series: stores);
```

:::

There is no column a mark belongs to and no order the points could be shuffled out of. A point with a `z` is drawn as a bubble and one without it as a dot, so a scatter and a bubble chart are the same component reading the same data — the third number is simply present or not.

## Props

<PropsTable name="PlScatterChart" />

Each point's `x` must be a number or a date. Text has no place on a number line, and a chart of named things against one measure is a [bar chart](./bar-chart).

Neither axis is forced to zero. What a position encodes is a place, so cropping a scale slides every mark by the same amount and the shape of the cloud survives — which is not true of a bar, whose length _is_ its value.

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Bubbles

<Demo src="scatter-chart/bubbles" :min-height="380">

::: fw react

<<< @/.vitepress/demos/scatter-chart/bubbles.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scatter_chart/bubbles.dart

:::

</Demo>

A point's `z` is an **area**, not a radius. Encoded as a radius, a value twice as large would draw a mark four times the size; the square root keeps the ink on the page proportional to the number behind it. One scale covers the whole chart and is taken over every series including the hidden ones, so two bubbles the same size mean the same number wherever they are, and switching a series off does not resize the rest.

Bubbles are painted largest first. A small bubble inside a big one is invisible if the big one is drawn on top of it, and the usual fix — half alpha on every fill — would undo the contrast the palette was solved for.

### shape

<Demo src="scatter-chart/shape" :min-height="380">

::: fw react

<<< @/.vitepress/demos/scatter-chart/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scatter_chart/shape.dart

:::

</Demo>

`auto` — the default — draws circles while colour alone can carry identity, and switches to a shape per series from the fourth on. That threshold is measured rather than chosen: taking the first three palette slots, the closest pair under deuteranopia is ΔE 64 on the light sheet and 51 on the dark one; add the fourth and those fall to 4.9 and 2.8. Past three, colour is not telling anyone anything, and a shape is the one channel a dot has going spare.

A series that carries a `color` of its own does not count against that ceiling — the caller has already answered the question it exists to ask.

`varied` turns the shapes on regardless, which is what to reach for when the chart will be printed or read in greyscale. Naming one of the five shapes puts every mark in it, and on four or more series that is opting out of the second channel.

### pointRadius and maxRadius

`pointRadius` is the radius of a mark with no `z`. `maxRadius` is how big the largest bubble may get, and it doubles as the room reserved around the plot — a mark is drawn from its centre, so a bubble at the largest `x` would otherwise hang over the edge.

## Accessibility

- The drawing carries the chart's name, and every point is handed over as text: each series, then its points as `x, y` pairs with the `z` in brackets where there is one.
- On React the picture is a `role="img"` and a tab stop, and the arrow keys walk the marks **in the order the data was given** — not the order they are painted in, which is largest-first and would be an order the reader cannot anticipate.
- On React the same numbers are written into a table under the chart: a row per point rather than the grid every other chart uses, because two points that are both the fifth of their series have nothing to do with each other and a shared row would invent a relationship. Its columns are named from the axis labels, falling back to `x`, `y` and `z`.
- Past three series the marks differ in **shape** as well as in hue, and the legend's swatches show the shapes.
