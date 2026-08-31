---
title: Right to left
order: 4
---

# Right to left

<p class="plass-lede">One attribute on one element. Every component is laid out in logical properties, so <code>dir="rtl"</code> is the whole setup — there is no provider, no plugin and nothing to configure.</p>

<Demo src="rtl/direction" :min-height="420" />

::: fw react

```html
<html dir="rtl"></html>
```

:::

::: fw flutter

Flutter reads `Directionality` from the widget tree, and `MaterialApp`/`WidgetsApp` set it from the locale. Nothing in this package needs telling either:

```dart
Directionality(textDirection: TextDirection.rtl, child: child);
```

:::

## The rule

**`start`/`end`, never `left`/`right`.** Every padding, margin, border, radius and inset in the library is written as a logical property, so what a component calls its start edge is the left one in English and the right one in Arabic. Nothing measures the direction to decide; the browser does it.

The same rule reaches the prop vocabulary: [`PlassAlign`](./prop-conventions) is `start | center | end` for exactly this reason, and a `PlSidebar` takes `side="start"` rather than `side="left"`.

## What flips, and what does not

|  |  |
| --- | --- |
| Padding, margins, borders, radii, insets | **Flip.** They are logical properties |
| Text alignment, list markers, table columns | **Flip.** The browser's own |
| A chevron that points along the reading direction — a breadcrumb's, a pagination stepper's, a submenu's | **Flip.** One glyph, turned |
| A `PlSwitch`'s thumb | **Flips.** Off is the inline start, which is the right-hand end under RTL — as every platform's own switch behaves |
| A `PlPanes` handle, a `PlSidebar` drag, a `PlCarousel` or `PlScrollZone` strip | **Flip**, including the arrow keys |
| `PlassSide` — a tooltip's `side`, a drawer's edge | **Physical, on purpose.** A tooltip above a button is above it in every writing direction |
| An icon that is not directional — a star, a bin, a spinner | Does not flip, and should not |
| Numbers, dates and times | The browser's and `Intl`'s. Set `locale` on the components that take one |

## Three places direction is read in JavaScript

Almost nothing needs to: CSS answers the question. The exceptions are the ones where the **thing being measured** is physical too, and all three read `getComputedStyle(…).direction` rather than guessing:

- a **`PlPanes`** handle dragged with the pointer or nudged with the arrow keys — a pointer's `clientX` grows to the right in both directions, so the delta has to be turned round;
- a **`PlSidebar`**'s resize drag, for the same reason, and the edge a collapsed one turns into a `PlDrawer` on;
- the moving indicator in **`PlTabs`**, **`PlSegmentedButton`** and **`PlFloatingBottomNavigation`**, which is placed from `offsetLeft` — a distance from the left edge in both directions. Those three keep `left` on purpose: pairing a logical property with a physical measurement is what would actually break the direction.

## Checking your own

```tsx
<div dir="rtl">{/* a screen */}</div>
```

`dir` can go on any element, so a single component can be checked without the whole page moving. What to look for is a gap that has landed on the wrong side, an icon that should have turned and did not, and text that is still ragged on the wrong edge.

A component that gets it wrong is a bug — the library carries a package test that renders in a real `dir="rtl"` document and reads every component's source for a physical utility that is not on a short, documented list.

## Notes

- The library ships no translations. `PlTable`'s `empty`, `PlPagination`'s labels, `PlAlert`'s `closeLabel` and the pickers' `labels` are plain props, and a `PlassProvider` sets the picker vocabulary once. A library that shipped translations would have to be told which language a page is in, and the page already knows.
- `PlassProvider`'s `locale` reaches the date, time and number components. It does not set `dir` — that is the document's, and a library has no business writing on `<html>`.
