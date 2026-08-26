---
title: PlSwitch
order: 8
---

# PlSwitch

<p class="plass-lede">An immediate on/off. The track is a neutral groove while it is off, and the colour family's gradient once it is on.</p>

<Demo src="switch/hero" :min-height="160" />

::: fw react

```tsx
import { PlSwitch } from 'plass-ui';

<PlSwitch label="Dark mode" checked={dark} onCheckedChange={setDark} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSwitch(
  value: dark,
  onChanged: (bool next) => setState(() => dark = next),
  label: const Text('Dark mode'),
);
```

:::

## Props

<PropsTable name="PlSwitch" />

::: fw react

Every other prop on Base UI's `Switch.Root` passes straight through. `className` and `style` land on the field wrapper rather than on the track, and `render` is not offered.

:::

::: fw flutter

The switch is **controlled**, like every other control in the package: it is handed a `value` and reports what the value should become. `onChanged: null` disables it.

:::

There is no `variant`, for the reason a `PlCheckbox` has none: on and off are not two strengths of one material.

What the shared axes (`size` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Switch or checkbox?

The difference is not visual, it is **temporal**. A checkbox is a value that gets submitted with a form; a switch takes effect the moment it moves. If there is a Save button underneath, it should have been a checkbox.

## Examples

### color

On, the track is the family's gradient with that family's tinted shadow under it. Off, it is the **groove** — the same neutral ink a `PlSlider`'s rail is, so the two controls in a settings panel are visibly made of the same thing.

The thumb is white in both states and in both themes: it is the light on the track, not a second coloured object, and a coloured thumb on a coloured track is two things fighting over sixteen pixels.

There is no inset shadow under the off track and no hairline round it. An off state drawn as the glass at its most opaque is a white pill with a white thumb in it, which on a light page is a switch nobody can find until they have already flipped it — and where it _was_ visible, in the dark, a recessed slot under a domed thumb was the moulded rocker this design language exists not to draw.

<Demo src="switch/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/switch/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/colors.dart

:::

</Demo>

### size

The thumb is inset 2px on every side, so its diameter is the track's height minus four at every step and the two never drift apart.

<Demo src="switch/sizes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/switch/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/sizes.dart

:::

</Demo>

### labelPlacement

<Fw react="end" flutter="PlassAlign.end" code /> (the default) reads as a caption for the control. <Fw react="start" flutter="PlassAlign.start" code /> is for a settings list: the labels form a column and every switch lines up against the trailing edge of the row.

<Demo src="switch/placement" :min-height="220">

::: fw react

<<< @/.vitepress/demos/switch/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/placement.dart

:::

</Demo>

### readOnly · disabled

<Demo src="switch/states" :min-height="220">

::: fw react

<<< @/.vitepress/demos/switch/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/states.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI renders a `role="switch"` control with `aria-checked`, and with `name` the hidden input that makes it part of a native form submission.
- `label`, `description` and `error` are wired to the control by Base UI's Field, so pressing the label flips the switch.
- <kbd>Space</kbd> and <kbd>Enter</kbd> both flip it; the focus ring appears only on `:focus-visible`.
- The thumb's position is not the only signal — the track changes material as well, so the state survives a reader who cannot tell the two ends of a 36px pill apart.
- The thumb is the one thing in the library that moves, and it carries no text — the no-transform rule is about a control resampling its own label under the finger, which this cannot do. It travels in one house duration, the same 150ms everything else changes in.
- A switch with no `label` needs an `aria-label`.

:::

::: fw flutter

- The track, its label and its description are **one** semantics node, announced as toggled or not.
- Pressing the label flips the switch: the whole row is the target.
- <kbd>Enter</kbd>, <kbd>Space</kbd> and the numpad <kbd>Enter</kbd> flip it; the focus ring only appears on what CSS calls `:focus-visible`.
- The thumb's position is not the only signal — the track changes material as well, so the state survives a reader who cannot tell the two ends of a 36px pill apart.
- The thumb is the one thing in the library that moves, and it carries no text. It travels in one house duration, the same 150ms everything else changes in.
- A switch with no `label` needs a `semanticLabel`.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `checked` / `onCheckedChange` | `value` / `onChanged` | Flutter's names, and `onChanged: null` disables the switch as it does everywhere else. |
| `name`, and a hidden input | — | There is no native form submission to be part of. |
| `labelPlacement="start"` | `labelPlacement: PlassAlign.start` | The same value out of the shared vocabulary; `PlassAlign.center` asserts, because a switch label sits at one end of a row or the other. |
| `aria-label` | `semanticLabel` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
