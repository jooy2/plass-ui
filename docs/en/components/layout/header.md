---
title: PlHeader
order: 7
---

# PlHeader

<p class="plass-lede">The bar across the top of a page: a brand at one end, the actions at the other, and whatever belongs in the middle. A real <code>&lt;header&gt;</code>, which is what makes it the banner landmark.</p>

<Demo src="header/hero" :flutter="false" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlHeader } from 'plass-ui';

<PlHeader brand={<Logo />} actions={<PlButton size="sm">Sign in</PlButton>}>
  <Nav />
</PlHeader>;
```

:::

## Props

<PropsTable name="PlHeader" />

::: fw react

Every native `<header>` attribute passes straight through. `color` and `title` are excluded because both are Plass props here.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## It is not a PlToolbar with a tag on it

A [`PlToolbar`](../surfaces/toolbar) is a row of controls anywhere on a screen, and it takes its height from its padding alone. A header is the page's **banner**: it has a height floor, a measure, a brand slot, and a place in a [`PlPageLayout`](./page-layout) — none of which mean anything on a row of controls beside a table.

Reach for the toolbar when what you have is controls. Reach for this when what you have is the top of a page.

## Examples

### The three slots

`brand`, `children` and `actions`, in that order. They are props rather than sub-components for [`PlCard`](../surfaces/card)'s reason: the arrangement is fixed, and what a caller decides is what goes in each.

A slot that is empty draws nothing — a header with only a brand is one region, not three.

### align

Where the middle sits. `start` packs it against the brand and is the default; `end` packs it against the actions.

`center` is the one worth explaining. Centring the middle in the space _left over_ puts it wherever the brand happens to end, so a logo one character longer moves the navigation — which is exactly what a reader notices between two pages of the same site. Both ends are given equal shares instead, so the middle lands on the bar's own midline whatever is in them. An empty end still takes its half.

<Demo src="header/align" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/header/align.tsx

</Demo>

### position

`sticky` is the default: the bar is held against the top of the window once the page has scrolled to it, and it stays in the flow, so nothing underneath has to be padded out of its way.

`fixed` takes it out of the flow entirely — inside a `PlPageLayout` that is answered for you, because the layout reserves the bar's height. `static` lets it scroll away with the page.

<Demo src="header/position" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/header/position.tsx

</Demo>

### variant

The three materials, read the way a **container** reads them. The bar is never dyed: what is on it — a chip, a button, an avatar — arrives with colours of its own, and a tinted sheet would put every one of them on a background it was not chosen against.

`divider` is on by default and is what actually separates the bar from the content: a translucent sheet pinned over a scrolling page has content passing underneath it at every moment, and nothing marking its edge reads as part of that.

<Demo src="header/variants" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/header/variants.tsx

</Demo>

### size

The bar's floor is a control of the same `size` with air above and below it — `md` is 64px, which is a 40px control with 12px either side. It is a floor and not a height: a bar whose content wraps grows, and keeps its padding while it does.

`density` moves the gutter and nothing else, as everywhere else in the library.

<Demo src="header/sizes" :flutter="false" :min-height="380">

<<< @/.vitepress/demos/header/sizes.tsx

</Demo>

### maxWidth

Holds the row of slots to a measure and centres it while the sheet still spans the window — which is what a site header on a wide screen almost always wants.

It is the same `rem` ladder [`PlContainer`](./container)'s `maxWidth` uses (`xs` 30 · `sm` 40 · `md` 48 · `lg` 64 · `xl` 80), so the logo and the first paragraph of the page under it sit on one edge rather than two that nearly agree.

<Demo src="header/measure" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/header/measure.tsx

</Demo>

### Inside a PlPageLayout

The header registers itself with the layout, which measures it and writes what it takes out of the window onto the layout's root. That is what lets a sidebar holding its place start below a bar whose height nobody but the bar knows.

Nothing has to be passed for this. Outside a layout the registration goes nowhere and the bar is simply a bar.

## Accessibility

- It renders a real `<header>`. At the top level of a document that is the `banner` landmark, which is what a screen reader's landmark list, a reader mode and a search engine all read.
- `label` names the bar. Worth writing when a page has two of them, because "banner" twice tells a reader which is which not at all.
- The bar claims no `role="toolbar"` and no `role="navigation"`. The first is a promise about keyboard behaviour it does not implement; the second belongs to the `<nav>` a caller puts in the middle slot.
- The slots are laid out but not reordered, so the reading order is the order they were written in.
