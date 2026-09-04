---
title: PlDataTable
order: 21
---

# PlDataTable

<p class="plass-lede">A table that owns its rows. It sorts them, narrows them to what was typed, hands them out a page at a time and remembers which of them are ticked — and draws exactly the grid <code>PlTable</code> draws, because both draw it out of one place.</p>

<Demo src="data-table/hero" :min-height="440" />

::: fw react

```tsx
import { PlDataTable, type PlDataTableColumn } from 'plass-ui';

const columns: PlDataTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice', sortable: true },
  { key: 'customer', header: 'Customer', sortable: true },
  { key: 'total', header: 'Total', align: 'end', sortable: true }
];

<PlDataTable
  columns={columns}
  rows={invoices}
  getRowKey={(row) => row.id}
  searchable
  selection="multiple"
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDataTable<Invoice>(
  rows: invoices,
  rowKey: (Invoice row, int index) => row.id,
  searchable: true,
  selection: PlDataTableSelection.multiple,
  columns: <PlDataTableColumn<Invoice>>[
    PlDataTableColumn<Invoice>(
      key: 'customer',
      header: const Text('Customer'),
      sortable: true,
      value: (Invoice row) => row.customer,
      cell: (Invoice row, int index) => Text(row.customer),
    ),
  ],
);
```

:::

## Which of the two to reach for

[`PlTable`](table) draws a grid it is given. Reach for it when the rows are already in the order they belong in — a summary, a receipt, a comparison, anything the reader is not going to interrogate. <span v-pre>It renders on a server, which this cannot.</span>

`PlDataTable` is for the table a reader works on: the one they sort, search, tick and page through. Every one of those is a decision that has to be remembered between renders, which is what makes it a client component and `PlTable` not one.

Below the columns they are **the same grid** — the measured column widths, the hover band, the rule between rows, the pinned header — because both are drawn from one internal module. A sorted table and a plain one on the same page cannot come out a shade apart.

## Props

<PropsTable name="PlDataTable" />

::: fw react

Every native `<div>` attribute passes straight through to the sheet. `color` and `onSelect` are excluded because they collide with the props above.

Generic in `Row` and therefore not a `forwardRef`, for `PlTable`'s reason: a component wrapped in `React.forwardRef` loses its type parameter, and the row type is the whole point of the API.

:::

::: fw flutter

Generic in its row's type — `PlDataTable<Invoice>` — so a column is handed the row, typed, and hands back a widget.

The uncontrolled starting values are named `initialSort`, `initialSearch`, `initialSelected` and `initialPage` rather than `default…`, which is Flutter's own convention and the one every other widget in this package follows.

:::

### PlDataTableColumn

<PropsTable name="PlDataTableColumn" />

::: fw flutter

`cell` is required for `PlTableColumn`'s reason: Dart has no `row[key]` on an arbitrary type. `value` is the other half of the same problem — the sort and the search cannot read a widget, so a sortable or searchable column says what it holds.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Controlled, or not

Sort, search, selection and page are each **uncontrolled by default and controllable one at a time**. Pass the value and the table draws what it is told; leave it out and the table keeps it.

That is not four separate conveniences, it is what makes one component cover both of the tables people build. The ordinary table is the markup at the top of this page. A table backed by a server is the same markup with `manual` and the handlers, and nothing in between changes shape.

## Examples

### Sorting

A `sortable` column's heading becomes a control: ascending, descending, then **back to the order the rows arrived in**. That third press is the part most tables leave out, and it matters — the arrival order is usually the order the server chose, and a table that can never be put back has thrown it away.

The mark is drawn faintly on every sortable heading rather than appearing on hover. A heading that only looks pressable once the pointer is on it is a heading nobody presses.

Values are compared as what they are: numbers numerically, dates by the moment they name, and **nothing sorts last in both directions** — a column of amounts with three blanks in it is a column whose blanks are not the smallest amounts, and a reader who reversed the sort to find the largest should not be handed the empty ones instead.

::: fw react

Text is compared with `localeCompare`, so `apple` comes before `Banana` and `Ösi` before `Zoe`. Sorting by code point puts every capitalised word above every lower-case one, which is a list a reader cannot scan.

:::

::: fw flutter

Text is compared case-insensitively, so `apple` comes before `Banana`. **Accents are not folded**, and the reason is the one `PlTransfer`'s search gives: Dart's core has no `String.normalize` and this package has no dependencies, so an `Ö` sorts where its code point puts it. The React build uses `localeCompare` and gets it right.

:::

`compare` takes over for a column whose order is its own. The direction is applied to whatever it returns, so a caller's comparator reverses the way the built-in one does rather than having to know which way round it is being asked.

<Demo src="data-table/sorting" :min-height="320">

::: fw react

<<< @/.vitepress/demos/data-table/sorting.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/sorting.dart

:::

</Demo>

### value, and why a drawn cell needs one

`render` decides what a reader sees. `value` decides what the sort and the search see. Most columns need neither — the cell is the property and that is what is compared and matched.

The moment a cell is _drawn_ rather than printed, the two come apart. A status column showing a chip has no text to search and no order to sort; a total column printing `$1,240.00` sorts as a string, which puts `$89` after `$1,240`. `value` is where the column says what it actually holds.

::: fw flutter

Every sortable or searchable column needs `value` here, not only a drawn one: `cell` returns a widget in all cases.

:::

### Selection

`single` keeps one row; `multiple` adds a tick-everything box at the top of the column. Both hand back the **keys** and the **rows** — out of every row the table has, not only the page on screen, so a selection that survived paging hands back what it survived on.

The header box goes indeterminate when part of the page is chosen. A half-filled page under a plain unticked box reads as "nothing here is chosen", which is the opposite of what is true.

Shift extends the selection from the last row pressed to this one, in the order the rows are **currently** in — which is what a reader dragging down a sorted page means by "these". `isRowSelectable` keeps a row out of the selection and out of the tick-everything with it.

::: fw react

A chosen row carries `aria-selected` as well as the tint. A row that is visibly tinted and silently unselected is a row a screen reader disagrees with the screen about.

A press on the tick is a press on the tick: it does not also activate the row, so `selection` and `onRowClick` can be on the same table.

:::

::: fw flutter

The row's tick carries the state a screen reader reads; the tint is what a sighted reader sees. Flutter's `Table` has no row-level selected flag to set, and a `Semantics(selected: true)` on each cell would announce it once per column.

Shift is read off the hardware keyboard, so the range gesture is there on a desktop or the web and simply does not arise on a touch device.

:::

<Demo src="data-table/selection" :min-height="360">

::: fw react

<<< @/.vitepress/demos/data-table/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/selection.dart

:::

</Demo>

### Search

`searchable` draws a field above the grid, inside the sheet. It matches against every column's `value`, folded once per keystroke rather than once per row per column — the same matcher `PlTransfer` and `PlCommandPalette` use, so a reader who has learned what the filter does in one part of a product has learned it for the rest.

`unsearchable` takes a column out of it. Right for a column of identifiers nobody types, where a match is a row the reader cannot see the reason for.

::: fw react

Case and accents are both folded, so `jose` finds `José`.

:::

::: fw flutter

Case is folded; accents are not, for the reason given under sorting.

:::

### Paging

`scroll` is the default and hands out every row. Pair it with `maxHeight` and they scroll inside the sheet.

`pages` cuts a slice and puts a [`PlPagination`](../inputs/pagination) in the footer, with the count beside it. Right when a row's position in the whole set is information — a ledger, an audit log — and the only honest option when the rows are fetched a page at a time.

Sorting or searching sends the reader **back to the first page**. Page nine of a different set of rows is not where they were.

<Demo src="data-table/paging" :min-height="440">

::: fw react

<<< @/.vitepress/demos/data-table/paging.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/paging.dart

:::

</Demo>

### manual: when the server does the work

Naming a stage in `manual` means the rows arriving have already had it done to them. The table reports what the reader asked for and draws what it is handed, rather than sorting an already-sorted page or filtering a page that is one tenth of the data.

`rowCount` goes with `manual` paging, and it has to: a table holding ten rows out of ninety has no way to know that the pager should offer nine pages.

<Demo src="data-table/server" :min-height="320">

::: fw react

<<< @/.vitepress/demos/data-table/server.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/server.dart

:::

</Demo>

### loading

Bars in place of the rows, as many as a page holds, so the grid does not change height when the data arrives. A table that grows under the pointer is a table where the row somebody was about to press moves out from under them.

::: fw react

The grid carries `aria-busy` while it waits.

:::

<Demo src="data-table/loading" :min-height="260">

::: fw react

<<< @/.vitepress/demos/data-table/loading.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/loading.dart

:::

</Demo>

### toolbar and footer

Two slots inside the sheet, above the grid and below it, on the same rules the caption sits on. `toolbar` is where a filter or a bulk action goes, beside the search field. `footer` replaces the row count at the start of the pager's row.

They are inside the sheet rather than floating above and below it because they belong to the table: a "Delete 3" button that is not visibly part of the grid it is going to act on is a button whose scope the reader has to guess.

## What it deliberately does not do

**It does not virtualize.** A hundred thousand rows in one DOM is a slow page whichever component draws it, and the honest answer is `paging="pages"`, which is also the only shape that works when the rows are being fetched. A virtualized body is a different component with a different bargain — fixed row heights, a scrollbar that lies about its length — and hiding that inside this one would make every table pay for it.

**It does not resize or reorder columns by dragging.** Both are real features and both belong to a table an application has built _on_ this one: they need somewhere to persist what the reader dragged, and a component that forgets the widths on every mount has given the reader a toy.

**It does not export.** Turning rows into a file is the application's data and the application's filename, and it is three lines beside the table rather than a prop on it. `toolbar` is where the button goes.

**It sorts on one column.** A sort three keys deep is a query, and a reader looking at the table cannot see the third key or work out why two rows are in the order they are in. An application that genuinely needs one owns the sort with `manual` and says so in its own words.

## Accessibility

::: fw react

- Renders a real `<table>` with `<thead>`, `<tbody>`, `<th scope="col">` and `<td>` — the same markup `PlTable` renders, and the same reasons behind every inline style on it.
- A sortable column announces its direction with `aria-sort` **on the heading**, not on the button inside it: the heading is what a screen reader reads when it enters a cell in that column, and a state on the button would only be heard by a reader who happened to land on the button.
- The sort control is a bare `<button>` wearing the heading's own type. A `PlButton` here would be a control on a control, bringing a background, a radius and a height into a cell whose job is to sit flush against the rule under it.
- Its focus ring is inset, because the sheet clips at its rounded corner and a ring outside the first heading would have its top sliced off.
- A chosen row carries `aria-selected`; each tick is named by the locale's `selectRow` and the header's by `selectAll`.
- The grid carries `aria-busy` while `loading`.
- `caption` is drawn above the sheet and marked `aria-hidden`, with a real `<caption>` inside the table carrying the same words. A caption that scrolled away would take the table's accessible name with it.

:::

::: fw flutter

- The grid is a real `Table`, announced as a table with rows and cells, and every heading is announced as the column's header.
- **A sorted heading says its direction out loud**, as its semantics value. That is the one place the two builds differ in kind rather than in spelling: `aria-sort` is a platform affordance every screen reader speaks in the reader's own language, and Flutter's semantics have no equivalent — so the word has to be said, and a word that is said has to be translated. `sortedAscending` and `sortedDescending` are in [the label set](../../guide/locales) here and are not in the React one.
- The tick in a row carries whether the row is chosen; the tint is what a sighted reader sees.
- The pinned header band is silent, because the row it copies is not.
- The row's focus stop is in its first cell and the ring is painted by the row — inset, for the sheet's rounded corner.

:::

## Notes

- **`getRowKey` before anything else.** Everything the table remembers is remembered _by key_: the selection, the range anchor, the identity React and Flutter reconcile rows by. Defaulting to the index is right for a static table and wrong for this one — sorting moves a row and its index stays behind.
- **`onSelectedChange` hands back rows from every page**, not from the page on screen. A selection made across three pages is three pages of rows.
- **The search, the sort and the page are computed in that order**, so a page is a page of the narrowed, ordered set rather than a page of the raw rows with a filter applied afterwards.
