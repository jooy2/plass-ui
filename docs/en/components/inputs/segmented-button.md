---
title: PlSegmentedButton
order: 10
---

# PlSegmentedButton

<p class="plass-lede">Two or more choices in one pill, exactly one of them taken. The tile slides from the segment you left to the one you chose.</p>

<Demo src="segmented-button/hero" :min-height="120" />

```tsx
import { PlSegment, PlSegmentedButton } from 'plass-ui';

<PlSegmentedButton aria-label="Period" value={period} onValueChange={setPeriod}>
  <PlSegment value="day">Day</PlSegment>
  <PlSegment value="week">Week</PlSegment>
</PlSegmentedButton>;
```

## Props

<PropsTable name="PlSegmentedButton" />

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, `defaultValue` and `onChange` because the set spells them `defaultValue` (a segment value) and `onValueChange`.

### PlSegment

<PropsTable name="PlSegment" />

`variant`, `size` and `density` are read from the `PlSegmentedButton` around the segment, not set on it. A segmented button whose third segment is a size out is not a segmented button.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Segmented button, tabs or select?

- **Segmented button** — a handful of short, mutually exclusive choices that filter what is already on screen: a period, a scope, a layout.
- **Tabs** — the choice swaps whole panels of content.
- **Select** — more than about five options, or long ones.

## Examples

### variant

The groove carries `--plass-well`, the one inset shadow in the library and the same one a `solid` field is drawn with: a segmented button, a slider's rail and a filled text field are the same idea — something recessed that holds a value.

`solid` puts the family's gradient in the tile with that family's tinted shadow under it, which is the design language's own sentence with nothing added: a key of tinted glass riding in a groove. `glass` and `ghost` lift a pane of clear glass instead and leave the label in the accent.

<Demo src="segmented-button/variants" :min-height="220">

<<< @/.vitepress/demos/segmented-button/variants.tsx

</Demo>

### color

<Demo src="segmented-button/colors" :min-height="220">

<<< @/.vitepress/demos/segmented-button/colors.tsx

</Demo>

### size

The same height ladder as `PlButton`, so a segmented button in a toolbar lines up with the buttons beside it.

<Demo src="segmented-button/sizes" :min-height="240">

<<< @/.vitepress/demos/segmented-button/sizes.tsx

</Demo>

### fullWidth

The segments share the row and take an equal part of it each. The tile is re-measured on resize, so it stays under its segment while the container changes width.

<Demo src="segmented-button/full-width" :min-height="120">

<<< @/.vitepress/demos/segmented-button/full-width.tsx

</Demo>

### startIcon and endIcon

Both are sized in `em`, so they track the label. An icon-only segment still needs an `aria-label`.

<Demo src="segmented-button/icons" :min-height="120">

<<< @/.vitepress/demos/segmented-button/icons.tsx

</Demo>

## Accessibility

- The set is a `role="radiogroup"` and each segment is a real radio, which is the whole accessibility argument: a segmented button **is** "exactly one of these". Built out of `aria-pressed` toggles it would announce four independent switches, three of which happen to be off.
- One tab stop for the whole set; <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd> move within it. Base UI owns the roving tab index.
- Give the set an `aria-label`. It has no visible label of its own, and a group with no name is a group a screen reader announces as "radio group".
- The focus ring is drawn **inset**, because an offset ring on a segment inside a groove would be painted over its neighbours.
- The tile animates `left`, `top`, `width` and `height` rather than a `transform`: it is an empty box, so no label is resampled while it travels. That is what lets the house no-transform rule survive a component whose entire point is that something moves.
- The first choice of an empty set appears **in place** rather than flying in from the left edge — the tile is not mounted until there is something to sit under.
