---
title: PlAnimateAppear
order: 1
---

# PlAnimateAppear

<p class="plass-lede">A list of things settling into place one after another. The effect belongs to the set rather than to any one item, so a reader's eye is walked down the list in the order it should be read.</p>

<Demo src="animate-appear/hero" :min-height="360" />

::: fw react

```tsx
import { PlAnimateAppear } from 'plass-ui';

<PlAnimateAppear className="flex flex-col gap-2">
  {services.map((service) => (
    <PlCard key={service.name} title={service.name} />
  ))}
</PlAnimateAppear>;
```

:::

## Props

<PropsTable name="PlAnimateAppear" />

::: fw react

The animation is written **onto the children themselves** rather than onto wrappers around them. A row of `<li>`s stays a row of `<li>`s, a grid's cells stay its direct children, and nothing about the layout changes because the list is being animated — so the class and style each child already had are kept alongside the ones this adds. Only a bare string has no element to write onto, and that one is wrapped in a `<span>`.

Every native `<div>` attribute passes straight through, and `render` swaps the container for another one.

:::

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. `delay` is what happens **before the first step**, so it is added once rather than to every child.

## Examples

### stagger

The whole effect. Everything else is what a single child does — a short drift and a fade — and the stagger is what turns that into a sequence.

It counts **children**, not leaves: eight children are eight steps, and one child holding eight things is one step. That is also how to opt part of a list out — group it.

<Demo src="animate-appear/stagger" :min-height="280">

::: fw react

<<< @/.vitepress/demos/animate-appear/stagger.tsx

:::

</Demo>

### from and reverse

`from` is the edge each child drifts in from, and `reverse` runs the list from the last child to the first. The distance is short on purpose: this is a settling, not an entrance from off screen, and a long travel over a list of eight turns the whole block into something moving. For one thing arriving from a long way off, use [PlAnimateSlide](./animate-slide).

<Demo src="animate-appear/direction" :min-height="300">

::: fw react

<<< @/.vitepress/demos/animate-appear/direction.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the whole list is simply there.
- Nothing is hidden from a screen reader at any point. The children are all in the document from the first frame — what is staggered is when each one is drawn, not when it exists.
- Keep the total short. Eight children at 70ms is half a second before the last one lands; at 300ms it is two and a half, and a reader is looking at an incomplete list for most of it.
- The stagger is decoration, not order. If the sequence matters, it has to be in the markup.

:::
