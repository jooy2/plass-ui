---
title: PlToolbar
order: 10
---

# PlToolbar

<p class="plass-lede">A bar of controls: an application header, a page's action row, the strip along the bottom of an editor. Three slots and a row.</p>

<Demo src="toolbar/hero" :flutter="false" :min-height="140" />

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

## Props

<PropsTable name="PlToolbar" />

::: fw react

Every other `<div>` attribute passes through, and `render` swaps the element.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## It takes no height

A toolbar is as tall as the controls in it plus its padding, and that padding is the `size` / `density` pair every other surface uses. So `density="compact"` gives the dense bar without a second prop meaning the same thing — and without the type scale moving under it.

<Demo src="toolbar/density" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/toolbar/density.tsx

</Demo>

## It has no toolbar role

Deliberately. `role="toolbar"` is a **promise about keyboard behaviour** — one tab stop for the whole bar, arrow keys between the controls in it — and a bar that claims it without implementing it is worse for a keyboard reader than one that never claimed anything.

What a page header wants is the right element. What a genuine roving-focus set of choices wants is a [`PlSegmentedButton`](../inputs/segmented-button), which is one.

## Examples

### The three slots

`start` and `end` are pinned to their ends and `children` takes what is left, which is the arrangement every toolbar has ever had — so it is laid out here rather than left to a caller and a spacer they have to remember. The middle keeps its width even when it is empty, or the two ends collapse together in the middle of the bar.

<Demo src="toolbar/slots" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/toolbar/slots.tsx

</Demo>

### variant

The three materials, read as a _container's_: the bar is never dyed, exactly as on a [`PlBox`](./box). A toolbar holds other people's controls, and those controls arrive with colours of their own.

<Demo src="toolbar/variants" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/toolbar/variants.tsx

</Demo>

### position and divider

`static` leaves the bar in the flow. `sticky` holds it against an edge once the page has scrolled that far, and it still takes up its own space — so nothing underneath has to be padded around it. `fixed` takes it out of the flow entirely, and the page then needs padding of its own or the first screenful sits behind the bar.

A pinned bar loses its corners: a rounded corner against the edge of the screen is a gap with nothing behind it.

`elevation` stays at `0` even pinned, which is deliberate — a shadow under a header is a way of saying "there is content beneath this", and that is only true once the page has been scrolled. Raise it yourself at that moment, or leave it flat and turn on `divider`, which draws a hairline along the edge that faces the content: under a `top` bar, over a `bottom` one.

## Accessibility

- The bar claims no role of its own. What it is is decided by the element it renders.
- The controls inside it are ordinary controls in document order, each with its own focus stop — which is what a bar that has not promised roving focus owes a keyboard reader.

::: fw react

- `render={<header />}` and `render={<nav />}` are the two that come up most; a page's header should be a `<header>`.

:::
