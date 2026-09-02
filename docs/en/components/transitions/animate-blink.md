---
title: PlAnimateBlink
order: 2
---

# PlAnimateBlink

<p class="plass-lede">Content pulsing between full opacity and a floor. The cycle is symmetric — full, faint, full — so however many times it runs, it ends where it started.</p>

<Demo src="animate-blink/hero" :min-height="160" />

::: fw react

```tsx
import { PlAnimateBlink } from 'plass-ui';

<PlAnimateBlink min={0.45}>
  <PlChip color="warning">Awaiting approval</PlChip>
</PlAnimateBlink>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateBlink(
  min: 0.45,
  child: PlChip(color: PlassColor.warning, child: Text('Awaiting approval')),
);
```

```

:::

## Props

<PropsTable name="PlAnimateBlink" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one.

:::

::: fw flutter

`repeat` is an `int?` and it is left at its default here, which is `null` — the value that never stops. There is no `mode` and no `fade`: a blink is a cycle rather than an arrival.

:::

There is no `mode` and no `fade`. A blink is a cycle rather than an arrival, so it has no direction to run in and nothing to fade separately from.

`repeat` defaults to `'infinite'` here and to `1` everywhere else, because a single blink is a flicker and nobody asks for a flicker. The rest of the shared settings — `duration`, `delay`, `easing`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — mean what they mean on every other `PlAnimate*` component.

::: fw react

Three more move the effect off the box and onto the things inside it: `stagger` holds each child back by its position, `durationStep` gives each one a longer or shorter run than the last, and `reverse` starts from the end of the set. They are on all six single-keyframe effects and are shown on the [PlAnimateFade](./animate-fade) page.

:::

## Examples

### min

How faint it gets at the bottom of the cycle. At `0` the content disappears; raise it for anything that has to stay readable while it pulses, which is most things — a word that is only there half the time is a word somebody will miss.

<Demo src="animate-blink/min" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-blink/min.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_blink/min.dart

:::

</Demo>

### repeat

A count is the way to draw attention to something once, rather than forever. The cycle is symmetric, so a run that ends leaves the content exactly as it found it.

<Demo src="animate-blink/count" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-blink/count.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_blink/count.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content sits at full opacity. **So `min` must never be the only thing carrying the message** — if it is urgent, say so in words as well.
- Something that never stops moving in the corner of a page somebody is reading is the one kind of motion the rest of this library refuses. Prefer a count over `'infinite'`, and prefer a colour over either.
- Keep it well away from three flashes a second. This is a slow pulse by default and it should stay one.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the effect is dropped and the content sits at full opacity. **So `min` must never be the only thing carrying the message** — if it is urgent, say so in words as well.
- Something that never stops moving in the corner of a screen somebody is reading is the one kind of motion the rest of this package refuses. Prefer a count over a `null` repeat, and prefer a colour over either.
- Keep it well away from three flashes a second. This is a slow pulse by default and it should stay one.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `repeat="infinite"` | `repeat: null` | The default here, and the value that never stops. |
| `render` | — | Flutter has no polymorphic element. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `stagger`, `durationStep`, `reverse` | — | The React build writes the effect onto the children themselves, so the caller's own layout is untouched. Flutter has no stylesheet to lay a set out with, so a staggered effect would have to own the row or the column as well — which is what [`PlAnimateAppear`](./animate-appear) is, and six more of it would be six more of it. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
