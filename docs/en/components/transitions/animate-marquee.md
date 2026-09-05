---
title: PlAnimateMarquee
order: 7
---

# PlAnimateMarquee

<p class="plass-lede">Content scrolling steadily past, forever. The content is laid down twice, so the moment the first copy has left, the second is standing precisely where it began, no seam, no jump, no empty frame.</p>

<Demo src="animate-marquee/hero" :min-height="120" />

::: fw react

```tsx
import { PlAnimateMarquee } from 'plass-ui';

<PlAnimateMarquee gap="1.5rem" speed={45}>
  {names.map((name) => (
    <PlChip key={name}>{name}</PlChip>
  ))}
</PlAnimateMarquee>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnimateMarquee(
  gap: 24,
  speed: 45,
  children: <Widget>[for (final String name in names) PlChip(child: Text(name))],
);
```

```

:::

## Props

<PropsTable name="PlAnimateMarquee" />

::: fw react

Every native `<div>` attribute passes straight through. There is no `render` here: the component owns its own structure — a clipping box with the copies inside it — so there is nothing meaningful to swap the outer element for.

:::

::: fw flutter

`gap` is a `double` in logical pixels, and so is `speed` — logical pixels per second. `duration` is a `Duration?`: leave it out and the strip is **measured**, which is what `speed` is for.

:::

There is no `mode`, no `from` and no `fade`. A marquee is a loop, not an arrival.

The rest of the shared settings — `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — mean what they mean everywhere else. `duration` is the exception: leave it out and the strip is **measured**, which is what `speed` is for.

## Examples

### speed

A speed rather than a duration, so a strip of four logos and a strip of forty move at the same pace instead of the long one becoming a blur. It is pixels per second, and the strip is re-measured whenever it changes size. Setting `duration` overrides the measurement entirely.

<Demo src="animate-marquee/speed" :min-height="180">

::: fw react

<<< @/.vitepress/demos/animate-marquee/speed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_marquee/speed.dart

:::

</Demo>

### orientation and reverse

Vertical needs a height on the box — there is nothing else to clip against. `reverse` runs it bottom to top, or left to right.

<Demo src="animate-marquee/orientation" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-marquee/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_marquee/orientation.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the strip stops dead and the content sits where it is. Everything on it is still in the document and still reachable — it is a row of things, not a slideshow.
- **Only the first copy is read out.** The rest carry `aria-hidden`, or a screen reader would announce everything on the strip as many times as it was laid down.
- `pauseOnHover` is on by default and it is not decoration: content moving past a pointer cannot be clicked reliably, and a link inside a marquee that never stops is a link nobody can follow. It does **not** pause on focus, so keyboard-reachable content on a strip is a reason to reach for a static list instead.
- Nothing that has to be read belongs here. A reader gets one pass at whatever speed you chose, and there is no way back.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the strip stands where it started. Everything on it is still in the tree and still reachable — it is a row of things, not a slideshow.
- **Only the first copy is read out.** The rest are behind `ExcludeSemantics`, or a screen reader would announce everything on the strip as many times as it was laid down.
- `pauseOnHover` is on by default and it is not decoration: content moving past a pointer cannot be pressed reliably. It does **not** pause on focus, so focusable content on a strip is a reason to reach for a static list instead.
- Nothing that has to be read belongs here. A reader gets one pass at whatever speed you chose, and there is no way back.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `aria-hidden` on the copies after the first | `ExcludeSemantics` | The framework's own name for the same exclusion. |
| `overflow: hidden` on the box | `UnconstrainedBox` with `clipBehavior: Clip.hardEdge` | The strip is longer than its box by design, so it has to be laid out against an unbounded main axis. A clip alone would clip the paint and leave the flex asserting that it overflowed. |
| a `translate` of `-100% - gap`, so nothing is measured | the strip is measured and moved by that many pixels | A percentage translate resolves against the element's own box in CSS; here the measurement decides both the distance and the duration, and it is taken again whenever the strip changes size. |
| `gap` as a CSS length | `double` | Logical pixels. |
| a reduced-motion `animation: none` | `t` held at `0` | The same outcome said two ways: a marquee's finished state is the content standing where it started, which is the opposite of what an entrance's is. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
