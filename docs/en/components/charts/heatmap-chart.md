---
title: PlHeatmapChart
order: 8
---

# PlHeatmapChart

<p class="plass-lede">A magnitude per cell, coloured rather than measured. Two shapes of one idea: a grid for two categorical axes, a treemap for parts of a whole.</p>

<Demo src="heatmap-chart/hero" :min-height="320" />

::: fw react

```tsx
import { PlHeatmapChart } from 'plass-ui';

<PlHeatmapChart series={week} categories={hours} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHeatmapChart(series: week, categories: hours);
```

:::

Reach for the grid when both axes are categorical and the question is _where_, which hour of which day, which cohort in which week. A [bar chart](./bar-chart) of the same data would be forty bars nobody can scan.

**Colour here encodes size and not identity**, so it comes off a one-hue ramp rather than the categorical palette. A heatmap in eight hues says its cells are eight unrelated things.

## Props

<PropsTable name="PlHeatmapChart" />

Each series is a row of the grid or a group of the treemap, and each datum a cell or a tile. A `null` leaves the cell as surface rather than drawing it as the bottom of the scale, because "nothing happened" and "the least of anything" are not the same reading.

One ladder covers the whole chart rather than one per row. The colour of a cell has to mean the same number wherever it is, which is the entire promise a heatmap makes.

## Examples

### shape

<Demo src="heatmap-chart/treemap" :min-height="360">

::: fw react

<<< @/.vitepress/demos/heatmap-chart/treemap.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/heatmap_chart/treemap.dart

:::

</Demo>

A treemap is for parts of a whole with more parts than a [pie chart](./pie-chart) can hold, and it is the same component because the data is the same shape: a row of a heatmap and a group of a treemap are both a named series of named magnitudes.

The packing is **squarified** rather than sliced. A slice-and-dice treemap of twenty values ends in slivers a pixel wide, and a sliver's _area_ is unreadable however exact it is, the reader compares its length instead, which is not the encoded quantity.

A tile's area is its share, so a negative value has no area to be. It stays in the table and off the picture.

A treemap has no axes: its tiles are named on their own faces, which is the trade it makes for filling the box edge to edge.

### scale

<Demo src="heatmap-chart/diverging" :min-height="280">

::: fw react

<<< @/.vitepress/demos/heatmap-chart/diverging.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/heatmap_chart/diverging.dart

:::

</Demo>

`sequential` is one hue, pale to deep, and is right whenever more is simply more. `diverging` is two hues either side of a neutral, for a value with a **middle** that means something, over and under target, gained and lost. Reached for on a plain magnitude it invents a boundary the data has none of.

A diverging scale is read from its middle rather than from its bottom, and both arms reach as far as the further one, so a set running from −2 to +40 does not paint every negative the deepest blue there is.

### valueLabels

Writes each cell's value on it where the cell is big enough for the text with room either side. A label that does not fit is **dropped rather than clipped**: a missing label sends the reader to the tooltip, and a clipped one sends them nowhere.

On a treemap the name comes first and the value only if there is still room under it, because nothing else on a treemap names its tiles. On a grid both coordinates are already written down the side and along the bottom, so the only thing left to write is the number.

## Accessibility

- The drawing carries the chart's name, and every cell is handed over as text, each row, then its cells as name-and-value pairs.
- On React the picture is a `role="img"` and a tab stop; the arrow keys walk the cells and <kbd>Escape</kbd> clears the readout, with each cell announced in a live region as it is reached.
- On React the same numbers are written into a table under the chart, with both sets of names on it: rows down the side, columns across the top.
- The label written inside a cell is the one place in the library where text does not wear an ink token. Which of the two it wears is decided **per ramp step**, where the step's lightness is known and the answer flips between the themes.
- The scale legend names both ends, and the middle too when the scale diverges.
