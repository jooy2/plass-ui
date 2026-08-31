---
title: PlBackTop
order: 8
---

# PlBackTop

<p class="plass-lede">The way back up, once there is a way back up to want. It is hidden until it is useful, which is the whole design.</p>

<Demo src="back-top/hero" :min-height="320" />

::: fw react

```tsx
import { PlBackTop } from 'plass-ui';

<PlBackTop />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

Stack(
  children: <Widget>[
    ListView(controller: controller, children: rows),
    Positioned(right: 24, bottom: 24, child: PlBackTop(controller: controller)),
  ],
);
```

:::

## Props

<PropsTable name="PlBackTop" />

Every native `<button>` attribute passes straight through, and everything else is a [`PlIconButton`](../inputs/icon-button)'s — the three materials, the elevation ladder, the pointer light.

::: fw flutter

**There is no `floating`, and no equivalent of it.** Flutter has no `position: fixed`, so where the button goes is the caller's: a `Stack` over the scrollable with a `Positioned` or an `Align` in it, which is how a Flutter screen pins anything to a corner.

`controller` is the `ScrollController` — left out, the `PrimaryScrollController`, which is what a `ListView` with no controller of its own attaches to and is therefore this framework's "the window". `onPressed` runs **instead of** the scroll rather than before it, which is the shape a Dart caller wants: there is no event to `preventDefault`.

:::

## Hidden until it is useful

A button pinned to the corner of every page from the first paint is one more thing covering the content, and on a page short enough not to scroll it is a control that does nothing.

It appears when the reader is `visibilityHeight` pixels down — 400 by default, roughly one screen on a laptop, which is the point at which scrolling back stops being something they would just do.

While it is out of reach it is **`aria-hidden` and out of the tab order**, not merely faded. A control a reader can tab to and cannot see is worse than one that is not there.

## Examples

### target

The window by default. A ref or an element for a panel that scrolls inside the page — a table's scroll box, a chat log, a modal's body.

```tsx
const panel = useRef<HTMLDivElement>(null);

<div ref={panel} className="overflow-y-auto">
  …
</div>
<PlBackTop target={panel} />
```

### floating

On by default, because that is what this component is. Turn it off to put the button somewhere of your own — the end of an article, a toolbar — and keep the appearing and the scrolling.

```tsx
<PlBackTop floating={false} className="mx-auto mt-8" />
```

### The glyph and the words

```tsx
<PlBackTop icon={<ArrowUpIcon />} label="위로" />
```

`label` is the accessible name **and** what the tooltip a browser draws says. Name it for what pressing it does.

## Notes

- The scroll is smooth, and **not** under `prefers-reduced-motion` — a page that flies past a reader who asked for less movement is the exact case that setting exists for. It jumps instead, which arrives at the same place.
- The position is read once on mount as well as on every scroll, so a page restored halfway down — a back navigation, an anchor in the URL — has the button already there.
- A caller's own `onClick` runs first, and calling `preventDefault()` in it stops the scroll. That is how to take the reader somewhere other than the top.
