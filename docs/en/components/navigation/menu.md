---
title: PlMenu
order: 3
---

# PlMenu

<p class="plass-lede">A list of actions that appears when something is pressed. Roving focus, typeahead, submenus with a safe triangle, and the roles that make any of it mean something to a screen reader.</p>

<Demo src="menu/hero" :min-height="200" :flutter="false" />

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

### The rows are composed, not passed as data

The opposite of [`PlSelect`](../inputs/select), and deliberately.

A select's options are values out of a list a caller already has, so they are data. A menu's rows are **code** — each one a different handler, a different icon, sometimes a link, sometimes a submenu. Passing them as data would mean an `items` type with a variant for every shape a row can take, which is a component tree spelled as a discriminated union.

<Demo src="menu/rows" :min-height="200" :flutter="false">

::: fw react

<<< @/.vitepress/demos/menu/rows.tsx

:::

</Demo>

### color on a row

A row can name its own family — `danger` on the one that deletes — and the slots are re-declared on the row so the tint, the hairline and the text all turn over together rather than one of them staying indigo.

It is a branch rather than a class appended next to the default. Two Tailwind utilities of equal specificity on one element resolve by their order in the generated stylesheet rather than by the order they were written in, so an appended accent would silently do nothing on some builds and work on others.

### Groups and separators

A group's label is a heading, not a row: it cannot be picked, it is not in the typeahead, and Base UI wires it to the rows underneath it.

<Demo src="menu/groups" :min-height="200" :flutter="false">

::: fw react

<<< @/.vitepress/demos/menu/groups.tsx

:::

</Demo>

### Ticking and choosing

A checkbox row is marked with a tick; a radio row with a dot. That is the same distinction `PlCheckbox` and `PlRadioGroup` make everywhere else — a tick says "and", a dot says "instead of".

Both default to **staying open** when they are picked, against the `true` a plain row takes. A list of things to tick is a list you tick more than one of.

<Demo src="menu/selection" :min-height="240" :flutter="false">

::: fw react

<<< @/.vitepress/demos/menu/selection.tsx

:::

</Demo>

### Submenus

The row that opens one is the same row every other item is, wearing a chevron. It opens on hover, on <kbd>Enter</kbd> and on the arrow key that points at it, and a diagonal reach toward it does not close it — Base UI tracks a safe triangle from the pointer to the popup.

Nesting is unlimited: a submenu renders its children inside a popup that is itself a menu, so a submenu of a submenu needs no different component.

<Demo src="menu/submenu" :min-height="220" :flutter="false">

::: fw react

<<< @/.vitepress/demos/menu/submenu.tsx

:::

</Demo>

### size and density

`size` sets the popup's radius, its type scale and the row padding ladder; `density` touches the padding and nothing else.

A row has a padding track of its own rather than the sheet one. A `PlList` row spans a sheet something else decided the width of; a menu row is inside a popup exactly as wide as its longest label, and the sheet track's `px-5` would add 40px to a menu that says "Cut" — which is how a five-row menu ends up the width of a dialog.

<Demo src="menu/sizes" :min-height="160" :flutter="false">

::: fw react

<<< @/.vitepress/demos/menu/sizes.tsx

:::

</Demo>

### PlContextMenu

The same menu, opened by a right-click or a long press instead of by a button.

It takes the rows as `content` and the area as `children`, which is `PlTooltip`'s shape rather than `PlMenu`'s — because here the trigger is not one element you hand over, it is a region of the page, and the region is the thing being wrapped. The popup is positioned at the pointer rather than against an anchor, and the long press is what makes it reachable on a touch screen at all.

<Demo src="menu/context" :min-height="200" :flutter="false">

::: fw react

<<< @/.vitepress/demos/menu/context.tsx

:::

</Demo>

## Accessibility

::: fw react

- Built on Base UI's Menu, which owns everything that makes a menu a menu rather than a floating list of `<div>`s: the `menu` and `menuitem` roles, roving focus with the arrow keys, <kbd>Home</kbd> and <kbd>End</kbd>, typeahead, <kbd>Esc</kbd>, closing on an outside click, and restoring focus to the trigger.
- A row with an `href` is a real `<a>`. A menu of links that are not links cannot be opened in a new tab, cannot be copied, and tells a screen reader the wrong thing about every one of them.
- Rows carry no focus ring. Base UI moves focus onto the highlighted row itself, so a ring would draw a rectangle inside the popup on every arrow press; the tint is the focus indicator, which is what makes it the same one the mouse gets.
- `data-highlighted` rather than `:hover` is what lights a row, so the keyboard and the pointer light the same one.
- A disabled row stays listed and stays findable by typeahead. A row that vanishes when it is unavailable is a menu that changes length.
- The popup animates its **opacity only**. A menu that slides in has moved the row you were already reaching for, which is the one thing a menu must never do.

:::
