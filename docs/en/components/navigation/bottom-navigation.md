---
title: PlBottomNavigation
order: 1
---

# PlBottomNavigation

<p class="plass-lede">A row of destinations held against the bottom edge of the window. A <code>&lt;nav&gt;</code> of real links or buttons — never a tab list, because it switches what the page <em>is</em> rather than which panel of one is showing.</p>

<Demo src="bottom-navigation/hero" :min-height="220" :flutter="false" />

::: fw react

```tsx
import { PlBottomNavigation, PlBottomNavigationItem } from 'plass-ui';

<PlBottomNavigation value={where} onValueChange={setWhere} label="Main">
  <PlBottomNavigationItem value="home" icon={<HomeIcon />} href="/">
    Home
  </PlBottomNavigationItem>
  <PlBottomNavigationItem value="search" icon={<SearchIcon />} href="/search">
    Search
  </PlBottomNavigationItem>
</PlBottomNavigation>;
```

:::

## Props

<PropsTable name="PlBottomNavigation" />

### PlBottomNavigationItem

<PropsTable name="PlBottomNavigationItem" />

::: fw react

Every native `<nav>` attribute passes through on the bar and every native `<button>` attribute on an item. `color` is excluded because it is a Plass prop here, and `onChange` because the bar spells it `onValueChange`.

:::

An item takes no `size`, `color` or `variant` of its own. All three belong to the **set**, which is the only place they can be set once and mean the same thing for every destination — the same arrangement `PlTabs` and `PlSegmentedButton` use. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Why it is not a tab list

A tab list owes a keyboard reader one tab stop for the whole set and arrow keys within it, and it owes a screen reader a panel per tab. A bottom navigation does neither of those things: it switches what the *page* is. Claiming the role without the behaviour is worse for a keyboard reader than never claiming it at all.

What is claimed instead is `aria-current`, which is the honest statement — this is the destination you are on. Never `aria-pressed`, which would make it a toggle.

### position

`fixed` is the default, against the `static` a layout component would take, because that is what a bottom navigation **is**: held against the bottom edge of the window whatever the page does. `sticky` is the same thing inside a scrolling panel, and `static` puts it in the flow — which is what the previews on this page use, since a fixed bar would leave the page and stick to the browser window.

A bar spanning an edge of the window has nothing behind its corners, so only one sitting in the flow is a sheet with corners at all.

### labels

`all` names every destination, and it is the only setting that works for a reader who has not used the app before. `selected` names only the current one. `none` draws no names at all.

The bar keeps its height at every setting, because the named item is always the tallest one — what changes is how much of the row is words.

**Undrawn is not unsaid.** A glyph on its own has no accessible name, so a name that is not drawn is kept in the document in a clipped box rather than dropped with the pixels.

<Demo src="bottom-navigation/labels" :min-height="360" :flutter="false">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/labels.tsx

:::

</Demo>

### variant and color

The sheet is never dyed, exactly as on a `PlCard`. A bar holds destinations that arrive with their own icons, and tinting the pane under them puts every one on a background it was not chosen against. What carries the colour family is the one item that is current.

<Demo src="bottom-navigation/variants" :min-height="320" :flutter="false">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/variants.tsx

:::

</Demo>

### divider, safeArea and elevation

`divider` draws a hairline along the top edge and is on by default: a bar pinned over a scrolling page has content passing underneath it at every moment, and a translucent sheet with nothing marking its edge reads as part of that.

`safeArea` keeps the row clear of the home indicator on a phone. The **sheet** still reaches the bottom of the screen — only the items move up — because a bar that stopped above the indicator would leave a stripe of page showing under the glass.

`elevation` is `0`, and flat is right: the bar is attached to the edge of the window rather than floating over the middle of it, and `divider` is what separates it from the content. The bar that floats over the page is a different object, and it is [`PlFloatingBottomNavigation`](./floating-bottom-navigation).

### size

<Demo src="bottom-navigation/sizes" :min-height="320" :flutter="false">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/sizes.tsx

:::

</Demo>

::: fw react

### href

With an `href` an item is a real `<a>`, which is what makes a long press offer "open in a new tab" and what puts the destination in the status bar — neither of which a `<button>` that calls `router.push` can do. Without one it is a `<button>`, because a `<div>` carrying a click handler is invisible to a keyboard.

A disabled link loses its `href` rather than keeping a live one behind an `aria-disabled`, because `disabled` is not a state an `<a>` can be in.

<Demo src="bottom-navigation/links" :min-height="160" :flutter="false">

<<< @/.vitepress/demos/bottom-navigation/links.tsx

</Demo>

:::

## Accessibility

- A named `<nav>` landmark, which a screen reader can skip to and skip past.
- The current destination carries `aria-current="page"`. Never `aria-pressed`.
- Every item has an accessible name whatever `labels` is set to.
- Items are real links or real buttons, in document order, each its own tab stop — which is what a set of destinations should be, and what a roving tab index would take away.
