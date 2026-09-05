---
title: PlMenubar
order: 6
---

# PlMenubar

<p class="plass-lede">The strip of words at the top of an application — File, Edit, View — each of which opens a menu. It is one thing to a screen reader, and only ever one of its menus is open.</p>

<Demo src="menubar/hero" :min-height="140" />

::: fw react

```tsx
import { PlMenubar, PlMenubarMenu, PlMenuItem } from 'plass-ui';

<PlMenubar>
  <PlMenubarMenu label="File">
    <PlMenuItem shortcut="Mod+N">New</PlMenuItem>
  </PlMenubarMenu>
</PlMenubar>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlMenubar(
  menus: <PlMenubarMenu>[
    PlMenubarMenu(
      label: 'File',
      items: <PlMenuEntry>[PlMenuItem(label: 'New', shortcut: '⌘N')],
    ),
  ],
);
```

:::

## Props

<PropsTable name="PlMenubar" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it is a Plass prop here.

:::

### PlMenubarMenu

<PropsTable name="PlMenubarMenu" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Composition

Not the look. A row of separate [`PlMenu`](./menu)s would look the same and differ in the ways that matter: it would be a row of buttons to a screen reader rather than one `menubar` whose words are `menuitem`s, and nothing would keep two of them from being open at once.

::: fw react

On a bar, crossing the strip also walks through the menus and the arrow keys move between them as well as inside them. Base UI owns all of it.

:::

## Shared with PlMenu

A `PlMenubarMenu` takes the rows a [`PlMenu`](./menu) takes — `PlMenuItem`, `PlMenuSeparator`, `PlMenuGroup`, `PlMenuSubmenu`, `PlMenuCheckboxItem`, `PlMenuRadioItem` — because it is the same menu with a different trigger.

What it does **not** take is `size`, `color` or `density`. Those belong to the bar: they are the one place the axes can be set once and hold for every menu on the strip, and a bar whose third menu is a size out is not a bar.

<Demo src="menubar/rows" :min-height="140">

<<< @/.vitepress/demos/menubar/rows.tsx

</Demo>

## Examples

### size

The strip sits a rung **below** the control ladder at every step, and it takes the compact padding track even at `density="default"`.

Both are the same decision: a menu bar is a strip of _words_, and it is usually inside something that already has a height — a [`PlToolbar`](../surfaces/toolbar), a [`PlHeader`](../layout/header). Sized as controls, `File Edit View` would be three buttons in a row and would make the bar taller than the thing it is drawn on.

<Demo src="menubar/sizes" :min-height="240">

<<< @/.vitepress/demos/menubar/sizes.tsx

</Demo>

### orientation

`vertical` is the shape a side rail of menus takes.

<Demo src="menubar/orientation" :min-height="200">

<<< @/.vitepress/demos/menubar/orientation.tsx

</Demo>

### No surface

A menu bar sits _on_ something, and a sheet under a strip that is already on a sheet is two sheets. The bar contributes a flex row and four colour slots, and nothing else.

The open menu is marked in colour and nothing else — the word does not move and the strip does not change height, which is the same rule every control in the library follows under a pointer.

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| composed `PlMenubarMenu` children | `menus: List<PlMenubarMenu>` as data | A menu on a bar is a word and a list of rows, and a list is what the strip can count. |
| crossing the strip walks through the menus | pressing elsewhere puts the open one away | An open menu's dismiss layer is between the pointer and the strip, so the words never hear it arrive. Only one is ever open either way. |
| `modal`, `loopFocus` | — | There is no page to make inert and no arrow-key ring to wrap: an open menu already owns the pointer. |
| `aria-expanded` on the word | `SemanticsRole.menuItem` with `expanded` | The same state under the framework's own name. Once a menu is open it is the accessibility tree, so the strip says which one in colour as well. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::

## Accessibility

- The strip is a real `menubar` and each word a `menuitem` that reports whether it is expanded.
- The focus ring is turned **inward** on a word, because a strip's items are a hair apart and a ring drawn outside one would overlap its neighbours.
- A `disabled` menu keeps its word on the bar and opens nothing. `disabled` on the bar does it to every menu at once.

::: fw react

- The arrow keys move along the bar and into an open menu; <kbd>Esc</kbd> closes it and returns focus to its word. `loopFocus` decides whether the bar wraps at its ends.
- `modal` is on by default, so an open menu is what the pointer is talking to — the page behind it is inert until it closes.

:::
