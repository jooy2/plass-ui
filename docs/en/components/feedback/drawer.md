---
title: PlDrawer
order: 7
---

# PlDrawer

<p class="plass-lede">A panel attached to one edge of the window. Two things in one component, because they are the same panel: the drawer you open, and the drawer that is simply part of the page.</p>

<Demo src="drawer/hero" :flutter="false" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlDrawer, PlDrawerClose } from 'plass-ui';

<PlDrawer side="right" trigger={<PlButton>Filters</PlButton>} title="Filters">
  Everything you can narrow by.
</PlDrawer>;
```

:::

## Props

<PropsTable name="PlDrawer" />

::: fw react

Every other `<div>` attribute passes through to the panel.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Two modes, one panel

`mode` is what separates them, and it is a separate axis from `variant` — which already means the weight of a surface across the whole library and would be a second spelling of nothing.

- **`overlay`** — it is opened, it floats over the page on a scrim, it holds the focus, and it is dismissed. The navigation drawer behind a hamburger, the filter panel beside a table.
- **`inline`** — it is part of the layout and the page is laid out around it. No scrim, no focus trap, nothing to dismiss. The sidebar that is simply there.

Everything else about them is identical, which is exactly why they are not two components a caller has to switch between when a sidebar becomes a hamburger at a breakpoint.

`defaultOpen` follows: `false` in `overlay`, `true` in `inline`, because a fixed sidebar that had to be opened before it appeared would not be a fixed sidebar.

<Demo src="drawer/inline" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/drawer/inline.tsx

</Demo>

## There is no variant and no elevation

The three materials answer "how much does this surface assert itself against the page", and a panel that has taken an **edge of the window** has answered it. An `overlay` drawer floats and carries a shadow at the top of the ladder; an `inline` one is part of the layout and carries none. Neither is a decision worth offering.

## Examples

### side

Physical rather than logical, the way `PlassSide` is everywhere: a drawer along the top of the window is along the top in every writing direction.

The panel is **square against the window and cut on the free side** — the corners that face the page take the house fillet, the two against the edge do not, because a corner cut off something with no visible end is a corner cut off nothing. The hairline follows the same rule and is drawn on the free edge only.

A `left` or `right` panel takes the width its `size` implies; a `top` or `bottom` one is as tall as what is in it, up to 85% of the window — a bottom sheet holding three rows should be three rows tall. `extent` overrides either.

<Demo src="drawer/sides" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/drawer/sides.tsx

</Demo>

### Nothing slides

The panel fades, and only fades. A drawer that slid in would be dragging its own text across the screen for the length of the transition — and a panel is nothing _but_ text and controls, so this is the case the [no-transform rule](../../design/design-language) was written for rather than the exception to it.

What says the panel came from an edge is that it is **attached** to one.

### dividers

Scores the panel between the header, the body and the actions with a hairline instead of separating them with space. Worth turning on the moment the body scrolls: the lines are what say the header stayed put.

The body is the only part that scrolls either way.

## Accessibility

- An `overlay` drawer is a real dialog: it holds the focus, restores it to the trigger on the way out, and takes the page behind it out of the accessibility tree. `modal="trap-focus"` keeps the page scrollable and clickable while still holding focus inside.
- `title` names it and `description` describes it — both wired to the panel rather than sitting near it.
- An `inline` drawer is **not** a dialog and claims none of that. It is a panel in the layout, and its heading is an ordinary one.
- `dismissible={false}` refuses both Escape and a press on the scrim. Give a drawer that refuses them actions that answer it, because there will be no other way out.

::: fw react

- Base UI owns the focus trap, the scroll lock, the `aria-labelledby` / `aria-describedby` wiring and the inert page behind.
- `PlDrawerClose` exists so an uncontrolled drawer's Cancel button has something to call. `render` makes it a real Plass button: `<PlDrawerClose render={<PlButton variant="ghost">Cancel</PlButton>} />`.

:::
