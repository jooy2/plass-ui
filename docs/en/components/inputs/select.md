---
title: PlSelect
order: 4
---

# PlSelect

<p class="plass-lede">One value chosen from a list of them. The trigger is a <code>PlTextField</code>'s shell wearing a chevron, so a select and a field in the same form are the same object.</p>

<Demo src="select/hero" :min-height="180" />

```tsx
import { PlSelect } from 'plass-ui';

<PlSelect
  label="City"
  placeholder="Pick a city"
  items={[
    { value: 'seoul', label: 'Seoul' },
    { value: 'lisbon', label: 'Lisbon' }
  ]}
/>;
```

## Props

<PropsTable name="PlSelect" />

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the select spells it as a value rather than a DOM attribute, and `children` because the options are `items`.

### PlSelectOption

<PropsTable name="PlSelectOption" />

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

The same three materials a `PlTextField` wears, on the same shell. `solid` is the **well** — the glass at its most opaque with an inset shadow falling into it — rather than a tinted pane, because a value read off a gradient is a value that has to be read off a gradient.

<Demo src="select/variants" :min-height="140">

<<< @/.vitepress/demos/select/variants.tsx

</Demo>

### size

The same height ladder as every other control, which is the point of drawing the trigger on the field's shell: a form where the select is a different height, radius or material from the fields around it is a form that looks assembled rather than designed.

<Demo src="select/sizes" :min-height="220">

<<< @/.vitepress/demos/select/sizes.tsx

</Demo>

### readOnly · disabled · error

`error` also turns the select invalid, which re-points the whole colour family at `danger` — the edge, the ring and the message turn over together. `invalid` does the same without a message, for when an external form library owns the validity.

A `readOnly` select keeps its value and its focus but will not open. A `disabled` one leaves the tab order.

An option may be `disabled` on its own: it stays in the list, because an option that vanishes when it cannot be picked is an option the reader will look for.

<Demo src="select/states" :min-height="200">

<<< @/.vitepress/demos/select/states.tsx

</Demo>

### Controlled

Pass `value` with `onValueChange`. The value is a `string` or a `number`, never an object — a select is a form control, and its value is what the form submits. Keep the identifier here and look the object up on the other side.

<Demo src="select/controlled" :min-height="160">

<<< @/.vitepress/demos/select/controlled.tsx

</Demo>

### startIcon

Drawn at `1.2em`, so it tracks the value beside it. There is no `endIcon`: the end of the trigger belongs to the chevron.

<Demo src="select/icons" :min-height="160">

<<< @/.vitepress/demos/select/icons.tsx

</Demo>

## Accessibility

- Base UI renders a `role="combobox"` trigger and a `listbox` popup with real `option` rows, keeps `aria-expanded` and `aria-activedescendant` in step, and traps focus while the list is open.
- `label`, `description` and `error` are wired to the trigger by Base UI's Field, so no `htmlFor` is needed.
- The keyboard is the primitive's: <kbd>↑</kbd> <kbd>↓</kbd> <kbd>Home</kbd> <kbd>End</kbd> move, typing jumps by prefix, <kbd>Enter</kbd> chooses and <kbd>Esc</kbd> closes.
- Rows light on `data-highlighted` rather than on `:hover`, so the pointer and the arrow keys illuminate the same row.
- With `name`, Base UI renders the hidden input that makes the value part of a native form submission.
- The trigger is held open at the width of the longest label it could show, so choosing a shorter option does not shrink the field out from under the pointer that chose it. Those samples are `aria-hidden` and drawn as generated content, so nothing extra is read out or found by find-in-page.
- The popup is portalled to the end of `<body>` and its positioner carries `.plass-portal`, which is where a host that scopes a CSS reset can hang the same reset.
