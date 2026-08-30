---
title: PlCommandPalette
order: 5
---

# PlCommandPalette

<p class="plass-lede">Everything an application can do, behind one field. The shape a keyboard-first product takes once it has more actions than a menu bar can hold: a reader types what they want instead of remembering where it was put.</p>

<Demo src="command-palette/hero" :min-height="200" />

::: fw react

```tsx
import { PlCommandPalette } from 'plass-ui';

<PlCommandPalette
  items={[{ value: 'new', label: 'New document', group: 'File', shortcut: 'Mod+N' }]}
  onSelect={(item) => run(item.value)}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCommandPalette(
  open: open,
  onOpenChanged: (bool next) => setState(() => open = next),
  onSelect: (PlCommandItem item) => run(item.value),
  items: const <PlCommandItem>[
    PlCommandItem(value: 'new', label: 'New document', group: 'File', shortcut: 'Mod+N'),
  ],
);
```

:::

## Props

<PropsTable name="PlCommandPalette" />

::: fw react

No native attribute passes through: the palette renders a portalled dialog rather than an element in your tree, so there is nothing for a stray `id` or `onClick` to land on. `className` and `style` are the two that reach it, and both land on the sheet. The scrim behind it is what `classNames.backdrop` reaches.

:::

### PlCommandItem

<PropsTable name="PlCommandItem" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Which control this is

- It is **not a [`PlMenu`](./menu)**. A menu is a short list in one place, and every row is visible before you go looking for it.
- It is **not a [`PlCombobox`](../inputs/combobox)** either. What comes back is not a value — it is something happening.

Reach for it when the answer to "where is that command?" has become "I do not remember".

## Examples

### Groups, descriptions and keywords

Commands are drawn in the order they are given, and a heading appears each time `group` changes — so a group's commands have to be listed together. That is the whole layout rule, and it means the order on screen is the order in the array rather than something the component sorted behind your back.

`keywords` are matched and **never drawn**: the name somebody else's product gives the same command, an abbreviation, the word a reader would have searched for.

The filter folds case and combining marks, so `cafe` finds `Café`. Each command's searchable text is folded **once per list** rather than once per comparison — a `normalize` on every command for every character typed is exactly the cost that makes a palette feel slow.

<Demo src="command-palette/groups" :min-height="160">

::: fw react

<<< @/.vitepress/demos/command-palette/groups.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/command_palette/groups.dart

:::

</Demo>

### shortcut

Two different things share the name, and only one of them is bound.

A **row's** `shortcut` is displayed, at the end of the row, with [`PlHotKeys`](../display/hot-keys). The palette does not bind it: the application already has, and a component that bound it too would be a second listener nobody asked for.

The **palette's** `shortcut` is bound, on the window, and defaults to `Mod+K`. It is read with the same `Mod`-aware vocabulary `PlHotKeys` draws, so the cap on the screen and the key that works cannot drift apart. `false` binds nothing.

### size

The sheet's width, the field's height and the rows' type scale. The field sits one step above the control ladder — `md` is 48px — because a palette's field is not a control in a row of controls: it is the top of a sheet, and it is the only thing on screen.

`density` moves the row height and nothing else.

<Demo src="command-palette/sizes" :min-height="140">

::: fw react

<<< @/.vitepress/demos/command-palette/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/command_palette/sizes.dart

:::

</Demo>

### Controlled

Pass `open` with `onOpenChange`. The palette still asks — the keystroke fires `onOpenChange(true)` — and does not open until the caller says so, which is what a route guard or a "not while the editor is busy" rule needs.

The query is dropped on the way **out** rather than on the way in, so the sheet never flashes the last search as it fades.

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `open` / `defaultOpen` | `open`, required | There is no uncontrolled mode: what opens a palette is a key bound on the whole app, and an app that binds one already holds the state. |
| `shortcut: false` | `shortcut: null` | Dart's way of saying "bind nothing". |
| the list keys handled by Base UI's Autocomplete | handled before the focus system, in the palette's own key handler | The field has the focus and an `EditableText` consumes the arrow keys and Enter itself. Reading them first is the only way the field keeps every character while the list keeps its four keys. |
| a `combobox` with `aria-activedescendant` | a field and a list of `button`s, one marked selected | Flutter's semantics tree has no `activedescendant`. What survives is the thing that matters: the highlight is one mark, and it is announced on the row it is on. |
| the fold strips case **and** combining marks | case only | Dart's core has no `String.normalize`, and this package has no dependencies. |
| `width`, `maxHeight` as a number or a CSS length | `double` | There is no second unit to name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::

## Accessibility

- The sheet is a dialog with a focus trap, a scrim, <kbd>Esc</kbd> to close, and focus returned to wherever the reader was. It has no visible title, so `label` is its accessible name.
- The field is a `combobox` and the list is its `listbox`, wired with `aria-activedescendant` by Base UI — so the arrow keys move a highlight without moving focus, and the field keeps every keystroke.
- The highlight is **one** mark: the pointer and the arrow keys move the same thing, so a reader is never looking at two highlighted rows wondering which <kbd>Enter</kbd> would run.
- A group heading is `role="presentation"`. It is a visual grouping of the same list, not a second list.
- A `disabled` command stays in the list and cannot be run. An option that vanishes when it cannot be chosen is one the reader will keep looking for.
- The whole thing is portalled to the end of `<body>`, and the backdrop and the viewport carry `.plass-portal`, which is where a host that scopes a CSS reset hangs the same reset.
