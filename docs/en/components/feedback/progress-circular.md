---
title: PlProgressCircular
order: 10
---

# PlProgressCircular

<p class="plass-lede">A ring that fills. The one to reach for where there is no room for a bar — inside a table row, beside a field, at the end of a line of text.</p>

<Demo src="progress-circular/hero" :flutter="false" :min-height="140" />

::: fw react

```tsx
import { PlProgressCircular } from 'plass-ui';

<PlProgressCircular label="Syncing" value={68} showValue />;
```

:::

## Props

<PropsTable name="PlProgressCircular" />

The table is [`PlProgressLinear`](./progress-linear)'s, and only `size` means something different: on a bar it is thickness, on a ring it is diameter. That is the claim the indicators make — one component in three shapes — and it is why they share a props table rather than three that would drift.

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `children` because a ring holds nothing.

:::

## The arc is a gradient

An SVG stroke cannot be given a CSS gradient, so the ring builds a `<linearGradient>` of its own out of the same two stops the bar's fill is made of, at the same 135°. It is worth the extra element: a flat ring beside a swept bar is two materials for one idea.

The track under it is `--plass-track`, the same neutral ink the bar's groove is — so a ring and a bar on one screen are cut into the same surface.

## The value sits beside the ring

Not inside it. A number in the middle of a dial is the picture everyone has of this component, and it works at two of the five sizes: at `xs` the ring is fourteen pixels across and there is nowhere for "40%" to go. Beside it, every size reads.

## Examples

### value

`null` — the default — is the indeterminate case. The ring then draws a fixed quarter-arc and turns, which is the one place the library moves something on its own, and the exception is the same one the button's spinner already has: an indeterminate indicator that holds still is a decoration.

With a value the ring holds still and the gap closes instead. Both are one dash pattern on one circle.

<Demo src="progress-circular/indeterminate" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/progress-circular/indeterminate.tsx

</Demo>

### size

Diameter, on a ladder that sits just under the control ladder at every step — a `md` ring is 20px inside a 40px control — so a ring dropped into a button, a field or a table row never makes the row taller than it already was.

<Demo src="progress-circular/sizes" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/progress-circular/sizes.tsx

</Demo>

### color

<Demo src="progress-circular/colors" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/progress-circular/colors.tsx

</Demo>

### In a row

The size ladder is what this is for: an `xs` ring in a table cell is fourteen pixels, and the row is the height it was already going to be.

<Demo src="progress-circular/inline" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/progress-circular/inline.tsx

</Demo>

## Accessibility

- Base UI renders a `role="progressbar"` and keeps `aria-valuenow`, `aria-valuemin` and `aria-valuemax` in step with the props.
- An indeterminate ring reports **no value at all** rather than zero, which is what tells a screen reader to announce indeterminate progress.
- The `<svg>` is `aria-hidden`: it is the drawing, and everything it says is already in the role and the value.
- `aria-valuetext` is the same string `showValue` draws. Without `format` that is a percentage of the range, not of 100.
- Under `prefers-reduced-motion` the ring is slowed to where it stops reading as motion rather than stopped, for the reason it turns at all.
