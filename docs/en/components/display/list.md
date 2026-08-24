---
title: PlList
order: 12
---

# PlList

<p class="plass-lede">A stack of rows. The list is a sheet and the rows are what is on it, so <code>size</code> and <code>density</code> belong to the stack and a row inherits them.</p>

<Demo src="list/hero" :min-height="360" />

```tsx
import { PlList, PlListItem } from 'plass-ui';

<PlList>
  <PlListItem description="Three unread" onClick={open}>
    Inbox
  </PlListItem>
  <PlListItem description="One saved">Drafts</PlListItem>
</PlList>;
```

## Props

<PropsTable name="PlList" />

Every native `<ul>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

### PlListItem

<PropsTable name="PlListItem" />

Every native `<li>` attribute passes straight through, onto the `<li>` rather than onto the button or link inside it. `size`, `density` and `dividers` are inherited from the `PlList` around it — a row that disagreed with its neighbours about any of them is a list with a hole in it.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### A row

The shell is always an `<li>`. What changes is what is inside it: a plain run of content, or — when `onClick` or `href` is given — a real `<button>` or `<a>` wrapping that content.

`action` sits outside that pressable area on purpose. A row that both navigates and holds a toggle has two things to press, and a `<button>` inside a `<button>` is markup the browser rewrites on parse.

<Demo src="list/rows" :min-height="380">

<<< @/.vitepress/demos/list/rows.tsx

</Demo>

### dividers

With dividers the rules have to reach both edges of the sheet, so the list gives up its inner padding and the rows give up their rounded corners. A row cannot be a floating tile and a ruled line at the same time.

<Demo src="list/dividers" :min-height="260">

<<< @/.vitepress/demos/list/dividers.tsx

</Demo>

### variant

The sheet is never dyed, exactly as on a `PlCard`. A list holds other people's content, and that content arrives with its own colours.

`ghost` is the one to reach for inside a card: the card is already a sheet, and a second bordered rectangle inside it is a second rectangle.

<Demo src="list/variants" :min-height="380">

<<< @/.vitepress/demos/list/variants.tsx

</Demo>

### size

<Demo src="list/sizes" :min-height="380">

<<< @/.vitepress/demos/list/sizes.tsx

</Demo>

## Accessibility

- There is no Base UI primitive under this on purpose. A list is not a composite widget — it has no roving focus, no selection model, no keyboard contract of its own. Reaching for a menu or a listbox primitive would hand a plain list of links the semantics of a menu.
- `role="list"` is written out because Tailwind's reset takes the bullets off every `<ul>`, and Safari takes the list semantics off with them.
- A chosen link carries `aria-current="page"` and a chosen button `aria-current="true"`. The first says "this is the page you are on", the second "this is the chosen one of these". `aria-pressed` would be a third thing — a toggle — and a selected row is not a toggle.
- A row with neither `onClick` nor `href` adds no role and takes no tab stop. An inert `<div>` with a click handler on it is invisible to a keyboard.
- Give the control in `action` its own accessible name. It is a separate tab stop from the row, which is the point of it being there.
