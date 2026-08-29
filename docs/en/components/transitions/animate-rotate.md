---
title: PlAnimateRotate
order: 8
---

# PlAnimateRotate

<p class="plass-lede">Content turning about a point. Two angles rather than one, which is what lets a single component cover both a quarter turn into place and a spin that never lands.</p>

<Demo src="animate-rotate/hero" :min-height="180" />

::: fw react

```tsx
import { PlAnimateRotate } from 'plass-ui';

<PlAnimateRotate from={0} to={360} duration={2400} easing="linear" repeat="infinite" fade={false}>
  <PlIcon icon={<RefreshGlyph />} label="Syncing" />
</PlAnimateRotate>;
```

:::

## Props

<PropsTable name="PlAnimateRotate" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page.

## Examples

### from and to

`from` alone is an arrival: something swings into place and stops. `from` and `to` together with `repeat="infinite"` and `easing="linear"` is a spin that never lands, which is what a badge, a loading mark or a decorative glyph wants. Turn `fade` off for the second one — a fade that repeats reads as flickering.

<Demo src="animate-rotate/spin" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-rotate/spin.tsx

:::

</Demo>

### origin

Any CSS `transform-origin`. Turning about a corner is a hinge rather than a wheel, and it is what a flag, a tag or a card being dealt onto a pile wants.

<Demo src="animate-rotate/origin" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-rotate/origin.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there. That is right for an arrival and worth thinking about for a spin: if the turning is what says _something is happening_, use [PlProgressCircular](../feedback/progress-circular) instead, which slows rather than stopping.
- **Not for text.** A rotated word is resampled along its whole length. Rotation is the one movement the design language allows on a glyph without argument — a chevron is turned rather than redrawn all over the library — and that is the shape of thing it is for.
- Something that turns forever in the corner of a page somebody is reading is the one kind of motion the rest of this library refuses. Give it a reason.

:::
