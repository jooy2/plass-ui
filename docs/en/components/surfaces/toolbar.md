---
title: PlToolbar
order: 10
---

# PlToolbar

<p class="plass-lede">A bar of controls: an application header, a page's action row, the strip along the bottom of an editor. Three slots and a row.</p>

<Demo src="toolbar/hero" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlToolbar, PlTypography } from 'plass-ui';

<PlToolbar
  render={<header />}
  start={<PlTypography level="h6">Reports</PlTypography>}
  end={<PlButton>New</PlButton>}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlToolbar(
  start: const <Widget>[PlTypography('Reports', level: PlTypographyLevel.h6)],
  end: <Widget>[PlButton(onPressed: create, child: const Text('New'))],
);
```

:::

## Props

<PropsTable name="PlToolbar" />

::: fw react

Every other `<div>` attribute passes through, and `render` swaps the element.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Height

A toolbar is as tall as the controls in it plus its padding, and that padding is the `size` / `density` pair every other surface uses. So `density="compact"` gives the dense bar without a second prop meaning the same thing, and without the type scale moving under it.

<Demo src="toolbar/density" :min-height="200">

::: fw react

<<< @/.vitepress/demos/toolbar/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/density.dart

:::

</Demo>

## No toolbar role

This is deliberate. `role="toolbar"`, and the semantics behind it, is a **promise about keyboard behaviour**: one tab stop for the whole bar, arrow keys between the controls in it. A bar that claims it without implementing it is worse for a keyboard reader than one that never claimed anything.

What a genuine roving-focus set of choices wants is a [`PlSegmentedButton`](../inputs/segmented-button), which is one.

::: fw react

What a page header wants is the right element: `render={<header />}`.

:::

## Examples

### The three slots

`start` and `end` are pinned to their ends and the middle takes what is left, which is the arrangement every toolbar has ever had, so it is laid out here rather than left to a caller and a spacer they have to remember. The middle keeps its width even when it is empty, or the two ends collapse together in the middle of the bar.

<Demo src="toolbar/slots" :min-height="140">

::: fw react

<<< @/.vitepress/demos/toolbar/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/slots.dart

:::

</Demo>

### variant

The three materials, read as a _container's_: the bar is never dyed, exactly as on a [`PlBox`](./box). A toolbar holds other people's controls, and those controls arrive with colours of their own.

<Demo src="toolbar/variants" :min-height="240">

::: fw react

<<< @/.vitepress/demos/toolbar/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/variants.dart

:::

</Demo>

### Held against an edge

::: fw react

`static` leaves the bar in the flow. `sticky` holds it against an edge once the page has scrolled that far, and it still takes up its own space, so nothing underneath has to be padded around it. `fixed` takes it out of the flow entirely, and the page then needs padding of its own or the first screenful sits behind the bar.

A pinned bar loses its corners: a rounded corner against the edge of the screen is a gap with nothing behind it.

:::

::: fw flutter

There is no `position` here, for the reason [`PlFloatingBottomNavigation`](../navigation/floating-bottom-navigation) has none: a `fixed` element has to span something, and a Flutter widget goes exactly where the screen puts it. A bar that has to stay put belongs in the screen's own layout, a `Stack` with a `Positioned`, or the top of a `Column` with the content scrolling under it.

What is left is the one visible consequence: `rounded`. On for a bar sitting in the layout, off for one held against an edge, because a rounded corner against the edge of the screen is a gap with nothing behind it.

:::

`side` then decides one thing only: which edge `divider` draws its hairline along, under a `top` bar, over a `bottom` one.

`elevation` stays at `0` even pinned, which is deliberate. A shadow under a header is a way of saying "there is content beneath this", and that is only true once the page has been scrolled. Raise it yourself at that moment, or leave it flat and turn on `divider`.

## Accessibility

- The bar claims no role of its own.
- The controls inside it are ordinary controls in reading order, each with its own focus stop, which is what a bar that has not promised roving focus owes a keyboard reader.

::: fw react

- What the bar _is_ is decided by the element it renders. `render={<header />}` and `render={<nav />}` are the two that come up most; a page's header should be a `<header>`.

:::

::: fw flutter

- `semanticLabel` names the bar itself when it needs a name of its own. The controls inside keep their own nodes, so the name is the bar's rather than the bar's and everything in it read as one blob.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `position` | — | A `fixed` element has to span something. A Flutter widget goes exactly where the screen puts it, and a bar that has to stay put belongs in the screen's own layout. |
| corners follow `position` | `rounded` | The same call, made directly: on in the flow, off against an edge. |
| `side` picks the pinned edge _and_ the rule's edge | `side` picks the rule's edge | Nothing else is left for it to decide. |
| `render` | The element you build it inside | There is no element to swap. `semanticLabel` is what names the bar. |
| `start`, `end` as one node | `List<Widget>` | Dart has no fragment, so the slot takes the list it was going to hold anyway, and spaces it. |
| `children` | `child` | One slot, and Dart spells it `child`. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
