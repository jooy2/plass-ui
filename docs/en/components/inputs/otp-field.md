---
title: PlOtpField
order: 6
---

# PlOtpField

<p class="plass-lede">A row of one-character slots: a PIN, a texted verification code, an invite key. One value behind however many boxes, with paste, backspace and the phone's own autofill all doing what a reader expects.</p>

<Demo src="otp-field/hero" :min-height="180" :flutter="false" />

::: fw react

```tsx
import { PlOtpField } from 'plass-ui';

<PlOtpField label="Verification code" groupSize={3} onComplete={verify} />;
```

:::

## Props

<PropsTable name="PlOtpField" />

::: fw react

Every native `<div>` attribute passes straight through, onto the row of slots rather than onto the field around it. `color` is excluded because it is a Plass prop here, `onChange` because the component spells it `onValueChange`, and `children` because the slots are the children.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### length

Clamped to 2–12. A single box is a `PlTextField`, and past twelve the row stops fitting a phone — which is the device most of these codes are typed on.

<Demo src="otp-field/length" :min-height="220" :flutter="false">

::: fw react

<<< @/.vitepress/demos/otp-field/length.tsx

:::

</Demo>

### charset

What may be typed. Anything rejected is dropped rather than shown, and `onValueInvalid` reports it — a slot that silently swallows a keystroke is a slot the reader thinks is broken.

`numeric` is the default because that is what a texted code is, and it is also what puts a number pad in front of a phone.

<Demo src="otp-field/charset" :min-height="280" :flutter="false">

::: fw react

<<< @/.vitepress/demos/otp-field/charset.tsx

:::

</Demo>

### groupSize and separator

`groupSize={3}` on a six-character code gives the familiar two blocks of three. The separator is punctuation inside one value rather than a break between two things, so it is hidden from a screen reader entirely: a reader that announced it once per group would be reading out the shape of the box instead of the code in it.

### variant

The same field shell as `PlTextField` and `PlSelect`, because a slot is a field-shaped box and a form holding both should not look like two form kits stacked on each other. `solid` is the **well** — the glass at its most opaque with a shadow falling into it — and not a tinted pane, for the reason it is on a text field: a caret and a selection have to stay legible on top of it.

<Demo src="otp-field/variants" :min-height="280" :flutter="false">

::: fw react

<<< @/.vitepress/demos/otp-field/variants.tsx

:::

</Demo>

### size

A slot has its own ladder rather than the control one, for the reason a tick box does: a slot is not a control in a row of controls, it is a character standing on its own, and an `md` slot the height of an `md` `PlButton` would be too small to read a code out of across a desk. Every step is taller than it is wide, which is what makes a row of them read as places for one character each rather than as a row of tiny fields.

The type scale is two steps up the control ladder with it. A verification code is read off one phone and typed with the other hand; it is the one piece of text in a form that should be bigger than the label above it.

`density` touches the gap between slots and nothing else.

<Demo src="otp-field/sizes" :min-height="380" :flutter="false">

::: fw react

<<< @/.vitepress/demos/otp-field/sizes.tsx

:::

</Demo>

### mask, readOnly, disabled and error

`error` carries a message **and** turns the field invalid, which re-points the whole slot family at `danger` so the edge, the ring, the caret and the message all turn over together. `invalid` is the escape hatch for a form library that owns the validity.

<Demo src="otp-field/states" :min-height="400" :flutter="false">

::: fw react

<<< @/.vitepress/demos/otp-field/states.tsx

:::

</Demo>

## Accessibility

::: fw react

- Built on Base UI's OTP Field, which owns everything that makes this harder than it looks: one hidden value behind however many inputs, paste spread across the slots from wherever the caret was, backspace stepping back a box, and a click landing on the first empty slot rather than on the one under the pointer.
- Every slot carries `autocomplete="one-time-code"`, so a phone offers the code straight from the message.
- The label, the description and the error are wired to the row by Base UI's `Field` — one `for`, one `aria-describedby`, and no ids for a caller to keep in step.
- The separator is an `aria-hidden` `<span>` rather than a `role="separator"`. It is punctuation inside one value, not a break between two things.
- The focus ring on a slot is `:focus` rather than `:focus-visible`, which is the one place in the library that distinction is deliberately dropped: a slot is put in focus by clicking it as often as by typing into it, and the ring is the only thing saying which character the next keystroke lands on.

:::
