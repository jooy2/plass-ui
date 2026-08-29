---
title: PlAnimateBlink
order: 2
---

# PlAnimateBlink

<p class="plass-lede">Content pulsing between full opacity and a floor. The cycle is symmetric — full, faint, full — so however many times it runs, it ends where it started.</p>

<Demo src="animate-blink/hero" :min-height="160" />

::: fw react

```tsx
import { PlAnimateBlink } from 'plass-ui';

<PlAnimateBlink min={0.45}>
  <PlChip color="warning">Awaiting approval</PlChip>
</PlAnimateBlink>;
```

:::

## Props

<PropsTable name="PlAnimateBlink" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

There is no `mode` and no `fade`. A blink is a cycle rather than an arrival, so it has no direction to run in and nothing to fade separately from.

`repeat` defaults to `'infinite'` here and to `1` everywhere else, because a single blink is a flicker and nobody asks for a flicker. The rest of the shared settings — `duration`, `delay`, `easing`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — mean what they mean on every other `PlAnimate*` component.

## Examples

### min

How faint it gets at the bottom of the cycle. At `0` the content disappears; raise it for anything that has to stay readable while it pulses, which is most things — a word that is only there half the time is a word somebody will miss.

<Demo src="animate-blink/min" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-blink/min.tsx

:::

</Demo>

### repeat

A count is the way to draw attention to something once, rather than forever. The cycle is symmetric, so a run that ends leaves the content exactly as it found it.

<Demo src="animate-blink/count" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-blink/count.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content sits at full opacity. **So `min` must never be the only thing carrying the message** — if it is urgent, say so in words as well.
- Something that never stops moving in the corner of a page somebody is reading is the one kind of motion the rest of this library refuses. Prefer a count over `'infinite'`, and prefer a colour over either.
- Keep it well away from three flashes a second. This is a slow pulse by default and it should stay one.

:::
