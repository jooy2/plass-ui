---
title: PlTextField
order: 2
---

# PlTextField

<p class="plass-lede">Single- or multi-line text input. The label, the helper text and the error message are part of the component rather than three elements you wire together yourself.</p>

<Demo src="text-field/hero" :min-height="180" />

::: fw react

```tsx
import { PlTextField } from 'plass-ui';

<PlTextField label="Email" type="email" description="We never share it." />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTextField(
  controller: email,
  label: const Text('Email'),
  keyboardType: TextInputType.emailAddress,
  description: const Text('We never share it.'),
);
```

:::

## Props

<PropsTable name="PlTextField" />

::: fw react

Every native `<input>` attribute passes straight through, and in `multiline` mode every `<textarea>` attribute does. The exceptions are `color` and `size`, which are the shared axes above.

A `className` lands on the stack that holds the label, the control and the two lines under it. `classNames` reaches the four parts inside it: `label`, `control` — the box the text goes in — `description` and `error`.

:::

::: fw flutter

The value lives in a `TextEditingController`, which is where Flutter keeps text. Left out, the field owns one — but a field whose value the app needs is a field the app should hand a controller to.

Under it is `EditableText` rather than a `TextField`: the latter is Material, and this package imports neither Material nor Cupertino. What Material adds on top — the decoration, the counter, the ripple — is what this component is _instead of_.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

`glass` is the default: a sheet with a hairline round it, which is what a field is on a Plass screen. The hairline is `--plass-border`, the same neutral line a tick, a switch and a tabs rail draw — not the sheet's own white edge, because a field is very often set on a card rather than on the page wash, and a white line round a near-white box on a white card is a field whose shape cannot be seen. `solid` is the **well** — the glass at its most opaque with the one inset shadow in the library falling into it — for a field that has to look recessed rather than raised. `ghost` has no surface until the pointer is on it, for a field in a table cell.

A `solid` field is deliberately **not** a tinted pane. A gradient under a caret, a text selection and a placeholder is not legible, so the family shows up in the hairline, the ring and the caret instead.

<Demo src="text-field/variants" :min-height="240">

::: fw react

<<< @/.vitepress/demos/text-field/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/variants.dart

:::

</Demo>

### size

The same ladder PlButton uses — `xs` 24px · `sm` 32px · `md` 40px · `lg` 48px · `xl` 56px — so a field and a button of the same `size` line up on one row.

<Demo src="text-field/sizes" :min-height="260">

::: fw react

<<< @/.vitepress/demos/text-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/sizes.dart

:::

</Demo>

### label, description and error

::: fw react

All three are nodes, and all three are wired to the control by Base UI's `Field`: the label points at it, and both messages end up in its `aria-describedby`.

:::

::: fw flutter

All three are widgets, and all three are part of the field's own semantics node — so a screen reader reads the label, the field and the message as one thing rather than as three.

:::

There is no floating-label variant. A floating label needs a `transform` on the thing being typed into, and a label that moves under the caret is the one effect this library rules out on a control.

### Validation

`error` carries a message **and** turns the field invalid, which re-points the whole slot family at `danger` — the hairline, the focus ring, the caret and the message all turn over together.

Two escape hatches, for when a form library owns the validity: `invalid` forces the state without a message, and <Fw react="invalid={false}" flutter="invalid: false" code /> shows a message without it.

<Demo src="text-field/validation" :min-height="120">

::: fw react

<<< @/.vitepress/demos/text-field/validation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/validation.dart

:::

</Demo>

### multiline

Every other axis is identical, and a one-row multiline field is exactly as tall as the single-line field of the same `size` — the vertical padding is derived from the height ladder, so `density` never touches it.

::: fw react

Renders a `<textarea>`. `resize` decides which way the user may drag it; horizontal resizing breaks a form's column, so only the vertical axis is on by default.

:::

::: fw flutter

There is no `resize`. A textarea's drag handle is the browser's, and Flutter has no equivalent to offer — a field that has to change size is one the layout around it resizes.

:::

<Demo src="text-field/multiline" :min-height="300">

::: fw react

<<< @/.vitepress/demos/text-field/multiline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/multiline.dart

:::

</Demo>

### startIcon and endIcon

Sized against the text rather than against the row. They sit on the shell rather than inside the control, and they answer its focus — an adornment goes from muted to the accent colour when the field is focused.

An adornment is centred on the control's **first line**, so it stays where it is when a multiline field grows.

<Demo src="text-field/icons" :min-height="220">

::: fw react

<<< @/.vitepress/demos/text-field/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/icons.dart

:::

</Demo>

### loading · readOnly · disabled

| prop       | Appearance                                     | Typing                  | Focus |
| ---------- | ---------------------------------------------- | ----------------------- | ----- |
| `loading`  | A spinner takes the `endIcon` slot             | Allowed                 | Kept  |
| `readOnly` | Keeps its colour, goes flat, drains saturation | Blocked, but selectable | Kept  |
| `disabled` | The page shows through the sheet               | Blocked                 | Lost  |

`loading` deliberately still allows typing: a field is usually loading _because of_ what was typed into it.

<Demo src="text-field/states" :min-height="300">

::: fw react

<<< @/.vitepress/demos/text-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/states.dart

:::

</Demo>

### hotKeys

A field that saves on <kbd>Mod</kbd>+<kbd>Enter</kbd> and clears on <kbd>Escape</kbd> is a form of keyboard affordance that has nowhere else to live. `hotKeys` is a map from a chord to what pressing it does, written in **the same vocabulary [`PlHotKeys`](../display/hot-keys) draws** — so the cap printed beside the field and the key that actually works come from one string, and cannot drift apart.

`Mod` resolves per platform: one entry is ⌘ on a Mac and <kbd>Ctrl</kbd> everywhere else. `Esc`, `Return`, `Cmd` and `Option` fold onto the same keys their caps do.

A chord that matches is **consumed** — the handler runs and the key goes no further, so `Escape` bound here does not also close the dialog around the field, and `Enter` does not also submit the form. That is what binding a key means, and it is why these are chords rather than letters: `{ a: … }` is a field that cannot type an `a`.

<Demo src="text-field/hot-keys" :min-height="280">

::: fw react

<<< @/.vitepress/demos/text-field/hot-keys.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/hot_keys.dart

:::

</Demo>

### Controlled

::: fw react

`value` and `onChange` behave exactly as they do on a native input; `onChange` is typed to accept either element so the same handler works in `multiline` mode.

:::

::: fw flutter

The controller **is** the value, and `onChanged` is told about every change. `maxLength` is a formatter rather than a counter: it stops the twenty-fifth character from arriving, and nothing is drawn under the field unless you draw it.

:::

<Demo src="text-field/controlled" :min-height="120">

::: fw react

<<< @/.vitepress/demos/text-field/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/controlled.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders a native `<input>`, or a `<textarea>` under `multiline`. Both take every attribute their element takes.
- `label` is a real `<label>` pointing at the control. Without one, give the field an `aria-label` or a `placeholder` that is not the only name it has.
- `description` and `error` both land in `aria-describedby`, so a screen reader reads the message with the field rather than after it.
- `error` and `invalid` set `aria-invalid`.
- The focus ring is drawn on the shell rather than on the control, so it traces the glass edge instead of a rectangle floating inside it. It appears on `:focus-visible` only.
- Clicking the shell's padding puts the caret in the field, the way clicking inside a native input does.

:::

::: fw flutter

- Announced as a text field, and as read-only or unavailable when it is.
- The label, the field, the description and the message are **one** semantics node, so a screen reader reads them together rather than one after another. Without a visible label, give the field a `semanticLabel` — a `placeholder` is not a name.
- The focus ring is drawn on the shell rather than on the editor, so it traces the glass edge instead of a rectangle floating inside it. It appears only on what CSS calls `:focus-visible`.
- Pressing the shell's padding puts the caret in the field, the way pressing inside a native input does.
- A selection is made by dragging and has **no handles** to adjust afterwards: the drag handles a touch platform puts under one belong to Material and Cupertino, and this package imports neither.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `value` / `onChange` | `controller` / `onChanged` | A `TextEditingController` is where Flutter keeps text, and it is what a caller already has. |
| `type="email"` | `keyboardType` | Flutter's way of saying which keyboard to raise. |
| `resize` | — | A textarea's drag handle is the browser's, and there is no equivalent to offer. |
| a `<textarea>` under `multiline` | the same widget, taller | There is one editor either way, so switching to multiline genuinely changes nothing but the height. |
| `aria-describedby` wiring | one merged semantics node | The same result by a different route. |
| selection handles on touch | — | They belong to Material and Cupertino, which this package does not import. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
