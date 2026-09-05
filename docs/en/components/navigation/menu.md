---
title: PlMenu
order: 3
---

# PlMenu

<p class="plass-lede">A list of actions that appears when something is pressed. Roving focus, typeahead, submenus with a safe triangle, and the roles that make any of it mean something to a screen reader.</p>

<Demo src="menu/hero" :min-height="200" />

::: fw react

```tsx
import { PlButton, PlMenu, PlMenuItem, PlMenuSeparator } from 'plass-ui';

<PlMenu trigger={<PlButton variant="glass">Actions</PlButton>}>
  <PlMenuItem shortcut="⌘X">Cut</PlMenuItem>
  <PlMenuItem shortcut="⌘C">Copy</PlMenuItem>
  <PlMenuSeparator />
  <PlMenuItem color="danger">Delete</PlMenuItem>
</PlMenu>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlMenu(
  items: <PlMenuEntry>[
    PlMenuItem(label: 'Cut', shortcut: '⌘X', onPressed: cut),
    PlMenuItem(label: 'Copy', shortcut: '⌘C', onPressed: copy),
    const PlMenuSeparator(),
    PlMenuItem(label: 'Delete', color: PlassColor.danger, onPressed: remove),
  ],
  trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
      PlButton(onPressed: open, variant: PlassVariant.glass, child: const Text('Actions')),
);
```

:::

## Props

<PropsTable name="PlMenu" />

### PlMenuItem

<PropsTable name="PlMenuItem" />

### PlMenuCheckboxItem and PlMenuRadioItem

<PropsTable name="PlMenuCheckboxItem" />

### PlMenuSubmenu

<PropsTable name="PlMenuSubmenu" />

### PlContextMenu

<PropsTable name="PlContextMenu" />

There is no `variant`, for the reason `PlModal` has none: the three materials answer "how much does this surface assert itself against the page", and a popup that has taken the pointer has already answered it. There is no `elevation` either — a menu genuinely floats, which is the one case the ladder exists for, so it is fixed at its top rung. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### The items array

::: fw react

**Composed, not passed as data** — the opposite of [`PlSelect`](../inputs/select), and deliberately.

A select's options are values out of a list a caller already has, so they are data. A menu's rows are **code** — each one a different handler, a different icon, sometimes a link, sometimes a submenu. Passing them as data would mean an `items` type with a variant for every shape a row can take, which is a component tree spelled as a discriminated union.

:::

::: fw flutter

**Descriptions, not composed widgets** — and this is the one place the two packages disagree about a component's shape.

It is forced. React composes because Base UI reads the DOM the rows are written into: it finds them, counts them, moves a roving highlight through them and matches typeahead against them without anybody handing it a list. There is no tree to walk here, so the menu has to be told — the same reason `PlAccordion`, `PlTabs` and `PlSelect` all take descriptions.

`PlMenuEntry` is a **sealed** hierarchy rather than one class with a discriminator on it, which is what lets a row be a different _kind_ of thing and the switch over it be checked.

:::

<Demo src="menu/rows" :min-height="200">

::: fw react

<<< @/.vitepress/demos/menu/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/rows.dart

:::

</Demo>

### color on a row

A row can name its own family — `danger` on the one that deletes — and the slots are re-declared on the row so the tint, the hairline and the text all turn over together rather than one of them staying indigo.

It is a branch rather than a class appended next to the default. Two Tailwind utilities of equal specificity on one element resolve by their order in the generated stylesheet rather than by the order they were written in, so an appended accent would silently do nothing on some builds and work on others.

### Groups and separators

A group's label is a heading, not a row: it cannot be picked, it is not in the typeahead, and Base UI wires it to the rows underneath it.

<Demo src="menu/groups" :min-height="200">

::: fw react

<<< @/.vitepress/demos/menu/groups.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/groups.dart

:::

</Demo>

### Ticking and choosing

A checkbox row is marked with a tick; a radio row with a dot. That is the same distinction `PlCheckbox` and `PlRadioGroup` make everywhere else — a tick says "and", a dot says "instead of".

Both default to **staying open** when they are picked, against the `true` a plain row takes. A list of things to tick is a list you tick more than one of.

::: fw flutter

There is no radio _group_. Every input in this package is controlled, so a `PlMenuRadioItem` is told whether it is the chosen one and reports that it was pressed — a group that owned the value would be the one thing in the library that did not report and forget.

:::

<Demo src="menu/selection" :min-height="240">

::: fw react

<<< @/.vitepress/demos/menu/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/selection.dart

:::

</Demo>

### Submenus

The row that opens one is the same row every other item is, wearing a chevron. It opens on hover, on <kbd>Enter</kbd> and on the arrow key that points at it, and a diagonal reach toward it does not close it — Base UI tracks a safe triangle from the pointer to the popup.

Nesting is unlimited: a submenu renders its children inside a popup that is itself a menu, so a submenu of a submenu needs no different component.

<Demo src="menu/submenu" :min-height="220">

::: fw react

<<< @/.vitepress/demos/menu/submenu.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/submenu.dart

:::

</Demo>

### size and density

`size` sets the popup's radius, its type scale and the row padding ladder; `density` touches the padding and nothing else.

A row has a padding track of its own rather than the sheet one. A `PlList` row spans a sheet something else decided the width of; a menu row is inside a popup exactly as wide as its longest label, and the sheet track's `px-5` would add 40px to a menu that says "Cut" — which is how a five-row menu ends up the width of a dialog.

<Demo src="menu/sizes" :min-height="160">

::: fw react

<<< @/.vitepress/demos/menu/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/sizes.dart

:::

</Demo>

::: fw react

### PlContextMenu

The same menu, opened by a right-click or a long press instead of by a button.

It takes the rows as `content` and the area as `children`, which is `PlTooltip`'s shape rather than `PlMenu`'s — because here the trigger is not one element you hand over, it is a region of the page, and the region is the thing being wrapped. The popup is positioned at the pointer rather than against an anchor, and the long press is what makes it reachable on a touch screen at all.

<Demo src="menu/context" :min-height="200" :flutter="false">

<<< @/.vitepress/demos/menu/context.tsx

</Demo>

:::

## Accessibility

::: fw react

- Built on Base UI's Menu, which owns everything that makes a menu a menu rather than a floating list of `<div>`s: the `menu` and `menuitem` roles, roving focus with the arrow keys, <kbd>Home</kbd> and <kbd>End</kbd>, typeahead, <kbd>Esc</kbd>, closing on an outside click, and restoring focus to the trigger.
- A row with an `href` is a real `<a>`. A menu of links that are not links cannot be opened in a new tab, cannot be copied, and tells a screen reader the wrong thing about every one of them.
- Rows carry no focus ring. Base UI moves focus onto the highlighted row itself, so a ring would draw a rectangle inside the popup on every arrow press; the tint is the focus indicator, which is what makes it the same one the mouse gets.
- `data-highlighted` rather than `:hover` is what lights a row, so the keyboard and the pointer light the same one.
- A disabled row stays listed and stays findable by typeahead. A row that vanishes when it is unavailable is a menu that changes length.
- The popup animates its **opacity only**. A menu that slides in has moved the row you were already reaching for, which is the one thing a menu must never do.

:::

::: fw flutter

- Focus stays on the **trigger** while the popup is up, which is what `PlSelect` does and for the same reason: the rows are painted in an overlay, and a focus scope lifted with them would take the keyboard away from the widget that knows what to do with it. The arrows, `Home`, `End`, `Esc`, `Enter` and typeahead are all bound there.
- The pointer moves the same highlight the arrow keys do, so the mouse and the keyboard light one row rather than two — and moving onto a row of an outer menu is what closes the submenu open beside it.
- A row is a button node with its name and its action on it; a ticked row is marked **checked** and a chosen one **selected in a mutually exclusive group**. Everything drawn inside is excluded, so a glyph never becomes a second thing to read.
- The arrow that opens a submenu follows the writing direction, so it runs the other way under RTL.
- A disabled row stays listed and stays findable by typeahead. A row that vanishes when it is unavailable is a menu that changes length.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| composed rows | `items: List<PlMenuEntry>` | Base UI reads the DOM the rows are written into. There is no tree to walk here, so the menu has to be told what it holds. |
| `children` on a row | `label`, a `String` | It is drawn, announced _and_ matched by typeahead. Only a string can be all three. |
| `PlMenuRadioGroup` | `PlMenuRadioItem.selected` | Every input in this package is controlled; a group holding a value would be the one that is not. |
| `trigger`, an element | `trigger`, a builder | It is handed the callback that opens the menu and whether it is open, which is what a trigger that stays lit needs. |
| `href` on a row | — | There is no link element and nothing crawls a Flutter app. `onPressed` is where a router is called. |
| `modal` | — | The popup is anchored rather than laid over the screen; the press that lands outside it closes it. |
| `PlContextMenu` | — | There is no right-click gesture to build on that means the same thing on every platform this package runs on. A long press that opens a menu is `onLongPress` and a `PlMenu` the app opens itself. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
