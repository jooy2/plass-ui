---
title: PlFloatingBottomNavigation
order: 2
---

# PlFloatingBottomNavigation

<p class="plass-lede">A row of round destinations floating clear of the bottom edge of the window. A capsule of clear glass with a key of tinted glass riding in it — the design language's own sentence, and nothing added to it.</p>

<Demo src="floating-bottom-navigation/hero" :min-height="220" />

::: fw react

```tsx
import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem } from 'plass-ui';

<PlFloatingBottomNavigation value={where} onValueChange={setWhere} label="Main">
  <PlFloatingBottomNavigationItem value="home" icon={<HomeIcon />}>
    Home
  </PlFloatingBottomNavigationItem>
  <PlFloatingBottomNavigationItem value="search" icon={<SearchIcon />}>
    Search
  </PlFloatingBottomNavigationItem>
</PlFloatingBottomNavigation>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlFloatingBottomNavigation<String>(
  value: where,
  onChanged: (String next) => setState(() => where = next),
  label: 'Main',
  items: const <PlFloatingBottomNavigationItem<String>>[
    PlFloatingBottomNavigationItem<String>(value: 'home', label: 'Home', icon: HomeIcon()),
    PlFloatingBottomNavigationItem<String>(value: 'search', label: 'Search', icon: SearchIcon()),
  ],
);
```

:::

## Props

<PropsTable name="PlFloatingBottomNavigation" />

### PlFloatingBottomNavigationItem

<PropsTable name="PlFloatingBottomNavigationItem" />

::: fw react

Every native `<nav>` attribute passes through on the bar and every native `<button>` attribute on an item.

:::

::: fw flutter

The bar is generic in the destination's type and **controlled**, and its destinations are descriptions rather than widgets — the same three decisions [`PlBottomNavigation`](./bottom-navigation) makes, for the same reasons.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Why it is a second component

It is the other half of [`PlBottomNavigation`](./bottom-navigation), and a different object rather than a variant of one.

That bar is **attached** to the edge of the window: full width, a hairline against the content it is over, its sheet running under the home indicator, and flat, because a thing lying against an edge does not cast a shadow onto it. This one is **not part of the page at all**. Everything that follows comes from that single difference — the capsule, the gap under it, the shadow it defaults to, and the pill corners it is allowed.

A `floating` boolean would have been the smaller API and the worse one: half the props on each bar would have meant nothing on the other, and the first `divider={true} floating` would have been a bar with a hairline along the top of a capsule that has no content behind it.

## Examples

### The discs

Every destination is a disc with a glyph in it and no name drawn, which is what keeps a row of five inside the width of a phone.

`rounded-full` is one of the very few places the library allows a pill, and it is allowed for the reason a `PlSegmentedButton`'s groove is: this is not a sheet lying on the page, it is an object floating clear of one. The house fillet is about a sheet with its corners cut, and a sheet that is not on anything has no corners to cut.

The current destination is a key of **tinted glass** riding in the clear sheet. Every other one has no surface until the pointer is on it.

### The key travels

The key is **one element**, measured off whichever disc is current and animated between them the way a [`PlSegmentedButton`](../inputs/segmented-button)'s tile is. It is not a fill that appears on one disc while it disappears from another: two discs cross-fading is two objects, and a bar with a key in it has one — where that key goes is the whole of what this component has to say.

Nothing is transformed. The key is an empty box moved by its own `left`, `top`, `width` and `height`, so no glyph in the row is resampled while it travels, and the house rule against moving a control survives a component whose entire point is that something moves.

The first placement is instant, however it arrives. A key that has only just mounted has nowhere to travel *from*, so the destination a bar opens on appears under its own disc rather than flying in from the left edge of the capsule.

### Names

`children` is required in practice and **never drawn**. A disc with a glyph in it has no accessible name at all, and a row of glyphs with no names is exactly the defect `PlIconButton`'s `label` exists to make impossible — it would be just as easy to ship here.

If a sighted reader also needs the words, put a `PlTooltip` around the item. What this component will not do is draw a name on some discs and not on others: a row where one item is a capsule and four are circles is a row with a layout shift in it every time the destination changes.

### variant

`glass` is the default and the whole point: a clear sheet over a blurred backdrop with a hairline around it. `solid` is the same sheet at its most opaque, for a bar that sits over photography. `ghost` has no capsule at all — the discs float on their own.

<Demo src="floating-bottom-navigation/variants" :min-height="320">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/variants.dart

:::

</Demo>

### color

The capsule is never dyed, exactly as on a `PlCard`. What carries the family is the one disc that is current.

<Demo src="floating-bottom-navigation/colors" :min-height="260">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/colors.dart

:::

</Demo>

### size, elevation and the gap

`size` is the disc's diameter, on the control ladder — so a floating bar at `md` is a row of 40px discs and lands on the same numbers as everything else.

`elevation` is `2`, against the `0` almost everything else defaults to, and that is not an inconsistency. Every other sheet in the library rests on the page and earns its separation from the glass edge, so a shadow is opt-in. This one hovers over whatever is underneath it, and a capsule lying flat on the content it is floating over reads as a mistake.

The gap under the bar comes off the same `size` ladder, with `env(safe-area-inset-bottom)` added to it while `safeArea` is on.

<Demo src="floating-bottom-navigation/sizes" :min-height="280">

::: fw react

<<< @/.vitepress/demos/floating-bottom-navigation/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_bottom_navigation/sizes.dart

:::

</Demo>

## Accessibility

- A named `<nav>` landmark, and every disc a real link or button in document order — one tab stop each.
- The current destination carries `aria-current="page"`. Never `aria-pressed`.
- Every disc has an accessible name, and none of them is drawn. The name lives in a 1px clipped box: invisible to a sighted reader, present to every other kind.

::: fw react

- The strip the capsule is centred in spans the window and takes **no pointer events**; only the capsule takes them back. A transparent band across the bottom of a page that swallowed presses would be a band nobody could scroll through.

:::

- The focus ring on a disc is offset rather than flush, which is the exception the rest of the library does not make: a flush ring on a circle is the circle's own edge thickening, which reads as a border rather than as focus.

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlFloatingBottomNavigationItem>` children | `items: List<…<T>>` | The bar has to reason about its members. The idiom the rest of the package uses. |
| `children` on an item | `label`, a `String` | It is only ever a semantics label here, and a semantics label is a string. |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled. |
| `position` | — | A Flutter screen has no page scroll to opt out of; the app places the bar. |
| a full-width strip with no pointer events | — | There is no strip to build. A `fixed` element has to span something; a Flutter widget goes exactly where it is put, so the bar is only as wide as its capsule. |
| `href` | — | There is no link element and nothing crawls a Flutter app. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
