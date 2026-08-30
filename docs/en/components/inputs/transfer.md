---
title: PlTransfer
order: 17
---

# PlTransfer

<p class="plass-lede">Two lists and the arrows between them: everything that could be chosen on one side, everything that has been on the other. Ticking is not choosing — the ticks say what the next press will move.</p>

<Demo src="transfer/hero" :flutter="false" :min-height="320" />

::: fw react

```tsx
import { PlTransfer } from 'plass-ui';

<PlTransfer
  items={columns}
  value={value}
  onValueChange={setValue}
  sourceLabel="Available columns"
  targetLabel="In the report"
/>;
```

:::

## Props

<PropsTable name="PlTransfer" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it is a Plass prop here, `defaultValue` because the pair spells it as a list of values, and `onChange` because the pair reports through `onValueChange`.

:::

### PlTransferItem

<PropsTable name="PlTransferItem" />

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## When this is the right control

For a choice that is **long**. A [`PlCombobox`](./combobox) with forty chips in its field stops being readable, and a list of forty checkboxes gives no answer to "what did I actually pick".

Below about a dozen options, one of those two is the smaller component. This one costs a reader two lists and a pair of arrows; it is worth it exactly when the answer is itself worth reading back.

## Ticking is not choosing

`value` is which side a row is on. The **ticks** are which rows the next press will move, and they are a separate piece of state on purpose: keeping them apart is what makes a press a deliberate act rather than a side effect of reading down a list.

Three things follow from it:

- The order of `items` is the order **both** lists show, so a row does not move when it is sent across and back.
- Moving drops the ticks on what moved and keeps the rest. A row that has arrived on the other side is not still waiting to be sent there.
- A row the filter was hiding was never part of that press.

## Examples

### searchable

Puts a filter above each list, and each one narrows only its own side.

The fold is case- and accent-insensitive — `cafe` finds `Café` — and it is the library's one answer to "this matches what I typed", shared by every filter in it. A reader who has learned what one search box in a product does has learned the right thing about the next one.

A label that is a node rather than a string has no text to match and **stays**. The alternative is a row that disappears from a filter it could never satisfy.

<Demo src="transfer/searchable" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/transfer/searchable.tsx

</Demo>

### variant

The two panels wear the **field** shell rather than the sheet one, because a list that holds a value is a field-shaped thing: `solid` is the well, `glass` the hairline pane, `ghost` no surface until the pointer arrives. The arrows follow — they are `glass` beside a panel that has an edge, and `ghost` beside one that has none.

Neither panel is dyed. What they hold is somebody's data, and the family reaches the ticks, the arrows and the focus rings.

<Demo src="transfer/variants" :flutter="false" :min-height="420">

<<< @/.vitepress/demos/transfer/variants.tsx

</Demo>

### A row that cannot move

`disabled` on an item leaves it in the list and takes it out of every press, including the heading's select-all — which is why that tick reports three of four rather than four of four. An option that vanished when it could not be chosen is an option the reader will look for.

`disabled` on the pair stops everything at once.

<Demo src="transfer/states" :flutter="false" :min-height="400">

<<< @/.vitepress/demos/transfer/states.tsx

</Demo>

### Controlled

Pass `value` with `onValueChange`. The value is the list of `value`s on the trailing side, in `items` order — not the objects: a transfer is a form control, and what it holds is what the form submits. Keep the identifiers here and look the objects up on the other side.

## Accessibility

- Every row is a real [`PlCheckbox`](./checkbox) with the row's label as its name, so a screen reader reads the list as the list of checkboxes it is.
- The tick in each heading is a checkbox too, named by `selectAllLabel`, and it reports `indeterminate` when only some of its list is ticked.
- The two arrows are [`PlIconButton`](./icon-button)s with real names, and they are disabled until a press would actually move something — the state a reader can see, made available to one who cannot.
- Each list has its own count (`ticked/total`) beside its heading, which is the answer to "how much did I just select" without counting rows.
- The lists scroll on their own and hold their scroll position, so moving a row does not throw a reader back to the top.
