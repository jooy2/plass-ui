---
title: PlAnimateReveal
order: 8
---

# PlAnimateReveal

<p class="plass-lede">Content uncovered behind a moving edge. The only entrance in the set where nothing moves and no colour changes. Every pixel it has drawn is already where it will finally be.</p>

<Demo src="animate-reveal/hero" :min-height="220" />

::: fw react

```tsx
import { PlAnimateReveal } from 'plass-ui';

<PlAnimateReveal render={<h2 />}>Everything is where it was.</PlAnimateReveal>;

<PlAnimateReveal from="top" trigger="visible" duration={700}>
  <PlDivider />
</PlAnimateReveal>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateReveal(child: PlTypography('Everything is where it was.', level: PlTypographyLevel.h3));

const PlAnimateReveal(
  from: PlassSide.top,
  trigger: PlassAnimateTrigger.visible,
  duration: Duration(milliseconds: 700),
  child: PlDivider(),
);
```

:::

## Props

<PropsTable name="PlAnimateReveal" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one, which is worth using here more than anywhere else in the set, because a reveal is usually wrapped around a heading or a rule that is already the right element.

:::

::: fw flutter

The clip is applied while **painting**, so the widget is laid out once at its full size and nothing beside it is laid out again. That is the difference from an `Align` with a `widthFactor`, which would resize the box and push its neighbours around.

:::

`from` is **physical** (`top`, `right`, `bottom`, `left`) as `PlassSide` is everywhere in the library. A heading uncovered from the top is uncovered from the top in every writing direction.

The ten shared settings (`duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold`) are the same on every `PlAnimate*` component. The four `trigger` values are shown on the [PlAnimateFade](./animate-fade) page. `timeline="view"` and `range` are there too, and hand the effect to the reader's scroll position instead of the clock.

::: fw react

Three more move the effect off the box and onto the things inside it: `stagger` holds each child back by its position, `durationStep` gives each one a longer or shorter run than the last, and `reverse` starts from the end of the set. They are on all six single-keyframe effects and are shown on the [PlAnimateFade](./animate-fade) page.

:::

## Choosing an entrance

The set has five other ways of arriving, and each of them changes something about the element while it does it. This one changes **how much of the element is drawn** and nothing else.

- [PlAnimateFade](./animate-fade) changes the ink. Safe on any block of text, and the first one to use, but a faded heading is a heading somebody has to read twice.
- [PlAnimateSlide](./animate-slide) changes the position. What it says is "this has arrived from somewhere", which is a lie about a rule that has always belonged between those two sections.
- [PlAnimateGrow](./animate-grow) and [PlAnimateZoom](./animate-zoom) change the size, so the text inside is resampled at every frame.
- **PlAnimateReveal changes neither.** Use it where the position _is_ the information: a heading over the paragraph it belongs to, a divider between two sections, the plot area of a chart, a column of figures that must not be read from the wrong place.

It is also the cheapest of the five to lay out, because there is nothing to lay out. No wrapper, no `overflow` box, no second element in the flow. The clip paints less of the element and the page around it never learns that anything happened.

## Examples

### from

Four edges, and `mode="out"` closes from whichever one it opened towards.

<Demo src="animate-reveal/sides" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-reveal/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_reveal/sides.dart

:::

</Demo>

### fade

**Off by default**, which is the opposite of every other effect that offers it. Turning it on asks for two entrances at once, and the reason to have reached for this one is usually that the first was the problem.

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there, including the clip, so nothing is left half drawn.
- Nothing reflows while it runs, and nothing is resampled. That makes it as safe on a block of text as a fade, and safer than anything that scales.
- The clipped part of the element is still in the document and still read out. This is an entrance, not a way to hide something: if it should be gone, unmount it.
- A caller's own `clip-path` on the same element is overwritten while the effect runs. Put one of them on a wrapper.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the effect is dropped entirely and the content is simply there.
- Nothing is laid out again while it runs. The clip happens at paint time, so neither the widget nor anything beside it changes size.
- The clipped part of the widget is still in the tree and still in the semantics. This is an entrance, not a way to hide something.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `clip-path: inset()` | `ClipRect` with a clipper | The same rectangle, named the way each platform names it. |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in` is a reserved word in Dart. |
| `render` | — | Flutter has no polymorphic element. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `stagger`, `durationStep`, `reverse` | — | The React build writes the effect onto the children themselves, so the caller's own layout is untouched. Flutter has no stylesheet to lay a set out with, so a staggered effect would have to own the row or the column as well, which is what [`PlAnimateAppear`](./animate-appear) is, and six more of it would be six more of it. |
| `timeline="view"` | — | `animation-timeline` is a CSS property with no counterpart here. A scroll-linked effect in Flutter is an `AnimationController` driven from a `ScrollPosition`, which is an application's own wiring rather than something a widget takes as a prop. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
