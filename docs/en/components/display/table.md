---
title: PlTable
order: 1
---

# PlTable

<p class="plass-lede">A grid of data on a sheet of glass. It takes columns and rows rather than markup, so the headings and the cells under them cannot drift apart.</p>

<Demo src="table/hero" :min-height="240" />

::: fw react

```tsx
import { PlTable, type PlTableColumn } from 'plass-ui';

const columns: PlTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice' },
  { key: 'customer', header: 'Customer' },
  { key: 'total', header: 'Total', align: 'end', render: (row) => `$${row.total}` }
];

<PlTable columns={columns} rows={invoices} caption="Recent invoices" hoverable />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTable<Invoice>(
  caption: const Text('Recent invoices'),
  hoverable: true,
  rows: invoices,
  columns: <PlTableColumn<Invoice>>[
    PlTableColumn<Invoice>(
      header: const Text('Invoice'),
      cell: (Invoice row, int index) => Text(row.id),
    ),
    PlTableColumn<Invoice>(
      header: const Text('Customer'),
      cell: (Invoice row, int index) => Text(row.customer),
    ),
    PlTableColumn<Invoice>(
      header: const Text('Total'),
      align: PlassAlign.end,
      cell: (Invoice row, int index) => Text(row.total),
    ),
  ],
);
```

:::

## Props

<PropsTable name="PlTable" />

::: fw react

Every native `<div>` attribute passes straight through to the sheet the grid sits on. `color` is excluded because it collides with the `color` in the table above.

`PlTable` is generic in `Row` and therefore not a `forwardRef` — a component wrapped in `React.forwardRef` loses its type parameter, and the row type is the whole point of the API. `ref` is not offered rather than being offered with `Row` widened to `any`.

:::

::: fw flutter

The table is generic in its row's type — `PlTable<Invoice>` — which is the whole point of the API: a column is handed the row, typed, and hands back a widget.

The grid is laid out by Flutter's own `Table`, which is also where the table, row, cell and column-header semantics come from. A column is measured from the content in it, exactly as a browser's automatic table layout measures one, so the same data comes out the same shape in both packages.

:::

### PlTableColumn

<PropsTable name="PlTableColumn" />

::: fw flutter

`cell` is required, which is the one real difference between the two builds. There a column names a property with `key` and the cell is `row[key]` unless `render` says otherwise; Dart has no such lookup on an arbitrary type, and a map of `dynamic` bought at the price of the row's type would be a worse bargain than writing the accessor.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

The sheet under the grid, on the same three materials as every other container, and never dyed.

There is no band behind the column names on any of them. The header is muted, semibold text over a firmer rule, and the rows under it are scored with the neutral divider ink — the same hairline a `PlCard` and a `PlList` are scored with. A filled strip across the top of a grid is the fastest way to make data look like chrome, and it puts all of a table's weight in the one place that needs none of it.

The exception is `stickyHeader`, where the fill is not decoration: rows pass directly under a pinned header and something has to stop the light.

<Demo src="table/variants" :min-height="360">

::: fw react

<<< @/.vitepress/demos/table/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/variants.dart

:::

</Demo>

### columns

::: fw react

A column names the property it reads with `key`, and `render` takes over when a cell is anything but a string or a number. `width` goes on a `<col>` rather than on the first row's cells — a width set on a `<th>` is one the browser renegotiates against every other row.

:::

::: fw flutter

A column says how to get a cell out of a row, and that is all it says: `cell` is handed the row and its position and hands back a widget.

Width comes in two forms, and they are different questions. `width` is a length in logical pixels, for the column that has to be exactly that wide — a fixed-width action column, a status pill. `flex` is a share of whatever is left after every column has room for its content, which is what the React build's `width: '30%'` actually means once a table has to add up to its own width.

:::

`align` is `start` by default. Numbers usually want `end`, so their digits line up in a column.

<Demo src="table/columns" :min-height="200">

::: fw react

<<< @/.vitepress/demos/table/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/columns.dart

:::

</Demo>

### striped and hoverable

`striped` washes every other row in `--plass-stripe`, a neutral ink rather than more glass: useful on a wide table where the eye has to track across, noise on a narrow one. `hoverable` lights the row under the pointer in the colour family's own soft tint.

<Demo src="table/striped" :min-height="260">

::: fw react

<<< @/.vitepress/demos/table/striped.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/striped.dart

:::

</Demo>

### stickyHeader and maxHeight

Two halves of one idea, and each is close to useless without the other.

`maxHeight` caps the **grid** and past it the rows scroll inside the sheet rather than the sheet growing. `stickyHeader` pins the column names to the top of what the rows are scrolling in. Capped without pinning, the names scroll away and the rest is a grid of unlabelled numbers; pinned without a cap, there is nothing for the names to stay put inside and nothing happens at all.

A `caption` sits **above** what scrolls, because a title that slid away would take the table's name with it.

A pinned header is the one place the grid draws a fill. Rows pass directly underneath it, and a translucent header would let them through: it is the sheet's densest glass over the page's own surface colour, two opaque layers stacked to stop the light.

::: fw react

`maxHeight` is a number in pixels or any CSS length. The caption is drawn as a heading outside the scroller and marked `aria-hidden`, with a real `<caption>` inside the `<table>` carrying the same words for a screen reader. Two copies of one string, and the reason is the next section: naming the table by id would mean generating one, and a component that generates an id is a client component.

The pinned header's rule is an inset shadow rather than a border, which is not a style preference: `border-collapse: collapse` hands a cell's borders to the _table's_ border grid, and that grid does not travel with a `position: sticky` cell — so a pinned header drawn with a border leaves its underline behind at the top of the scroll.

:::

::: fw flutter

`maxHeight` is a `double` in logical pixels. The scroll view is always there, so a table in a box too small for it scrolls rather than overflowing, with or without a cap.

The pinned band is **not a second grid**. Two grids measured from their own content cannot agree on a column width, so there is still one `Table` with its header row in it. The band laid over the scroll is a _copy_ of that row: each cell is boxed at the width the real header cell was laid out at. The copy is silent, because the grid already announces those names as column headers.

:::

<Demo src="table/scroll" :min-height="340">

::: fw react

<<< @/.vitepress/demos/table/scroll.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/scroll.dart

:::

</Demo>

### <Fw react="onRowClick" flutter="onRowPressed" />

Makes rows activatable, and turns on the hover treatment with it. Each row picks up a focus stop and answers <kbd>Enter</kbd> and <kbd>Space</kbd>, so a row is reachable without a pointer.

::: fw react

A key pressed inside a cell is left alone: a cell can hold a link or a button with an <kbd>Enter</kbd> of its own, and running both would open the row and follow the link at once.

:::

::: fw flutter

The row's focus stop lives in its **first cell**, which is the only place it can: a row here is not a widget — `Table` lays the cells out and paints the band and the ring behind them — so the one thing that can hold focus is a cell, and the ring it lights is the whole row.

A key pressed on a control inside a cell belongs to that control. The row's own keys are on the row's own focus stop, and a button in a cell has a focus stop of its own.

:::

<Demo src="table/rows" :min-height="260">

::: fw react

<<< @/.vitepress/demos/table/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/rows.dart

:::

</Demo>

### empty

A table with no rows still draws its headings, with the line <Fw react="in one cell spanning the grid underneath" flutter="centred under the grid" />. The default is `No data`; `empty` takes anything.

<Demo src="table/empty" :min-height="180">

::: fw react

<<< @/.vitepress/demos/table/empty.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/empty.dart

:::

</Demo>

### density

Changes cell padding and nothing else, so two tables of the same `size` keep the same type scale whatever their density.

<Demo src="table/density" :min-height="240">

::: fw react

<<< @/.vitepress/demos/table/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/density.dart

:::

</Demo>

::: fw react

## Server rendering

`PlTable` is the one component in the library with no `'use client'` on it, so a React Server Component renders the whole table — the sheet, the header, every row and every `render` callback in the columns.

That is not a size optimisation, it is the component's own API. A client boundary cannot be handed a function, and every column here _is_ a function; with the directive on, a table could not be built by the page that fetches its rows, which is the page a table belongs on. Keeping it off cost one thing, and the caption above is where it was paid.

Nothing changes for a caller on the client. A module with `'use client'` at the top that imports `PlTable` gets a client component, the way it does for everything else it imports — and `onRowClick`, which is a function, needs such a module either way.

:::

## Accessibility

::: fw react

- Renders a real `<table>` with `<thead>`, `<tbody>`, `<th scope="col">` and `<td>`. A screen reader announces the column header with each cell, the row's position, and the row count.
- `caption` becomes a `<caption>`, which is the table's accessible name. A table on a page with more than one deserves it.
- A clickable row stays a `<tr>`. `role="button"` on a row reads well in isolation and takes the row semantics off it, which orphans every cell inside from the table it belongs to.
- Clickable rows carry `tabIndex={0}` and answer <kbd>Enter</kbd> and <kbd>Space</kbd>; <kbd>Space</kbd> is prevented from scrolling the page.
- The focus ring on a row is drawn inset, because the sheet clips at its own rounded edge and an outline outside the first or last row would lose its top or bottom.
- Cell padding, alignment, backgrounds and **borders** are inline styles, and so are the `<table>`'s own `display`, `width`, `margin` and `border-collapse`. Host stylesheets style `table`, `td` and `th` by tag name, at a specificity no utility class can outrank: `td { border: 1px solid }` draws cell rules the design never asked for, `table { display: block }` stops the grid filling the sheet, and `table { margin: 20px 0 }` pushes it off the corner of the pane. Inline styles are what beat all three.

:::

::: fw flutter

- The grid is a real `Table`, so it is announced as a table with rows and cells in it, and a screen reader can move through it a cell at a time.
- A heading is announced as the column's header, which is what puts the name of the column in front of every number under it.
- `caption` is drawn at the top of the sheet and read as the line above the grid. `semanticLabel` is there for the case where the table's name has to differ from what is drawn.
- A row that answers a press keeps its row semantics: the tap action is on the cells, and nothing calls a row a button. A row announced as a button is a row whose cells have been orphaned from the table they belong to.
- The row's focus stop is in its first cell, and the ring is painted by the row itself — inset, because the sheet clips at its rounded corner and a ring outside the first or last row would come back with its top or bottom sliced off.
- Every cell is as tall as the tallest one in its row, so a row answers a press on all of itself rather than only on the line of text that happens to be longest.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `key` names the property, `render` is optional | `cell` is required | Dart has no `row[key]` on an arbitrary type. Writing the accessor is cheaper than widening the row to `dynamic`. |
| `width: number \| string` | `width: double` and `flex: double` | Pixels stay pixels; a percentage becomes a share of the leftover width, which is what a percentage of a table that must add up to its own width already was. |
| `overflow-x: auto` on the sheet | — | The grid is as wide as the sheet. Wrap it in a `SingleChildScrollView` when the columns need more room than there is. The _vertical_ scroll is the table's own either way. |
| `getRowKey` | `rowKey` | Same job, Flutter's spelling, and it hands back a `LocalKey` rather than a `React.Key`. |
| `onRowClick` | `onRowPressed` | The package's name for the thing a press calls. |
| `maxHeight: number \| string` | `maxHeight: double` | Pixels stay pixels. There is no CSS length to accept. |
| `<caption>` as the accessible name | a drawn line, plus `semanticLabel` | Flutter names a node with a string, and a caption is a widget. The words are still read first. |
| the inline-style workaround | — | There is no host stylesheet reaching in to restyle `table`, `td` and `th`, so there is nothing to work around. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
