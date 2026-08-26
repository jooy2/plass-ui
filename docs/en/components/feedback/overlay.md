---
title: PlOverlay
order: 3
---

# PlOverlay

<p class="plass-lede">A sheet over the whole page that stops it being used. The scrim on its own, with whatever the caller puts on top of it — most often a spinner and a line saying what is being waited for.</p>

<Demo src="overlay/hero" :min-height="120" />

::: fw react

```tsx
import { PlOverlay } from 'plass-ui';

<PlOverlay open={saving} label="Saving your changes">
  <Spinner />
</PlOverlay>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlOverlay(
  open: saving,
  label: 'Saving your changes',
  child: const Spinner(),
);
```

An overlay lifts itself out of the tree, so it needs an `Overlay` above it — `WidgetsApp` with a navigator and `MaterialApp` both provide one. Where it is _written_ does not matter, and it takes up no room there.

:::

## Props

<PropsTable name="PlOverlay" />

::: fw react

Every native `<div>` attribute passes straight through, onto the popup. `color` and `children` are excluded from the pass-through because both are Plass props here.

:::

::: fw flutter

**Controlled**: `open` and `onOpenChanged` are how an overlay is driven, and there is no uncontrolled mode. `onOpenChanged` is only ever called when `dismissible` is on, because nothing else can ask.

There is no `color` either. The one thing a colour family reached in the React build was the slots the content reads, and content in Flutter arrives with its own.

:::

There is no `variant` — the three materials answer "how much does this surface assert itself against the page", and an overlay has already taken the page; `tone` is the question it actually has to answer. There is no `elevation` either: the overlay _is_ the plane everything else floats above, and a scrim with a drop shadow is a scrim with an edge.

What the shared axes (`size` `color` `align`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### tone

The four steps are one axis — how legible is what is behind — and they are tuned with the blur radius as much as with the alpha, because past about 16px a backdrop smears into flat colour and the scrim reads opaque no matter how low its alpha goes.

`scrim` matches `PlModal`'s backdrop exactly. The two have to, or a modal opened over an overlay would show a seam.

`clear` draws nothing at all and still covers the viewport, which is the whole reason to reach for it: an invisible sheet that catches a click.

<Demo src="overlay/tones" :min-height="180">

::: fw react

<<< @/.vitepress/demos/overlay/tones.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/tones.dart

:::

</Demo>

### dismissible

Off by default, which is the other way round from `PlModal` and the one prop here worth reading twice. A modal asks a question and Escape is the universal "no"; an overlay is not asking anything — it is saying _wait_ — and a save that can be dismissed by a stray click is a save the user will think finished.

Turn it on for the overlay whose job is to catch a click outside something.

<Demo src="overlay/dismissible" :min-height="120">

::: fw react

<<< @/.vitepress/demos/overlay/dismissible.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/dismissible.dart

:::

</Demo>

### align

<Demo src="overlay/align" :min-height="120">

::: fw react

<<< @/.vitepress/demos/overlay/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/align.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI's Dialog owns the hard parts: the portal, the scroll lock, the focus held inside, the page behind going inert, and focus returning to wherever it came from when the overlay closes.
- `label` has a default rather than being left empty, because an overlay that holds nothing readable — a bare spinner, a `clear` sheet — still has to say what it is.
- `modal="trap-focus"` keeps the page scrollable and clickable while still holding focus inside, which is what a `clear` overlay usually wants.
- The overlay animates opacity and nothing else. One that scaled or slid would drag whatever is written on it across the screen, and unlike a control this one is usually carrying a sentence.
- Use a `PlModal` instead when there is a question to answer. An overlay has no title, no description and no actions, so a screen reader has nothing to work with beyond `label`.

:::

::: fw flutter

- Focus goes in and stays in: the layer is its own focus scope, and traversal is bounded by the nearest scope, so <kbd>Tab</kbd> inside the overlay cannot land on the page under it. When the overlay closes, focus goes back to whatever had it.
- `label` has a default rather than being left empty, because an overlay that holds nothing readable — a bare spinner, a `clear` sheet — still has to say what it is. It names the layer as a route, which is how a screen reader knows the screen changed.
- `modal: false` leaves the page clickable and scrollable while focus is still held inside, which is what a `clear` overlay usually wants.
- The overlay animates opacity and nothing else. One that scaled or slid would drag whatever is written on it across the screen, and unlike a control this one is usually carrying a sentence. With animations turned off at the OS it appears at once.
- Use a `PlModal` instead when there is a question to answer. An overlay has no title, no description and no actions, so a screen reader has nothing to work with beyond `label`.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter's own controls are controlled, and its name for the callback. |
| `modal={true \| 'trap-focus'}` | `modal: bool` | The two values were "does the pointer get through" — a boolean says that in Flutter's words. |
| `children` | `child` | Flutter's name. |
| `color` | — | The only thing it reached was the slots the content read, and content here arrives with its own colours. |
| a portal to `document.body` | an `Overlay` ancestor | Flutter's portal goes to the nearest `Overlay`, which `WidgetsApp` with a navigator and `MaterialApp` both provide. |
| the scroll lock | — | There is no document to lock. The barrier already takes the pointer, and a scrollable behind it is not reachable. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
