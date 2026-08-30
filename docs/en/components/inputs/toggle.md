---
title: PlToggle
order: 16
---

# PlToggle

<p class="plass-lede">A button that stays down, and a set of them that share one state. Off is neutral, because a toggle at rest is not an action waiting to be taken — it is a state that is currently false.</p>

<Demo src="toggle/hero" :flutter="false" :min-height="180" />

::: fw react

```tsx
import { PlToggle, PlToggleGroup } from 'plass-ui';

<PlToggle pressed={bold} onPressedChange={setBold}>
  Bold
</PlToggle>;

<PlToggleGroup multiple value={marks} onValueChange={setMarks}>
  <PlToggle value="bold">Bold</PlToggle>
  <PlToggle value="italic">Italic</PlToggle>
</PlToggleGroup>;
```

:::

## Props

<PropsTable name="PlToggle" />

::: fw react

Every native `<button>` attribute passes straight through. `color` is excluded because it is a Plass prop here, and `value` because it identifies the toggle in a group rather than being submitted.

:::

### PlToggleGroup

<PropsTable name="PlToggleGroup" />

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Which control this is

- A **toggle** changes the state of the thing beside it — bold on the selected words, the grid on the canvas, the filter on the list. It is a control, and it never goes in a form.
- A [`PlSwitch`](./switch) changes a setting, and the change _is_ the point.
- A [`PlCheckbox`](./checkbox) is an answer in a form rather than a control.
- A [`PlSegmentedButton`](./segmented-button) or a [`PlRadioGroup`](./radio-group) is what a one-of-a-set **value** is. A `PlToggleGroup` without `multiple` looks like one and is not: what it holds is a state, not an answer.

## Examples

### variant

What the key is made of while it is **off**. On is always the colour family asserting itself, whichever material was asked for — and the two answers it gives are the same two a `PlSegmentedButton`'s chosen segment gives: `solid` takes the gradient and the on-fill ink, `glass` and `ghost` light the sheet and leave the label in the accent.

Off, the ink is `--plass-muted-fg` in all three and none of them is dyed. An off toggle is a piece of clear glass; the family arrives with the press and not before it.

<Demo src="toggle/variants" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/toggle/variants.tsx

</Demo>

### The elevation does not move

A toggle that is on is not a toggle that is elevated. `elevation` is the same in both states and only the colour changes, because "on" is a fact about the thing beside the toggle rather than about how far the key is off the page.

It defaults to `0`, one below a [`PlButton`](./button)'s, for the same reason.

### size

The control ladder, unchanged: a `md` toggle is 40px and lines up with the field and the button beside it. `density` moves the padding and nothing else.

<Demo src="toggle/sizes" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/toggle/sizes.tsx

</Demo>

### PlToggleGroup

Two things are happening and only one of them is visual. The corners facing a neighbour are squared off — that is the look. The other half is that the set owns the value: the toggles report into one array, and `variant`, `size`, `color`, `density`, `elevation` and `disabled` are set once on the group rather than on every toggle.

The value is an **array in both cases**, which is the one shape that does not change type when `multiple` is turned on.

<Demo src="toggle/group" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/toggle/group.tsx

</Demo>

### An icon and no label

Left out, `children` makes the toggle go square around whatever icon it was given — which is what a toolbar toggle is. It still needs an `aria-label`: a control whose whole label is a drawing has no accessible name at all.

<Demo src="toggle/icons" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/toggle/icons.tsx

</Demo>

## Accessibility

- Base UI renders a real `<button>` with `aria-pressed`, which is what says "this is a state" rather than "this does something".
- A `PlToggleGroup` is one tab stop with the arrow keys moving between its members, which is what makes a toolbar of eight toggles two key presses deep instead of eight. `loopFocus` decides whether the arrows wrap at the ends.
- An icon-only toggle needs an `aria-label`. Nothing else can name it.
- `disabled` takes the toggle out of the tab order. A group's `disabled` does it to every member at once.
- The pointer light is off while the toggle is disabled, so a surface nobody can press does not answer the pointer.
