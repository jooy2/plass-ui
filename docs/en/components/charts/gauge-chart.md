---
title: PlGaugeChart
order: 7
---

# PlGaugeChart

<p class="plass-lede">One number on a scale that is known in advance, drawn as a dial. A <code>PlMeter</code> bent into an arc, for a tile of its own rather than a row of fields.</p>

<Demo src="gauge-chart/hero" :min-height="280" />

::: fw react

```tsx
import { PlGaugeChart } from 'plass-ui';

<PlGaugeChart value={68} caption="of quota" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlGaugeChart(value: 68, caption: Text('of quota'));
```

:::

`value`, `min`, `max` and `thresholds` mean exactly what they mean on a [meter](../feedback/meter), so a page can move a reading from a bar to a dial without changing what it says. Reach for the bar in a row of fields and for this one where a dial reads at a glance from across a room and a four-pixel bar does not.

**It is not a [pie chart](./pie-chart) with `shape="semi"`.** A pie is parts of a whole and every slice is a category; this is one value against a scale, and the unfilled part of the arc is not a second category — it is the rest of the dial.

## Props

<PropsTable name="PlGaugeChart" />

A `null` value draws the dial with nothing on it, which is the honest picture of an instrument that has not been told anything. There is no `legend` and no `tooltip`: one number needs neither.

What the shared props mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### sweep

<Demo src="gauge-chart/sweep" :min-height="240">

::: fw react

<<< @/.vitepress/demos/gauge-chart/sweep.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gauge_chart/sweep.dart

:::

</Demo>

Degrees, opened symmetrically about twelve o'clock. `180` is the half-dial a dashboard tile wants, `270` is the instrument shape, `360` is a ring.

The dial is sized against the box rather than assuming a circle, because how far it reaches _below_ its centre depends on the sweep: a half-dial stops level with the centre and a 270° one drops most of a radius past it. That is what keeps a wide, short card from drawing a thin band with an empty half above it.

### thresholds

<Demo src="gauge-chart/thresholds" :min-height="240">

::: fw react

<<< @/.vitepress/demos/gauge-chart/thresholds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gauge_chart/thresholds.dart

:::

</Demo>

The highest band at or below the value wins, and `color` is what the arc is made of below all of them. Order in the list does not matter — the bands are read, not walked — which is the same rule and the same code a `PlMeter` uses.

A band is a second way of saying the number, never the only one. The reading is written in the middle whatever colour the arc has taken.

### ticks and showRange

<Demo src="gauge-chart/ticks" :min-height="280">

::: fw react

<<< @/.vitepress/demos/gauge-chart/ticks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gauge_chart/ticks.dart

:::

</Demo>

Ticks are off by default. A gauge on a dashboard is read as a proportion, and marks around the rim are for an instrument somebody takes a _number_ off.

`showRange` writes `min` and `max` at the two ends, and is dropped past 330° whatever it says: by then the two ends have come within a label's width of each other, and `0` and `100` set on top of each other is a smudge rather than a scale.

### center and caption

`center` replaces the number in the hole, and `caption` hangs a line under it. Replacing the reading is for adding to it rather than for taking it away — the number is what the dial is for.

The reading is **real text, not a label painted into the drawing**, so it can be selected, found by the browser's own search and read without the chart having to describe itself. Its size is solved against the room the hole actually leaves rather than fixed, because `38` and `10,000%` are the same prop.

## Accessibility

- With a `label` the dial is one named image saying one thing: `"Storage used: 1.36 / 2"`. That saves a reader hearing the two end labels as loose numbers.
- Without one it stays a plain box, and the reading in the middle is read as the text it already is.
- The value is never carried by colour alone. A threshold changes the family; the number in the middle says the same thing in words.
- The arc sweeps to a new reading rather than jumping to it, and the sweep is a length rather than a transform — the numbers written across the dial are never resampled.
