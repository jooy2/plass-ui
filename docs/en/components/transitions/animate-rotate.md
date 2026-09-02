---
title: PlAnimateRotate
order: 9
---

# PlAnimateRotate

<p class="plass-lede">Content turning about a point. Two angles rather than one, which is what lets a single component cover both a quarter turn into place and a spin that never lands.</p>

<Demo src="animate-rotate/hero" :min-height="180" />

::: fw react

```tsx
import { PlAnimateRotate } from 'plass-ui';

<PlAnimateRotate from={0} to={360} duration={2400} easing="linear" repeat="infinite" fade={false}>
  <PlIcon icon={<RefreshGlyph />} label="Syncing" />
</PlAnimateRotate>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateRotate(
  from: 0,
  to: 360,
  duration: Duration(milliseconds: 2400),
  curve: Curves.linear,
  repeat: null,
  fade: false,
  child: PlIcon(icon: RefreshGlyph()),
);
```

```

:::

## Props

<PropsTable name="PlAnimateRotate" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

::: fw flutter

`from` and `to` are **degrees**, not radians. The framework counts in radians and the design language counts in degrees — every gradient in the package is at 135° — so the conversion happens inside the widget, once, rather than at every call site. `origin` is an `Alignment`.

:::

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page. `timeline="view"` and `range` are there too, and hand the effect to the reader's scroll position instead of the clock.

::: fw react

Three more move the effect off the box and onto the things inside it: `stagger` holds each child back by its position, `durationStep` gives each one a longer or shorter run than the last, and `reverse` starts from the end of the set. They are on all six single-keyframe effects and are shown on the [PlAnimateFade](./animate-fade) page.

:::

## Examples

### from and to

`from` alone is an arrival: something swings into place and stops. `from` and `to` together with `repeat="infinite"` and `easing="linear"` is a spin that never lands, which is what a badge, a loading mark or a decorative glyph wants. Turn `fade` off for the second one — a fade that repeats reads as flickering.

<Demo src="animate-rotate/spin" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-rotate/spin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_rotate/spin.dart

:::

</Demo>

### origin

Any CSS `transform-origin`. Turning about a corner is a hinge rather than a wheel, and it is what a flag, a tag or a card being dealt onto a pile wants.

<Demo src="animate-rotate/origin" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-rotate/origin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_rotate/origin.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there. That is right for an arrival and worth thinking about for a spin: if the turning is what says _something is happening_, use [PlProgressCircular](../feedback/progress-circular) instead, which slows rather than stopping.
- **Not for text.** A rotated word is resampled along its whole length. Rotation is the one movement the design language allows on a glyph without argument — a chevron is turned rather than redrawn all over the library — and that is the shape of thing it is for.
- Something that turns forever in the corner of a page somebody is reading is the one kind of motion the rest of this library refuses. Give it a reason.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the effect is dropped entirely and the content is simply there. That is right for an arrival and worth thinking about for a spin: if the turning is what says *something is happening*, use [PlProgressCircular](../feedback/progress-circular) instead, which slows rather than stopping.
- **Not for text.** A rotated word is resampled along its whole length.
- Something that turns forever in the corner of a screen somebody is reading is the one kind of motion the rest of this package refuses. Give it a reason.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `from`, `to` in degrees | `double` degrees, converted inside | The framework counts in radians; the design language counts in degrees, and the conversion belongs in one place. |
| `origin` as a CSS `transform-origin` string | `Alignment` | The framework already has the type. |
| `easing="linear"` | `curve: Curves.linear` | Dart's own name for the same curve. |
| `render` | — | Flutter has no polymorphic element. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `stagger`, `durationStep`, `reverse` | — | The React build writes the effect onto the children themselves, so the caller's own layout is untouched. Flutter has no stylesheet to lay a set out with, so a staggered effect would have to own the row or the column as well — which is what [`PlAnimateAppear`](./animate-appear) is, and six more of it would be six more of it. |
| `timeline="view"` | — | `animation-timeline` is a CSS property with no counterpart here. A scroll-linked effect in Flutter is an `AnimationController` driven from a `ScrollPosition`, which is an application's own wiring rather than something a widget takes as a prop. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
