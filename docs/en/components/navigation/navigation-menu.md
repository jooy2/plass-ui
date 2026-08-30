---
title: PlNavigationMenu
order: 4
---

# PlNavigationMenu

<p class="plass-lede">A site's navigation: a row of destinations, some of which open a panel of more of them. Every row is a real link, which is the whole reason this is not a menu.</p>

<Demo src="navigation-menu/hero" :min-height="200" />

::: fw react

```tsx
import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';

<PlNavigationMenu>
  <PlNavigationMenuItem label="Product" columns={2}>
    <PlNavigationMenuLink href="/analytics" title="Analytics" description="Numbers over time" />
  </PlNavigationMenuItem>
  <PlNavigationMenuItem label="Pricing" href="/pricing" />
</PlNavigationMenu>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlNavigationMenu(
  items: <PlNavigationMenuItem>[
    PlNavigationMenuItem(
      label: 'Product',
      columns: 2,
      links: <PlNavigationMenuLink>[
        PlNavigationMenuLink(title: 'Analytics', onPressed: openAnalytics),
      ],
    ),
    PlNavigationMenuItem(label: 'Pricing', onPressed: openPricing),
  ],
);
```

:::

## Props

<PropsTable name="PlNavigationMenu" />

::: fw react

Every native `<nav>` attribute passes straight through. `color` is excluded because it is a Plass prop here, and `defaultValue` / `onChange` because the menu spells them as a value and an `onValueChange`.

:::

### PlNavigationMenuItem

<PropsTable name="PlNavigationMenuItem" />

### PlNavigationMenuLink

<PropsTable name="PlNavigationMenuLink" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## It is not a PlMenu

The difference is what the rows **are**.

A [`PlMenu`](./menu) holds actions. Its rows are `menuitem`s, and the whole thing is a widget that traps the arrow keys and closes when one is chosen.

This holds **links**. It is a `<nav>` full of real `<a>`s, which is what puts them in the browser's link list, on the status bar under the pointer, in the middle-click menu and in a crawler's index. A destination that is a `<div>` with a click handler is in none of those.

Reach for a menu when the row _does_ something. Reach for this when the row _goes_ somewhere.

## Examples

### Items that link, and items that open

An item with an `href` and no children is a link. One with children is a trigger and a panel.

The difference is not cosmetic: the first is announced as a destination and the second as something that expands, so a screen reader tells a reader which of the two they are about to press.

<Demo src="navigation-menu/states" :min-height="180">

::: fw react

<<< @/.vitepress/demos/navigation-menu/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/states.dart

:::

</Demo>

### columns

How many columns the panel lays its links out in. A [`PlNavigationMenuLink`](#plnavigationmenulink) is one row: a `title`, an optional muted `description` under it and an optional glyph before it.

One panel is open at a time and it **resizes between items** rather than closing and reopening, which is what makes crossing the row read as one surface rather than three.

<Demo src="navigation-menu/columns" :min-height="200">

::: fw react

<<< @/.vitepress/demos/navigation-menu/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/columns.dart

:::

</Demo>

### orientation

`vertical` is a nav rail whose panels open beside it rather than under it. The arrow keys follow either way.

<Demo src="navigation-menu/orientation" :min-height="200">

::: fw react

<<< @/.vitepress/demos/navigation-menu/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/orientation.dart

:::

</Demo>

### The row has no surface

At rest the items are the page's own words: no fill, no edge, no shadow. Five bordered boxes across the top of a site is a toolbar rather than a navigation, and a navigation should read as text until it is reached for.

The family arrives with the pointer and with the open panel, and the sheet itself is never dyed — the panel is the same frosted glass a [`PlMenu`](./menu) and a [`PlPopover`](../feedback/popover) draw.

### A link that opens elsewhere

`target` on an item does what it does on an `<a>`, and anything other than this tab has `noopener noreferrer` **merged** into whatever `rel` was asked for.

Merged rather than replaced: the common reason to write a `rel` by hand is `nofollow` or `sponsored`, and spelling that as an override would silently take the protection off a link that still opens elsewhere.

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `href` on an item and on a link | `onPressed` | There is no navigator in this package and no address to resolve. Where a destination _is_ belongs to the app's own router. |
| composed `PlNavigationMenuItem` children | `items: List<PlNavigationMenuItem>` as data | The row has to know which item is which to keep one panel open at a time, and a list is what it can count. |
| `value` / `defaultValue` | `initialValue` | `String?` has no way to tell "the caller did not say" from "the caller says closed", so a controlled mode would be one that could never be closed from outside. Which panel is open is the pointer's state, not the app's. |
| one panel that resizes between items | one panel per item, fading | The resize is Base UI measuring the outgoing and incoming panels and animating between them. Here each item anchors its own popup, so crossing the row swaps panels rather than growing one. |
| `target` and a merged `rel` | — | There is no `rel` to protect, because there is no anchor. |
| the `<nav>` landmark | `SemanticsRole.navigation` | The same landmark under the framework's own name. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::

## Accessibility

- It is a real `<nav>` full of real `<a>`s. That is the component's whole argument, and everything below follows from it.
- Base UI owns the keyboard: the arrow keys move along the row, <kbd>Enter</kbd> and <kbd>Space</kbd> open a panel, <kbd>Esc</kbd> closes it and focus returns to the trigger, and <kbd>Tab</kbd> moves into an open panel's links.
- A trigger reports `aria-expanded`, so a reader is told what pressing it will do.
- A `disabled` item keeps its word in the row and opens nothing. It is dimmed rather than recoloured, which is what `disabled` looks like everywhere in the library.
- The popup is portalled to the end of `<body>` and its positioner carries `.plass-portal`, which is where a host that scopes a CSS reset hangs the same reset.
- The chevron turns rather than the panel sliding. Nothing here moves under the pointer.
