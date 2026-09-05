---
title: PlTreeSelect
order: 22
---

# PlTreeSelect

<p class="plass-lede">A value chosen out of a hierarchy rather than out of a list. A <code>PlTree</code> behind a field, for a category, a folder, a region or an org chart node — the shapes a flat list flattens away.</p>

<Demo src="tree-select/hero" :min-height="220" />

::: fw react

```tsx
import { PlTreeSelect, type PlTreeSelectNode } from 'plass-ui';

const items: PlTreeSelectNode[] = [
  {
    id: 'europe',
    label: 'Europe',
    children: [{ id: 'france', label: 'France' }]
  },
  { id: 'antarctica', label: 'Antarctica' }
];

<PlTreeSelect items={items} label="Region" placeholder="Pick a region" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeSelectNode> items = <PlTreeSelectNode>[
  PlTreeSelectNode(
    id: 'europe',
    label: 'Europe',
    children: <PlTreeSelectNode>[PlTreeSelectNode(id: 'france', label: 'France')],
  ),
  PlTreeSelectNode(id: 'antarctica', label: 'Antarctica'),
];

PlTreeSelect(
  items: items,
  label: const Text('Region'),
  value: chosen,
  onValueChanged: (Set<String> next) => setState(() => chosen = next),
);
```

The popup lifts itself out of the tree, so a tree select needs an `Overlay` above it — `WidgetsApp` with a navigator and `MaterialApp` both provide one.

:::

## Props

<PropsTable name="PlTreeSelect" />

### PlTreeSelectNode

<PropsTable name="PlTreeSelectNode" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the picker spells it as a list of ids rather than as a DOM attribute, and `children` because the tree is `items`.

A `className` lands on the stack that holds the label, the control and the two lines under it. `classNames` reaches the four parts inside it: `label`, `control`, `description` and `error`.

:::

::: fw flutter

`value` is a **`Set<String>`** and it is controlled — there is no uncontrolled form, which is the package's rule for every input in it. `expanded` and `open` are the two exceptions: leave either out and the picker keeps it itself.

A node's `label` is a **`String`** here and a `ReactNode` in React, which is the divergence `PlTransferItem` already carries. The filter reads the label, the trigger writes it and a screen reader is handed it, so text is what keeps every node searchable by construction. That is also why there is no `searchLabel` on this side: the label is already the words.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### searchable

A field above the tree that filters it. A match keeps **its ancestors** — a "Seoul" under nothing at all does not say which taxonomy it came out of — and every branch the filter kept is opened, since a match folded inside a shut parent is a match nobody was shown.

<Demo src="tree-select/searchable" :min-height="220">

::: fw react

<<< @/.vitepress/demos/tree-select/searchable.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_select/searchable.dart

:::

</Demo>

Clearing the field hands the folds back to the reader: the branches they had opened are still open, and the ones the filter opened are shut again.

::: fw react

The fold is accent- and case-insensitive, so `jose` finds `José`.

:::

::: fw flutter

The fold is case-insensitive. It does **not** strip accents, because Dart's core has no `String.normalize` and this package has no dependencies — the React build folds accents as well.

:::

### selectableBranches

Off by default, which is the shape most of these trees have: the branches are the taxonomy and the leaves are the answers. A branch that cannot be chosen still opens and closes — pressing it is how you get at what is under it.

<Demo src="tree-select/branches" :min-height="220">

::: fw react

<<< @/.vitepress/demos/tree-select/branches.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_select/branches.dart

:::

</Demo>

A node's own `selectable` overrides it either way, so a "Home" that is a real category can be chosen while the rest of the branches stay roads.

### multiple

Every node a press adds is kept, and the trigger writes them comma-joined. The popup stays open, because a picker that shut after the first of several answers would have to be reopened for each of the rest.

<Demo src="tree-select/multiple" :min-height="220">

::: fw react

<<< @/.vitepress/demos/tree-select/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_select/multiple.dart

:::

</Demo>

`format` takes the chosen nodes and writes them however you like, for a trigger that stops growing with its answer.

```tsx
<PlTreeSelect items={items} multiple format={(chosen) => chosen.length + ' regions'} />
```

### Controlled

The value, the folds and the popup are three separate questions, and each has its own pair.

```tsx
<PlTreeSelect
  items={items}
  value={chosen}
  onValueChange={setChosen}
  expanded={open}
  onExpandedChange={setOpen}
/>
```

Opening a folder is not choosing it, which is why the second pair exists at all.

### In a form

`name` puts one `<input type="hidden">` on the page per held id, so a `multiple` picker submits as a repeated field.

```tsx
<PlTreeSelect items={items} multiple name="region" defaultValue={['france', 'spain']} />
```

## Accessibility

- The trigger is a button, exactly as every other picker's is, and it carries the label, the description, the error and `aria-invalid`.
- What is inside the popup is a real [`PlTree`](../display/tree) — `role="tree"` of `role="treeitem"`s, `aria-level`, `aria-expanded`, `aria-selected`, and **one tab stop** for the whole thing.
- <kbd>↓</kbd> and <kbd>↑</kbd> walk the rows that are visible, <kbd>→</kbd> opens a branch and steps into it, <kbd>←</kbd> closes it or steps out, and <kbd>Enter</kbd> or <kbd>Space</kbd> chooses.
- A node that cannot be chosen is not marked `aria-disabled` when it is only a branch: it is still an operable row, because pressing it opens what is under it. A `disabled` node is marked, and is not a stop for the arrow keys.
- The filter field names itself with `searchLabel`, so it is announced without a visible label above it.
