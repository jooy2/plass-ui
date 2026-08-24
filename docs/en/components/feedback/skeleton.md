---
title: PlSkeleton
order: 4
---

# PlSkeleton

<p class="plass-lede">The shape of something that has not loaded yet. It reserves the space the real thing will take, which is the whole job — a spinner cannot do that.</p>

<Demo src="skeleton/hero" :min-height="300" />

```tsx
import { PlSkeleton } from 'plass-ui';

<PlSkeleton lines={3} label="Loading the article" />;
<PlSkeleton shape="circle" />;
<PlSkeleton shape="rect" height={120} />;
```

## Props

<PropsTable name="PlSkeleton" />

Every native `<div>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

There is no `variant`, no `elevation` and no `density`. A skeleton is deliberately **not** made of glass: every other sheet in the library is translucent over a blurred backdrop because it is a thing sitting on the page, and a skeleton is the opposite — the shape of something that is not there yet. So it is a flat tint and nothing else, which also keeps a page of thirty placeholders from asking for thirty backdrop filters.

What the shared axes (`size` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### shape

The three shapes are the three things a layout is made of — a run of text, a block and a circle — and each is sized off the ladder the real component uses. A `md` line is as tall as `md` type, and a `md` circle is exactly a `PlAvatar` at `md`.

`lines` draws a stack of bars rather than one striped box, so the gaps between them are real gaps: text has leading. The last one is drawn short, the way the last line of a paragraph is.

<Demo src="skeleton/shapes" :min-height="320">

<<< @/.vitepress/demos/skeleton/shapes.tsx

</Demo>

### Standing in for the real thing

The point is that nothing moves when the content arrives. A card that grows by 200px when its image loads has shifted everything below it while somebody was reading.

<Demo src="skeleton/matching" :min-height="200">

<<< @/.vitepress/demos/skeleton/matching.tsx

</Demo>

### animated

The travelling highlight is on by default. Turn it off for a page holding dozens of placeholders, or where the wait is expected to be long enough that motion becomes noise.

This is not the accessibility switch: a reduced-motion preference already replaces the sweep with a colour pulse without being asked.

<Demo src="skeleton/animated" :min-height="220">

<<< @/.vitepress/demos/skeleton/animated.tsx

</Demo>

### size

<Demo src="skeleton/sizes" :min-height="300">

<<< @/.vitepress/demos/skeleton/sizes.tsx

</Demo>

## Accessibility

- Unlabelled, a placeholder is `aria-hidden` and says nothing. A dozen boxes each announcing themselves is worse than silence.
- Give the **one** skeleton that stands for the whole region a `label`, and it becomes a `role="status"` with `aria-busy` — one announcement for one wait.
- Under `prefers-reduced-motion` the highlight stops travelling and the placeholder pulses in colour instead. It is not stopped outright, because a skeleton that holds still is indistinguishable from an empty box that finished loading with nothing in it.
