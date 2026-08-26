---
title: PlBottomNavigation
order: 1
---

# PlBottomNavigation

<p class="plass-lede">A row of destinations held against the bottom edge of the window. A <code>&lt;nav&gt;</code> of real links or buttons — never a tab list, because it switches what the page <em>is</em> rather than which panel of one is showing.</p>

<Demo src="bottom-navigation/hero" :min-height="220" />

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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBottomNavigation<String>(
  value: where,
  onChanged: (String next) => setState(() => where = next),
  label: 'Main',
  items: const <PlBottomNavigationItem<String>>[
    PlBottomNavigationItem<String>(value: 'home', label: 'Home', icon: HomeIcon()),
    PlBottomNavigationItem<String>(value: 'search', label: 'Search', icon: SearchIcon()),
  ],
);
```

:::

## Props

<PropsTable name="PlBottomNavigation" />

### PlBottomNavigationItem

<PropsTable name="PlBottomNavigationItem" />

::: fw react

Every native `<nav>` attribute passes through on the bar and every native `<button>` attribute on an item. `color` is excluded because it is a Plass prop here, and `onChange` because the bar spells it `onValueChange`.

:::

::: fw flutter

The bar is generic in the destination's type, so `value` and `onChanged` are checked rather than `dynamic`, and it is **controlled** — handed a value, reporting the one that should replace it — which is how every other input in this package works.

An item is a **description rather than a widget**, the idiom `PlAccordion` and `PlTable` already use: the bar has to know which destination is current and how many there are, and a `Widget` is opaque.

:::

An item takes no `size`, `color` or `variant` of its own. All three belong to the **set**, which is the only place they can be set once and mean the same thing for every destination — the same arrangement `PlTabs` and `PlSegmentedButton` use. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Why it is not a tab list

A tab list owes a keyboard reader one tab stop for the whole set and arrow keys within it, and it owes a screen reader a panel per tab. A bottom navigation does neither of those things: it switches what the *page* is. Claiming the role without the behaviour is worse for a keyboard reader than never claiming it at all.

What is claimed instead is `aria-current`, which is the honest statement — this is the destination you are on. Never `aria-pressed`, which would make it a toggle.

### Where it sits

::: fw react

`position` defaults to `fixed`, against the `static` a layout component would take, because that is what a bottom navigation **is**: held against the bottom edge of the window whatever the page does. `sticky` is the same thing inside a scrolling panel, and `static` puts it in the flow — which is what the previews on this page use, since a fixed bar would leave the page and stick to the browser window.

A bar spanning an edge of the window has nothing behind its corners, so only one sitting in the flow is a sheet with corners at all.

:::

::: fw flutter

There is no `position`, because a Flutter screen has no page scroll for a widget to opt out of. A bar goes in whatever the app's scaffold calls its bottom slot, or at the bottom of a `Stack` — and either way it is the app that decides, not the bar.

Its corners are square for the reason the React build's are: a bar spanning an edge of the screen has nothing behind them to cut.

:::

### labels

`all` names every destination, and it is the only setting that works for a reader who has not used the app before. `selected` names only the current one. `none` draws no names at all.

The bar keeps its height at every setting, because the named item is always the tallest one — what changes is how much of the row is words.

**Undrawn is not unsaid.** A glyph on its own has no accessible name, so a name that is not drawn is kept in the document in a clipped box rather than dropped with the pixels.

<Demo src="bottom-navigation/labels" :min-height="360">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/labels.dart

:::

</Demo>

### variant and color

The sheet is never dyed, exactly as on a `PlCard`. A bar holds destinations that arrive with their own icons, and tinting the pane under them puts every one on a background it was not chosen against. What carries the colour family is the one item that is current.

<Demo src="bottom-navigation/variants" :min-height="320">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/variants.dart

:::

</Demo>

### divider, safeArea and elevation

`divider` draws a hairline along the top edge and is on by default: a bar pinned over a scrolling page has content passing underneath it at every moment, and a translucent sheet with nothing marking its edge reads as part of that.

`safeArea` keeps the row clear of the home indicator on a phone. The **sheet** still reaches the bottom of the screen — only the items move up — because a bar that stopped above the indicator would leave a stripe of page showing under the glass.

`elevation` is `0`, and flat is right: the bar is attached to the edge of the window rather than floating over the middle of it, and `divider` is what separates it from the content. The bar that floats over the page is a different object, and it is [`PlFloatingBottomNavigation`](./floating-bottom-navigation).

### size

<Demo src="bottom-navigation/sizes" :min-height="320">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/sizes.dart

:::

</Demo>

::: fw react

### href

With an `href` an item is a real `<a>`, which is what makes a long press offer "open in a new tab" and what puts the destination in the status bar — neither of which a `<button>` that calls `router.push` can do. Without one it is a `<button>`, because a `<div>` carrying a click handler is invisible to a keyboard.

A disabled link loses its `href` rather than keeping a live one behind an `aria-disabled`, because `disabled` is not a state an `<a>` can be in.

<Demo src="bottom-navigation/links" :min-height="160">

<<< @/.vitepress/demos/bottom-navigation/links.tsx

</Demo>

:::

## Accessibility

- A named group a screen reader can skip to and skip past — <Fw react="a &lt;nav&gt; landmark" flutter="a semantics container" />.
- Every item has an accessible name whatever `labels` is set to. **Undrawn is not unsaid.**
- Items are in document order, each its own focus stop — which is what a set of destinations should be, and what a roving tab index would take away.

::: fw react

- The current destination carries `aria-current="page"`. Never `aria-pressed`, which would make it a toggle.

:::

::: fw flutter

- The current destination is marked **selected**, which is Flutter's nearest word for `aria-current` and the one that does not claim the item is a toggle.
- Each item is a button node with the name and the tap action on it; the drawing inside is excluded, so a glyph never becomes a second thing to read.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlBottomNavigationItem>` children | `items: List<PlBottomNavigationItem<T>>` | The bar has to reason about its members, and a `Widget` is opaque. The idiom `PlAccordion` and `PlTable` already use. |
| `children` on an item | `label`, a `String` | It is the name that is drawn **and** the name that is announced. A widget could be the first; only a string can be both. |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| `position` | — | A Flutter screen has no page scroll to opt out of. The app's scaffold decides where the bar goes. |
| `href` | — | There is no link element and nothing crawls a Flutter app. `onChanged` is where a router is called. |
| `aria-current="page"` | the selected flag | Flutter's semantics tree has no `current`. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
