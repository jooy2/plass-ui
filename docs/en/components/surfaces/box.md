---
title: PlBox
order: 5
---

# PlBox

<p class="plass-lede">A sheet of glass with content on it. The plainest surface in the library: it groups things, and that is all it does.</p>

<Demo src="box/hero" :min-height="180" />

::: fw react

```tsx
import { PlBox } from 'plass-ui';

<PlBox>
  <p>Everything in here is grouped, and nothing else is claimed.</p>
</PlBox>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBox(child: Text('Everything in here is grouped, and nothing else is claimed.'));
```

:::

## Props

<PropsTable name="PlBox" />

::: fw react

Every other `<div>` attribute passes through, and `render` swaps the element.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## PlBox or PlCard

Everything structural — a title, a subtitle, a footer, hairlines between sections — belongs to [`PlCard`](./card), which is a box with those sections laid out on it. What is left here is the sheet itself, and it is worth having on its own because most of what a screen groups has no heading: a well behind a form, a tile in a shelf, a panel round a chart.

The moment you find yourself putting a heading and a body inside a box by hand, the component you wanted was a card.

## `size` means the sheet

`size` means something different here from what it means on a control, and this is the one place in the library where that is true.

A box is as tall as what it holds, and its children bring their own typography — a container that reset the type scale would render the same paragraph at two sizes depending on what it was wrapped in. So `size` is the size of the **sheet**: its radius and its padding, and nothing else.

<Demo src="box/sizes" :min-height="320">

::: fw react

<<< @/.vitepress/demos/box/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/sizes.dart

:::

</Demo>

## Examples

### variant

The three materials say what they say everywhere else, read as a _container's_: the sheet is never dyed. What a box holds arrives with its own colours, and tinting the pane under them puts every one on a background it was not chosen against — so the family reaches the hairline and the focus ring and stops.

`ghost` is the one to reach for inside another surface, where a second bordered rectangle is a second rectangle.

<Demo src="box/variants" :min-height="280">

::: fw react

<<< @/.vitepress/demos/box/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/variants.dart

:::

</Demo>

### padded

On by default. Turn it off for content that should reach the edges — an image, a table, a list that draws its own rows.

::: fw react

Add `overflow-hidden` so the content is cut by the sheet's own corners.

:::

::: fw flutter

`clipped` is what cuts the content at the sheet's own corners, and it is a parameter here where the React build needs only a class. It is off by default because a clip also cuts off anything a child draws _outside_ itself, a focus ring included.

:::

<Demo src="box/padded" :min-height="220">

::: fw react

<<< @/.vitepress/demos/box/padded.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/box/padded.dart

:::

</Demo>

### elevation

`0` and flat, which is the right default: the glass edge is what separates the box from the page. Raise it only for a surface that genuinely floats above the content around it — and remember that a `ghost` box has no sheet for a shadow to fall from.

::: fw react

```tsx
<PlBox elevation={2}>Floating clear of the page</PlBox>
```

:::

::: fw flutter

```dart
PlBox(elevation: 2, child: Text('Floating clear of the page'));
```

:::

## Accessibility

- A box is a `<div>` and claims nothing. It has no role, no name and no place in the document outline, which is correct: grouping for the eye is not grouping for a screen reader.
- When the group _is_ meaningful — a region of the page, a list item, a section with a heading — say so with the element rather than with the sheet.

::: fw react

`render={<section aria-label="Storage" />}` and `render={<li />}` are the two that come up most.

:::

::: fw flutter

A `Semantics(container: true, label: …)` around the box is what says the group is one, and it belongs outside the sheet rather than inside it.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `render` | — | There is no element to swap. What a `<section>` was saying is said by a `Semantics` around the box. |
| `overflow-hidden` as a class | `clipped` | A clip is a widget here rather than a property, so it has to be somebody's decision — and it is off by default, because a clip also cuts anything a child draws outside itself. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
