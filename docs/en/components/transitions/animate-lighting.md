---
title: PlAnimateLighting
order: 6
---

# PlAnimateLighting

<p class="plass-lede">A light travelling around the outside of something. It draws attention with light rather than by moving anything, which is the only way this library has of saying "here" without also saying "and it moved".</p>

<Demo src="animate-lighting/hero" :min-height="260" />

::: fw react

```tsx
import { PlAnimateLighting } from 'plass-ui';

<PlAnimateLighting size="lg" color="primary">
  <PlCard size="lg" title="Recommended">
    …
  </PlCard>
</PlAnimateLighting>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateLighting(
  size: PlassSize.lg,
  child: PlCard(size: PlassSize.lg, title: Text('Recommended'), child: Text('…')),
);
```

```

:::

## Props

<PropsTable name="PlAnimateLighting" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here, and `render` swaps the element for another one.

:::

::: fw flutter

`glow` is a `Color?` rather than a CSS colour string. `spread` and `blur` are `double`s in logical pixels, and `arc` is degrees.

:::

**`size` has to agree with the radius of what is inside it.** The glow follows the wrapper's own corners, so an `lg` card in an `xs` Lighting shows light poking out of four corners the card has already rounded away.

The light sits **behind** the content rather than on it, in a stacking context of its own, so nothing inside is altered or overlaid and the content stays exactly as legible as it was.

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component, except that `repeat` defaults to `'infinite'` here.

## Examples

### color

The arc **turns between the two ends of the family** as it travels, which is the same rule every filled surface in the library follows: a flat coloured arc would be paint, and nothing here is paint. `glow` takes one CSS colour instead when a semantic family is not what is wanted, and then there is nothing for the arc to turn to.

<Demo src="animate-lighting/colors" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-lighting/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_lighting/colors.dart

:::

</Demo>

### arc, blur and spread

How much of the outline is lit at once, how soft the light is, and how far past the content it reaches. A small arc is a spark running round an edge; a large one is a sweep. At `blur={0}` it stops being light and becomes a graphic.

<Demo src="animate-lighting/shape" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-lighting/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_lighting/shape.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the arc stops travelling and becomes an even glow. The decoration survives; the motion does not.
- The light says nothing to a screen reader, and it should not have to. Whatever it is marking — the row that is processing, the plan being recommended — needs to be stated in the content as well.
- One per screen. A page with three things glowing has no one thing that is live.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the arc stops travelling and becomes an even glow. The decoration survives; the motion does not.
- The light says nothing to a screen reader, and it should not have to. Whatever it is marking needs to be stated in the content as well.
- One per screen. A screen with three things glowing has no one thing that is live.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `glow` as a CSS colour string | `Color?` | The framework already has the type. |
| a conic gradient on a `::before` | a `SweepGradient` on a `Positioned` layer behind the child | There are no pseudo-elements. The layer is first in a `Stack` with `clipBehavior: Clip.none`, so the glow reaches past the content and still sits under it. |
| `@property` on the angle so the `from` is animatable | `GradientRotation` on the sweep | What moves is the gradient's own rotation, not the layer's — rotating the layer would swing its corners out past the content on every quarter turn, which is the same reason the CSS animates the angle rather than the element. |
| `filter: blur()` | `ImageFiltered` | The framework's own name for the same filter. |
| `render` | — | Flutter has no polymorphic element. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
