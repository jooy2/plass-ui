---
title: PlMeter
order: 12
---

# PlMeter

<p class="plass-lede">A quantity inside a range, drawn as a bar. It looks like a progress bar and it is not one: progress is something advancing, and a meter is something already known.</p>

<Demo src="meter/hero" :min-height="220" />

::: fw react

```tsx
import { PlMeter } from 'plass-ui';

<PlMeter
  value={82}
  label="Disk used"
  showValue
  thresholds={[
    { from: 75, color: 'warning' },
    { from: 90, color: 'danger' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlMeter(
  value: 82,
  label: const Text('Disk used'),
  showValue: true,
  thresholds: const <PlMeterThreshold>[
    PlMeterThreshold(from: 75, color: PlassColor.warning),
    PlMeterThreshold(from: 90, color: PlassColor.danger),
  ],
);
```

:::

## Props

<PropsTable name="PlMeter" />

### PlMeterThreshold

<PropsTable name="PlMeterThreshold" />

Every native `<div>` attribute passes straight through. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Meter or progress bar

The two are drawn out of the same groove and the same gradient, and they say different things.

|  |  |
| --- | --- |
| [`PlProgressLinear`](./progress-linear) | Something is **advancing**. An upload, an install, a step of four. It can be indeterminate, because nobody always knows how much is left. |
| `PlMeter` | Something is **already known**. Disk used, seats taken, a password's strength, how full a battery is. It is not going anywhere on its own. |

Which follows into the API: `value` is **required** here and there is no sweep, because a meter with nothing to report is not a meter — it is a bar that should not have been drawn yet.

::: fw react

And into the semantics: the role is `meter`, not `progressbar`. A screen reader announces the two differently, and telling somebody a static figure is in progress is telling them to wait for something that will never finish.

Base UI's `Meter` owns all of that — the role, the range attributes, `aria-valuetext`, the formatting and the fill width — the same way its `Progress` owns a progress bar's. What is left here is the material.

:::

::: fw flutter

The semantics are where the two builds genuinely differ. `SemanticsRole` has no `meter`, and claiming `progressBar` would announce the one thing this widget exists to say it is not — so the Flutter build reports a **named node carrying a value** and no role at all. That is what the platforms read out for either one in practice; what is given up is the role name itself.

:::

## thresholds

The prop it exists for. A quota bar that turns amber at three quarters and red at ninety percent says something a fixed colour cannot, and the colour is derived from the value rather than chosen by the caller at the moment they happened to be looking at it.

<Demo src="meter/thresholds" :min-height="240">

::: fw react

<<< @/.vitepress/demos/meter/thresholds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/meter/thresholds.dart

:::

</Demo>

Three rules, and none of them has an order in it:

- The band with the **highest `from` at or below the value** wins. The list is read, not walked, so writing the bands in any order gives the same answer.
- `from` is in the meter's own **units**, not a percentage — unless the range happens to be one. A band outside `min`…`max` is simply never reached.
- `color` is what the bar is made of below every band.

**Turn `showValue` on with them.** A band is a second way of saying how full something is; it must never be the only one, because a reader who cannot tell amber from red is left with a bar and no number.

## Examples

### A range that is not a percentage

`min` and `max` are the units the figure is actually in, and `format` writes it out in them. Without `format` the value reads as a percentage of the range, which is the only formatting that holds for a range nobody described.

::: fw react

```tsx
<PlMeter
  value={18}
  max={100}
  label="Documents"
  showValue
  format={{ style: 'unit', unit: 'gigabyte' }}
/>
```

:::

::: fw flutter

`formatValue` is a callback rather than an options object, and that is deliberate. There is no `Intl.NumberFormat` in the framework, and a package that pulled `package:intl` in to provide one would be making a dependency decision on its consumer's behalf. Whatever formats numbers in the app already formats this one.

```dart
PlMeter(
  value: 18,
  label: const Text('Documents'),
  showValue: true,
  formatValue: (double value) => '${value.toStringAsFixed(0)} of 100 GB',
);
```

:::

### Password strength

Four steps rather than a hundred, which is what `min` and `max` are for.

```tsx
<PlMeter
  value={score}
  min={0}
  max={4}
  label="Password strength"
  thresholds={[
    { from: 2, color: 'warning' },
    { from: 3, color: 'success' }
  ]}
  color="danger"
/>
```

## Notes

- A value outside the range is **clamped**, and both halves of that agree: the bar is drawn at the edge of the range and the value announced is the clamped one, so what is read out and what is on screen never disagree. `value` usually arrives from a division somewhere, and a bar rendered 140% wide because one number was counted twice is a worse bug than a bar that sits full.
- An empty range (`max` at or below `min`) leaves the bar at nothing. It is a caller's mistake rather than a state, and drawing a full bar for it would be a claim.
- The groove is `--plass-track`, the same neutral ink a slider's rail and a switch's off state are cut in, and the fill is the family's gradient. The travel is on the **width**, because a gradient cannot be transitioned and a length can.
- No `variant`, no `density`, no `elevation`. A meter is one material, it has nothing to pad, and it is cut _into_ the surface it sits on the way a groove is.

## Accessibility

- The value is announced as **text** rather than as a bare number — `aria-valuetext` in React, the node's value in Flutter. "3" out of a range that is not 0–100 is a percentage the platform would guess wrong.
- `label` names the meter, and it is the same string a sighted reader sees. Without one the bar is an unnamed figure, which is a number with nothing attached to it.
- With `showValue` the figure is drawn **and** carried on the node, and the drawn copy is hidden from the accessibility tree so it is heard once rather than twice.
- Colour is never the only carrier of a band. Pair `thresholds` with `showValue`.
