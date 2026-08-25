---
title: PlTable
order: 1
---

# PlTable

<p class="plass-lede">A grid of data on a sheet of glass. It takes columns and rows rather than markup, so the headings and the cells under them cannot drift apart.</p>

<Demo src="table/hero" :min-height="240" />

```tsx
import { PlTable, type PlTableColumn } from 'plass-ui';

const columns: PlTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice' },
  { key: 'customer', header: 'Customer' },
  { key: 'total', header: 'Total', align: 'end', render: (row) => `$${row.total}` }
];

<PlTable columns={columns} rows={invoices} caption="Recent invoices" hoverable />;
```

## Props

<PropsTable name="PlTable" />

Every native `<div>` attribute passes straight through to the sheet the grid sits on. `color` is excluded because it collides with the `color` in the table above.

`PlTable` is generic in `Row` and therefore not a `forwardRef` — a component wrapped in `React.forwardRef` loses its type parameter, and the row type is the whole point of the API. `ref` is not offered rather than being offered with `Row` widened to `any`.

### PlTableColumn

<PropsTable name="PlTableColumn" />

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

The sheet under the grid, on the same three materials as every other container, and never dyed.

There is no band behind the column names on any of them. The header is muted, semibold text over a firmer rule, and the rows under it are scored with `--plass-divider` — the same hairline a `PlCard` and a `PlList` are scored with. A filled strip across the top of a grid is the fastest way to make data look like chrome, and it puts all of a table's weight in the one place that needs none of it. The exception is `stickyHeader`, where the fill is not decoration: rows pass directly under a pinned header and something has to stop the light.

<Demo src="table/variants" :min-height="360">

<<< @/.vitepress/demos/table/variants.tsx

</Demo>

### columns

A column names the property it reads with `key`, and `render` takes over when a cell is anything but a string or a number. `width` goes on a `<col>` rather than on the first row's cells — a width set on a `<th>` is one the browser renegotiates against every other row.

`align` is `start` by default. Numbers usually want `end`, so their digits line up in a column.

<Demo src="table/columns" :min-height="200">

<<< @/.vitepress/demos/table/columns.tsx

</Demo>

### striped and hoverable

`striped` washes every other row in `--plass-stripe`, a neutral ink rather than more glass: useful on a wide table where the eye has to track across, noise on a narrow one. `hoverable` lights the row under the pointer in the colour family's own soft tint.

<Demo src="table/striped" :min-height="260">

<<< @/.vitepress/demos/table/striped.tsx

</Demo>

### onRowClick

Makes rows activatable, and turns on the hover treatment with it. Each row picks up a tab stop and answers <kbd>Enter</kbd> and <kbd>Space</kbd>, so a row is reachable without a pointer.

A key pressed inside a cell is left alone: a cell can hold a link or a button with an <kbd>Enter</kbd> of its own, and running both would open the row and follow the link at once.

<Demo src="table/rows" :min-height="260">

<<< @/.vitepress/demos/table/rows.tsx

</Demo>

### empty

A table with no rows still draws its headers, with one cell spanning the grid underneath. The default line is `No data`; `empty` takes anything.

<Demo src="table/empty" :min-height="180">

<<< @/.vitepress/demos/table/empty.tsx

</Demo>

### density

Changes cell padding and nothing else, so two tables of the same `size` keep the same type scale whatever their density.

<Demo src="table/density" :min-height="240">

<<< @/.vitepress/demos/table/density.tsx

</Demo>

## Accessibility

- Renders a real `<table>` with `<thead>`, `<tbody>`, `<th scope="col">` and `<td>`. A screen reader announces the column header with each cell, the row's position, and the row count.
- `caption` becomes a `<caption>`, which is the table's accessible name. A table on a page with more than one deserves it.
- A clickable row stays a `<tr>`. `role="button"` on a row reads well in isolation and takes the row semantics off it, which orphans every cell inside from the table it belongs to.
- Clickable rows carry `tabIndex={0}` and answer <kbd>Enter</kbd> and <kbd>Space</kbd>; <kbd>Space</kbd> is prevented from scrolling the page.
- The focus ring on a row is drawn inset, because the sheet clips at its own rounded edge and an outline outside the first or last row would lose its top or bottom.
- Cell padding, alignment, backgrounds and **borders** are written as inline styles, and so are the `<table>`'s own `display`, `width`, `margin` and `border-collapse`. Host stylesheets style `table`, `td` and `th` by tag name at a specificity a utility class cannot outrank: a prose stylesheet's `td { border: 1px solid }` draws a full grid of cell rules the design never asked for, its `table { display: block }` stops the grid filling the sheet, and its `table { margin: 20px 0 }` pushes the whole thing off the corner of the pane it is meant to be flush inside. This is the one component in the library that has to work around all of that.
