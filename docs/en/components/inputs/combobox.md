---
title: PlCombobox
order: 5
---

# PlCombobox

<p class="plass-lede">A field you can type into and also choose from. The text filters the list, and — unless you say otherwise — it can become the value itself.</p>

<Demo src="combobox/hero" :flutter="false" :min-height="180" />

::: fw react

```tsx
import { PlCombobox } from 'plass-ui';

<PlCombobox
  label="Framework"
  placeholder="Search…"
  items={[
    { value: 'react', label: 'React' },
    { value: 'vue', label: 'Vue' }
  ]}
/>;
```

:::

## Props

<PropsTable name="PlCombobox" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the combobox spells it as a value rather than a DOM attribute, and `children` because the options are `items`.

:::

### PlComboboxOption

<PropsTable name="PlComboboxOption" />

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## It is a PlTextField wearing a chevron

To the pixel, and so is [`PlSelect`](./select)'s trigger. The three have to be indistinguishable in a form or the form looks assembled rather than designed, which is why the shell lives in `internal/styles` and not in any one of them.

What is different is what the text does. On a select the text is the value; here it filters the list, and it can become the value.

## Examples

### Choosing against typing

A [`PlSelect`](./select) is for a closed set you pick from. This is for a set you _search_, and — with `allowCustom` on, which is the default — one you can add to.

The typed text is offered as its own row at the end of the list, so committing it is a choice the user makes rather than something that happens to them on blur. Turn `allowCustom` off for a field whose values really are a closed set; you then have a searchable select.

<Demo src="combobox/custom" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/combobox/custom.tsx

</Demo>

### multiple

The chosen values become [`PlChip`](../display/chip)s inside the field and the input goes on filtering after each one, so a set of tags is built without the field ever closing.

The field then has no fixed height — the chips wrap — so its padding is `(control height − chip height) / 2` instead, which makes a one-row combobox exactly as tall as the field beside it.

<Demo src="combobox/multiple" :flutter="false" :min-height="180">

<<< @/.vitepress/demos/combobox/multiple.tsx

</Demo>

### size

The same height ladder as every other control. With `multiple` the number is a minimum rather than a height, for the reason above.

<Demo src="combobox/sizes" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/combobox/sizes.tsx

</Demo>

### readOnly · disabled · error

`error` also turns the combobox invalid, which re-points the whole colour family at `danger` — the edge, the ring, the caret and the message turn over together. `invalid` does the same without a message.

A `readOnly` combobox keeps its value and its focus but cannot be typed into, and its chips lose their ×. A `disabled` one leaves the tab order.

An option may be `disabled` on its own: it stays in the list, because an option that vanishes when it cannot be picked is an option the reader will look for.

<Demo src="combobox/states" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/combobox/states.tsx

</Demo>

### Controlled

Pass `value` with `onValueChange`. The value is a `string` or a `number` — an array of them with `multiple` — and never an object: a combobox is a form control, and its value is what the form submits. Keep the identifier here and look the object up on the other side.

## Accessibility

- Base UI renders the `combobox`/`listbox` pair, keeps `aria-expanded` and `aria-activedescendant` in step, and owns the filtering and its collator.
- `label`, `description` and `error` are wired to the input by Base UI's Field, so no `htmlFor` is needed.
- The keyboard is the primitive's: <kbd>↑</kbd> <kbd>↓</kbd> move through the list, <kbd>Enter</kbd> takes the highlighted row and <kbd>Esc</kbd> closes. With `multiple`, <kbd>←</kbd> <kbd>→</kbd> walk the chips and <kbd>Backspace</kbd> removes one.
- The first match lights up as you type, so <kbd>Enter</kbd> commits without an arrow key first. That is also what makes the "add this" row reachable from the keyboard at all: a value the list does not have is the only match there is.
- The "add this" row is a **real option**, not a special case in the key handling, so a click, <kbd>Enter</kbd> and the arrow keys all reach it the way every other row is reached.
- Rows light on `data-highlighted` rather than on `:hover`, so the pointer and the arrow keys illuminate the same row.
- Each chip's × is named after its chip — `Remove Seoul`, not `Remove` — because a screen reader reading a row of six identical buttons has told the reader nothing.
- With `name`, Base UI renders the hidden input that makes the value part of a native form submission.
- The popup is portalled to the end of `<body>` and its positioner carries `.plass-portal`, which is where a host that scopes a CSS reset can hang the same reset.
