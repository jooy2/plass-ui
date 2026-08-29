---
title: PlAnimateHeadline
order: 5
---

# PlAnimateHeadline

<p class="plass-lede">One line replacing the one above it, on a timer. Every line sits in the same grid cell, so the box is as tall as the longest of them from the first frame and never resizes as the reel turns.</p>

<Demo src="animate-headline/hero" :min-height="180" />

::: fw react

```tsx
import { PlAnimateHeadline } from 'plass-ui';

<PlAnimateHeadline interval={2200}>
  <span>ships on Friday</span>
  <span>reads like prose</span>
  <span>weighs almost nothing</span>
</PlAnimateHeadline>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateHeadline(
  interval: Duration(milliseconds: 2200),
  children: <Widget>[
    Text('ships on Friday'),
    Text('reads like prose'),
    Text('weighs almost nothing'),
  ],
);
```

```

:::

## Props

<PropsTable name="PlAnimateHeadline" />

::: fw react

Every native `<div>` attribute passes straight through. There is no `render` and no `alternate`: the component owns its grid, and a reel has no other direction to run in.

:::

::: fw flutter

`rise` is a `double?` in logical pixels, and **`null` — the default — is one line's own height**, the same trade `PlAnimateSlide`'s `distance` makes. There is no `alternate`: a reel has no other direction to run in.

:::

`interval` is counted **from the moment a line arrives** rather than from the start of the cycle, so raising `duration` does not quietly eat the reading time.

The rest of the shared settings — `duration`, `delay`, `easing`, `repeat`, `paused`, `trigger`, `play`, `once`, `threshold` — mean what they mean everywhere else. `delay` is what happens before the reel starts turning at all, so it is added once rather than to every line.

## Examples

### Controlled

Pass `index` and the reel stops running a timer of its own — a controlled headline is somebody else's clock, and a second one underneath it would fight for the same state. Drive it from a step in a form, a tab, or a timer you own.

<Demo src="animate-headline/controlled" :min-height="220">

::: fw react

<<< @/.vitepress/demos/animate-headline/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_headline/controlled.dart

:::

</Demo>

### rise

How far a line travels as it comes up or leaves. `'100%'` is one line's own height, which is what makes it read as a reel; a few pixels is closer to a crossfade with a hint of direction.

<Demo src="animate-headline/rise" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-headline/rise.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_headline/rise.dart

:::

</Demo>

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the lines still change, but nothing slides: the outgoing line is dropped rather than animated away. The reel is the content, so switching it off entirely would leave only the first line.
- **Not for content a reader has to see.** There is no guarantee anyone is looking during the two seconds a line is up, and a screen reader is given whichever line happens to be showing rather than the set. Use it for phrases where any one of them would have done.
- Every line is in the document from the first frame; the ones not showing keep their space with `visibility` rather than being taken out of the layout. That is what keeps the box from resizing, and it also means nothing is announced twice.
- Consider `loop={false}` for anything with a natural end. A reel that never stops is motion in the corner of a page somebody is reading.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the lines still change, but nothing slides: the outgoing line is dropped rather than animated away. The reel is the content, so switching it off entirely would leave only the first line.
- **Not for content a reader has to see.** There is no guarantee anyone is looking during the two seconds a line is up, and a screen reader is given whichever line happens to be showing rather than the set.
- Every line is in the tree from the first frame; the ones not showing are drawn at zero opacity rather than taken out of the layout. That is what keeps the box from resizing.
- Consider `loop: false` for anything with a natural end. A reel that never stops is motion in the corner of a screen somebody is reading.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| every line in one grid cell | a `Stack` | The framework's own way of putting things in the same place; a stack is as tall as its tallest child, which is the property the effect needs. |
| the lines that are not showing keep their space with `visibility` | drawn at zero opacity | Same outcome — they overlap in the stack either way, so nothing has to be taken out of the layout to begin with. |
| `rise` as a CSS length | `double?`, `null` is one line's own height | A fraction of a line's own height is what `FractionalTranslation` already means. |
| `render` | — | Flutter has no polymorphic element. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
