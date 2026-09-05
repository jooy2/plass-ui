---
title: PlTimelineChart
order: 9
---

# PlTimelineChart

<p class="plass-lede">Work against time, a row per thing, a bar per stretch of it. The two axes are a set of rows and a calendar.</p>

<Demo src="timeline-chart/hero" :min-height="280" />

::: fw react

```tsx
import { PlTimelineChart } from 'plass-ui';

<PlTimelineChart series={plan} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTimelineChart(series: plan);
```

:::

This is a [bar chart](./bar-chart) turned on its side with the baseline taken away: every bar starts where its own data says rather than at zero, so what the chart is about is _when_ rather than _how much_.

Not to be confused with [`PlTimeline`](../display/timeline), which is a list of steps and draws no axis at all. That one is for a sequence of events; this one is for how long each of them took.

## Props

<PropsTable name="PlTimelineChart" />

A row is a series (one entity, one name, one colour), but its data are spans rather than values, so it takes `PlassTimelineSeries` rather than the usual series type. There is no `legend` and no `hidden`: **the rows are the category axis**, already named down the side, and a twenty-entry legend restating them adds nothing.

The time axis ticks where a calendar ticks. The 1-2-5 family that rounds a value axis is the wrong one for an instant, run on milliseconds it produces a tick every 200,000,000 ms, which lands at 14:53:20 on an arbitrary Tuesday.

## Examples

### Overlapping spans

<Demo src="timeline-chart/lanes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/timeline-chart/lanes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline_chart/lanes.dart

:::

</Demo>

A row that is doing two things at once is the ordinary case, and drawing the second bar on top of the first turns two facts into one smudge. Overlapping spans are moved onto lanes of their own, by the greedy packing every scheduler uses: walk the spans in start order and drop each into the first lane whose last one has finished.

A row with no overlaps stays in a single lane, so the common row is exactly as thick as it was. Lanes are assigned in **start** order but stored against the span's original index, because the order the data was written in is the order the arrow keys walk and a layout decision must not reshuffle it.

### min and max

<Demo src="timeline-chart/window" :min-height="200">

::: fw react

<<< @/.vitepress/demos/timeline-chart/window.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline_chart/window.dart

:::

</Demo>

A span is cut to the plot rather than to the data. A caller who pinned the axis to this quarter still has work that began last one, and a bar that stops at the edge says there is more of it off the side; one drawn past the edge says the axis is wrong.

A zero-width span keeps a hairline, so a milestone is still something on the row.

### rounded

Both ends, unlike a [bar chart](./bar-chart), where the baseline end stays square. A span grows from nothing: neither of its ends is a zero, so neither is the one the reader is measuring from.

## Accessibility

- The drawing carries the chart's name, and every span is handed over as text: each row, then its spans as the two instants they run between.
- On React the picture is a `role="img"` and a tab stop, and the arrow keys walk the spans in the order the data was written.
- On React the same data is written into a table under the chart, **a row per span** rather than the grid every other chart uses. Two rows of a Gantt have no columns in common: the third thing on one row and the third thing on another are unrelated, and filing them side by side would invent a relationship.
- A span that names itself is named in the readout, with its row on the second line rather than repeated on the first.
