---
title: PlForm
order: 18
---

# PlForm

<p class="plass-lede">A <code>&lt;form&gt;</code> that knows which of its fields is wrong. It collects every field's validity on submit, focuses the first that failed, and puts a server's answer back on the field it belongs to.</p>

<Demo src="form/hero" :flutter="false" :min-height="280" />

::: fw react

```tsx
import { PlButton, PlForm, PlTextField } from 'plass-ui';

<PlForm errors={errors} onSubmit={(values) => save(values)}>
  <PlTextField name="email" type="email" label="Email" required />
  <PlButton type="submit">Sign in</PlButton>
</PlForm>;
```

:::

## Props

<PropsTable name="PlForm" />

::: fw react

Every native `<form>` attribute passes straight through. `onSubmit` is excluded because this one reports the form's **values** rather than a DOM event, and prevents the native submit so nothing navigates.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## It is not a form library

There is no schema here, no resolver and no field array. A project that wants those keeps the one it already has and hands the result to `errors`, which is the seam this component is built around.

What it owns is the part that cannot live on a single field:

- **A submit** collects every field's validity at once rather than one at a time.
- **Focus** goes to the first field that failed, so a reader is not left to hunt for the red one.
- **`errors`** puts an answer from outside the browser back on the field it belongs to, by `name`.

It draws no surface either. A form is a stack of controls, and the sheet it sits on is a [`PlCard`](../surfaces/card) or a [`PlBox`](../surfaces/box) when one is wanted.

## Examples

### validationMode

`onSubmit` is the default and the only one of the three that does not tell somebody their email is wrong while they are still typing it: nothing is checked until the form is submitted, and from then on each field re-checks as it changes.

`onBlur` checks when a field loses focus. `onChange` checks on every keystroke, which is worth it for a strength meter and not much else.

<Demo src="form/validation" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/form/validation.tsx

</Demo>

### errors

Keyed by the `name` of the field each belongs to. The message is shown on that field and cleared as soon as it changes, because a server's objection to a value that no longer exists is noise.

This is where a schema's output goes, and where a form action's response goes. Everything a caller already has for validation stays where it is.

<Demo src="form/errors" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/form/errors.tsx

</Demo>

### Every field can show a message it was not given

A field component renders its error box **whether or not it was given an `error`**. With one, the message is the caller's and shows unconditionally; without one, the box is left for Base UI to fill with whatever actually failed — the browser's own constraint message, or this form's `errors` entry for that field.

That is what makes `errors` work without threading a message through every field by hand, and it is why a field marked invalid never goes red with nothing said.

### onSubmit

Called with the form's values, and only when every field is valid. The native submit is prevented, so nothing navigates and no page reloads.

```tsx
<PlForm onSubmit={(values) => save(values)}>
```

The values come from the fields' `name`s, which is the same contract a native form has. A field with no `name` is not in the object — and is not in a native submission either.

## Accessibility

- It is a real `<form>`. Enter in a text field submits it, the way it always has.
- On a failed submit, focus moves to the first invalid field, so a screen reader is taken to the problem rather than told there is one.
- Each field's message is wired to it by Base UI's Field, so it is announced with the field rather than read as loose text.
- `errors` marks the field invalid as well as writing the message, so `aria-invalid` and the visible state say the same thing.
