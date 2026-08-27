---
title: PlProgressBox
order: 11
---

# PlProgressBox

<p class="plass-lede">A row of small glass plates that light up. The third shape, and the one that is about the material rather than about the quantity.</p>

<Demo src="progress-box/hero" :flutter="false" :min-height="160" />

::: fw react

```tsx
import { PlProgressBox } from 'plass-ui';

<PlProgressBox label="Step 3 of 5" value={3} max={5} count={5} showValue />;
```

:::

## Props

<PropsTable name="PlProgressBox" />

Everything above `count` is [`PlProgressLinear`](./progress-linear)'s table, unchanged except for what `size` measures: one plate rather than the thickness of a groove.

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `children` because a row of plates holds nothing.

:::

## When to reach for it

A bar and a ring both answer _how much of it is done_. A row of plates answers _this is working_, in the library's own vocabulary — the same groove, the same corner, the same gradient — which makes it the right one for a loading state **inside** a Plass surface, where a foreign grey spinner would look borrowed.

It is also the one that reads as steps. Set `count` to the number of steps the thing being waited on actually has and the row becomes a progress _sequence_ rather than a measurement.

## Examples

### value and count

The plates fill in order, the leading one partially — so four plates at 30% are one full plate and a fifth of the next, rather than one quarter rounded off. That is why each plate is a groove of its own: without it, four plates could only ever show 0, 25, 50, 75 or 100.

<Demo src="progress-box/count" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/progress-box/count.tsx

</Demo>

### Indeterminate

`null` — the default — sets the row cycling, each plate held back by its own index. What cycles is the fill's **opacity** and never its paint: a Plass fill is a gradient, and `background-image` has no interpolation between a gradient and nothing, so a plate that swapped its background would snap rather than light.

The plates never move. A row of them reads as a surface being written to rather than as something bouncing in the corner of a page somebody is reading.

<Demo src="progress-box/indeterminate" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/progress-box/indeterminate.tsx

</Demo>

### size

The plate's own ladder, which is the tick ladder a [`PlCheckbox`](../inputs/checkbox)'s box and a [`PlRadio`](../inputs/radio-group)'s ring are on — a plate is an indicator beside a label, not a control you can put one inside.

<Demo src="progress-box/sizes" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/progress-box/sizes.tsx

</Demo>

### color

<Demo src="progress-box/colors" :flutter="false" :min-height="180">

<<< @/.vitepress/demos/progress-box/colors.tsx

</Demo>

## Accessibility

- Base UI renders a `role="progressbar"` and keeps `aria-valuenow`, `aria-valuemin` and `aria-valuemax` in step with the props. The plates themselves are `aria-hidden`: they are the drawing.
- An indeterminate row reports **no value at all** rather than zero, which is what tells a screen reader to announce indeterminate progress.
- `aria-valuetext` is the same string `showValue` draws. Without `format` that is a percentage of the range, not of 100 — which matters most here, where a row of five plates usually means `max={5}`.
- Under `prefers-reduced-motion` the wave is slowed to where it stops reading as motion rather than stopped: a row of plates holding still says the work has stalled.
