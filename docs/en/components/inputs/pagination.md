---
title: PlPagination
order: 3
---

# PlPagination

<p class="plass-lede">The strip of page numbers under a long list. Every button in it is a real <code>PlButton</code>, so it lines up with any other control of the same size.</p>

<Demo src="pagination/hero" :min-height="120" />

::: fw react

```tsx
import { PlPagination } from 'plass-ui';

<PlPagination count={12} page={page} onPageChange={setPage} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPagination(
  count: 12,
  page: page,
  onPageChanged: (int next) => setState(() => page = next),
);
```

:::

## Props

<PropsTable name="PlPagination" />

::: fw react

Every native `<nav>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `onChange` because the row spells it `onPageChange`.

:::

::: fw flutter

The row is **controlled**: it is handed the current `page` and reports the one that was chosen.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

Sets how a page at rest looks. The current page is always `solid`, whatever the row's resting variant is — it is the one thing here that has to be legible without being read.

The default is `ghost` rather than the `solid` a lone `PlButton` takes: nine panes of tinted glass in a row say that all nine are the primary action.

<Demo src="pagination/variants" :min-height="220">

::: fw react

<<< @/.vitepress/demos/pagination/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/variants.dart

:::

</Demo>

### siblingCount and boundaryCount

`boundaryCount` is how many pages stay pinned at each end; `siblingCount` is how many sit either side of the current page. Everything between is an ellipsis — except a gap of exactly one page, which is filled with that page instead, because `1 … 3 … 9` hides a single number behind a symbol wider than the number it replaced.

The row keeps a constant number of slots whatever page it is on: the window slides toward whichever end it is near rather than being clipped by it. Without that, stepping from page 1 to page 2 would relayout the row and move every button out from under the pointer that just pressed one.

<Demo src="pagination/window" :min-height="300">

::: fw react

<<< @/.vitepress/demos/pagination/window.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/window.dart

:::

</Demo>

### showArrows and showEdges

The steppers are icon-only buttons, so they go square and land on exactly the same footprint as a single-digit page — a row whose ends are a different width from its middle reads as two controls pushed together. At either end of the range the relevant steppers are disabled and stay in place, so the row never shifts sideways.

<Demo src="pagination/steppers" :min-height="200">

::: fw react

<<< @/.vitepress/demos/pagination/steppers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/steppers.dart

:::

</Demo>

::: fw react

### getPageHref

Turns every number into a real `<a href>`. Without it the row is buttons, and a crawler cannot press one — a paged list of articles or products then exists for a reader and stops at page one for everything else.

With an `href` **and** an `onPageChange`, the handler wins and the navigation is cancelled: that is a client-side router keeping the page it already has. With an `href` and no handler, the link is left to do what a link does, which is also what makes the row work before JavaScript has loaded. A press carrying <kbd>⌘</kbd>, <kbd>Ctrl</kbd>, <kbd>Shift</kbd> or <kbd>Alt</kbd> is never cancelled — that is the reader asking the browser for a new tab.

The current page and a stepper at the end of the row stay `<button>`s, because `disabled` is not something an `<a>` can be.

:::

<Demo src="pagination/links" :min-height="140">

<<< @/.vitepress/demos/pagination/links.tsx

</Demo>

### size

The same height ladder as `PlButton`, so a pagination and a button on the same row keep their baseline. `density` defaults to `compact` here: a number needs less room beside it than a word.

<Demo src="pagination/sizes" :min-height="260">

::: fw react

<<< @/.vitepress/demos/pagination/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pagination/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders a `<nav>` around a `<ul>`: a named landmark a screen reader can skip, holding a list whose length says how far the pages go.
- The current page carries `aria-current="page"`, and a visually hidden `aria-live` line says which page of how many — the list length alone does not, once an ellipsis is in it.
- Every button has an accessible name (`Page 4`, `Next page`). All of them are props, so a page in another language sets its own; nothing here is ever drawn.
- The ellipsis is an `aria-hidden` `<span>`, not a disabled button. It is punctuation, not a control that happens to be unavailable.

:::

::: fw flutter

- The row is a named group, and `label` is that name.
- Every button has a name of its own — "Page 4", "Next page". All of them are parameters, so a screen in another language sets its own; nothing here is ever drawn.
- The digit on a page button is **excluded** from what is read, because `pageLabel` already says it — a label that merged both would announce the number twice.
- The ellipsis is excluded from semantics entirely. It is punctuation, not a control that happens to be unavailable.
- A stepper at the end of the range is disabled and stays in place, so the row never shifts sideways.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `getPageHref` | — | Flutter has no link element and nothing crawls a Flutter app, so the row is buttons and `onPageChanged` is where a router is called. |
| `defaultPage` / `onPageChange` | `page` / `onPageChanged` | Flutter's own controls are controlled, and its name for the callback. |
| `statusLabel`, as a live region | — | The current page is announced by its own button's name when focus reaches it, and a live region that fired on every page change would talk over the list it just replaced. |
| `<nav>` around a `<ul>` | a named semantics group | There is no landmark to skip to, and no list semantics for a reset to take away. |
| `aria-current="page"` | the filled variant, and the button's name | Flutter's semantics tree has no `current`. |

:::

- Fewer than two pages renders nothing at all. A row with a lone disabled `1` in it is a control advertising that it has nothing to do.
- The steppers turn one chevron glyph rather than shipping four drawings, and they flip under RTL.
