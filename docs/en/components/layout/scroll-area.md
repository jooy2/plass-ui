---
title: PlScrollArea
order: 6
---

# PlScrollArea

<p class="plass-lede">A bounded box that scrolls, with the library's own scrollbar in it. The reason to use it over <code>overflow: auto</code> is the bar: a platform scrollbar is either an overlay that vanishes or a strip of grey furniture, and neither belongs beside a translucent sheet.</p>

<Demo src="scroll-area/hero" :min-height="260" />

::: fw react

```tsx
import { PlScrollArea } from 'plass-ui';

<PlScrollArea height={200} label="Release notes">
  <ul>…</ul>
</PlScrollArea>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlScrollArea(
  height: 200,
  label: 'Release notes',
  child: Column(children: notes),
);
```

:::

## Props

<PropsTable name="PlScrollArea" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Bound it, or nothing scrolls

A vertical scroll area has to be **bounded by something**, or there is nothing for the content to overflow and the box simply grows to fit. `height` is that something, and it is a prop rather than a class or an enclosing box because it is the one measurement without which the component does nothing at all.

`maxHeight` is the other shape of the same answer: a ceiling rather than a size, for a panel that should shrink to short content and only start scrolling once there is too much. `width` and `maxWidth` are the pair for a horizontal area.

::: fw react

A number is pixels and a string is any CSS length, so `height={200}` and `height="40vh"` both work.

:::

## PlScrollArea or PlScrollZone

Two components, one fact (content that runs off the end of its box), and two different answers.

|  |  |
| --- | --- |
| `PlScrollArea` | Keeps the bar, and makes it the library's own. For a **panel of content**, where a reader wants to know how far through they are. |
| [`PlScrollZone`](./scroll-zone) | Takes the bar away, fades the end that still has something behind it, and adds a pair of buttons. For a **strip** (a row of tabs, chips, filters) where a bar under one line of labels is heavier than the labels. |

There is deliberately **no fade here**. A fade says "there is more"; the bar says that _and_ how much and where you are. Two signals for one fact, one measured and one not, is one more than the box needs.

## Axes

`orientation` is `vertical` by default, `horizontal` for a row, and `both` for a grid that runs off two edges, where a lane is drawn along each and a corner fills the join.

<Demo src="scroll-area/axes" :min-height="260">

::: fw react

<<< @/.vitepress/demos/scroll-area/axes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_area/axes.dart

:::

</Demo>

::: fw flutter

`both` is two scrollables, one nested inside the other, and each bar answers only its own. A widget that let a horizontal bar move when the page scrolled down would be reporting the wrong axis.

:::

## scrollbars

`auto` draws the lane while the pointer is over the box or the content is moving, and nothing otherwise. That is what a reader is used to and it is the default.

`always` holds it open, and it is the right choice more often than it looks: for a panel whose whole point is that there is more below, a bar that only appears on hover is a signal nobody standing back from the screen ever sees. Turning it on costs the content **no width** either way. The lane is overlaid, not laid out.

## Examples

### A dialog body that scrolls while the header stays

The ordinary case. Bound the middle and leave the two ends where they are.

```tsx
<PlModal title="Terms">
  <PlScrollArea maxHeight="60vh" label="Terms of service">
    <div className="pe-3">{terms}</div>
  </PlScrollArea>
</PlModal>
```

### A sidebar of its own

```tsx
<PlScrollArea height="100%" label="Projects" size="sm">
  <PlList>…</PlList>
</PlScrollArea>
```

## Notes

- The thumb is `--plass-track`, the same neutral ink a [slider](../inputs/slider)'s rail and a [progress](../feedback/progress-linear) groove are cut in. One material for every channel in the library.
- The lane is **overlaid**, so showing or hiding it never reflows what is underneath.
- The box is cut to the `size` step of the house radius, and the content is clipped to it.

::: fw react

- The viewport is `overscroll-contain`: reaching the bottom of the panel does not start scrolling the page behind it.
- Base UI owns the behaviour. The overlay measurement, the thumb's size and position, the drag, and making the viewport a tab stop exactly while there is something to scroll.
- `classNames` reaches the parts a `className` does not: `viewport`, `scrollbar`, `thumb`.

:::

::: fw flutter

- Built on `RawScrollbar` from `package:flutter/widgets.dart`. The framework's own `Scrollbar` lives in `material.dart`, which this package does not import.

:::

## Accessibility

- **A scrollable box is a tab stop when nothing inside it is focusable**, because somebody using a keyboard has to be able to scroll it. That is handled for you, and it is the reason `label` matters: a landing point with no name is announced as nothing at all.
- With a `label` the box becomes a named region. Without one it claims **no landmark**, deliberately: an unnamed region is something a screen reader lists as "region" and nothing else, which is worse than no landmark at all.
- The scrollbar is not the only way to move: the arrow keys, <kbd>Page Down</kbd> and the wheel all work on the box itself.
