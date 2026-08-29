---
title: PlAnimateSlide
order: 9
---

# PlAnimateSlide

<p class="plass-lede">Content travelling in from one edge. The default distance is the element's own size, so it starts exactly out of frame and is never half drawn somewhere it does not belong.</p>

<Demo src="animate-slide/hero" :min-height="280" />

::: fw react

```tsx
import { PlAnimateSlide } from 'plass-ui';

<div className="overflow-hidden">
  <PlAnimateSlide from="right">
    <PlCard title="New message">Ada replied to your review.</PlCard>
  </PlAnimateSlide>
</div>;
```

:::

## Props

<PropsTable name="PlAnimateSlide" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

`from` is **physical** — `top`, `right`, `bottom`, `left` — as `PlassSide` is everywhere in the library. A panel coming down from the top comes from the top in every writing direction.

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page.

## Examples

### from

Four edges, and `mode="out"` leaves by whichever one it would have arrived from.

<Demo src="animate-slide/sides" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-slide/sides.tsx

:::

</Demo>

### distance

A number is pixels, a string is any CSS length. `'100%'` is the element's own width or height — put it in a box with `overflow: hidden` and the effect is a panel appearing from behind that box's edge. Short distances are a different gesture: a nudge that says something changed, rather than an entrance.

<Demo src="animate-slide/distance" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-slide/distance.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there.
- Nothing on the page reflows while it runs. This is a `translate` rather than a change of layout, so what is _around_ the element does not move.
- A slide that starts out of frame will overflow whatever is holding it unless that box clips. Clip it, or the page grows a scrollbar for the length of the animation.
- For a much shorter travel across a list of things, one after another, use [PlAnimateAppear](./animate-appear) — the stagger is what makes that effect, and a slide per child would leave you writing the delays yourself.

:::
