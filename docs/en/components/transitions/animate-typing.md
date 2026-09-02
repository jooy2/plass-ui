---
title: PlAnimateTyping
order: 11
---

# PlAnimateTyping

<p class="plass-lede">Text appearing one character at a time. The whole string is in the document from the first frame, so the effect costs a reader who cannot see it nothing and reflows nothing for a reader who can.</p>

<Demo src="animate-typing/hero" :min-height="160" />

::: fw react

```tsx
import { PlAnimateTyping } from 'plass-ui';

<PlAnimateTyping text="npm install plass-ui" speed={14} hold={1600} erase repeat="infinite" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateTyping(
  'flutter pub add plass_ui',
  speed: 14,
  hold: Duration(milliseconds: 1600),
  erase: true,
  repeat: null,
);
```

```

:::

## Props

<PropsTable name="PlAnimateTyping" />

::: fw react

Every native `<div>` attribute passes straight through, except `children`, which is the text. There is no `render`, no `easing` and no `alternate`: the component owns its two spans, and a typewriter advances a character at a time rather than along a curve.

:::

::: fw flutter

The text is the **first positional argument** and a plain `String`, the way `PlTypography` takes its data. There is nothing to flatten here: a typewriter reveals a string one grapheme at a time, so its input is a string. It draws in whatever `DefaultTextStyle` it is sitting in.

:::

**Only text is typed.** Pass a string, or strings; an element among the children contributes its text and nothing about its markup, because there is no honest way to reveal half of a link.

`duration` is honoured as the time for the **whole string**, and it overrides `speed`. `speed` is the natural unit here — a long paragraph and a short one should be typed at the same pace, not in the same time — so it is the default.

## Examples

### speed

Characters per second. Around 24 reads as somebody typing; below 10 is a machine printing, and above 60 is closer to the line simply appearing.

<Demo src="animate-typing/speed" :min-height="240">

::: fw react

<<< @/.vitepress/demos/animate-typing/speed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_typing/speed.dart

:::

</Demo>

### erase

`repeat`, `hold` and `erase` are what make it a loop: type, hold, delete, type again. Without `erase` a repeat clears in one frame, which is right for a line being **replaced** rather than rewritten.

<Demo src="animate-typing/erase" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-typing/erase.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_typing/erase.dart

:::

</Demo>

## Accessibility

::: fw react

- The whole string sits in a clipped box that a screen reader reads **once**, and the visible copy that animates is `aria-hidden`. Nobody is made to sit through the performance.
- Under `prefers-reduced-motion` the text is simply there. Not "nothing happens" — that is the only outcome that still delivers what the component was carrying.
- The advance is by **grapheme**, not by code point. `👩‍👩‍👧` is one character to a reader and seven code points to JavaScript, and a typewriter that advanced by code points would spend four frames assembling it out of parts that mean nothing on their own.
- The box is not laid out from the characters that have arrived, so the text around it does not reflow on every frame. It will, however, be as wide as its container allows — give a one-line effect a `white-space: nowrap` or a width if the wrap matters.

:::

::: fw flutter

- The whole string is the widget's accessible label and the drawn copy is behind `ExcludeSemantics`, so a screen reader is given the text **once** and is not made to sit through the performance.
- When the platform has animations turned off (`MediaQuery.disableAnimations`) the text is simply there. Not "nothing happens" — that is the only outcome that still delivers what the widget was carrying.
- The advance is by **grapheme**, not by code point. `👩‍👩‍👧` is one character to a reader and seven code points to Dart.
- The box the whole string will need is held from the first frame, so nothing around it is laid out again as the characters arrive.

:::


::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `text` or children, flattened to a string | one positional `String` | There is nothing to flatten: a typewriter's input is text, so it takes text. |
| a clipped copy for a screen reader plus an `aria-hidden` visible one | `Semantics(label:)` over an `ExcludeSemantics` | Same two jobs, one node fewer. |
| the box is not laid out from the arrived characters | the full string is drawn invisibly under the partial one | Flutter lays a `Text` out from what it holds, so the space has to be reserved by something that holds the whole string. |
| `Intl.Segmenter` | `String.characters` | Both know where a grapheme ends; this one ships with the framework. |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here; with no scrollable above it there is nothing to watch, so it runs. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
```
