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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const ClipRect(
  child: PlAnimateSlide(
    from: PlassSide.right,
    child: PlCard(title: Text('New message'), child: Text('Ada replied to your review.')),
  ),
);
```

```

:::

## Props

<PropsTable name="PlAnimateSlide" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

::: fw flutter

`distance` is a `double?` in logical pixels, and **`null` — the default — is the widget's own width or height**. There is no CSS length to write: a fraction of a widget's own size is what `FractionalTranslation` already means, and that is what the widget uses when no distance is given.

:::

`from` is **physical** — `top`, `right`, `bottom`, `left` — as `PlassSide` is everywhere in the library. A panel coming down from the top comes from the top in every writing direction.

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page. `timeline="view"` and `range` are there too, and hand the effect to the reader's scroll position instead of the clock.

::: fw react

Three more move the effect off the box and onto the things inside it: `stagger` holds each child back by its position, `durationStep` gives each one a longer or shorter run than the last, and `reverse` starts from the end of the set. They are on all six single-keyframe effects and are shown on the [PlAnimateFade](./animate-fade) page.

:::

## Examples

### from

Four edges, and `mode="out"` leaves by whichever one it would have arrived from.

<Demo src="animate-slide/sides" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-slide/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_slide/sides.dart

:::

</Demo>

### distance

A number is pixels, a string is any CSS length. `'100%'` is the element's own width or height — put it in a box with `overflow: hidden` and the effect is a panel appearing from behind that box's edge. Short distances are a different gesture: a nudge that says something changed, rather than an entrance.

<Demo src="animate-slide/distance" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-slide/distance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_slide/distance.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there.
- Nothing on the page reflows while it runs. This is a `translate` rather than a change of layout, so what is _around_ the element does not move.
- A slide that starts out of frame will overflow whatever is holding it unless that box clips. Clip it, or the page grows a scrollbar for the length of the animation.
- For a much shorter travel across a list of things, one after another, use [PlAnimateAppear](./animate-appear) — the stagger is what makes that effect, and a slide per child would leave you writing the delays yourself.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the effect is dropped entirely and the content is simply there.
- Nothing around it is laid out again while it runs. This moves the widget rather than changing the layout.
- A slide that starts out of frame will overflow whatever is holding it unless that box clips. Wrap it in a `ClipRect`.
- For a much shorter travel across a list of things, one after another, use [PlAnimateAppear](./animate-appear).

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `distance` as a CSS length or a number | `double?`, `null` is its own size | A fraction of a widget's own size is what `FractionalTranslation` already means, so there is nothing to spell as a string. |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in` is a reserved word in Dart. |
| `overflow: hidden` on a wrapper | `ClipRect` | The framework's own name for the same clip. |
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
