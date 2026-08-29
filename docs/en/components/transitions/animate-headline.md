---
title: PlAnimateHeadline
order: 5
---

# PlAnimateHeadline

<p class="plass-lede">One line replacing the one above it, on a timer. Every line sits in the same grid cell, so the box is as tall as the longest of them from the first frame and never resizes as the reel turns.</p>

<Demo src="animate-headline/hero" :min-height="180" />

::: fw react

```tsx
import { PlAnimateHeadline } from 'plass-ui';

<PlAnimateHeadline interval={2200}>
  <span>ships on Friday</span>
  <span>reads like prose</span>
  <span>weighs almost nothing</span>
</PlAnimateHeadline>;
```

:::

## Props

<PropsTable name="PlAnimateHeadline" />

::: fw react

Every native `<div>` attribute passes straight through. There is no `render` and no `alternate`: the component owns its grid, and a reel has no other direction to run in.

:::

`interval` is counted **from the moment a line arrives** rather than from the start of the cycle, so raising `duration` does not quietly eat the reading time.

The rest of the shared settings — `duration`, `delay`, `easing`, `repeat`, `paused`, `trigger`, `play`, `once`, `threshold` — mean what they mean everywhere else. `delay` is what happens before the reel starts turning at all, so it is added once rather than to every line.

## Examples

### Controlled

Pass `index` and the reel stops running a timer of its own — a controlled headline is somebody else's clock, and a second one underneath it would fight for the same state. Drive it from a step in a form, a tab, or a timer you own.

<Demo src="animate-headline/controlled" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-headline/controlled.tsx

:::

</Demo>

### rise

How far a line travels as it comes up or leaves. `'100%'` is one line's own height, which is what makes it read as a reel; a few pixels is closer to a crossfade with a hint of direction.

<Demo src="animate-headline/rise" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-headline/rise.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the lines still change, but nothing slides: the outgoing line is dropped rather than animated away. The reel is the content, so switching it off entirely would leave only the first line.
- **Not for content a reader has to see.** There is no guarantee anyone is looking during the two seconds a line is up, and a screen reader is given whichever line happens to be showing rather than the set. Use it for phrases where any one of them would have done.
- Every line is in the document from the first frame; the ones not showing keep their space with `visibility` rather than being taken out of the layout. That is what keeps the box from resizing, and it also means nothing is announced twice.
- Consider `loop={false}` for anything with a natural end. A reel that never stops is motion in the corner of a page somebody is reading.

:::
