---
title: PlBackTop
order: 8
---

# PlBackTop

<p class="plass-lede">The way back to the top of a long page. It stays hidden until the page has scrolled far enough to need it, which is the whole design.</p>

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

Every native `<button>` attribute passes straight through, and everything else is a [`PlIconButton`](../inputs/icon-button)'s, the three materials, the elevation ladder, the pointer light.

::: fw flutter

**There is no `floating`, and no equivalent of it.** Flutter has no `position: fixed`, so where the button goes is the caller's: a `Stack` over the scrollable with a `Positioned` or an `Align` in it, which is how a Flutter screen pins anything to a corner.

`controller` is the `ScrollController`, left out, the `PrimaryScrollController`, which is what a `ListView` with no controller of its own attaches to and is therefore this framework's "the window". `onPressed` runs **instead of** the scroll rather than before it, which is the shape a Dart caller wants: there is no event to `preventDefault`.

**Desktop and the desktop web need `controller`.** A scroll view takes the `PrimaryScrollController` by itself only on Android, iOS and Fuchsia, so anywhere else nothing is attached to it and a button left without one never appears. A debug build asserts when that happens. For a scroll view built with `primary: true`, pass `PrimaryScrollController.of(context)`.

:::

## Hidden until it is useful

A button pinned to the corner of every page from the first paint is one more thing covering the content, and on a page short enough not to scroll it is a control that does nothing.

It appears when the reader is `visibilityHeight` pixels down, 400 by default, roughly one screen on a laptop, which is the point at which scrolling back stops being something they would just do.

## Examples

### target

The window by default. A ref or an element for a panel that scrolls inside the page, a table's scroll box, a chat log, a modal's body.

```tsx
const panel = useRef<HTMLDivElement>(null);

<div ref={panel} className="overflow-y-auto">
  …
</div>
<PlBackTop target={panel} />
```

### floating

On by default, because that is what this component is. Turn it off to put the button somewhere of your own (the end of an article, a toolbar), and keep the appearing and the scrolling.

```tsx
<PlBackTop floating={false} className="mx-auto mt-8" />
```

::: fw react

A pinned button sits 24px off the bottom end corner, and `env(safe-area-inset-bottom)` on top of that, so it clears the home indicator or the navigation bar of an edge-to-edge screen. The pinning is an inline `position: fixed` with logical insets rather than a utility class, so a `style` of your own replaces it and a class of your own cannot.

:::

### The glyph and the words

```tsx
<PlBackTop icon={<ArrowUpIcon />} label="위로" />
```

`label` is the accessible name. It is not drawn anywhere, not even as a tooltip, so name it for what pressing it does.

## Notes

- The position is read once on mount as well as on every scroll, so a page restored halfway down (a back navigation, an anchor in the URL) has the button already there.
- A caller's own `onClick` runs first, and calling `preventDefault()` in it stops the scroll. That is how to take the reader somewhere other than the top.

## Accessibility

- While it is out of reach it is not merely faded: it is <Fw react="`aria-hidden` and out of the tab order" flutter="left out of the semantics tree and out of the focus order" />, and it takes no pointer.
- It is named by `label`, and left out, by the label pack's `backToTop`, "Back to top" in English.
- The scroll <Fw react="jumps instead of sliding under `prefers-reduced-motion`" flutter="jumps instead of animating when the platform asks for less motion" />, and arrives at the same place.

::: fw react

- A press that scrolls while the button holds the focus moves the focus to the first element that takes it at the top of what was scrolled, or off the button when there is none, so the next Tab does not start from a button that has just hidden itself.

:::
