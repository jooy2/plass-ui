---
title: PlAnimateMarquee
order: 7
---

# PlAnimateMarquee

<p class="plass-lede">Content scrolling steadily past, forever. The content is laid down twice, so the moment the first copy has left, the second is standing precisely where it began — no seam, no jump, no empty frame.</p>

<Demo src="animate-marquee/hero" :min-height="120" />

::: fw react

```tsx
import { PlAnimateMarquee } from 'plass-ui';

<PlAnimateMarquee gap="1.5rem" speed={45}>
  {names.map((name) => (
    <PlChip key={name}>{name}</PlChip>
  ))}
</PlAnimateMarquee>;
```

:::

## Props

<PropsTable name="PlAnimateMarquee" />

::: fw react

Every native `<div>` attribute passes straight through. There is no `render` here: the component owns its own structure — a clipping box with the copies inside it — so there is nothing meaningful to swap the outer element for.

:::

There is no `mode`, no `from` and no `fade`. A marquee is a loop, not an arrival.

The rest of the shared settings — `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — mean what they mean everywhere else. `duration` is the exception: leave it out and the strip is **measured**, which is what `speed` is for.

## Examples

### speed

A speed rather than a duration, so a strip of four logos and a strip of forty move at the same pace instead of the long one becoming a blur. It is pixels per second, and the strip is re-measured whenever it changes size. Setting `duration` overrides the measurement entirely.

<Demo src="animate-marquee/speed" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-marquee/speed.tsx

:::

</Demo>

### orientation and reverse

Vertical needs a height on the box — there is nothing else to clip against. `reverse` runs it bottom to top, or left to right.

<Demo src="animate-marquee/orientation" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-marquee/orientation.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the strip stops dead and the content sits where it is. Everything on it is still in the document and still reachable — it is a row of things, not a slideshow.
- **Only the first copy is read out.** The rest carry `aria-hidden`, or a screen reader would announce everything on the strip as many times as it was laid down.
- `pauseOnHover` is on by default and it is not decoration: content moving past a pointer cannot be clicked reliably, and a link inside a marquee that never stops is a link nobody can follow. It does **not** pause on focus, so keyboard-reachable content on a strip is a reason to reach for a static list instead.
- Nothing that has to be read belongs here. A reader gets one pass at whatever speed you chose, and there is no way back.

:::
