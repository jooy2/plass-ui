---
title: PlRadioGroup
order: 7
---

# PlRadioGroup

<p class="plass-lede">A set of options where exactly one is chosen. The set takes a single tab stop and the arrow keys move within it.</p>

<Demo src="radio-group/hero" :min-height="240" />

```tsx
import { PlRadio, PlRadioGroup } from 'plass-ui';

<PlRadioGroup label="Plan" defaultValue="team">
  <PlRadio value="starter" label="Starter" />
  <PlRadio value="team" label="Team" />
</PlRadioGroup>;
```

## Props

<PropsTable name="PlRadioGroup" />

Every other prop on Base UI's `RadioGroup` passes straight through. `className` and `style` land on the field wrapper; `render` is not offered.

### PlRadio

<PropsTable name="PlRadio" />

`size` and `color` are read from the `PlRadioGroup` around the option, not set on it: a radio button says nothing on its own, so how it looks belongs to the set. Passing them per option would be four chances to get one of them wrong.

What the shared axes (`size` `color` `orientation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### orientation

Vertical by default. A column of options is scannable at any length; a row silently becomes unreadable the moment one label is longer than expected.

<Demo src="radio-group/orientation" :min-height="280">

<<< @/.vitepress/demos/radio-group/orientation.tsx

</Demo>

### color

Chosen, the dot fills with the family's gradient and the inner disc is the family's own `on-solid` ink. The dot is round, and one of only two round things in the library: roundness is exactly what tells a reader "one of these" rather than "any of these", and it is the one convention old enough that breaking it would cost more than it bought.

<Demo src="radio-group/colors" :min-height="180">

<<< @/.vitepress/demos/radio-group/colors.tsx

</Demo>

### size

Set on the group and inherited by every option, so a set cannot end up with two dot sizes in it.

<Demo src="radio-group/sizes" :min-height="180">

<<< @/.vitepress/demos/radio-group/sizes.tsx

</Demo>

### readOnly · disabled · error

`disabled` on the group stops every option; on one `PlRadio` it stops only that one, and the option stays in the list — an option that vanishes when it cannot be chosen is an option the reader will look for.

`error` on the group also turns it invalid, which re-points the whole colour family at `danger`.

<Demo src="radio-group/states" :min-height="260">

<<< @/.vitepress/demos/radio-group/states.tsx

</Demo>

### Controlled

Pass `value` with `onValueChange`. The value is whatever a `PlRadio` was given — usually a string, but Base UI compares by identity, so anything works as long as it is stable between renders.

<Demo src="radio-group/controlled" :min-height="180">

<<< @/.vitepress/demos/radio-group/controlled.tsx

</Demo>

## Accessibility

- Base UI renders a `role="radiogroup"` holding real radios, keeps `aria-checked` in step, and owns the roving tab index — the set takes one tab stop and <kbd>↑</kbd> <kbd>↓</kbd> <kbd>←</kbd> <kbd>→</kbd> move within it. That is the whole reason a radio group is a component rather than a `<div>` full of inputs.
- The group's `label`, `description` and `error` are wired to it by Base UI's Field, and so is each option's own label — pressing a label chooses its option.
- Each dot is centred on its label's **first** line, so it stays put when a label wraps.
- A chosen dot is a filled disc, not a colour change alone: the shape carries the state for a reader who cannot see the fill.
- With `name`, Base UI renders the hidden input that makes the choice part of a native form submission.
