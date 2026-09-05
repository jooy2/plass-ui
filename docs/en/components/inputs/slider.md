---
title: PlSlider
order: 5
---

# PlSlider

<p class="plass-lede">A value chosen along a range. The rail is a neutral groove and the run that fills it is the same gradient a button is made of.</p>

The rail is `--plass-track`, the same ink a `PlSwitch`'s off state is. It is not the glass with an inset shadow in it, which is what a filled field is: a field is a box you look _into_, and a rail is a line you look _along_, and the part of a rail that matters is the part with nothing on it, which is exactly the part a white-on-white groove does not have.

<Demo src="slider/hero" :min-height="120" />

::: fw react

```tsx
import { PlSlider } from 'plass-ui';

<PlSlider label="Volume" value={volume} onValueChange={setVolume} showValue />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSlider(
  label: const Text('Volume'),
  values: <double>[volume],
  showValue: true,
  onChanged: (List<double> next) => setState(() => volume = next.first),
);
```

:::

## Props

<PropsTable name="PlSlider" />

::: fw react

Every other prop on Base UI's `Slider.Root` passes straight through, `minStepsBetweenValues`, `largeStep`, `format`, `onValueCommitted`, `name`, `disabled`.

:::

::: fw flutter

`values` is always a list, even for a single value: it is the same parameter either way, and the length is what makes it a range.

:::

There is no `variant` here. The three materials answer "what is this surface made of", and a slider is two surfaces at once: a groove and a key travelling along it. Neither has a choice to offer.

The thumb **travels** to a value it was not dragged to: an arrow key, a press on the rail, or a value set from elsewhere. It moves over the same duration everything else here does, and the run behind it fills at the same rate. Under a finger it does not travel at all, because a thumb that eased towards the pointer would lag behind it. This is the one place in the library a position is animated, and it keeps the [no-transform rule](../../design/design-language#controls-do-not-move): what moves is the value, not the control.

What the shared axes (`size` `color` `elevation` `orientation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Range

Pass more than one value and it becomes a range slider with one thumb per entry. There is no separate `range` prop, because the shape of the value already says which one this is.

::: fw flutter

The thumbs cannot cross: a value is held between its neighbours, so a range whose ends have swapped is a range that was entered backwards, and the fix lives here rather than in every caller.

:::

<Demo src="slider/range" :min-height="120">

::: fw react

<<< @/.vitepress/demos/slider/range.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/range.dart

:::

</Demo>

### color

The filled run is the family's gradient, the same two-stop sweep at 135° a `solid` button carries, and the thumb sits on it, ringed in the page's own surface colour so it never dissolves into the run behind it.

<Demo src="slider/colors" :min-height="280">

::: fw react

<<< @/.vitepress/demos/slider/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/colors.dart

:::

</Demo>

### min · max · step

`step` decides what the thumb can land on. A slider with five stops is still a slider and not a segmented control: it is chosen by dragging, and the values are on a scale.

<Demo src="slider/steps" :min-height="260">

::: fw react

<<< @/.vitepress/demos/slider/steps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/steps.dart

:::

</Demo>

### showValue

::: fw react

`true` prints the raw value; a function is handed both Base UI's already-localised strings and the raw numbers, so a currency, a percentage or a duration is one line.

:::

::: fw flutter

`showValue` turns the number on and `formatValue` decides what it says, a currency, a percentage, a duration. Left out, the values are printed with no decimals and joined with an en dash.

:::

The value sits at the end of the label's row rather than following the thumb. A number that moves is a number that is hard to read and impossible to compare between two sliders stacked on each other.

### size

Moves the groove, the thumb and the label together. The thumb is deliberately far bigger than the groove at every step. It is the only part of the control you can actually catch, and a thumb sized to match a 6px rail is a thumb nobody hits on a touchscreen.

<Demo src="slider/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/slider/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/sizes.dart

:::

</Demo>

### orientation

A vertical slider has no length of its own, so it is given one: 160px by default. <Fw react="Override it with a class" flutter="`length` overrides it" /> when a mixer needs taller faders.

<Demo src="slider/orientation" :min-height="220">

::: fw react

<<< @/.vitepress/demos/slider/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/orientation.dart

:::

</Demo>

### disabled

The light going out, as everywhere else: the shape and the position stay, the saturation and half the opacity go.

<Demo src="slider/states" :min-height="140">

::: fw react

<<< @/.vitepress/demos/slider/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/states.dart

:::

</Demo>

## Accessibility

::: fw react

- Each thumb is a real `<input type="range">`, so the browser's own slider semantics, the tab order and `disabled` all come for free.
- `label` is wired to the control by Base UI. Without one, a fader in a bank of them, give the slider an `aria-label`.
- The keyboard is the primitive's: <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd> step, <kbd>PageUp</kbd> / <kbd>PageDown</kbd> take the large step, <kbd>Home</kbd> and <kbd>End</kbd> jump to the ends.
- The whole strip is a pointer target, not just the rail: the control box is several times the groove's thickness, so a press anywhere along it moves the thumb.
- The thumb grows a halo on hover and while dragging rather than growing itself. Nothing under the finger is ever scaled.
- `showValue` is a rendered number, not a substitute for the accessible value. That is `aria-valuenow` on the input, which Base UI keeps in step.

:::

::: fw flutter

- Announced as a slider, with the current value as its value. Without a visible `label`, a fader in a bank of them, give it a `semanticLabel`.
- <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd> move a thumb by one `step`, <kbd>PageUp</kbd> / <kbd>PageDown</kbd> by a tenth of the range, and <kbd>Home</kbd> and <kbd>End</kbd> jump to the ends.
- Each thumb is its own focus stop, which is what makes a range slider operable: <kbd>Tab</kbd> moves between the two ends.
- The whole strip is a pointer target, not just the rail: the control box is several times the groove's thickness, so a press anywhere along it moves the nearest thumb.
- The thumb grows a halo on hover and while dragging rather than growing itself. Nothing under the finger is ever scaled.
- `showValue` is a drawn number, not a substitute for the announced one.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `value` as a number or an array | `values`, always a list | One parameter either way, and the length is what makes it a range. |
| `onValueChange` / `onValueCommitted` | `onChanged` / `onChangeEnd` | Flutter's names for "as it moves" and "when it is let go". |
| `showValue` as boolean-or-function | `showValue` and `formatValue` | Dart has no union type, so turning the number on and deciding what it says are two parameters. |
| `<input type="range">` | a drawn strip with its own key handling | There is no native range input to inherit a keyboard from, so the keys are bound here, the same set, including <kbd>Page</kbd> and <kbd>Home</kbd>/<kbd>End</kbd>. |
| `aria-label` | `semanticLabel` | Flutter's name. |
| `className` for a vertical slider's height | `length` | There is no class list; the length is a parameter. |

:::
