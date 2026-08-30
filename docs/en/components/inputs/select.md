---
title: PlSelect
order: 4
---

# PlSelect

<p class="plass-lede">One value chosen from a list of them. The trigger is a <code>PlTextField</code>'s shell wearing a chevron, so a select and a field in the same form are the same object.</p>

<Demo src="select/hero" :min-height="180" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSelect<String>(
  label: const Text('City'),
  placeholder: const Text('Pick a city'),
  value: city,
  onChanged: (String? next) => setState(() => city = next),
  options: const <PlSelectOption<String>>[
    PlSelectOption<String>(value: 'seoul', label: Text('Seoul')),
    PlSelectOption<String>(value: 'lisbon', label: Text('Lisbon')),
  ],
);
```

The list lifts itself out of the tree, so a select needs an `Overlay` above it — `WidgetsApp` with a navigator and `MaterialApp` both provide one.

:::

## Props

<PropsTable name="PlSelect" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the select spells it as a value rather than a DOM attribute, and `children` because the options are `items`.

A `className` lands on the stack that holds the label, the control and the two lines under it. `classNames` reaches the four parts inside it: `label`, `control` — the trigger — `description` and `error`.

:::

::: fw flutter

The select is generic in its value's type — `PlSelect<String>`, `PlSelect<Currency>` — so `value` and `onChanged` are typed rather than restrained by convention, and it is **controlled**, like every other input in the package.

That generic is the one place this parts company with the React build's advice. There a value is a `string` or a `number` on purpose, because it is what a form submits; here nothing is submitted, so the value can be the thing itself and the type checker can hold you to it.

:::

### PlSelectOption

<PropsTable name="PlSelectOption" />

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

The same three materials a `PlTextField` wears, on the same shell. `solid` is the **well** — the glass at its most opaque with an inset shadow falling into it — rather than a tinted pane, because a value read off a gradient is a value that has to be read off a gradient.

<Demo src="select/variants" :min-height="140">

::: fw react

<<< @/.vitepress/demos/select/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/variants.dart

:::

</Demo>

### size

The same height ladder as every other control, which is the point of drawing the trigger on the field's shell: a form where the select is a different height, radius or material from the fields around it is a form that looks assembled rather than designed.

<Demo src="select/sizes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/select/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/sizes.dart

:::

</Demo>

### readOnly · disabled · error

`error` also turns the select invalid, which re-points the whole colour family at `danger` — the edge, the ring and the message turn over together. `invalid` does the same without a message, for when an external form library owns the validity.

A `readOnly` select keeps its value and its focus but will not open. A `disabled` one leaves the tab order.

An option may be `disabled` on its own: it stays in the list, because an option that vanishes when it cannot be picked is an option the reader will look for.

<Demo src="select/states" :min-height="200">

::: fw react

<<< @/.vitepress/demos/select/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/states.dart

:::

</Demo>

### Controlled

::: fw react

Pass `value` with `onValueChange`. The value is a `string` or a `number`, never an object — a select is a form control, and its value is what the form submits. Keep the identifier here and look the object up on the other side.

:::

::: fw flutter

This is the only mode: `value` with `onChanged`. The value is a `T` — an enum, an id, the object itself — and `null` is a select with nothing chosen.

:::

<Demo src="select/controlled" :min-height="160">

::: fw react

<<< @/.vitepress/demos/select/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/controlled.dart

:::

</Demo>

### startIcon

Drawn at 1.2× the value beside it, so it tracks the text. There is no `endIcon`: the end of the trigger belongs to the chevron.

<Demo src="select/icons" :min-height="160">

::: fw react

<<< @/.vitepress/demos/select/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/icons.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI renders a `role="combobox"` trigger and a `listbox` popup with real `option` rows, keeps `aria-expanded` and `aria-activedescendant` in step, and traps focus while the list is open.
- `label`, `description` and `error` are wired to the trigger by Base UI's Field, so no `htmlFor` is needed.
- The keyboard is the primitive's: <kbd>↑</kbd> <kbd>↓</kbd> <kbd>Home</kbd> <kbd>End</kbd> move, typing jumps by prefix, <kbd>Enter</kbd> chooses and <kbd>Esc</kbd> closes.
- Rows light on `data-highlighted` rather than on `:hover`, so the pointer and the arrow keys illuminate the same row.
- With `name`, Base UI renders the hidden input that makes the value part of a native form submission.
- The trigger is held open at the width of the longest label it could show, so choosing a shorter option does not shrink the field out from under the pointer that chose it. Those samples are `aria-hidden` and drawn as generated content, so nothing extra is read out or found by find-in-page.
- The popup is portalled to the end of `<body>` and its positioner carries `.plass-portal`, which is where a host that scopes a CSS reset can hang the same reset.

:::

::: fw flutter

- The trigger is announced as a button that says what is chosen and whether the list is open. Each row is announced as one of a mutually exclusive set, taken or not.
- **The keys stay on the trigger**, and so does focus: <kbd>↑</kbd> <kbd>↓</kbd> move the highlight, <kbd>Home</kbd> and <kbd>End</kbd> go to the ends, <kbd>Enter</kbd> takes the highlighted row and <kbd>Escape</kbd> closes without taking one. The list is the trigger's list, not a second place to be.
- The highlight is one number rather than a hover state per row, which is what makes the pointer and the arrow keys light the same row.
- A row that cannot be taken stays in the list and is announced as unavailable. An option that vanishes when it cannot be picked is an option the reader will look for.
- The trigger is held open at the width of the longest label it could ever say. Those samples are laid out and not painted, and they are excluded from semantics, so nothing extra is read out.
- Opening the list takes focus to the trigger, because the list's keys are bound there: an open select nothing is focused on is a list the arrow keys cannot reach.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `items` | `options` | The word the rest of the package uses for a list of choices — a radio group's are `options` too. |
| a value of `string \| number` | a generic `T` | Nothing is submitted here, so the value can be the thing itself and the type checker can hold you to it. |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| typing jumps by prefix | — | Typeahead needs the text of every label, and a label here is a widget. Long lists want a field above them rather than a guess. |
| focus moves into the popup | focus stays on the trigger | The list is the trigger's list. Keeping focus where it started is also what makes closing put it back with nothing to restore. |
| the hidden input, `name`, `required` | — | There is no native form submission to be part of. |
| `id` | — | Nothing points at anything by id here; the label and the messages are part of the component. |
| `role="combobox"`, `aria-activedescendant` | an expanded button, and rows in a mutually exclusive set | Flutter names the state on the node itself; there is no id to point at. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
