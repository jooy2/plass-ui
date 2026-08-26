---
title: PlOtpField
order: 6
---

# PlOtpField

<p class="plass-lede">A row of one-character slots: a PIN, a texted verification code, an invite key. One value behind however many boxes, with paste, backspace and the phone's own autofill all doing what a reader expects.</p>

<Demo src="otp-field/hero" :min-height="180" />

::: fw react

```tsx
import { PlOtpField } from 'plass-ui';

<PlOtpField label="Verification code" groupSize={3} onComplete={verify} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlOtpField(
  label: const Text('Verification code'),
  groupSize: 3,
  onCompleted: verify,
);
```

:::

## Props

<PropsTable name="PlOtpField" />

::: fw react

Every native `<div>` attribute passes straight through, onto the row of slots rather than onto the field around it. `color` is excluded because it is a Plass prop here, `onChange` because the component spells it `onValueChange`, and `children` because the slots are the children.

:::

::: fw flutter

The value lives in a `TextEditingController`, the way it does on a `PlTextField` — so `value` and `defaultValue` have one parameter between them, and a caller who wants to clear the code sets `controller.text`.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### length

Clamped to 2–12. A single box is a `PlTextField`, and past twelve the row stops fitting a phone — which is the device most of these codes are typed on.

<Demo src="otp-field/length" :min-height="220">

::: fw react

<<< @/.vitepress/demos/otp-field/length.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/length.dart

:::

</Demo>

### charset

What may be typed. Anything rejected is dropped rather than shown, and `onValueInvalid` reports it — a slot that silently swallows a keystroke is a slot the reader thinks is broken.

`numeric` is the default because that is what a texted code is, and it is also what puts a number pad in front of a phone.

<Demo src="otp-field/charset" :min-height="280">

::: fw react

<<< @/.vitepress/demos/otp-field/charset.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/charset.dart

:::

</Demo>

### groupSize and separator

`groupSize={3}` on a six-character code gives the familiar two blocks of three. The separator is punctuation inside one value rather than a break between two things, so it is hidden from a screen reader entirely: a reader that announced it once per group would be reading out the shape of the box instead of the code in it.

### variant

The same field shell as `PlTextField` and `PlSelect`, because a slot is a field-shaped box and a form holding both should not look like two form kits stacked on each other. `solid` is the **well** — the glass at its most opaque with a shadow falling into it — and not a tinted pane, for the reason it is on a text field: a caret and a selection have to stay legible on top of it.

<Demo src="otp-field/variants" :min-height="280">

::: fw react

<<< @/.vitepress/demos/otp-field/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/variants.dart

:::

</Demo>

### size

A slot has its own ladder rather than the control one, for the reason a tick box does: a slot is not a control in a row of controls, it is a character standing on its own, and an `md` slot the height of an `md` `PlButton` would be too small to read a code out of across a desk. Every step is taller than it is wide, which is what makes a row of them read as places for one character each rather than as a row of tiny fields.

The type scale is two steps up the control ladder with it. A verification code is read off one phone and typed with the other hand; it is the one piece of text in a form that should be bigger than the label above it.

`density` touches the gap between slots and nothing else.

<Demo src="otp-field/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/otp-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/sizes.dart

:::

</Demo>

### mask, readOnly, disabled and error

`error` carries a message **and** turns the field invalid, which re-points the whole slot family at `danger` so the edge, the ring, the caret and the message all turn over together. `invalid` is the escape hatch for a form library that owns the validity.

<Demo src="otp-field/states" :min-height="400">

::: fw react

<<< @/.vitepress/demos/otp-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/states.dart

:::

</Demo>

## How it is built

::: fw react

One `<input>` per slot, with Base UI keeping a single value behind them. That is what a browser's paste and autofill expect, and it is what makes a click land on the first empty slot rather than on the box under the pointer.

:::

::: fw flutter

**One editor behind the whole row**, drawn as slots. Flutter's text input is a single connection to the platform, and splitting it into six would be six keyboards fighting over one code — so the value lives in a `TextEditingController`, the boxes are painted from it, and pressing anywhere in the row puts the caret at the first empty slot.

The editor is laid out over the row at zero opacity rather than taken off screen: a text input has to be in the tree and measured to hold that connection, so it cannot be `Offstage`. Nothing touches it directly — one gesture owns every press — and what a reader sees is the boxes.

Rejected characters go through a formatter of the component's own rather than Flutter's `FilteringTextInputFormatter`, which drops them and says nothing. A refusal that disappears silently is the single worst thing a code field does: the reader presses a key, sees nothing, and concludes the field is broken.

:::

## Accessibility

::: fw react

- Built on Base UI's OTP Field, which owns everything that makes this harder than it looks: one hidden value behind however many inputs, paste spread across the slots from wherever the caret was, backspace stepping back a box, and a click landing on the first empty slot rather than on the one under the pointer.
- Every slot carries `autocomplete="one-time-code"`, so a phone offers the code straight from the message.
- The label, the description and the error are wired to the row by Base UI's `Field` — one `for`, one `aria-describedby`, and no ids for a caller to keep in step.
- The separator is an `aria-hidden` `<span>` rather than a `role="separator"`. It is punctuation inside one value, not a break between two things.
- The focus ring on a slot is `:focus` rather than `:focus-visible`, which is the one place in the library that distinction is deliberately dropped: a slot is put in focus by clicking it as often as by typing into it, and the ring is the only thing saying which character the next keystroke lands on.

:::

::: fw flutter

- The row is one text-field semantics node carrying the code as its value. The boxes are a drawing of that value and are excluded from semantics entirely, so a screen reader reads the code rather than counting empty rectangles.
- The editor carries `AutofillHints.oneTimeCode`, so a phone offers the code straight from the message.
- The ring is drawn on the slot the next keystroke lands in, and it follows focus rather than focus-visible — for the reason it does in the other package.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| one `<input>` per slot | one editor behind the row | Flutter's text input is a single connection to the platform. Six of them would be six keyboards fighting over one code. |
| `value` / `defaultValue` / `onValueChange` | `controller` / `onChanged` | The shape every editable widget in Flutter has, and the one `PlTextField` already uses. |
| `onValueInvalid` | `onRejected` | It is handed the characters that were refused rather than the value that survived, which is the more useful half. |
| `name`, `required`, `autoSubmit` | — | All three are about an HTML form submission, which Flutter has no equivalent of. |
| `autoFocus` | `autofocus` | Flutter's spelling. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
