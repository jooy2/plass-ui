---
title: PlAnimateZoom
order: 11
---

# PlAnimateZoom

<p class="plass-lede">Content arriving from the middle of where it will end up. Use it for the one thing on a screen that is meant to interrupt — a confirmation, a result, a number that has just landed.</p>

<Demo src="animate-zoom/hero" :min-height="280" />

::: fw react

```tsx
import { PlAnimateZoom } from 'plass-ui';

<PlAnimateZoom>
  <PlBox color="success">92</PlBox>
</PlAnimateZoom>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateZoom(
  child: PlBox(color: PlassColor.success, child: Text('92')),
);
```

```

:::

## Props

<PropsTable name="PlAnimateZoom" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

::: fw flutter

`duration` and `delay` are `Duration`s, `curve` is a `Curve`, and `repeat` is an `int?` where `null` never stops.

:::

There is deliberately **no `origin`**. A zoom anchored to a corner is a grow, and the library does not offer two spellings of one idea — reach for [PlAnimateGrow](./animate-grow) when the effect should come out of something next to it.

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page.

## Examples

### from

More than twice a grow's distance by default, and that is the whole difference in feel. Below `1` the content comes forward out of the page; above it, it arrives oversized and settles back, which reads as coming _towards_ the reader.

<Demo src="animate-zoom/from" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-zoom/from.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_zoom/from.dart

:::

</Demo>

### Announcing a result

What the effect is for. One thing on the screen, once, at the moment it becomes true.

<Demo src="animate-zoom/result" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-zoom/result.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_zoom/result.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there.
- The wrapper adds no role and no label. A result that has to be announced needs a live region of its own — the effect is what a reader sees, not what a screen reader is told.
- The travel is long enough to resample text noticeably. Keep it for a figure, a glyph or a small card; a paragraph wants [PlAnimateFade](./animate-fade).
- Nothing repeats by default, and this is the effect to leave that way. Something that zooms twice is something that failed to arrive the first time.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the effect is dropped entirely and the content is simply there.
- The widget adds no semantics of its own. A result that has to be announced needs a `Semantics(liveRegion: true)` of its own — the effect is what a reader sees, not what a screen reader is told.
- The travel is long enough to resample text noticeably. Keep it for a figure, a glyph or a small card; a paragraph wants [PlAnimateFade](./animate-fade).
- Nothing repeats by default, and this is the effect to leave that way.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in` is a reserved word in Dart. |
| `fade` draws an always-present opacity layer | no `Opacity` widget at all when `fade` is off | One fewer layer to composite. |
| `render` | — | Flutter has no polymorphic element. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
