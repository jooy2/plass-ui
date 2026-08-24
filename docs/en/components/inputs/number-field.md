---
title: PlNumberField
order: 11
---

# PlNumberField

<p class="plass-lede">A field that only holds a number. The shell is a <code>PlTextField</code>'s to the pixel; what is added on top is a real numeric control — arrow keys, steppers, clamping and locale-aware formatting.</p>

<Demo src="number-field/hero" :min-height="260" />

```tsx
import { PlNumberField } from 'plass-ui';

<PlNumberField label="Quantity" min={1} max={12} defaultValue={2} />;
<PlNumberField label="Budget" locale="en-US" format={{ style: 'currency', currency: 'USD' }} />;
```

## Props

<PropsTable name="PlNumberField" />

Every native `<div>` attribute passes straight through, onto the field's wrapper. `color`, `defaultValue` and `children` are excluded from the pass-through because all three are Plass props here.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### steppers

`end` puts both buttons at the trailing edge, the way a spinner has always looked. `split` puts the minus at the start and the plus at the end with the number between them, for a quantity that is nudged rather than typed. `none` drops them, and the field is still a number field — the arrow keys, the clamping and the formatting all stay.

There is deliberately no stacked pair of half-height chevrons. At `xs` each arrow would be under three pixels tall, and a target that small is a target nobody hits.

<Demo src="number-field/steppers" :min-height="300">

<<< @/.vitepress/demos/number-field/steppers.tsx

</Demo>

### format

Passed straight to `Intl.NumberFormat`, so the field shows `$1,240.00` or `18.5%` while `value` stays a plain number. What was typed is parsed back against the same locale, which is what makes a comma mean a decimal point where it should.

<Demo src="number-field/format" :min-height="200">

<<< @/.vitepress/demos/number-field/format.tsx

</Demo>

### step, largeStep and smallStep

The arrow keys and the steppers both move by `step`, with Shift taking `largeStep` and Alt taking `smallStep`. `snapOnStep` makes a step land on a multiple rather than move by one.

<Demo src="number-field/steps" :min-height="240">

<<< @/.vitepress/demos/number-field/steps.tsx

</Demo>

### variant

The shell is a `PlTextField`'s, to the pixel. A form where the quantity box is a different height or radius from the boxes around it is a form that looks assembled rather than designed — so `solid` is the well cut into the sheet here too, not a tinted pane.

<Demo src="number-field/variants" :min-height="300">

<<< @/.vitepress/demos/number-field/variants.tsx

</Demo>

### States

`readOnly` keeps the number readable and takes the steppers away; there is nothing to press on a value that cannot change. `error` also turns the field invalid, which re-points the whole slot family at `danger`, so the edge, the ring, the caret and the message all turn over together.

<Demo src="number-field/states" :min-height="380">

<<< @/.vitepress/demos/number-field/states.tsx

</Demo>

### size

<Demo src="number-field/sizes" :min-height="420">

<<< @/.vitepress/demos/number-field/sizes.tsx

</Demo>

## Accessibility

- Base UI's NumberField owns the hard parts: parsing what was typed against the locale, clamping to `min`/`max`, the press-and-hold repeat on the steppers, and the hidden input that submits with a form.
- The label, the description and the error are wired to the control by Base UI's Field, so none of them needs an `id` from the caller.
- Both steppers carry an accessible name already; `incrementLabel` and `decrementLabel` are what change them.
- A stepper that has run into the end of the range is genuinely `disabled`, not just dimmed.
- `allowWheelScrub` is off by default. A page that scrolls under the pointer and a field that changes under it are the same gesture, and only one of them was meant.
