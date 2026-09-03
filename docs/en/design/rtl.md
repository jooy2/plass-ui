---
title: Right to left
order: 5
---

# Right to left

<p class="plass-lede">One attribute on one element. Every component is laid out in logical properties, so <code>dir="rtl"</code> is the whole of it — there is nothing to configure and no direction to declare twice.</p>

<Demo src="rtl/direction" :min-height="420" />

::: fw react

```html
<html dir="rtl"></html>
```

That is the layout, and it needs no JavaScript at all. **A handful of behaviours read the direction in JavaScript** — a slider's arrow keys, the way ←/→ walk a tab list, which physical edge a popup's `align="start"` resolves to — and those hear about it through a [`PlassProvider`](../guide/defaults), which reads the document's own direction. Nothing to pass; the provider is the wire, not a second place to declare the answer.

```tsx
<PlassProvider>
  <App />
</PlassProvider>
```

:::

::: fw flutter

Flutter reads `Directionality` from the widget tree, and `MaterialApp`/`WidgetsApp` set it from the locale. Nothing in this package needs telling either:

```dart
Directionality(textDirection: TextDirection.rtl, child: child);
```

:::

## The rule

**`start`/`end`, never `left`/`right`.** Every padding, margin, border, radius and inset in the library is written as a logical property, so what a component calls its start edge is the left one in English and the right one in Arabic.

::: fw react

Nothing measures the direction to decide; the browser does it.

:::

::: fw flutter

Nothing measures the direction to decide; `EdgeInsetsDirectional`, `PositionedDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional` and `BorderDirectional` resolve themselves against the ambient `Directionality`. A `Row`, a `CrossAxisAlignment.start` and a `TextAlign.start` already do.

:::

The same rule reaches the prop vocabulary: [`PlassAlign`](./prop-conventions) is `start | center | end` for exactly this reason, and a `PlSidebar` takes a `start` side rather than a left one.

## What flips, and what does not

|  |  |
| --- | --- |
| Padding, margins, borders, radii, insets | **Flip.** They are logical properties |
| Text alignment, list markers, table columns | **Flip.** The browser's own |
| A chevron that points along the reading direction — a breadcrumb's, a pagination stepper's, a submenu's, a `PlTree`'s closed twisty | **Flip.** One glyph, turned |
| A `PlSwitch`'s thumb | **Flips.** Off is the inline start, which is the right-hand end under RTL — as every platform's own switch behaves |
| A `PlPanes` handle, a `PlSidebar` drag, a `PlCarousel` or `PlScrollZone` strip | **Flip**, including the arrow keys |
| A `PlSlider`'s run | **Flips.** The minimum is at the inline start, so the paint, the press mapping and the left/right arrow keys turn over together |
| A `PlChatBubble`'s tail corner, a `PlButtonGroup`'s squared edges, a date range's open and closed ends | **Flip.** They face the reader's start |
| A `PlAnimateMarquee` | **Flips.** A strip travels towards the reading start, so the words arrive in the order they are read |
| `PlassSide` — a tooltip's `side`, a drawer's edge | **Physical, on purpose.** A tooltip above a button is above it in every writing direction |
| A `PlColorPicker`'s rails | **Do not flip.** A hue rail is a colour space rather than a reading axis: 0° sits where 0° sits in every picker, and a mirrored one would be unrecognisable |
| A `PlSkeleton`'s sweep | **Does not flip.** It is a light crossing a surface, and a light that changed direction with the locale would read as a different material |
| An icon that is not directional — a star, a bin, a spinner | Does not flip, and should not |
| Numbers, dates and times | The platform's own. Set `locale` on the components that take one |

## Where the direction is read in code

Almost nothing needs to. The exceptions are the places where the **thing being measured** is physical too, and pairing a logical property with a physical measurement is what would actually break the direction.

::: fw react

Three, and all three read `getComputedStyle(…).direction` rather than guessing:

- a **`PlPanes`** handle dragged with the pointer or nudged with the arrow keys — a pointer's `clientX` grows to the right in both directions, so the delta has to be turned round;
- a **`PlSidebar`**'s resize drag, for the same reason, and the edge a collapsed one turns into a `PlDrawer` on;
- the moving indicator in **`PlTabs`**, **`PlSegmentedButton`** and **`PlFloatingBottomNavigation`**, which is placed from `offsetLeft` — a distance from the left edge in both directions.

Base UI's own primitives read it from a **React context** instead, and that is the one thing a page has to do something about: with no provider its `useDirection()` answers `ltr` however the document is written. `PlassProvider` renders that context from the document's direction, which is why a page that set `dir` and nothing else would look right and behave the other way round.

There is one place CSS answers it instead of JavaScript, and it is the exception that proves the rule: there is no logical `translate`, so `.plass-marquee-track` flips its sign under `[dir='rtl']`.

:::

::: fw flutter

All of them read `Directionality.of(context)`, and they fall into three kinds:

- **A pointer or an arrow key against a physical axis.** A drag's `delta.dx` grows to the right in both directions, so `PlPanes`, `PlSidebar`, `PlSlider` and `PlScrollZone` turn it round — and with it the left/right arrow keys, which mean "further along the line" rather than "further right".
- **A corner that has to be handed over resolved.** `PlButtonGroup`'s squared edges, `PlChatBubble`'s tail and a date range's open and closed ends are written as a `BorderRadius` rather than as a `BorderRadiusDirectional`, because the same value reaches a `ClipRRect`, a `BoxDecoration` and a painter — and the painter takes a resolved one.
- **A `PlassSide` chosen for the reader.** `PlassSide` names an edge of the screen, so a `PlNavigationMenu` picks which edge its panel flies out towards rather than always taking the right.

A **`PlSlider`** is worth naming, because it turns over more than a margin: the paint, the press mapping and the left/right arrow keys mirror together, and a control where only some of them did would be arguing with itself.

Everything else is a `*Directional` widget, and the package test below is what keeps it that way.

:::

## Checking your own

::: fw react

```tsx
<div dir="rtl">{/* a screen */}</div>
```

`dir` can go on any element, so a single component can be checked without the whole page moving. A subtree that runs the other way from its page wants a `PlassProvider direction="rtl"` around it as well, for the same reason the page does.

:::

::: fw flutter

```dart
Directionality(textDirection: TextDirection.rtl, child: screen);
```

`Directionality` can wrap any subtree, so a single widget can be checked without the whole app moving.

:::

What to look for is a gap that has landed on the wrong side, an icon that should have turned and did not, and text that is still ragged on the wrong edge.

A component that gets it wrong is a bug. Both packages carry a test for it, in two halves: one drives a real right-to-left tree and asserts the handful of behaviours that must turn over, and the other reads every component's source and fails on a physical property that is not on a short, documented list. The second half is the one that catches the _next_ component.

## Notes

- The library ships no translations. `PlTable`'s `empty`, `PlPagination`'s labels, `PlAlert`'s `closeLabel` and the pickers' `labels` are plain props, and the app-wide defaults set the picker vocabulary once. A library that shipped translations would have to be told which language a page is in, and the page already knows.
- The `locale` default reaches the date, time and number components. It does not set the direction — that belongs to the document in React and to the app in Flutter, and a component library has no business writing on either.
