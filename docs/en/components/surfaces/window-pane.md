---
title: PlWindowPane
order: 13
---

# PlWindowPane

<p class="plass-lede">A window, drawn the way one of eight systems draws it, with anything at all inside it. Not a real window and not pretending to be one — a frame that behaves.</p>

<Demo src="window-pane/hero" :min-height="340" />

::: fw react

```tsx
import { PlWindowPane } from 'plass-ui';

<PlWindowPane title="Notes">
  <MyApp />
</PlWindowPane>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlWindowPane(title: const Text('Notes'), child: MyApp());
```

:::

There is no desktop, no z-order and no dock. What there is is a title bar that drags, corners that resize and three buttons that are real buttons with real names — so a screenshot of an app, a demo of a feature or a piece of a landing page can be shown as the thing it will be rather than as a picture of it.

**Nothing here is transformed.** A dragged window moves on its position and a resized one changes its width and height, which is what keeps the text inside it at whole pixels through both gestures. A scale would resample every glyph in the window for the length of the drag, which is exactly what the house rule against transforming a surface exists to prevent.

## Props

<PropsTable name="PlWindowPane" />

`minimize` rolls the window up to its title bar rather than sending it anywhere, because a page has nowhere to send it to. `maximize` fills whatever is holding the window.

**`size` scales the chrome and nothing else** — the bar, the buttons and the title. A window's content is the caller's and is laid out at its own scale, exactly as it would be on a real desktop where the title bar does not grow with the document. It is the third component after [`PlBox`](./box) and [`PlMockup`](../display/mockup) where the ladder means something other than a control height.

## Examples

### os

<Demo src="window-pane/os" :min-height="700">

::: fw react

<<< @/.vitepress/demos/window-pane/os.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/window_pane/os.dart

:::

</Demo>

Versions are separate entries wherever the _title bar_ is what changed, which is why Windows has five and the others have one or two. XP painted its bar in Luna blue and framed the window in it; 7 made it glass; 8 threw both away for a flat square sheet; 10 ruled the bar off from the body; 11 rounded the corners and made the two one sheet again. `macosx` is Aqua against the flat `macos` that replaced it.

Which buttons a window has is the caller's decision; **what order they sit in is the system's.** macOS puts close first and Windows puts it last, and that is not something a caller should have to remember.

Nothing here is a copy of any of those systems: what is drawn is a bar, a border and three buttons at the proportions the system used, and no mark, wordmark or icon belonging to anyone else.

### accent and active

<Demo src="window-pane/accent" :min-height="340">

::: fw react

<<< @/.vitepress/demos/window-pane/accent.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/window_pane/accent.dart

:::

</Demo>

A window behind the one in front keeps its shape and loses its emphasis: its colour drains, its shadow drops a step and its title greys. Never `opacity`, which would take the content down with the chrome.

On React, `active` works itself out if you leave it off — a window is in front until another one on the page is pressed or takes the focus. A click on the page _around_ the windows changes nothing; a paragraph is not a desktop. On Flutter it is a plain value: there is no document to listen to, and a widget that reached across the tree to find the other windows would be inventing a desktop.

### transparency

<Demo src="window-pane/transparency" :min-height="360">

::: fw react

<<< @/.vitepress/demos/window-pane/transparency.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/window_pane/transparency.dart

:::

</Demo>

It applies to the title bar, the body's own fill and the border — **never to the content on it**, which stays exactly as legible as it was. On React anything above `0` also turns the blur on, so the page underneath is blurred rather than merely visible.

### draggable and resizable

The title bar drags and the eight edges and corners resize. Both are off by default: a window in a page is usually a picture of one, and a frame that moved when a reader brushed it would be a surprise.

## Accessibility

- The window is a named group, taking its name from the title. On React that is `role="group"` with `aria-labelledby`; on Flutter it is a semantics container with `explicitChildNodes`, which is what stops the title, the buttons and every word of the content merging into one long name.
- The three buttons are real buttons and say what they do. `maximize` becomes **Restore** once the window is filling its container, which is what every system calls it.
- On React one of the eight resize handles is reachable without a pointer, and it is the corner that changes both axes at once. Eight tab stops around every window would cost a keyboard reader more than the seven extra directions are worth; the arrow keys move that corner.
- A minimized window's content is put **out of reach rather than taken away** — it is still in the tree, marked inert, so nothing under a rolled-up bar can be tabbed into.
