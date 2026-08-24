---
title: TextField
order: 2
---

# TextField

<p class="plass-lede">Single- or multi-line text input. The label, the helper text and the error message are part of the component rather than three elements you wire together yourself.</p>

<Demo src="text-field/hero" :min-height="180" />

```tsx
import { TextField } from 'plass-ui';

<TextField label="Email" type="email" description="We never share it." />;
```

## Props

<PropsTable name="TextField" />

Every native `<input>` attribute passes straight through, and in `multiline` mode every `<textarea>` attribute does. The exceptions are `color` and `size`, which are the shared axes above.

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

`glass` is the default: a sheet with a hairline round it, which is what a field is on a Plass screen. `solid` is the **well** — the glass at its most opaque with the one inset shadow in the library falling into it — for a field that has to look recessed rather than raised. `ghost` has no surface until the pointer is on it, for a field in a table cell.

A `solid` field is deliberately **not** a tinted pane. A gradient under a caret, a text selection and a placeholder is not legible, so the family shows up in the hairline, the ring and the caret instead.

<Demo src="text-field/variants" :min-height="240">

<<< @/.vitepress/demos/text-field/variants.tsx

</Demo>

### size

The same ladder Button uses — `xs` 24px · `sm` 32px · `md` 40px · `lg` 48px · `xl` 56px — so a field and a button of the same `size` line up on one row.

<Demo src="text-field/sizes" :min-height="260">

<<< @/.vitepress/demos/text-field/sizes.tsx

</Demo>

### label, description and error

All three are nodes, and all three are wired to the control by Base UI's `Field`: the label points at it, and both messages end up in its `aria-describedby`.

There is no floating-label variant. A floating label needs a `transform` on the thing being typed into, and a label that moves under the caret is the one effect this library rules out on a control.

### Validation

`error` carries a message **and** turns the field invalid, which re-points the whole slot family at `danger` — the hairline, the focus ring, the caret and the message all turn over together.

Two escape hatches, for when a form library owns the validity: `invalid` forces the state without a message, and `invalid={false}` shows a message without it.

<Demo src="text-field/validation" :min-height="120">

<<< @/.vitepress/demos/text-field/validation.tsx

</Demo>

### multiline

Renders a `<textarea>`. Every other axis is identical, and a one-row textarea is exactly as tall as the single-line field of the same `size` — the vertical padding is derived from the height ladder, so `density` never touches it.

`resize` decides which way the user may drag it. Horizontal resizing breaks a form's column, so only the vertical axis is on by default.

<Demo src="text-field/multiline" :min-height="300">

<<< @/.vitepress/demos/text-field/multiline.tsx

</Demo>

### startIcon and endIcon

Sized in `em`, so they track the text. They sit on the shell rather than inside the control, and they answer its focus — an adornment goes from muted to the accent colour when the field is focused.

An adornment is centred on the control's **first line**, so it stays where it is when a multiline field grows.

<Demo src="text-field/icons" :min-height="220">

<<< @/.vitepress/demos/text-field/icons.tsx

</Demo>

### loading · readOnly · disabled

| prop       | Appearance                                     | Typing                  | Focus |
| ---------- | ---------------------------------------------- | ----------------------- | ----- |
| `loading`  | A spinner takes the `endIcon` slot             | Allowed                 | Kept  |
| `readOnly` | Keeps its colour, goes flat, drains saturation | Blocked, but selectable | Kept  |
| `disabled` | The page shows through the sheet               | Blocked                 | Lost  |

`loading` deliberately still allows typing: a field is usually loading _because of_ what was typed into it.

<Demo src="text-field/states" :min-height="300">

<<< @/.vitepress/demos/text-field/states.tsx

</Demo>

### Controlled

`value` and `onChange` behave exactly as they do on a native input; `onChange` is typed to accept either element so the same handler works in `multiline` mode.

<Demo src="text-field/controlled" :min-height="120">

<<< @/.vitepress/demos/text-field/controlled.tsx

</Demo>

## Accessibility

- Renders a native `<input>`, or a `<textarea>` under `multiline`. Both take every attribute their element takes.
- `label` is a real `<label>` pointing at the control. Without one, give the field an `aria-label` or a `placeholder` that is not the only name it has.
- `description` and `error` both land in `aria-describedby`, so a screen reader reads the message with the field rather than after it.
- `error` and `invalid` set `aria-invalid`.
- The focus ring is drawn on the shell rather than on the control, so it traces the glass edge instead of a rectangle floating inside it. It appears on `:focus-visible` only.
- Clicking the shell's padding puts the caret in the field, the way clicking inside a native input does.
