---
title: PlAnimateZoom
order: 11
---

# PlAnimateZoom

<p class="plass-lede">Content arriving from the middle of where it will end up. Use it for the one thing on a screen that is meant to interrupt — a confirmation, a result, a number that has just landed.</p>

<Demo src="animate-zoom/hero" :min-height="280" />

::: fw react

```tsx
import { PlAnimateZoom } from 'plass-ui';

<PlAnimateZoom>
  <PlBox color="success">92</PlBox>
</PlAnimateZoom>;
```

:::

## Props

<PropsTable name="PlAnimateZoom" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

There is deliberately **no `origin`**. A zoom anchored to a corner is a grow, and the library does not offer two spellings of one idea — reach for [PlAnimateGrow](./animate-grow) when the effect should come out of something next to it.

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page.

## Examples

### from

More than twice a grow's distance by default, and that is the whole difference in feel. Below `1` the content comes forward out of the page; above it, it arrives oversized and settles back, which reads as coming _towards_ the reader.

<Demo src="animate-zoom/from" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-zoom/from.tsx

:::

</Demo>

### Announcing a result

What the effect is for. One thing on the screen, once, at the moment it becomes true.

<Demo src="animate-zoom/result" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-zoom/result.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there.
- The wrapper adds no role and no label. A result that has to be announced needs a live region of its own — the effect is what a reader sees, not what a screen reader is told.
- The travel is long enough to resample text noticeably. Keep it for a figure, a glyph or a small card; a paragraph wants [PlAnimateFade](./animate-fade).
- Nothing repeats by default, and this is the effect to leave that way. Something that zooms twice is something that failed to arrive the first time.

:::
