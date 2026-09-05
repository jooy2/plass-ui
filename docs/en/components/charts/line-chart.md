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

### Gaps

A `null` **breaks the line**. `connectNulls` bridges it instead, and it should stay off unless the gap is an artefact of how the data was collected rather than a period where nothing happened.

<Demo src="line-chart/gaps" :min-height="320">

::: fw react

<<< @/.vitepress/demos/line-chart/gaps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/gaps.dart

:::

</Demo>

A point with a gap either side of it is drawn as a dot rather than dropped: it is a reading, and a reading with nothing to join to is still a reading.

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

- The whole drawing carries a name and, as its value, **each visible series and where it ended up**. The reading a sighted reader takes from the shape, rather than a cell-by-cell recital of the table.
- The legend is a row of real controls: each entry says whether its series is on, and pressing one switches it.
- A hovered legend entry dims the **others** rather than lighting its own, a chart whose hovered series changes colour is a chart whose legend lies for as long as the pointer is on it.

::: fw react

- The chart also renders a real `<table>` of the data, visually hidden, which is what a screen reader reads instead of the picture.

:::

::: fw flutter

- A tap **leaves** the tooltip up and a second tap on the same column takes it down. Clearing it on the release would be a tooltip a reader with no pointer never gets to read: on a touch screen the press and the release are a tenth of a second apart. A drag scrubs along the axis.

:::
