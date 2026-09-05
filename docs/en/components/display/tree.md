---
title: PlTree
order: 17
---

# PlTree

<p class="plass-lede">A hierarchy, opened one branch at a time. It takes its nodes as data rather than as children, because a tree is recursive and recursion written in JSX is a component every caller has to write for themselves.</p>

<Demo src="tree/hero" :min-height="380" />

::: fw react

```tsx
import { PlTree, type PlTreeNode } from 'plass-ui';

const items: PlTreeNode[] = [
  { id: 'src', label: 'src', children: [{ id: 'index', label: 'index.ts' }] },
  { id: 'readme', label: 'README.md' }
];

<PlTree items={items} defaultExpanded={['src']} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const List<PlTreeNode> items = <PlTreeNode>[
  PlTreeNode(id: 'src', label: Text('src'), children: <PlTreeNode>[
    PlTreeNode(id: 'index', label: Text('index.ts')),
  ]),
  PlTreeNode(id: 'readme', label: Text('README.md')),
];

PlTree(
  items: items,
  expanded: open,
  onExpandedChanged: (Set<String> next) => setState(() => open = next),
);
```

:::

## Props

<PropsTable name="PlTree" />

### PlTreeNode

<PropsTable name="PlTreeNode" />

Every native `<div>` attribute passes straight through. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

::: fw flutter

`expanded` and `selected` are **`Set<String>`** and both are controlled. There is no uncontrolled form, which is the package's rule for every input in it. Each callback hands back the whole set rather than the one id that changed, so a caller assigns it and is done.

:::

## Examples

### selection

`single` by default. `multiple` keeps every row a click adds, and says so with `aria-multiselectable`. `none` makes the tree a **browser** rather than a chooser. Every row still expands, and a click still reports through `onItemClick`, but nothing stays lit.

<Demo src="tree/selection" :min-height="320">

::: fw react

<<< @/.vitepress/demos/tree/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree/selection.dart

:::

</Demo>

### Controlled

`expanded` and `selected` are separate, because they are separate questions: opening a folder is not choosing it.

```tsx
<PlTree
  items={items}
  expanded={open}
  onExpandedChange={setOpen}
  selected={chosen}
  onSelectedChange={setChosen}
/>
```

Both are arrays of ids, and both are uncontrolled with `defaultExpanded` / `defaultSelected`.

The twisty **turns** over the house duration rather than jumping between its two angles. It is the only thing on a row that reports whether the branch is open, so a glyph that changes angle between two frames is a state change that happened off-screen, and it is the same turn an [accordion](../surfaces/accordion)'s chevron makes, which is what tells a reader the two controls are the same kind of thing.

### A branch with nothing in it

`children: []` and `children: undefined` are **different things**, and the difference is visible: the first is a branch that opens and shows nothing, the second is a leaf with no twisty at all.

```tsx
{ id: 'empty', label: 'Archive', children: [] }   // a branch
{ id: 'file',  label: 'README.md' }               // a leaf
```

That is what makes a lazily-loaded tree possible: give a folder an empty array, and fill it in when `onExpandedChange` says it was opened.

### Opening a branch

A branch **travels** over the same 260ms an [accordion](../surfaces/accordion) or a [collapsible](../surfaces/collapsible) panel does, clipped rather than squashed while it moves. What is moving in all three cases is the page under the row somebody just pressed. Folds nest exactly: an outer branch at rest is sized to whatever it currently holds, so an inner one opening inside it is contained frame for frame with nothing to catch up to.

Nothing inside a shut branch is reachable. The rows leave the accessibility tree and the tab order the moment the fold has finished shutting, so the arrow keys walk what is visible and nothing else.

::: fw react

The rows of a shut branch are **built and not mounted**. A row dropped from the document on the frame the twisty turns has nothing to travel. React discards the elements it built, so the cost is building them rather than rendering them, and it is a cost worth knowing about for a tree with hundreds of closed folders in it. `children: undefined` until a branch is opened is the answer there, and it is the same answer as for a tree too big to send at all.

:::

::: fw flutter

A shut branch is **not built at all**: the rows come from a callback the fold only calls when there is something to show them for. That differs from the React build, where the elements are built and thrown away, and it is the one place a tree of four hundred closed folders costs less here.

:::

## Accessibility

- A real `role="tree"` of `role="treeitem"`s, with `role="group"` around the children of an open branch, and `aria-level`, `aria-expanded` and `aria-selected` on each row.
- **One tab stop for the whole tree.** It follows the focus rather than leading it, so tabbing back in returns to the row you left. A tree where <kbd>Tab</kbd> walked four hundred rows would be one nobody reaches the end of.
- <kbd>↓</kbd> and <kbd>↑</kbd> walk the rows that are actually **visible**, <kbd>→</kbd> opens a branch and then steps into it (two presses, so a reader can open a branch without leaving the row that told them it was there) <kbd>←</kbd> closes it or steps out to the parent, <kbd>Home</kbd> and <kbd>End</kbd> jump to the ends, and <kbd>Enter</kbd> or <kbd>Space</kbd> selects.
- A `disabled` row is `aria-disabled` and is not a stop for the arrow keys. It is left in the tree rather than removed, because a hierarchy with a hole in it is a hierarchy nobody can read.
- The twisty is `aria-hidden`: a screen reader is told a branch is open by `aria-expanded`, and would otherwise be told twice.

::: fw flutter

Every row is a `Semantics` node with `expanded` on a branch and `selected` on a selectable row, and the tree itself takes an `explicitChildNodes` container so the rows are not merged into one.

**One tab stop, the same way.** Every row's `FocusNode` but the current one carries `skipTraversal`, which takes it out of the Tab order while leaving it in the focus tree, so the arrow keys can still reach it. The current stop follows the focus rather than leading it.

:::
