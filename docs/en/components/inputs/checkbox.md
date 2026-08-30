---
title: PlCheckbox
order: 6
---

# PlCheckbox

<p class="plass-lede">A single yes/no, or one member of a set of them. The box is a small pane of clear glass until it is ticked, and then it is the colour family's gradient.</p>

<Demo src="checkbox/hero" :min-height="160" />

::: fw react

```tsx
import { PlCheckbox } from 'plass-ui';

<PlCheckbox label="Email me about releases" defaultChecked />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCheckbox(
  value: subscribed,
  onChanged: (bool next) => setState(() => subscribed = next),
  label: const Text('Email me about releases'),
);
```

:::

## Props

<PropsTable name="PlCheckbox" />

::: fw react

Every other prop on Base UI's `Checkbox.Root` passes straight through. `className` and `style` land on the field wrapper rather than on the tick, and `render` is not offered — replacing the tick would leave something that is no longer a checkbox.

`classNames` reaches the four parts inside that wrapper: `label`, `control` — the tick — `description` and `error`.

:::

::: fw flutter

The checkbox is **controlled**: it is handed a `value` and reports what the value should become. There is no uncontrolled form and no `defaultChecked` — Flutter's own controls work this way, and a widget that owned a copy of your state would be a widget your state could disagree with.

`onChanged: null` disables the checkbox, as it does everywhere else in Flutter.

:::

There is no `variant`. On and off are not two strengths of one material, so the box swaps its whole surface rather than shifting a step along a ladder — the one place in the library a state is expressed that way.

What the shared axes (`size` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### color

Ticked, the box fills with the family's gradient and the mark on it is the family's own `on-solid` ink, which is the value the contrast was measured against.

<Demo src="checkbox/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/checkbox/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox/colors.dart

:::

</Demo>

### size

The tick has its own ladder rather than a step off the control heights: it is not a control you can put a label inside, it is an indicator next to one, so it is sized against the text beside it. It also takes a much tighter radius — `--plass-radius-md` on an 18px box is most of the way to a circle, and a checkbox that is round is a radio button.

<Demo src="checkbox/sizes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/checkbox/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox/sizes.dart

:::

</Demo>

### indeterminate

The third state, for a parent box over a set of children: neither ticked nor cleared. The mark becomes a dash, and the box is announced as mixed rather than as checked.

It is a display state, not a value — pressing an indeterminate box ticks it.

<Demo src="checkbox/indeterminate" :min-height="240">

::: fw react

<<< @/.vitepress/demos/checkbox/indeterminate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox/indeterminate.dart

:::

</Demo>

### readOnly · disabled · error

`error` also turns the checkbox invalid, which re-points the whole colour family at `danger` — the box, the ring and the message turn over together.

<Demo src="checkbox/states" :min-height="280">

::: fw react

<<< @/.vitepress/demos/checkbox/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox/states.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI renders a `role="checkbox"` control with `aria-checked` and, with `name`, the hidden input that makes it part of a native form submission.
- `label`, `description` and `error` are wired to the control by Base UI's Field, so pressing the label ticks the box and a screen reader reads all three together.
- The tick is centred on the label's **first** line with `1lh`, so it stays put when the label wraps to three.
- `indeterminate` is announced as `aria-checked="mixed"`, and the dash rather than the check is what says so without colour.
- The focus ring only appears on `:focus-visible`, so a mouse press never draws one.
- A checkbox with no `label` needs an `aria-label` — a box with nothing beside it is a box nobody can name.

:::

::: fw flutter

- The tick, its label, its description and its error are **one** semantics node, checked or not, so a screen reader reads the whole thing once rather than four times.
- Pressing the label ticks the box: the whole row is the target, not the 18px square.
- The tick is centred on the label's **first** line — a box the height of one line box, whatever the type scale turns out to be — so it stays put when the label wraps to three.
- `indeterminate` is announced as mixed, and the dash rather than the check is what says so without colour.
- <kbd>Enter</kbd>, <kbd>Space</kbd> and the numpad <kbd>Enter</kbd> tick it. The focus ring only appears on what CSS calls `:focus-visible` — a keyboard reaching the control, never a pointer clicking it.
- A checkbox with no `label` needs a `semanticLabel` — a box with nothing beside it is a box nobody can name.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `defaultChecked` / `checked` | `value` and `onChanged` | Flutter's own controls are controlled. A widget that owned a copy of your state would be a widget your state could disagree with. |
| `onCheckedChange` | `onChanged` | Flutter's name. `onChanged: null` disables the checkbox, as it does everywhere else. |
| `name`, and a hidden input | — | There is no native form submission to be part of. |
| Base UI's `Field` wiring | one merged semantics node | The same result by a different route: label, description and error are read together because they are one node. |
| `aria-label` | `semanticLabel` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
