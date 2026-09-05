---
title: PlNumberField
order: 11
---

# PlNumberField

<p class="plass-lede">A field that only holds a number. The shell is a <code>PlTextField</code>'s to the pixel; what is added on top is a real numeric control, arrow keys, steppers, clamping and locale-aware formatting.</p>

<Demo src="number-field/hero" :min-height="260" />

::: fw react

```tsx
import { PlNumberField } from 'plass-ui';

<PlNumberField label="Quantity" min={1} max={12} defaultValue={2} />;
<PlNumberField label="Budget" locale="en-US" format={{ style: 'currency', currency: 'USD' }} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlNumberField(
  label: const Text('Quantity'),
  min: 1,
  max: 12,
  value: quantity,
  onChanged: (double? next) => setState(() => quantity = next),
);

PlNumberField(
  label: const Text('Budget'),
  value: budget,
  format: (double value) => '\$${value.toStringAsFixed(2)}',
  onChanged: (double? next) => setState(() => budget = next),
);
```

:::

## Props

<PropsTable name="PlNumberField" />

::: fw react

Every native `<div>` attribute passes straight through, onto the field's wrapper. `color`, `defaultValue` and `children` are excluded from the pass-through because all three are Plass props here.

A `className` lands on the stack that holds the label, the control and the two lines under it. `classNames` reaches the four parts inside it: `label`, `control` (the shell, steppers included) `description` and `error`.

:::

::: fw flutter

**Controlled**, like every other input in the package: it is handed a `value` and reports what the value should become. There is no `defaultValue`, and `value` is a `double?`. `null` is an empty box.

There are two callbacks rather than one, and the difference matters here more than anywhere else in the library. `onChanged` fires on every keystroke with **what has been typed**; `onCommitted` fires when the field settles, with what it settled to. `5` on the way to `50` is half-finished rather than out of a range that starts at ten, so the clamp waits for the field to settle.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### steppers

`end` puts both buttons at the trailing edge, the way a spinner has always looked. `split` puts the minus at the start and the plus at the end with the number between them, for a quantity that is nudged rather than typed. `none` drops them, and the field is still a number field, the arrow keys, the clamping and the formatting all stay.

There is deliberately no stacked pair of half-height chevrons. At `xs` each arrow would be under three pixels tall, and a target that small is a target nobody hits.

<Demo src="number-field/steppers" :min-height="300">

::: fw react

<<< @/.vitepress/demos/number-field/steppers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/steppers.dart

:::

</Demo>

### format

::: fw react

Passed straight to `Intl.NumberFormat`, so the field shows `$1,240.00` or `18.5%` while `value` stays a plain number. What was typed is parsed back against the same locale, which is what makes a comma mean a decimal point where it should.

:::

::: fw flutter

Two functions rather than one options object: `format` writes a settled value and `parse` reads typed text back. There is no `Intl.NumberFormat` in the Dart SDK and this package has no dependencies, so a locale-aware field is one an app builds out of its own formatter, which it already has, because the rest of its screens need one too.

Left out, `format` writes a whole number with no decimal point and `parse` throws away everything but digits, a sign and a decimal point. That default pair is what makes `$1,240.50` typeable into a field showing currency without either function being written.

:::

<Demo src="number-field/format" :min-height="200">

::: fw react

<<< @/.vitepress/demos/number-field/format.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/format.dart

:::

</Demo>

### step, largeStep and smallStep

The arrow keys and the steppers both move by `step`, with <kbd>Shift</kbd> taking `largeStep` and <kbd>Alt</kbd> taking `smallStep`, the modifiers count for a pressed stepper as well as a pressed key. `snapOnStep` makes a step land on a multiple rather than move by one.

::: fw flutter

<kbd>Page Up</kbd> and <kbd>Page Down</kbd> take `largeStep` too, and <kbd>Home</kbd> and <kbd>End</kbd> go to `min` and `max` when there are any. A stepper held down repeats after a short pause; a stepper pressed and let go is worth exactly one step, the way every other button in the library is.

:::

<Demo src="number-field/steps" :min-height="240">

::: fw react

<<< @/.vitepress/demos/number-field/steps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/steps.dart

:::

</Demo>

### variant

The shell is a `PlTextField`'s, to the pixel. A form where the quantity box is a different height or radius from the boxes around it is a form that looks assembled rather than designed, so `solid` is the well cut into the sheet here too, not a tinted pane.

<Demo src="number-field/variants" :min-height="300">

::: fw react

<<< @/.vitepress/demos/number-field/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/variants.dart

:::

</Demo>

### States

`readOnly` keeps the number readable and takes the steppers away; there is nothing to press on a value that cannot change. `error` also turns the field invalid, which re-points the whole slot family at `danger`, so the edge, the ring, the caret and the message all turn over together.

<Demo src="number-field/states" :min-height="380">

::: fw react

<<< @/.vitepress/demos/number-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/states.dart

:::

</Demo>

### size

<Demo src="number-field/sizes" :min-height="420">

::: fw react

<<< @/.vitepress/demos/number-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/number_field/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI's NumberField owns the hard parts: parsing what was typed against the locale, clamping to `min`/`max`, the press-and-hold repeat on the steppers, and the hidden input that submits with a form.
- The label, the description and the error are wired to the control by Base UI's Field, so none of them needs an `id` from the caller.
- Both steppers carry an accessible name already; `incrementLabel` and `decrementLabel` are what change them.
- A stepper that has run into the end of the range is genuinely `disabled`, not just dimmed.
- `allowWheelScrub` is off by default. A page that scrolls under the pointer and a field that changes under it are the same gesture, and only one of them was meant.

:::

::: fw flutter

- The field is announced as a text field holding what it shows, so a screen reader reads `$1,240.00` rather than `1240`. What is drawn is what is read.
- Both steppers carry a name already; `incrementLabel` and `decrementLabel` are what change them. Each is its own focus stop, after the number.
- A stepper that has run into the end of the range is announced as unavailable, not merely dimmed.
- The arrow keys are bound **inside** the field, closer to the editor than an app's own text-editing shortcuts, which is what keeps the up arrow moving the number rather than the caret.
- `allowWheelScrub` is off by default, and even on it wants the field focused _and_ the pointer over it. A page that scrolls under the pointer and a field that changes under it are the same gesture, and only one of them was meant.
- The label, the description and the error are part of the component, so there is no `id` to wire and nothing to forget to wire.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| `onValueCommitted` | `onCommitted` | Same idea, shorter name, and it is where the clamp happens. |
| `format`, an `Intl.NumberFormatOptions` | `format` and `parse`, two functions | There is no `Intl.NumberFormat` in the Dart SDK and this package has no dependencies. A field that formats without parsing cannot be typed into, so both halves are the caller's. |
| `locale` | — | It belongs to the formatter the app passes in, which already knows which locale it is writing. |
| a value of `number \| null` | `double?` | Dart's floating-point type. An `int` field is `step: 1` with a `format` that writes no decimals. |
| the hidden input, `name`, `required` | — | There is no native form submission to be part of. |
| `id` | — | Nothing points at anything by id here; the label and the messages are part of the component. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
