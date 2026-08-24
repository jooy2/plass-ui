---
title: PlTabs
order: 3
---

# PlTabs

<p class="plass-lede">One set of panels, one of which is shown. The indicator slides from the tab you left to the one you chose.</p>

<Demo src="tabs/hero" :min-height="200" />

```tsx
import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

<PlTabs defaultValue="account">
  <PlTab value="account">Account</PlTab>
  <PlTab value="billing">Billing</PlTab>

  <PlTabPanel value="account">Your name and your avatar.</PlTabPanel>
  <PlTabPanel value="billing">Cards and invoices.</PlTabPanel>
</PlTabs>;
```

The tabs and the panels are written as siblings and sorted apart by the component. There is no `<PlTabList>` to remember, and no array-of-subtrees prop — a panel is a subtree, and there is no useful shape for that which is not just children.

## Props

<PropsTable name="PlTabs" />

### PlTab

<PropsTable name="PlTab" />

### PlTabPanel

<PropsTable name="PlTabPanel" />

`variant`, `size`, `density` and `orientation` are read from the `PlTabs` around them. A tab that could disagree with its neighbours about any of those is a tab bar with a hole in it.

What the shared axes (`variant` `size` `color` `density` `orientation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Tabs or a segmented button?

Tabs swap whole panels of content. A [segmented button](../inputs/segmented-button) filters what is already on screen. That is also why the `solid` tile here is a pane of **clear** glass rather than the family's gradient — the gradient tile belongs to the segmented button, and a screen with both should be able to tell them apart.

## Examples

### variant

`glass` is the classic bar: a rule along its edge with the indicator riding on it. `solid` is a groove with a pane sliding in it. `ghost` is the same bar with the rule taken away, for tabs inside a `PlCard` that already has an edge of its own.

<Demo src="tabs/variants" :min-height="420">

<<< @/.vitepress/demos/tabs/variants.tsx

</Demo>

### orientation

`vertical` puts the tabs down the side and the panel beside them, and moves the arrow keys onto the other axis — which is Base UI's doing, and is what makes a vertical tab bar reachable.

<Demo src="tabs/orientation" :min-height="200">

<<< @/.vitepress/demos/tabs/orientation.tsx

</Demo>

### fullWidth

<Demo src="tabs/full-width" :min-height="160">

<<< @/.vitepress/demos/tabs/full-width.tsx

</Demo>

### size

A tab is a control, so it takes the control height ladder — a `md` tab and a `md` `PlButton` are the same 40px, which is what lets a tab bar sit in a toolbar next to one without the row losing its baseline.

<Demo src="tabs/sizes" :min-height="380">

<<< @/.vitepress/demos/tabs/sizes.tsx

</Demo>

### Controlled

<Demo src="tabs/controlled" :min-height="200">

<<< @/.vitepress/demos/tabs/controlled.tsx

</Demo>

## Accessibility

- Base UI owns everything that makes a tab bar a tab bar rather than a row of buttons: roving focus so the whole bar is one tab stop, the arrow keys on whichever axis it runs, <kbd>Home</kbd> and <kbd>End</kbd>, the `tab` / `tabpanel` roles, and the `aria-controls` wiring between them.
- `activateOnFocus` is **off** by default. Automatic activation is only kind when every panel is already on the page; the moment one of them fetches, walking past four tabs fires four requests.
- A panel with nothing focusable inside takes focus itself, so its content is reachable from the keyboard.
- The focus ring on a tab is drawn inset, because an offset ring on a tab inside a `solid` groove would be painted over its neighbours.
- The indicator animates `left`, `top`, `width` and `height` rather than a `transform`. It is an empty box: nothing with text in it moves.
- A bar with more tabs than room scrolls rather than wrapping. A tab bar on two lines has stopped being a bar, and the indicator has nowhere sensible to sit.
