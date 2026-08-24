---
title: PlChip
order: 10
---

# PlChip

<p class="plass-lede">A compact token: a tag, a filter, a status, an entity plucked out of a list. It can carry a count, be pressed, be removed, or all three at once.</p>

<Demo src="chip/hero" :min-height="180" />

```tsx
import { PlChip } from 'plass-ui';

<PlChip>design</PlChip>;
<PlChip selected onClick={toggle} count={12}>
  open
</PlChip>;
<PlChip onDelete={remove}>infra</PlChip>;
```

## Props

<PropsTable name="PlChip" />

Every native `<span>` attribute passes straight through, onto the shell. `color` is excluded from the pass-through because it is a Plass prop here.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### onClick and onDelete

The shell is always a `<span>`. What changes is what is inside it: a plain run of content, or — when `onClick` is given — a real `<button>` wrapping that content, plus a second button for `onDelete`.

That is not indirection. A `<button>` inside a `<button>` is invalid HTML that browsers un-nest on parse, so keeping the shell a `<span>` is what lets "activate this chip" and "remove this chip" both be real, focusable buttons.

<Demo src="chip/interactive" :min-height="140">

<<< @/.vitepress/demos/chip/interactive.tsx

</Demo>

### variant

A chip **is** the thing being coloured — a tag names one particular thing — so unlike a `PlCard` its sheet takes the tint.

`glass` is the default rather than `solid`. A filter bar is a row of chips, and a row of gradient keys is a row in which nothing is the primary action because everything is.

<Demo src="chip/variants" :min-height="120">

<<< @/.vitepress/demos/chip/variants.tsx

</Demo>

### selected

Chosen moves the chip one step up the ladder its own variant already sits on, rather than changing the colour family: a filter that is on is still the same filter.

`solid` has no opacity ladder to climb, because a gradient fill is the fill. So it answers the other way the design language allows — it casts its own colour onto the sheet under it. A chosen key lifts; an unchosen one lies flat.

<Demo src="chip/selected" :min-height="200">

<<< @/.vitepress/demos/chip/selected.tsx

</Demo>

### startIcon, endIcon and count

`count` is drawn on its own small plate, so "Errors 12" reads as one token with a count rather than as two words.

<Demo src="chip/slots" :min-height="120">

<<< @/.vitepress/demos/chip/slots.tsx

</Demo>

### color

<Demo src="chip/colors" :min-height="120">

<<< @/.vitepress/demos/chip/colors.tsx

</Demo>

### size

A chip sits one step down the control ladder from everything else: a `md` chip is a `sm` control, 32px rather than 40px. At full control height a `glass` chip and a `glass` button are the same object, and a screen full of them says nothing about which one can be pressed.

<Demo src="chip/sizes" :min-height="120">

<<< @/.vitepress/demos/chip/sizes.tsx

</Demo>

## Accessibility

- A chip with `onClick` is a real `<button>` carrying `aria-pressed`, so a filter that is on says so. A chip without one adds no role and takes no tab stop — an inert `<span>` with a click handler on it is the single most common way a component library loses its keyboard users.
- The label and the delete button are two separate tab stops, and neither is nested inside the other.
- The delete button has an accessible name already; `deleteLabel` is what changes it.
- `disabled` stops the label from being a button at all rather than leaving a focusable one that does nothing, and marks the shell `aria-disabled` so the state is still announced.
