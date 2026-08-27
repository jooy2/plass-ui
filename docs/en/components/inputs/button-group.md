---
title: PlButtonGroup
order: 2
---

# PlButtonGroup

<p class="plass-lede">A run of buttons that belong together. The corners that face a neighbour are squared off, and <code>variant</code>, <code>size</code>, <code>color</code>, <code>density</code>, <code>elevation</code> and <code>disabled</code> are stated once for the set.</p>

<Demo src="button-group/hero" :flutter="false" :min-height="120" />

::: fw react

```tsx
import { PlButton, PlButtonGroup } from 'plass-ui';

<PlButtonGroup variant="glass" color="secondary">
  <PlButton>Day</PlButton>
  <PlButton>Week</PlButton>
  <PlButton>Month</PlButton>
</PlButtonGroup>;
```

:::

## Props

<PropsTable name="PlButtonGroup" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above.

:::

The five style axes have **no default of their own**: an axis the group does not state is one each button falls back to its own default on, so a group with no props changes nothing except the corners. A button that states an axis itself still wins — a run of secondary actions with one `danger` button in it is a real thing.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## It is not a segmented control

The buttons stay real [`PlButton`](./button)s and nothing about them is replaced: the group squares four corners and hands down six props. It does not manage selection, it has no value, and none of its buttons is ever _the chosen one_.

For one-of-a-set — a view switcher, a mode toggle — reach for [`PlSegmentedButton`](./segmented-button), which is that control and carries the roving focus and the `radiogroup` semantics that go with it.

## Examples

### variant

`glass` is the one variant with a seam to handle. It is also the only one that draws an edge, and two glass keys meeting would otherwise show both of their hairlines — twice the weight of every other edge on the page — so the second is pulled back a pixel and the two share one line.

`solid` must not do that. Its keys have no border to double up, and overlapping would put one gradient over the start of the next.

<Demo src="button-group/variants" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/button-group/variants.tsx

</Demo>

### size

Stated once, so it cannot be a size out on one button. The heights are the library's control ladder, unchanged.

<Demo src="button-group/sizes" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/button-group/sizes.tsx

</Demo>

### orientation

`vertical` stacks the run and squares the top and bottom edges instead of the sides. It is for a stacked menu of equal actions; `horizontal` is the default because that is what a toolbar is.

<Demo src="button-group/orientation" :flutter="false" :min-height="180">

<<< @/.vitepress/demos/button-group/orientation.tsx

</Demo>

### fullWidth

Stretches the group to its container and divides the width evenly between the buttons, so three actions across the bottom of a card are three equal thirds rather than three different lengths of word.

<Demo src="button-group/full-width" :flutter="false" :min-height="120">

<<< @/.vitepress/demos/button-group/full-width.tsx

</Demo>

## Accessibility

- The group is a `role="group"`. Give it an `aria-label` when the run needs a name of its own — a bar with three of these in it is three unnamed groups otherwise.
- It is **not** a `role="toolbar"` and takes no roving focus. That role is a promise about keyboard behaviour, and every button here is its own tab stop, which is what ordinary `<button>` semantics already say.
- The corners are squared with logical properties, so under RTL the first button is on the right and the flattened side follows it.
- Each button gets a stacking context, so a focus ring — drawn outside the border box — is never painted over by the neighbour that comes after it.
- `disabled` on the group disables every button in it; a button that sets `disabled` itself still wins.
