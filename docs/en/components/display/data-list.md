---
title: PlDataList
order: 20
---

# PlDataList

<p class="plass-lede">A list of labels and the values that go with them. The panel every detail screen ends with, and the whole reason it is a component is the markup: it says that "Owner" <em>names</em> "Ada Lovelace" rather than sitting beside it.</p>

<Demo src="data-list/hero" :min-height="280" />

::: fw react

```tsx
import { PlDataList, PlDataListItem } from 'plass-ui';

<PlDataList divider>
  <PlDataListItem label="Owner" value="Ada Lovelace" />
  <PlDataListItem label="Plan" value="Team" />
</PlDataList>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDataList(
  divider: true,
  children: const <Widget>[
    PlDataListItem(label: Text('Owner'), value: Text('Ada Lovelace')),
    PlDataListItem(label: Text('Plan'), value: Text('Team')),
  ],
);
```

:::

## Props

<PropsTable name="PlDataList" />

### PlDataListItem

<PropsTable name="PlDataListItem" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## One thing and its fields

Three components lay out rows of text, and they answer different questions.

|  |  |
| --- | --- |
| `PlDataList` | **One** thing and its fields. A project's owner, plan, region, created date. |
| [`PlTable`](./table) | **Many** things with the same fields. |
| [`PlList`](./list) | A run of items of the same kind, with no fields at all. |

A details panel built as a two-column table is the common mistake, and it is not a styling one: a table claims a row-and-column relationship that is not there, so a reader navigating it by cell is told there are two columns of data when there is a column of **names** and a column of **values**.

::: fw react

That is what the markup is for. It is a real `<dl>` with real `<dt>`s and `<dd>`s, each pair grouped in a `<div>` — which the HTML specification allows, and which is what lets a row be laid out side by side without giving up the grouping that makes it a pair.

:::

::: fw flutter

The Dart half of the same claim is `MergeSemantics` around each row: the label and its value are announced together. A label read on its own is a word, and a value read on its own is a fact nobody can place.

:::

## orientation

`horizontal` puts the label beside the value in a column of its own, which is the shape a details panel takes. `vertical` puts it above — for a narrow column, or for values long enough that a label beside them leaves the value nowhere to go.

<Demo src="data-list/orientation" :min-height="200">

::: fw react

<<< @/.vitepress/demos/data-list/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_list/orientation.dart

:::

</Demo>

The label column is a **fixed width** rather than the width of the longest label, and that is deliberate: two panels on one screen line up with each other, and a value does not move when somebody renames a field. `labelWidth` sets it.

::: fw react

`'12ch'` is usually the right value. A label column is measured in characters, and no ladder of `rem` can spell that.

:::

## Examples

### Rows that need a rule between them

`divider` draws a hairline between the rows — and only between them. A line above the first or below the last would be a box drawn around a list that has no box.

```tsx
<PlCard>
  <PlDataList divider>…</PlDataList>
</PlCard>
```

### A value that is not a string

The value takes anything: a chip for a status, an avatar for a person, a link for a reference.

::: fw react

```tsx
<PlDataListItem label="Status">
  <PlChip color="success">Active</PlChip>
</PlDataListItem>
```

`value` and `children` say the same thing. Use `value` for a string and `children` for markup.

:::

::: fw flutter

```dart
PlDataListItem(label: const Text('Status'), value: const PlChip(child: Text('Active')));
```

:::

## Notes

- The rows are **children rather than data**, unlike a [`PlTable`](./table)'s columns. A details panel is written out once and read in source order, and every value in it is a different shape — so a data array would be an array of `render` functions.
- It draws no surface. A details panel sits in a [`PlCard`](../surfaces/card), and a sheet inside a sheet is two sheets.
- `size` and `density` come from the list and reach every row, so a panel is one decision rather than one per line.

## Accessibility

- The label and its value are announced as a **pair**. That is the component's whole reason to exist, and it is what a grid of `<div>`s cannot do.
- An `icon` is decorative and is hidden from a screen reader: the label beside it already says what the field is.
- A label is not a heading. Naming the panel is the page's job — a `<h2>` above it, or an `aria-label` on the region it sits in.
