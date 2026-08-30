---
title: PlCombobox
order: 5
---

# PlCombobox

<p class="plass-lede">A field you can type into and also choose from. The text filters the list, and — unless you say otherwise — it can become the value itself.</p>

<Demo src="combobox/hero" :min-height="180" />

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

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCombobox<String>(
  label: const Text('Framework'),
  placeholder: 'Search…',
  value: framework,
  onChanged: (String? next) => setState(() => framework = next),
  options: const <PlComboboxOption<String>>[
    PlComboboxOption<String>(value: 'react', label: 'React'),
    PlComboboxOption<String>(value: 'vue', label: 'Vue'),
  ],
);
```

The list lifts itself out of the tree, so a combobox needs an `Overlay` above it — `WidgetsApp` with a navigator and `MaterialApp` both provide one.

:::

## Props

<PropsTable name="PlCombobox" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the combobox spells it as a value rather than a DOM attribute, and `children` because the options are `items`.

A `className` lands on the stack that holds the label, the control and the two lines under it. `classNames` reaches the four parts inside it: `label`, `control` — the field's shell, chips and all — `description` and `error`.

:::

::: fw flutter

The combobox is generic in its value's type — `PlCombobox<String>`, `PlCombobox<Tag>` — and it is **controlled**, like every other input in the package. Holding a set is a second constructor, `PlCombobox.multiple`, which takes `values` and reports a `List<T>`: one widget with a `multiple` flag would have to hold both shapes of value and neither would be typed.

`onCreate` is what React spells as `allowCustom`, and it is a callback rather than a flag for a reason React does not have: there a value is always a `string` or a `number`, so the field can build one out of the query on its own. Here it is a `T`, and only the caller knows how to make one — so the permission and the recipe are the same parameter. For a `PlCombobox<String>` that is `(String query) => query`.

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

<Demo src="combobox/custom" :min-height="260">

::: fw react

<<< @/.vitepress/demos/combobox/custom.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/custom.dart

:::

</Demo>

### multiple

The chosen values become [`PlChip`](../display/chip)s inside the field and the input goes on filtering after each one, so a set of tags is built without the field ever closing.

The field then has no fixed height — the chips wrap — so its padding is `(control height − chip height) / 2` instead, which makes a one-row combobox exactly as tall as the field beside it.

<Demo src="combobox/multiple" :min-height="180">

::: fw react

<<< @/.vitepress/demos/combobox/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/multiple.dart

:::

</Demo>

### size

The same height ladder as every other control. With `multiple` the number is a minimum rather than a height, for the reason above.

<Demo src="combobox/sizes" :min-height="300">

::: fw react

<<< @/.vitepress/demos/combobox/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/sizes.dart

:::

</Demo>

### readOnly · disabled · error

`error` also turns the combobox invalid, which re-points the whole colour family at `danger` — the edge, the ring, the caret and the message turn over together. `invalid` does the same without a message.

A `readOnly` combobox keeps its value and its focus but cannot be typed into, and its chips lose their ×. A `disabled` one leaves the tab order.

An option may be `disabled` on its own: it stays in the list, because an option that vanishes when it cannot be picked is an option the reader will look for.

<Demo src="combobox/states" :min-height="300">

::: fw react

<<< @/.vitepress/demos/combobox/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/states.dart

:::

</Demo>

### Controlled

Pass `value` with `onValueChange`. The value is a `string` or a `number` — an array of them with `multiple` — and never an object: a combobox is a form control, and its value is what the form submits. Keep the identifier here and look the object up on the other side.

## Accessibility

::: fw react

- Base UI renders the `combobox`/`listbox` pair, keeps `aria-expanded` and `aria-activedescendant` in step, and owns the filtering and its collator.
- `label`, `description` and `error` are wired to the input by Base UI's Field, so no `htmlFor` is needed.
- The keyboard is the primitive's: <kbd>↑</kbd> <kbd>↓</kbd> move through the list, <kbd>Enter</kbd> takes the highlighted row and <kbd>Esc</kbd> closes. With `multiple`, <kbd>←</kbd> <kbd>→</kbd> walk the chips and <kbd>Backspace</kbd> removes one.
- The first match lights up as you type, so <kbd>Enter</kbd> commits without an arrow key first. That is also what makes the "add this" row reachable from the keyboard at all: a value the list does not have is the only match there is.
- The "add this" row is a **real option**, not a special case in the key handling, so a click, <kbd>Enter</kbd> and the arrow keys all reach it the way every other row is reached.
- Rows light on `data-highlighted` rather than on `:hover`, so the pointer and the arrow keys illuminate the same row.
- Each chip's × is named after its chip — `Remove Seoul`, not `Remove` — because a screen reader reading a row of six identical buttons has told the reader nothing.
- With `name`, Base UI renders the hidden input that makes the value part of a native form submission.
- The popup is portalled to the end of `<body>` and its positioner carries `.plass-portal`, which is where a host that scopes a CSS reset can hang the same reset.

:::

::: fw flutter

- The field is announced as a text field that says whether its list is open. Each row is announced as one of a mutually exclusive set, taken or not.
- **The keys stay on the field**, and so does focus: <kbd>↑</kbd> <kbd>↓</kbd> move the highlight, <kbd>Enter</kbd> takes the highlighted row and <kbd>Escape</kbd> closes without taking one. The list is the field's list, not a second place to be.
- The first match lights up as the query changes, so <kbd>Enter</kbd> commits without an arrow key first — which is also what makes the create row reachable from the keyboard at all.
- The highlight is one number rather than a hover state per row, which is what makes the pointer and the arrow keys light the same row.
- A row that cannot be taken stays in the list and is announced as unavailable.
- Each chip's × is named after its chip.
- Nothing is committed when focus leaves: the query goes back to being the value, and a value the list does not have is only ever taken by taking its row.

:::

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `items` | `options` | The word the rest of the package uses for a list of choices. |
| a value of `string \| number` | a generic `T` | Nothing is submitted here, so the value can be the thing itself and the type checker can hold you to it. |
| `multiple` as a prop | `PlCombobox.multiple`, a second constructor | One widget with a flag would have to hold both shapes of value, and neither would be typed. |
| `allowCustom` (a `boolean`, on by default) | `onCreate` (a `T Function(String)`) | A `T` cannot be built out of a query by the field. The permission and the recipe are the same parameter. |
| `label` of `ReactNode`, filtering by Base UI's collator | a `Widget`, filtering by a case-folded `contains` | The label is still a `String`, for the same reason: the filter reads it and it is written into a field. |
| the hidden input, `name`, `required` | — | There is no native form submission to be part of. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |
