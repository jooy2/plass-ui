---
title: PlLineChart
order: 1
---

# PlLineChart

<p class="plass-lede">A value against time, or against anything else with an order to it. The line is the mark for <em>change</em>: it reads the space between two points as one movement rather than two separate facts.</p>

<Demo src="line-chart/hero" :min-height="320" />

::: fw react

```tsx
import { PlLineChart } from 'plass-ui';

<PlLineChart
  series={[{ name: 'Europe', data: [42, 45, 51, 49] }]}
  categories={['Jan', 'Feb', 'Mar', 'Apr']}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlLineChart(
  series: const <PlassChartSeries>[
    PlassChartSeries(
      name: 'Europe',
      data: <PlassChartDatum>[
        PlassChartDatum(42), PlassChartDatum(45), PlassChartDatum(51),
      ],
    ),
  ],
  categories: const <PlassChartCategory>[
    PlassChartCategory.text('Jan'),
    PlassChartCategory.text('Feb'),
    PlassChartCategory.text('Mar'),
  ],
);
```

:::

Reach for a bar chart when the categories could be shuffled without losing anything: a line between two products draws a relationship the data does not have.

Everything around the line (the axes, the grid, the crosshair, the legend, the tooltip and what a screen reader gets instead of the picture) comes from a shared frame, which is what makes two different charts on one dashboard read as one drawing rather than two.

## Props

<PropsTable name="PlLineChart" />

### PlassChartSeries

<PropsTable name="PlassChartSeries" />

A datum is a bare number, a `null`, or a point that says more about itself. **A `null` is a gap and never a zero**, a sensor that was offline, a month that has not closed yet. A chart that renders missing data as zero reports an outage as a collapse.

::: fw react

```tsx
data: [42, null, 51, { y: 49, label: 'Revised' }];
```

:::

::: fw flutter

```dart
data: const <PlassChartDatum>[
  PlassChartDatum(42),
  PlassChartDatum.gap(),
  PlassChartDatum(51),
  PlassChartDatum.point(PlassChartPoint(y: 49, label: 'Revised')),
],
```

A closed union rather than React's `number | null | object`, which is what Dart gives instead of a union type.

:::

### <Fw react="PlassChartAxis" flutter="PlChartAxis" />

`xAxis` is the category axis and `yAxis` the value axis on every chart, in either orientation: a bar chart turned on its side keeps its options on the same prop.

<PropsTable name="PlassChartAxis" />

### <Fw react="PlassChartLegend" flutter="PlChartLegend" />

<PropsTable name="PlassChartLegend" />

### <Fw react="PlassChartTooltip" flutter="PlChartTooltip" />

<PropsTable name="PlassChartTooltip" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### curve

`linear` is the default and the only one that adds nothing to the data. `smooth` is a **monotone cubic**, not a plain spline: it is curved, but it will not dip below a value that both of its neighbours are above. A chart is allowed to be curved and it is not allowed to show a value that is not in the data. `step` is what a rate, a tier or a setting actually did between two readings, rather than a diagonal pretending it drifted.

<Demo src="line-chart/curve" :min-height="380">

::: fw react

<<< @/.vitepress/demos/line-chart/curve.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/curve.dart

:::

</Demo>

### dashed

A series marked `dashed` is drawn with a **6px dash and a 4px gap** instead of a solid stroke. It is what tells a reader that a line is a forecast, a target or last year rather than a measurement — the colour already says which entity the line is about, and asking it to also say how certain the line is would be two jobs for one channel.

<Demo src="line-chart/dashed" :min-height="320">

::: fw react

<<< @/.vitepress/demos/line-chart/dashed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/dashed.dart

:::

</Demo>

The pattern is fixed rather than scaled by the size ladder, so a dashed line reads as the same rhythm on an `sm` chart and an `lg` one. Only a line has a line to dash: it does nothing on a bar, and nothing on a stacked band either, whose fill is the mark and which has no stroke along its top. Where the line is dashed, its legend entry is a short dashed rule in place of the square, so the key says what the plot says. Pair `dashed` with a name that says what the line is as well.

### Gaps

A `null` **breaks the line**, which is the default and the only answer that claims nothing the data did not: the blank says the reading is missing. `nulls` has the other two. `connect` joins the two sides, for a gap that is an artefact of how the data was collected rather than a period where nothing happened; `zero` reads the gap as a nought, for a missing row that genuinely means none.

<Demo src="line-chart/gaps" :min-height="320">

::: fw react

<<< @/.vitepress/demos/line-chart/gaps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/gaps.dart

:::

</Demo>

A point with a gap either side of it is drawn as a dot rather than dropped: it is a reading, and a reading with nothing to join to is still a reading.

`zero` is a change to the **data** rather than to the drawing: the nought moves the value axis, fills the tooltip row and appears in the table under the chart, which is what makes the picture and the numbers agree about what happened that hour. `connectNulls` still works and means `nulls="connect"`; it is read only where `nulls` says nothing.

### valueLabels

`last` names where each series ended up, which is the question a line chart is usually being asked, and it is the setting that lets a chart drop its value axis entirely.

<Demo src="line-chart/labels" :min-height="300">

::: fw react

<<< @/.vitepress/demos/line-chart/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/labels.dart

:::

</Demo>

`extremes` writes the high and the low; `all` writes every one of them, and a chart with a number on every point is a table drawn badly.

### Reference lines

`reference` draws a target, an average or a limit across the plot. It is **not data**, and it is drawn as if it knows that: dashed, in the muted ink, and under the marks.

<Demo src="line-chart/reference" :min-height="320">

::: fw react

<<< @/.vitepress/demos/line-chart/reference.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/reference.dart

:::

</Demo>

It sits on the **value** axis, so the same line runs across a vertical chart and down a horizontal one — turning a bar chart on its side does not move it. `color` takes it to a family where the line already means something on the page, `dashed: false` makes it solid, and each one is written into the description a screen reader is handed with the chart, because a target is a fact about the picture rather than decoration on it.

### The value axis leaves zero out

A line encodes a **position**, so cropping the scale moves every point by the same amount and the shape survives. A bar encodes a **length**, which stops meaning anything the moment it starts from 98, which is why a bar chart's axis includes zero and this one does not.

A series that lives between 98 and 99 is a flat line on a scale that begins at zero. Ask for one with the axis' own `min`.

```tsx
<PlLineChart series={series} yAxis={{ min: 0 }} />
```

### Colour

The palette is **eight hues in a fixed order**, and it is the one place in the library where a colour is not a semantic role. A series is an entity (a region, a plan, a competitor), and nothing about it says success or danger.

Slots are handed out by a series' **index in the array it was passed**, never by its position among the ones currently visible: a reader who learned that Europe is blue has learned something a filter is not allowed to take back. A ninth series is not a ninth colour; it is an "Other" row, or a second chart.

The tokens are `--plass-chart-1` through `--plass-chart-8`, and a project that must match a brand overrides them once rather than per chart.

## Accessibility

- The whole drawing carries a name.
- The picture is a tab stop. <kbd>←</kbd> and <kbd>→</kbd> walk the categories one at a time, <kbd>Home</kbd> and <kbd>End</kbd> go to the first and the last, and <kbd>Escape</kbd> clears the readout. The key is taken only while something is being read; otherwise it goes on to whatever the chart sits in, so a sheet around it still closes. Each category is announced in a live region as it is reached, with the value of every visible series there. With the tooltip turned off the keys do nothing and nothing is announced.
- The legend is a row of real controls: each entry says whether its series is on, and pressing one switches it.
- A hovered legend entry dims the **others** rather than lighting its own, a chart whose hovered series changes colour is a chart whose legend lies for as long as the pointer is on it.

::: fw react

- The picture is a `role="img"`. Focusing it reads its name and then a one-line summary: each visible series and where it ended up, such as "Web 40, App 8". The chart also renders a real `<table>` of every value, clipped from view but never hidden from the accessibility tree, as a sibling of the picture — so the values are one step away rather than four hundred of them read out on every focus.

:::

::: fw flutter

- The tab stop is the chart's own semantics node, so a reader arriving on it by Tab hears the name and the text below.
- As its value, the drawing carries **every number in it**: each visible series, then the categories it has a value at and what it was worth there — "Revenue: Jan 12; Feb 19; Mar 15. Cost: Jan 8; Feb 11; Mar 9". There is no hidden table on this side the way there is on React, so the text is the only path to the numbers. A gap is left out rather than read as a category with nothing after it, and a chart given no `categories` leaves the positions out too, because the order of the reading already carries them.
- `semanticValue` replaces that text for a chart whose summary is not "each series and its values". It is handed which series are on.
- A tap **leaves** the tooltip up and a second tap on the same column takes it down. Clearing it on the release would be a tooltip a reader with no pointer never gets to read: on a touch screen the press and the release are a tenth of a second apart. A drag scrubs along the axis.

:::
