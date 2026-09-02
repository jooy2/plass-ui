---
title: PlShow
order: 7
---

# PlShow

<p class="plass-lede">Content at some widths and not others. It decides in CSS, so the first paint a server sends is already the right half — and it is not a box, so it changes nothing about the layout it sits in.</p>

<Demo src="show/hero" :min-height="140" />

::: fw react

```tsx
import { PlShow } from 'plass-ui';

<PlShow from="md">
  <PlTable columns={columns} rows={rows} />
</PlShow>

<PlShow until="md">
  <PlList>…</PlList>
</PlShow>
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlShow(from: PlassBreakpointFloor.md, child: PlTable<Row>(columns: columns, rows: rows));
PlShow(until: PlassBreakpointFloor.md, child: PlList(children: rows));
```

:::

## Props

<PropsTable name="PlShow" />

`until` is **exclusive**, and it has to be: `until="md"` on one element and `from="md"` on another are then the two halves of one decision, with no width that draws both and none that draws neither.

There is no `xs`. Everything is at or above the bottom rung, so `from="xs"` would mean "always" — which is what leaving the prop out already means — and `until="xs"` would mean "never".

## Why a component and not a media query

::: fw react

A `useMediaQuery` and a ternary look like the same thing and are not. **A media query answered in JavaScript is `false` on a server and on the first frame a browser renders**, so a JavaScript gate draws the wrong half of a responsive layout and then throws it away. That is a flash on every page load, not an edge case. The stylesheet knows the width before React has been asked anything.

It is also the only way this works for a project that imports `plass-ui/styles.css` and has no Tailwind of its own — there is no `md:hidden` to reach for there.

:::

::: fw flutter

`MediaQuery.sizeOf` is already correct on the first frame, so the gate is a plain conditional. What it buys over writing that conditional yourself is the ladder: the same five names, the same widths, and the same exclusive `until` as everything else in the package.

:::

## It is not a box

::: fw react

While it is showing, `PlShow` is `display: contents`. Its children take part in the layout around it exactly as they would have without it — a gate inside a flex row does not become a flex item, and one inside a grid does not become a cell.

Which also means **a `className` carrying a margin or a width does nothing here.** There is no box for it to land on. Put your own element inside.

:::

## What it costs

::: fw react

**Both halves are in the document.** Hiding is `display: none`, which takes the subtree off the accessibility tree and out of the layout — so nothing is read out twice and nothing is drawn — but both were rendered and both were sent.

That is the right trade for two arrangements of the same content, and the wrong one for a subtree that is expensive to build, that fetches, or that must not mount at all. For those, [`usePlBreakpointValue`](../../hooks/use-breakpoint) picks one and only that one is mounted — at the cost of a server rendering the `xs` answer.

:::

::: fw flutter

Nothing is built at a width the gate is closed at, so an expensive subtree costs nothing while it is hidden. The other side of that is state: a subtree that is thrown away when the window crosses a boundary loses everything it was holding. Lift that state above the gate.

:::

<Demo src="show/layout" :min-height="320">

::: fw react

<<< @/.vitepress/demos/show/layout.tsx

:::

</Demo>

## Accessibility

::: fw react

- The hidden half is `display: none`, which is what takes it off the accessibility tree and out of the tab order. A gate that moved content off screen instead would leave a screen reader reading both arrangements of the same thing.
- The gate itself has no role and no label. It is not an element as far as the layout or the accessibility tree is concerned.

:::

::: fw flutter

- The hidden half is not built, so there is nothing in the semantics tree and nothing to focus.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| both halves rendered, one `display: none` | only the open half built | There is no `display: contents` and no cheap hidden subtree here. It cuts both ways: an expensive subtree is free while closed, and its state is lost when the window crosses the boundary. |
| `from` / `until` as `'sm' \| 'md' \| 'lg' \| 'xl'` | `PlassBreakpointFloor` | The same four rungs, as an enum. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
