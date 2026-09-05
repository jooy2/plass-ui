---
title: PlProgressLinear
order: 9
---

# PlProgressLinear

<p class="plass-lede">A bar that fills. The one indicator that can show <em>how much</em> is left at a glance, because length is the one quantity a reader can compare without counting.</p>

<Demo src="progress-linear/hero" :min-height="140" />

::: fw react

```tsx
import { PlProgressLinear } from 'plass-ui';

<PlProgressLinear label="Uploading" value={62} showValue />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlProgressLinear(label: const Text('Uploading'), value: 62, showValue: true);
```

:::

## Props

<PropsTable name="PlProgressLinear" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `children` because a bar holds nothing.

:::

::: fw flutter

`formatValue` is a function where React takes an options object, and it is the one prop that could not cross: there is no `Intl.NumberFormat` in the framework to hand options to, and a package that pulled `package:intl` in to provide one would be making a dependency decision on its consumer's behalf. Whatever formats numbers in the app already can format this one.

:::

There is no `variant`, no `density` and no `elevation`. An indicator is one material, it has nothing to pad, and it is cut **into** the surface it sits on the way a groove is, and a groove does not float.

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Composition

The groove is `--plass-track`, the same neutral ink a [`PlSlider`](../inputs/slider)'s rail and a [`PlSwitch`](../inputs/switch)'s off state are cut in, so a form with a slider, a switch and a progress bar in it is made of one material rather than three.

The segment over it is the family's gradient, which means the filled part of the run is exactly the material the button that submits the form is made of. It is also why the movement is on `width`: a gradient cannot be transitioned, and a length can.

Both the groove and the segment are fully rounded, and that is the one place the house rule about pills does not apply. The rule protects the flat run along a control's edge that a line of text sits on; at six pixels tall there is no flat run left to protect, and a square-ended bar reads as a rendering fault rather than as a cut edge.

## Examples

### value

`null`, the default, is the indeterminate case: something is happening and nobody knows how much of it is left. A bar with no value **sweeps** rather than sitting empty, because an empty bar is a claim that no progress has been made.

A value outside `min`…`max` is clamped rather than drawn: `value` usually arrives from a division somewhere, and a bar that renders 140% wide because one request finished twice is a worse bug than a bar that sits full.

<Demo src="progress-linear/indeterminate" :min-height="140">

::: fw react

<<< @/.vitepress/demos/progress-linear/indeterminate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/indeterminate.dart

:::

</Demo>

### size

Thickness only. A bar is not a control you can put a label inside, and at `md` it wants to be the weight of a rule between two paragraphs rather than a quarter of a button, so these are `PlSlider`'s rail thicknesses, deliberately: a rail and a bar are the same channel, one of which you drag and one of which you watch.

<Demo src="progress-linear/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/progress-linear/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/sizes.dart

:::

</Demo>

### color

<Demo src="progress-linear/colors" :min-height="280">

::: fw react

<<< @/.vitepress/demos/progress-linear/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/colors.dart

:::

</Demo>

### showValue and format

Without `format` the value is written as a percentage of `min`…`max`, which is the only formatting that holds for a range nobody described. "3%" for step 3 of 4 is worse than saying nothing.

With it, the number goes straight to `Intl.NumberFormat`, so bytes, currencies and units all work and the value keeps whatever meaning the caller gave it.

<Demo src="progress-linear/format" :min-height="160">

::: fw react

<<< @/.vitepress/demos/progress-linear/format.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/format.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI renders a `role="progressbar"` and keeps `aria-valuenow`, `aria-valuemin` and `aria-valuemax` in step with the props.
- An indeterminate bar reports **no value at all** rather than zero, which is what tells a screen reader to announce indeterminate progress.
- `aria-valuetext` is the same string `showValue` draws, so what is heard and what is read are one sentence. Without `format` that is a percentage of the range, not of 100.
- `label` names what is loading. A bar with no label is a bar a screen reader can only describe as a number.
- Under `prefers-reduced-motion` the segment stops travelling, fills the groove and breathes instead. It is not stopped: an indeterminate indicator that holds still says the opposite of what it is for.

:::

::: fw flutter

- The bar is one merged semantics node carrying `SemanticsRole.progressBar` and its value, so the label and the bar are read together rather than as a name floating beside an unnamed indicator.
- With no value the role is `SemanticsRole.loadingSpinner` and there is no value at all, which is what tells the platform to announce indeterminate progress rather than zero.
- The drawn percentage is behind `ExcludeSemantics`: the same string is already the node's value, and it should be heard once.
- With `MediaQuery.disableAnimations` the segment stops travelling, fills the groove and breathes instead, the same stand-in, on the same axis.

:::

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `format: Intl.NumberFormatOptions` | `formatValue: String Function(double)` | There is no `Intl.NumberFormat` in the framework, and pulling `package:intl` in to provide one would be a dependency decision made on the consumer's behalf. |
| `label: ReactNode`, and `min`/`max`/`value` are `number` | `Widget?` and `double` | Dart's own names for the same things. |
| the segment travels on `inset-inline-start` | it travels on a directional `Alignment` | Neither is a transform, and both run the other way under RTL without being told. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |
