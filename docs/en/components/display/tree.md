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

## Props

<PropsTable name="PlTree" />

### PlTreeNode

<PropsTable name="PlTreeNode" />

Every native `<div>` attribute passes straight through. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### selection

`single` by default. `multiple` keeps every row a click adds, and says so with `aria-multiselectable`. `none` makes the tree a **browser** rather than a chooser — every row still expands, and a click still reports through `onItemClick`, but nothing stays lit.

<Demo src="tree/selection" :min-height="320">

::: fw react

<<< @/.vitepress/demos/tree/selection.tsx

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

### A branch with nothing in it

`children: []` and `children: undefined` are **different things**, and the difference is visible: the first is a branch that opens and shows nothing, the second is a leaf with no twisty at all.

```tsx
{ id: 'empty', label: 'Archive', children: [] }   // a branch
{ id: 'file',  label: 'README.md' }               // a leaf
```

That is what makes a lazily-loaded tree possible: give a folder an empty array, and fill it in when `onExpandedChange` says it was opened.

## Accessibility

- A real `role="tree"` of `role="treeitem"`s, with `role="group"` around the children of an open branch, and `aria-level`, `aria-expanded` and `aria-selected` on each row.
- **One tab stop for the whole tree.** It follows the focus rather than leading it, so tabbing back in returns to the row you left. A tree where <kbd>Tab</kbd> walked four hundred rows would be one nobody reaches the end of.
- <kbd>↓</kbd> and <kbd>↑</kbd> walk the rows that are actually **visible**, <kbd>→</kbd> opens a branch and then steps into it — two presses, so a reader can open a branch without leaving the row that told them it was there — <kbd>←</kbd> closes it or steps out to the parent, <kbd>Home</kbd> and <kbd>End</kbd> jump to the ends, and <kbd>Enter</kbd> or <kbd>Space</kbd> selects.
- A `disabled` row is `aria-disabled` and is not a stop for the arrow keys. It is left in the tree rather than removed, because a hierarchy with a hole in it is a hierarchy nobody can read.
- The twisty is `aria-hidden`: a screen reader is told a branch is open by `aria-expanded`, and would otherwise be told twice.
