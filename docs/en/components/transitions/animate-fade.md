---
title: PlAnimateFade
order: 3
---

# PlAnimateFade

<p class="plass-lede">Content arriving or leaving on opacity alone. Nothing moves, so nothing reflows and nothing is resampled — the one entrance that is safe on a block of text at any size.</p>

<Demo src="animate-fade/hero" :min-height="260" />

::: fw react

```tsx
import { PlAnimateFade } from 'plass-ui';

<PlAnimateFade>
  <p>Two services restarted, no errors.</p>
</PlAnimateFade>;

<PlAnimateFade trigger="visible" duration={600}>
  <PlCard title="Usage">…</PlCard>
</PlAnimateFade>;
```

:::

## Props

<PropsTable name="PlAnimateFade" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one — a `<section>`, an `<li>`, whatever the surrounding markup needs.

:::

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component and mean the same thing on each. What the shared style axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### trigger

Four ways in, and they are the whole of what the shared settings are for. `mount` needs nothing from the caller. `visible` waits for the element to be scrolled into view — paused on its own first frame while it waits, so it is not fully drawn and then blinked out at the moment it arrives. `hover` starts on the pointer **and on focus**, or the effect would be unreachable without a mouse. `manual` never runs on its own, and each `false` → `true` on `play` starts it over.

<Demo src="animate-fade/triggers" :min-height="280">

::: fw react

<<< @/.vitepress/demos/animate-fade/triggers.tsx

:::

</Demo>

### mode

`out` is the same keyframe run backwards rather than a second animation, which is why it costs nothing — and why it is **held at the end**: a faded-out element stays faded out instead of snapping back into view when the run finishes.

<Demo src="animate-fade/mode" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-fade/mode.tsx

:::

</Demo>

### delay

A delay per element is what turns a set of things into a sequence. For a list where every child takes the same effect one after another, [PlAnimateAppear](./animate-appear) counts the steps for you.

<Demo src="animate-fade/timing" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-fade/timing.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there. That is the opposite of what the loading indicators do, and the difference is what each of them is saying: a spinner that stops is lying about whether anything is happening, while an entrance that never plays has still delivered everything it was carrying.
- The wrapper adds no role and no label. It is a `<div>` around content that already says what it is.
- Nothing here is a way to hide content. A `mode="out"` element is still in the document and still read out; if it should be gone, unmount it.
- `trigger="hover"` also starts on focus, so an effect on something keyboard-reachable runs for a reader who is not holding a mouse.

:::
