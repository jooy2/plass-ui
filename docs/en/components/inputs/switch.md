---
title: PlSwitch
order: 8
---

# PlSwitch

<p class="plass-lede">An immediate on/off. The track is a groove cut into the sheet while it is off, and the colour family's gradient once it is on.</p>

<Demo src="switch/hero" :min-height="160" />

```tsx
import { PlSwitch } from 'plass-ui';

<PlSwitch label="Dark mode" checked={dark} onCheckedChange={setDark} />;
```

## Props

<PropsTable name="PlSwitch" />

Every other prop on Base UI's `Switch.Root` passes straight through. `className` and `style` land on the field wrapper rather than on the track, and `render` is not offered.

There is no `variant`, for the reason a `PlCheckbox` has none: on and off are not two strengths of one material.

What the shared axes (`size` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Switch or checkbox?

The difference is not visual, it is **temporal**. A checkbox is a value that gets submitted with a form; a switch takes effect the moment it moves. If there is a Save button underneath, it should have been a checkbox.

## Examples

### color

On, the track is the family's gradient with that family's tinted shadow under it. The thumb keeps the page's own surface colour in both states: it is the light on the track, not a second coloured object, and a coloured thumb on a coloured track is two things fighting over sixteen pixels.

<Demo src="switch/colors" :min-height="120">

<<< @/.vitepress/demos/switch/colors.tsx

</Demo>

### size

The thumb is inset 2px on every side, so its diameter is the track's height minus four at every step and the two never drift apart.

<Demo src="switch/sizes" :min-height="220">

<<< @/.vitepress/demos/switch/sizes.tsx

</Demo>

### labelPlacement

`end` (the default) reads as a caption for the control. `start` is for a settings list: the labels form a column and every switch lines up against the right edge of the row.

<Demo src="switch/placement" :min-height="220">

<<< @/.vitepress/demos/switch/placement.tsx

</Demo>

### readOnly · disabled

<Demo src="switch/states" :min-height="220">

<<< @/.vitepress/demos/switch/states.tsx

</Demo>

## Accessibility

- Base UI renders a `role="switch"` control with `aria-checked`, and with `name` the hidden input that makes it part of a native form submission.
- `label`, `description` and `error` are wired to the control by Base UI's Field, so pressing the label flips the switch.
- <kbd>Space</kbd> and <kbd>Enter</kbd> both flip it; the focus ring appears only on `:focus-visible`.
- The thumb's position is not the only signal — the track changes material as well, so the state survives a reader who cannot tell the two ends of a 36px pill apart.
- The thumb is the one thing in the library that moves, and it carries no text — the no-transform rule is about a control resampling its own label under the finger, which this cannot do. It travels in one house duration, the same 150ms everything else changes in.
- A switch with no `label` needs an `aria-label`.
