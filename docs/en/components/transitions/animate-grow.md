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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateGrow(
  origin: Alignment.topCenter,
  child: PlBox(child: Text('Sort, group and column visibility.')),
);
```

```

:::

## Props

<PropsTable name="PlAnimateGrow" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

::: fw flutter

`origin` is an `Alignment` rather than a CSS `transform-origin` string, because the framework already has the type. `duration` and `delay` are `Duration`s, `curve` is a `Curve`, and `repeat` is an `int?` where `null` never stops.

:::

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page.

## Examples

### origin

The anchor is the whole difference between this and `PlAnimateZoom`. A panel that unfolds from `top` is a panel coming out of the control above it; one that unfolds from `bottom right` is coming out of the corner it is pinned to. Anything anchored to the middle is a zoom, and there is only one component for that idea.

<Demo src="animate-grow/origin" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-grow/origin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/origin.dart

:::

</Demo>

### from

Above `1` it arrives oversized and settles back. Short travel is what keeps it safe on glass: a sheet growing from `0.8` stays recognisably the same sheet the whole way, and the blur behind it is never asked to resolve a surface a fifth of the size it is about to be.

<Demo src="animate-grow/from" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-grow/from.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/from.dart

:::

</Demo>

### Opening a panel

The common use, and the one the defaults were chosen for: `origin="top"`, a short distance, a quick duration. The panel unfolds from the control that opened it rather than appearing beside it.

<Demo src="animate-grow/panel" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-grow/panel.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/panel.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there.
- The wrapper adds no role and no label. It is a `<div>` around content that already says what it is.
- Scaling resamples whatever is inside, so keep the travel short over text — that is what `from` defaults to `0.8` for. Long travel belongs on a shape, an icon or a picture.
- This is a wrapper, not a disclosure. Mounting and unmounting the content is the caller's job, and so is whatever `aria-expanded` belongs on the control that did it.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the effect is dropped entirely and the content is simply there.
- The widget adds no semantics of its own. It is a `Transform` around content that already says what it is.
- Scaling resamples whatever is inside, so keep the travel short over text — that is what `from` defaults to `0.8` for. Long travel belongs on a shape, an icon or a picture.
- This is a wrapper, not a disclosure. Adding and removing the content is the caller's job, and so is whatever a screen reader should be told about it.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `origin` as a CSS `transform-origin` string | `Alignment` | The framework already has the type, and `Alignment.topCenter` reads better than `'top'`. |
| `fade` draws an always-present opacity layer | no `Opacity` widget at all when `fade` is off | One fewer layer to composite, and nothing in the tree claiming to be doing something it is not. |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in` is a reserved word in Dart. |
| `render` | — | Flutter has no polymorphic element. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
