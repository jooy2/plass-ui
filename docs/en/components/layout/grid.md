---
title: PlGrid
order: 3
---

# PlGrid

<p class="plass-lede">A twelve-column row and the cells in it. The column count and the two gutters live on the row; how many columns a cell takes lives on the cell, and it can change at every breakpoint.</p>

<Demo src="grid/hero" :min-height="260" :flutter="false" />

::: fw react

```tsx
import { PlGrid, PlGridItem } from 'plass-ui';

<PlGrid spacing={3}>
  <PlGridItem span={{ xs: 12, md: 8 }}>{main}</PlGridItem>
  <PlGridItem span={{ xs: 12, md: 4 }}>{aside}</PlGridItem>
</PlGrid>;
```

:::

## Props

<PropsTable name="PlGrid" />

### PlGridItem

<PropsTable name="PlGridItem" />

::: fw react

Every native `<div>` attribute passes straight through, on both.

:::

Neither takes `variant`, `color`, `elevation`, `size` or `density`. A grid is not a surface — it is the arrangement of the surfaces inside it — and a cell that drew a sheet would make `span` a visual decision. There is no padding here either: the gutter round a page is a [`PlContainer`](./container)'s and the padding round content is a `PlCard`'s, and a grid with a track of its own would be a third one to keep in step. `spacing` is the only measurement it owns, and it is the space *between* cells.

## Examples

### span

A cell's width is `span` out of the row's `columns`, so `span={6}` is a half of the default twelve and a quarter of `columns={24}`.

A span wider than the row is clamped to the row rather than overflowing the page, which is what the caller meant. A cell with no `span` at all fills the row.

<Demo src="grid/span" :min-height="300" :flutter="false">

::: fw react

<<< @/.vitepress/demos/grid/span.tsx

:::

</Demo>

### Responsive values

`span`, `offset`, `columns` and the three spacings all take a map as well as a value. Every entry applies **from its own breakpoint up**, so two of them usually describe a whole layout: <code v-pre>span={{ xs: 12, md: 6 }}</code> is full width on a phone and a half from 48rem.

The widths are Tailwind's own — `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem, with `xs` meaning from zero up — so a Plass grid and an `md:` utility change at the same moment.

A map is "from here up, use this instead". It is not "and nothing below": naming only `md` still leaves the prop's own default in force underneath, rather than silently dropping to whatever CSS would have fallen back to.

<Demo src="grid/responsive" :min-height="240" :flutter="false">

::: fw react

<<< @/.vitepress/demos/grid/responsive.tsx

:::

</Demo>

### offset

Columns left empty **before** the cell — space pushed in ahead of it, not an absolute position in the row. First in a twelve-column row, `offset={4}` with `span={4}` is the middle third; after a cell that already took four columns, the same offset skips four more and lands on the last third.

<Demo src="grid/offset" :min-height="200" :flutter="false">

::: fw react

<<< @/.vitepress/demos/grid/offset.tsx

:::

</Demo>

### spacing

Tailwind's spacing scale, not Material's 8px one: `spacing={4}` is `1rem`, exactly what `gap-4` already means and what the padding tables already use. Fractions are the point — `1.5` is `0.375rem`. Every other number in this library is on that ladder, and a grid that measured its gutters differently from the card around it would be the one place a caller has to stop and convert.

`rowSpacing` and `columnSpacing` each override one axis and fall back to `spacing`.

The gutter comes out of the **cell**, not out of the row: two halves plus one gutter is still exactly the row's width, so a grid can sit flush against whatever is around it.

<Demo src="grid/spacing" :min-height="300" :flutter="false">

::: fw react

<<< @/.vitepress/demos/grid/spacing.tsx

:::

</Demo>

### alignItems, alignContent and alignSelf

`alignItems` is how cells sit against each other across the row, and `stretch` is the default — which is what makes a row of cards the same height without anybody asking. `alignSelf` overrides it for one cell. `alignContent` is where the rows sit when the grid is shorter than the box holding it, and it is only ever visible on a grid with a height of its own.

<Demo src="grid/alignment" :min-height="220" :flutter="false">

::: fw react

<<< @/.vitepress/demos/grid/alignment.tsx

:::

</Demo>

## Nesting

A grid inside a **cell**, not a cell that is also a grid. The inner grid re-declares the column count for its own subtree while the cell around it keeps the width the outer grid gave it — which is what lets an eight-column region be divided into thirds without any arithmetic against the outer twelve.

::: fw react

## How it is built

`PlGrid` is a flex row and `PlGridItem` is a width in it, which is the shape a twelve-column grid has had since long before CSS had one of its own — and still the only shape where a cell can carry a start offset without an explicit line number, and where the row can be told to stop wrapping.

The three numbers a cell cannot know on its own — the column count and the two gutters — are handed down as **inherited custom properties** rather than through a React context. That is not a shortcut: the values are responsive, and a media query can change an inherited custom property without React hearing about it, so the column count a cell lays itself out against is always the one that is actually on screen. A context would have to re-render the tree at every breakpoint to say the same thing.

The width itself is `(100% + gap) × span / columns − gap`, and it lives in the stylesheet rather than in a class name. `columns` is a number the caller picks and `span` changes at four widths, so the class would have to be assembled at runtime — and a class name assembled at runtime is a class name Tailwind never sees.

:::

## Accessibility

- Neither element adds a role. A grid is an arrangement, and an arrangement is not something a screen reader should have to announce.
- The document order **is** the reading order. `offset` moves a cell with a margin rather than reordering the row, so what a screen reader reads and what a sighted reader sees stay the same sequence.

::: fw react

- `render={<ul />}` on the row and `render={<li />}` on the cells is how a grid of things that really are a list says so.

:::
