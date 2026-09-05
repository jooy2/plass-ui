---
title: PlProgressCircular
order: 10
---

# PlProgressCircular

<p class="plass-lede">A ring that fills. The one to reach for where there is no room for a bar — inside a table row, beside a field, at the end of a line of text.</p>

<Demo src="progress-circular/hero" :min-height="140" />

::: fw react

```tsx
import { PlProgressCircular } from 'plass-ui';

<PlProgressCircular label="Syncing" value={68} showValue />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlProgressCircular(label: const Text('Syncing'), value: 68, showValue: true);
```

:::

## Props

<PropsTable name="PlProgressCircular" />

The table is [`PlProgressLinear`](./progress-linear)'s, and only `size` means something different: on a bar it is thickness, on a ring it is diameter. That is the claim the indicators make — one component in three shapes — and it is why they share a props table rather than three that would drift.

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `children` because a ring holds nothing.

:::

::: fw flutter

`formatValue` is a function where React takes an options object, for the reason [`PlProgressLinear`](./progress-linear) gives.

:::

## The arc

::: fw react

An SVG stroke cannot be given a CSS gradient, so the ring builds a `<linearGradient>` of its own out of the same two stops the bar's fill is made of, at the same 135°.

:::

::: fw flutter

A stroke takes a `Shader` rather than a decoration, so the sweep the rest of the package gets from `PlassCssGradient` is asked for directly — the one place in the library a shader is built by hand.

:::

Either way it is worth the extra work: a flat ring beside a swept bar is two materials for one idea.

The track under it is `--plass-track`, the same neutral ink the bar's groove is — so a ring and a bar on one screen are cut into the same surface.

## The value label

Not inside it. A number in the middle of a dial is the picture everyone has of this component, and it works at two of the five sizes: at `xs` the ring is fourteen pixels across and there is nowhere for "40%" to go. Beside it, every size reads.

## Examples

### value

`null` — the default — is the indeterminate case. The ring then draws a fixed quarter-arc and turns, which is the one place the library moves something on its own, and the exception is the same one the button's spinner already has: an indeterminate indicator that holds still is a decoration.

With a value the ring holds still and the gap closes instead. Both are one dash pattern on one circle.

<Demo src="progress-circular/indeterminate" :min-height="140">

::: fw react

<<< @/.vitepress/demos/progress-circular/indeterminate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/indeterminate.dart

:::

</Demo>

### size

Diameter, on a ladder that sits just under the control ladder at every step — a `md` ring is 20px inside a 40px control — so a ring dropped into a button, a field or a table row never makes the row taller than it already was.

<Demo src="progress-circular/sizes" :min-height="140">

::: fw react

<<< @/.vitepress/demos/progress-circular/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/sizes.dart

:::

</Demo>

### color

<Demo src="progress-circular/colors" :min-height="160">

::: fw react

<<< @/.vitepress/demos/progress-circular/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/colors.dart

:::

</Demo>

### In a row

The size ladder is what this is for: an `xs` ring in a table cell is fourteen pixels, and the row is the height it was already going to be.

<Demo src="progress-circular/inline" :min-height="220">

::: fw react

<<< @/.vitepress/demos/progress-circular/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/inline.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI renders a `role="progressbar"` and keeps `aria-valuenow`, `aria-valuemin` and `aria-valuemax` in step with the props.
- An indeterminate ring reports **no value at all** rather than zero, which is what tells a screen reader to announce indeterminate progress.
- The `<svg>` is `aria-hidden`: it is the drawing, and everything it says is already in the role and the value.
- `aria-valuetext` is the same string `showValue` draws. Without `format` that is a percentage of the range, not of 100.
- Under `prefers-reduced-motion` the ring is slowed to where it stops reading as motion rather than stopped, for the reason it turns at all.

:::

::: fw flutter

- The ring is one merged semantics node carrying `SemanticsRole.progressBar` and its value, so the label and the ring are read together.
- With no value the role is `SemanticsRole.loadingSpinner` and there is no value at all, which is what tells the platform to announce indeterminate progress.
- The drawn percentage is behind `ExcludeSemantics`: the same string is already the node's value.
- With `MediaQuery.disableAnimations` the ring is slowed rather than stopped.

:::

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `format: Intl.NumberFormatOptions` | `formatValue: String Function(double)` | There is no `Intl.NumberFormat` in the framework, and pulling `package:intl` in to provide one would be a dependency decision made on the consumer's behalf. |
| an `<svg>` with a `<linearGradient>` | a `CustomPainter` with a `ui.Gradient` shader | Same two stops, same 135°; a stroke takes a shader rather than a decoration. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |
