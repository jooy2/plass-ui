---
title: PlPieChart
order: 4
---

# PlPieChart

<p class="plass-lede">Parts of a whole, at a glance. The narrowest chart in the library and the easiest one to misuse. A pie is right for exactly one question: <em>is one of these most of it?</em></p>

<Demo src="pie-chart/hero" :min-height="360" />

::: fw react

```tsx
import { PlPieChart } from 'plass-ui';

<PlPieChart data={traffic} categories={sources} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPieChart(data: traffic, categories: sources);
```

:::

An angle is a poor thing to compare. Two slices within a few percent of each other are indistinguishable, and a reader cannot rank six of them. Anything finer than "is one of these most of it", and anything past six slices, is a [bar chart](./bar-chart).

## Props

<PropsTable name="PlPieChart" />

The data is one list of slices rather than a list of series, because that is what a pie is: **the slices are the entities here.** Each one takes a palette slot of its own, the legend lists them, and the colour follows the slice rather than its size, so a chart that is refiltered or resorted keeps every category the colour it had.

A `null` and a zero are both left undrawn. Neither has an angle, and a slice of no width is a slice a reader cannot point at.

What the shared props mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### shape

<Demo src="pie-chart/shape" :min-height="260">

::: fw react

<<< @/.vitepress/demos/pie-chart/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/shape.dart

:::

</Demo>

`semi` takes the **whole** height as its radius rather than half of it, because it only draws the top half. Its centre then sits below the middle of the box by half a radius, which puts the arc itself in the middle of the tile.

### center

<Demo src="pie-chart/center" :min-height="380">

::: fw react

<<< @/.vitepress/demos/pie-chart/center.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/center.dart

:::

</Demo>

A donut with nothing in the middle is a pie with a bite out of it. The total, or the one figure the chart is about, is what the ring was drawn around. It is ignored on a `pie`, which has no hole to put it in.

### valueLabels

<Demo src="pie-chart/value-labels" :min-height="380">

::: fw react

<<< @/.vitepress/demos/pie-chart/value-labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/value_labels.dart

:::

</Demo>

The number written on a slice is its **share**, not its value: a share is what a pie is a picture of, and the value is one hover away. A label wider than the slice it belongs to is dropped rather than clipped, so it can never end up sitting over the neighbour it would then be labelling.

### The hole and the gap

`shape` picks both — nothing cut out of a `pie`, and a little under two thirds out of a `donut` and a `semi`. `innerRadius` and `padAngle` set them directly, for when the hole has a particular job or the ring has to read as separate segments.

<Demo src="pie-chart/ring" :min-height="260">

::: fw react

<<< @/.vitepress/demos/pie-chart/ring.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/ring.dart

:::

</Demo>

`innerRadius` is a fraction of the radius, so it holds whatever size the chart is drawn at. `padAngle` is in degrees; left out, the gap is the 2px the library puts between any two marks, worked out at the rim — a constant **on screen** rather than a constant in the data, so a small pie is not drawn with the same sliver of surface a large one gets. A slice narrower than twice the gap keeps none of it, or a one-degree sliver would invert and draw the whole circle instead of nothing.

### startAngle

Where the first slice starts, in degrees clockwise from twelve o'clock. `semi` ignores it, that shape is defined by where it opens.

## Accessibility

- The drawing carries the chart's name, and the reading a sighted reader takes from the angles is handed over as text: every visible slice, its value and its share. A slice worth 0 has no angle, so it is not read either. A slice whose point carries its own `label` is read by that label instead, and its readout writes the label too.
- The picture is a **tab stop**. <kbd>←</kbd> and <kbd>→</kbd> walk the slices that are drawn, one at a time: after the last comes the first, and before the first the last. <kbd>Escape</kbd> clears the readout. The key is taken only while a slice is being read; otherwise it goes on to whatever the chart sits in, so a sheet around it still closes. Each slice is announced in a live region as it is reached, by its name and what it is worth.
- Focusing the picture reads its name and then every slice with its share, such as "Search 40 · 40%, Social 25 · 25%". On React the picture is a `role="img"`, and the same numbers are also written into a table under the chart, clipped from view but never hidden from the accessibility tree.
- The legend is real buttons. Pressing one takes its slice out of the ring and shares the angle out again among the rest.
- Colour is never the only channel: every slice is named in the legend, in the readout and in the table.
