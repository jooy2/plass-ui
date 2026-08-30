---
title: PlRadioGroup
order: 7
---

# PlRadioGroup

<p class="plass-lede">A set of options where exactly one is chosen. The set takes a single tab stop and the arrow keys move within it.</p>

<Demo src="radio-group/hero" :min-height="240" />

::: fw react

```tsx
import { PlRadio, PlRadioGroup } from 'plass-ui';

<PlRadioGroup label="Plan" defaultValue="team">
  <PlRadio value="starter" label="Starter" />
  <PlRadio value="team" label="Team" />
</PlRadioGroup>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlRadioGroup<String>(
  label: const Text('Plan'),
  value: plan,
  onChanged: (String next) => setState(() => plan = next),
  options: const <PlRadioOption<String>>[
    PlRadioOption<String>(value: 'starter', label: Text('Starter')),
    PlRadioOption<String>(value: 'team', label: Text('Team')),
  ],
);
```

:::

## Props

<PropsTable name="PlRadioGroup" />

::: fw react

Every other prop on Base UI's `RadioGroup` passes straight through. `className` and `style` land on the field wrapper; `render` is not offered.

`classNames` reaches the four parts inside that wrapper: `label`, `control` — the run of radios — `description` and `error`.

:::

::: fw flutter

The group is generic in the option's type — `PlRadioGroup<String>`, `PlRadioGroup<Plan>` — so `value` and `onChanged` are typed rather than `dynamic`, and an option that does not belong to the set will not compile.

It is **controlled**, like every other control in the package.

:::

::: fw react

### PlRadio

<PropsTable name="PlRadio" />

:::

::: fw flutter

### PlRadioOption

<PropsTable name="PlRadioOption" />

:::

::: fw react

`size` and `color` are read from the `PlRadioGroup` around the option, not set on it: a radio button says nothing on its own, so how it looks belongs to the set. Passing them per option would be four chances to get one of them wrong.

:::

::: fw flutter

An option is a **`PlRadioOption`, a description rather than a widget**, and here the reason is sharper than it is on a [breadcrumb](../display/breadcrumb): the group owns the roving focus and the arrow keys, so it has to know which option is chosen, which are available, and what comes after each one. None of that can be asked of a `Widget`.

It carries no `size` and no `color` either, and could not: a radio button says nothing on its own, so how it looks belongs to the set.

:::

What the shared axes (`size` `color` `orientation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### orientation

Vertical by default. A column of options is scannable at any length; a row silently becomes unreadable the moment one label is longer than expected.

<Demo src="radio-group/orientation" :min-height="280">

::: fw react

<<< @/.vitepress/demos/radio-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/orientation.dart

:::

</Demo>

### color

Chosen, the dot fills with the family's gradient and the inner disc is the family's own `on-solid` ink. The dot is round, and one of only two round things in the library: roundness is exactly what tells a reader "one of these" rather than "any of these", and it is the one convention old enough that breaking it would cost more than it bought.

<Demo src="radio-group/colors" :min-height="180">

::: fw react

<<< @/.vitepress/demos/radio-group/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/colors.dart

:::

</Demo>

### size

Set on the group and inherited by every option, so a set cannot end up with two dot sizes in it.

Every step's inner disc has the same **parity** as the ring's content box — 12/6, 14/6, 16/8, 18/8, 22/10 — so the margin round it is a whole number of pixels. A 7px disc inside an 18px ring with a 1px edge is exactly centred and sits 4.5px from each side, and a circle antialiased at half coverage on all four sides reads as though it has drifted up and to the left. The line box the dot and its label share is a whole number for the same reason. The ratio wanders between 38% and 44% as a result, which is the price, and it is invisible next to the thing it buys.

<Demo src="radio-group/sizes" :min-height="180">

::: fw react

<<< @/.vitepress/demos/radio-group/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/sizes.dart

:::

</Demo>

### readOnly · disabled · error

`disabled` on the group stops every option; on one `PlRadio` it stops only that one, and the option stays in the list — an option that vanishes when it cannot be chosen is an option the reader will look for.

`error` on the group also turns it invalid, which re-points the whole colour family at `danger`.

<Demo src="radio-group/states" :min-height="260">

::: fw react

<<< @/.vitepress/demos/radio-group/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/states.dart

:::

</Demo>

### Controlled

::: fw react

Pass `value` with `onValueChange`. The value is whatever a `PlRadio` was given — usually a string, but Base UI compares by identity, so anything works as long as it is stable between renders.

:::

::: fw flutter

There is only the controlled form: `value` with `onChanged`. Options are compared with `==`, so a value type with a sensible equality — a `String`, an `enum`, anything `@immutable` — works without being kept identical between builds.

:::

<Demo src="radio-group/controlled" :min-height="180">

::: fw react

<<< @/.vitepress/demos/radio-group/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/controlled.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI renders a `role="radiogroup"` holding real radios, keeps `aria-checked` in step, and owns the roving tab index — the set takes one tab stop and <kbd>↑</kbd> <kbd>↓</kbd> <kbd>←</kbd> <kbd>→</kbd> move within it. That is the whole reason a radio group is a component rather than a `<div>` full of inputs.
- The group's `label`, `description` and `error` are wired to it by Base UI's Field, and so is each option's own label — pressing a label chooses its option.
- Each dot is centred on its label's **first** line, so it stays put when a label wraps.
- A chosen dot is a filled disc, not a colour change alone: the shape carries the state for a reader who cannot see the fill.
- With `name`, Base UI renders the hidden input that makes the choice part of a native form submission.

:::

::: fw flutter

- Each option is announced as one of a mutually exclusive set, checked or not.
- The set takes **one** focus stop: exactly one option is in the tab order and the rest are wrapped in an `ExcludeFocus`, which is the roving tab index in one widget. <kbd>↑</kbd> <kbd>↓</kbd> <kbd>←</kbd> <kbd>→</kbd> move the choice, wrapping at both ends and skipping an option that cannot be chosen.
- Wrapping is what an arrow key does in a radio group and what it does not do in a list: the set is a ring of alternatives with no beginning.
- Pressing a label chooses its option: the whole row is the target.
- Each dot is centred on its label's **first** line, so it stays put when a label wraps.
- A chosen dot is a filled disc, not a colour change alone: the shape carries the state for a reader who cannot see the fill.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlRadio>` children | `options`, as descriptions | The group owns the roving focus and the arrow keys, so it has to know which option is chosen and what comes after it. A `Widget` is opaque. |
| `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| a value of `unknown`, compared by identity | a generic `T`, compared with `==` | Dart has generics, so the type is checked rather than hoped for — and a value with sensible equality does not have to stay identical between builds. |
| `name`, and a hidden input | — | There is no native form submission to be part of. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
