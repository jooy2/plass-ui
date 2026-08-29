---
title: PlAnimateGrow
order: 4
---

# PlAnimateGrow

<p class="plass-lede">Content unfolding from a point. It starts close to its final size and can be anchored to any edge, so it reads as something opening out of the thing beside it.</p>

<Demo src="animate-grow/hero" :min-height="260" />

::: fw react

```tsx
import { PlAnimateGrow } from 'plass-ui';

<PlAnimateGrow origin="top">
  <PlBox>Sort, group and column visibility.</PlBox>
</PlAnimateGrow>;
```

:::

## Props

<PropsTable name="PlAnimateGrow" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page.

## Examples

### origin

The anchor is the whole difference between this and `PlAnimateZoom`. A panel that unfolds from `top` is a panel coming out of the control above it; one that unfolds from `bottom right` is coming out of the corner it is pinned to. Anything anchored to the middle is a zoom, and there is only one component for that idea.

<Demo src="animate-grow/origin" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-grow/origin.tsx

:::

</Demo>

### from

Above `1` it arrives oversized and settles back. Short travel is what keeps it safe on glass: a sheet growing from `0.8` stays recognisably the same sheet the whole way, and the blur behind it is never asked to resolve a surface a fifth of the size it is about to be.

<Demo src="animate-grow/from" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-grow/from.tsx

:::

</Demo>

### Opening a panel

The common use, and the one the defaults were chosen for: `origin="top"`, a short distance, a quick duration. The panel unfolds from the control that opened it rather than appearing beside it.

<Demo src="animate-grow/panel" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-grow/panel.tsx

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there.
- The wrapper adds no role and no label. It is a `<div>` around content that already says what it is.
- Scaling resamples whatever is inside, so keep the travel short over text — that is what `from` defaults to `0.8` for. Long travel belongs on a shape, an icon or a picture.
- This is a wrapper, not a disclosure. Mounting and unmounting the content is the caller's job, and so is whatever `aria-expanded` belongs on the control that did it.

:::
