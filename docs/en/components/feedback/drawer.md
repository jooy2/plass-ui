---
title: PlDrawer
order: 7
---

# PlDrawer

<p class="plass-lede">A panel attached to one edge of the window. Two things in one component, because they are the same panel: the drawer you open, and the drawer that is simply part of the page.</p>

<Demo src="drawer/hero" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlDrawer, PlDrawerClose } from 'plass-ui';

<PlDrawer side="right" trigger={<PlButton>Filters</PlButton>} title="Filters">
  Everything you can narrow by.
</PlDrawer>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDrawer(
  side: PlassSide.right,
  open: filtering,
  onOpenChanged: (bool next) => setState(() => filtering = next),
  title: const Text('Filters'),
  child: const FilterForm(),
);
```

:::

## Props

<PropsTable name="PlDrawer" />

::: fw react

Every other `<div>` attribute passes through to the panel, and so does a `className`. The scrim an overlay drawer draws behind it is a second element in the same portal. `classNames.backdrop` is the way to reach it, and an inline drawer has none for it to land on.

:::

`mode` decides what the panel is, and everything else about it is the same in both:

- **`overlay`** is opened, floats over the page on a scrim, holds the focus and is dismissed: the navigation drawer behind a menu button, the filter panel beside a table.
- **`inline`** is part of the layout, and the page is laid out around it. It has no scrim, no focus trap and nothing to dismiss: the sidebar that is simply there.

A sidebar that turns into a menu button at a breakpoint therefore changes `mode` rather than the component.

::: fw react

`defaultOpen` follows `mode`: `false` in `overlay` and `true` in `inline`.

:::

There is no `variant` and no `elevation`. An `overlay` drawer carries the shadow at the top of the ladder and an `inline` one carries none. The panel fades in and out and never slides. [Design language](../../design/design-language) has the reasons for both.

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### mode

`inline` puts the panel in the layout, with the page laid out beside it.

<Demo src="drawer/inline" :min-height="300">

::: fw react

<<< @/.vitepress/demos/drawer/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/drawer/inline.dart

:::

</Demo>

### side

Physical rather than logical, the way `PlassSide` is everywhere: a drawer along the top of the window is along the top in every writing direction.

The panel is **square against the window and rounded on the free side**: the corners that face the page take the house fillet, and the two against the edge do not. The hairline follows the same rule and is drawn on the free edge only.

A `left` or `right` panel takes the width its `size` implies; a `top` or `bottom` one is as tall as what is in it, up to 85% of the window. A bottom sheet holding three rows should be three rows tall. `extent` overrides either.

<Demo src="drawer/sides" :min-height="140">

::: fw react

<<< @/.vitepress/demos/drawer/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/drawer/sides.dart

:::

</Demo>

### dividers

Scores the panel between the header, the body and the actions with a hairline instead of separating them with space. Worth turning on the moment the body scrolls: the lines are what say the header stayed put.

The body is the only part that scrolls either way.

## Accessibility

- An `overlay` drawer holds the focus while it is up, puts it back where it came from on the way out, and takes the screen behind it away.
- `description` describes it and `title` is announced as a heading, both wired to the panel rather than sitting near it.
- An `inline` drawer is **not** a dialog and claims none of that. It is a panel in the layout, and its heading is an ordinary one.
- `dismissible={false}` refuses both Escape and a press on the scrim. Give a drawer that refuses them actions that answer it, because there will be no other way out.

::: fw react

- `title` names the drawer.
- Base UI owns the focus trap, the scroll lock, the `aria-labelledby` / `aria-describedby` wiring and the inert page behind. `modal="trap-focus"` keeps the page scrollable and clickable while still holding focus inside.
- `PlDrawerClose` exists so an uncontrolled drawer's Cancel button has something to call. `render` makes it a real Plass button: `<PlDrawerClose render={<PlButton variant="ghost">Cancel</PlButton>} />`.

:::

::: fw flutter

- `label` is the name an `overlay` drawer is announced with. `title` is a widget and has no text to hand over, so a drawer with no `label` opens with no name; give it the same words as the title.
- The lift, the scrim, the focus scope, <kbd>Escape</kbd> and focus going back where it came from are `PlassPortal`'s. The same layer a `PlModal` and a `PlOverlay` are built on, so a drawer opened over an overlay shows no seam.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter's own controls are controlled, and so is every stateful widget in this package. |
| `trigger` | — | There is nothing to wire a trigger up _to_ here: the app opens the drawer by setting `open`, and the button that does it is the app's own. |
| `PlDrawerClose` | — | It exists over there so an _uncontrolled_ drawer's Cancel button has something to call. Every drawer here is controlled, so the button already has `onOpenChanged`. |
| `extent: number \| string` | `extent: double` | Pixels stay pixels. There is no CSS length to accept. |
| `modal: boolean \| 'trap-focus'` | `modal: bool` | The two values that differ are "the pointer is held out" and "it is not". Flutter has no scroll lock to be the third thing. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
