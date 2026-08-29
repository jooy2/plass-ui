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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnimateAppear(
  spacing: 8,
  children: <Widget>[
    for (final Service service in services) PlCard(title: Text(service.name)),
  ],
);
```

```

:::

## Props

<PropsTable name="PlAnimateAppear" />

::: fw react

The animation is written **onto the children themselves** rather than onto wrappers around them. A row of `<li>`s stays a row of `<li>`s, a grid's cells stay its direct children, and nothing about the layout changes because the list is being animated — so the class and style each child already had are kept alongside the ones this adds. Only a bare string has no element to write onto, and that one is wrapped in a `<span>`.

Every native `<div>` attribute passes straight through, and `render` swaps the container for another one.

:::

::: fw flutter

It **lays its children out**, which the React build does not have to: there is no stylesheet here to put a `display: flex` on the container, so `orientation` and `spacing` are what a `className` would have done. Anything more elaborate than a row or a column belongs *inside* one child — which also makes that whole arrangement one step of the stagger. `distance` is a `double` in logical pixels.

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

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_appear/stagger.dart

:::

</Demo>

### from and reverse

`from` is the edge each child drifts in from, and `reverse` runs the list from the last child to the first. The distance is short on purpose: this is a settling, not an entrance from off screen, and a long travel over a list of eight turns the whole block into something moving. For one thing arriving from a long way off, use [PlAnimateSlide](./animate-slide).

<Demo src="animate-appear/direction" :min-height="300">

::: fw react

<<< @/.vitepress/demos/animate-appear/direction.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_appear/direction.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the whole list is simply there.
- Nothing is hidden from a screen reader at any point. The children are all in the document from the first frame — what is staggered is when each one is drawn, not when it exists.
- Keep the total short. Eight children at 70ms is half a second before the last one lands; at 300ms it is two and a half, and a reader is looking at an incomplete list for most of it.
- The stagger is decoration, not order. If the sequence matters, it has to be in the markup.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the effect is dropped entirely and the whole list is simply there.
- Nothing is hidden from a screen reader at any point. Every child is in the tree from the first frame — what is staggered is when each one is drawn, not when it exists.
- Keep the total short. Eight children at 70ms is half a second before the last one lands; at 300ms it is two and a half.
- The stagger is decoration, not order. If the sequence matters, it has to be in the tree.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| the animation is written onto the children's own `className` and `style` | each child is wrapped | There is no class list to add to. Wrapping is transparent to a `Flex`, but a child that has to be the direct child of something — an `Expanded` — belongs outside this widget. |
| the container is a bare `<div>` the caller styles | `orientation` and `spacing` | No stylesheet, so the widget has to lay its children out. |
| `distance` as a CSS length | `double` | Logical pixels. |
| `render` | — | Flutter has no polymorphic element. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
