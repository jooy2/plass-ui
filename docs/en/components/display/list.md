---
title: PlList
order: 12
---

# PlList

<p class="plass-lede">A stack of rows. The list is a sheet and the rows are what is on it, so <code>size</code> and <code>density</code> belong to the stack and a row inherits them.</p>

<Demo src="list/hero" :min-height="360" />

::: fw react

```tsx
import { PlList, PlListItem } from 'plass-ui';

<PlList>
  <PlListItem description="Three unread" onClick={open}>
    Inbox
  </PlListItem>
  <PlListItem description="One saved">Drafts</PlListItem>
</PlList>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlList(
  children: <Widget>[
    PlListItem(description: const Text('Three unread'), onPressed: open, child: const Text('Inbox')),
    const PlListItem(description: Text('One saved'), child: Text('Drafts')),
  ],
);
```

:::

## Props

<PropsTable name="PlList" />

::: fw react

Every native `<ul>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

:::

### PlListItem

<PropsTable name="PlListItem" />

::: fw react

Every native `<li>` attribute passes straight through, onto the `<li>` rather than onto the button or link inside it. `size`, `density` and `dividers` are inherited from the `PlList` around it — a row that disagreed with its neighbours about any of them is a list with a hole in it.

:::

::: fw flutter

`size`, `density`, `color` and `dividers` are inherited from the `PlList` around it, through an `InheritedWidget` — a row that disagreed with its neighbours about any of them is a list with a hole in it. Which is also why a `PlListItem` outside a `PlList` asserts rather than picking defaults: a row is a row _of_ something.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### A row

::: fw react

The shell is always an `<li>`. What changes is what is inside it: a plain run of content, or — when `onClick` or `href` is given — a real `<button>` or `<a>` wrapping that content.

`action` sits outside that pressable area on purpose. A row that both navigates and holds a toggle has two things to press, and a `<button>` inside a `<button>` is markup the browser rewrites on parse.

:::

::: fw flutter

A row with `onPressed` is a focus stop announced as a button; one without adds no role and takes none.

`action` sits outside that pressable area on purpose. A row that both navigates and holds a toggle has two things to press, and a nested gesture recogniser would take one tap twice.

:::

<Demo src="list/rows" :min-height="380">

::: fw react

<<< @/.vitepress/demos/list/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/rows.dart

:::

</Demo>

### dividers

With dividers the rules have to reach both edges of the sheet, so the list gives up its inner padding and the rows give up their rounded corners. A row cannot be a floating tile and a ruled line at the same time.

<Demo src="list/dividers" :min-height="260">

::: fw react

<<< @/.vitepress/demos/list/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/dividers.dart

:::

</Demo>

### variant

The sheet is never dyed, exactly as on a `PlCard`. A list holds other people's content, and that content arrives with its own colours.

`ghost` is the one to reach for inside a card: the card is already a sheet, and a second bordered rectangle inside it is a second rectangle.

<Demo src="list/variants" :min-height="380">

::: fw react

<<< @/.vitepress/demos/list/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/variants.dart

:::

</Demo>

### size

<Demo src="list/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/list/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- There is no Base UI primitive under this on purpose. A list is not a composite widget — it has no roving focus, no selection model, no keyboard contract of its own. Reaching for a menu or a listbox primitive would hand a plain list of links the semantics of a menu.
- `role="list"` is written out because Tailwind's reset takes the bullets off every `<ul>`, and Safari takes the list semantics off with them.
- A chosen link carries `aria-current="page"` and a chosen button `aria-current="true"`. The first says "this is the page you are on", the second "this is the chosen one of these". `aria-pressed` would be a third thing — a toggle — and a selected row is not a toggle.
- A row with neither `onClick` nor `href` adds no role and takes no tab stop. An inert `<div>` with a click handler on it is invisible to a keyboard.
- Give the control in `action` its own accessible name. It is a separate tab stop from the row, which is the point of it being there.

:::

::: fw flutter

- A list is not a composite widget — it has no roving focus, no selection model and no keyboard contract of its own — so it adds no role beyond grouping its rows, and each row speaks for itself.
- A chosen row reports that it is selected. It is not a toggle, and it does not claim to be one.
- A row with no `onPressed` adds no role and takes no focus stop.
- Give the widget in `action` its own name. It is a separate focus stop from the row, which is the point of it being there.
- A row's focus ring turns inward when the list is ruled, so it is not sliced off at the sheet's clipped edge.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `onClick` / `href` | `onPressed` | Flutter has no link element, so a row that navigates calls your router from `onPressed`. |
| `<ul>` / `<li>` and `role="list"` | a grouped semantics node | There are no bullets to reset and no list semantics for a reset to take away. |
| `aria-current="page"` vs `"true"` | `selected` | Flutter's semantics tree has one selection flag and no page-vs-option distinction. |
| a React context | an `InheritedWidget` | The same idea in Flutter's words, for the same reason: cloning children stops reaching a row the moment a caller wraps one. |
| `render` | — | Flutter has no polymorphic element. |
| `children` on a row | `child` | Flutter's name. |

:::
