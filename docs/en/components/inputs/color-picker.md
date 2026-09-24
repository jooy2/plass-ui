---
title: PlColorPicker
order: 20
---

# PlColorPicker

<p class="plass-lede">A colour, chosen by eye. A saturation square with a hue rail beside it. The arrangement every design tool has settled on, because it puts every colour of a hue within one movement of the pointer.</p>

<Demo src="color-picker/hero" :min-height="220" />

::: fw react

```tsx
import { PlColorPicker } from 'plass-ui';

<PlColorPicker label="Project colour" value={color} onValueChange={setColor} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlColorPicker(
  label: const Text('Project colour'),
  value: colour,
  onValueChanged: (String next) => setState(() => colour = next),
);
```

:::

## Props

<PropsTable name="PlColorPicker" />

::: fw react

Every native `<div>` attribute passes straight through to the wrapper. `color` is excluded because it is a Plass prop here (the _family_ the control lights up in, not the colour it is holding), and `defaultValue` / `onChange` because the picker spells them as a value and an `onValueChange`.

:::

The panel holds a hue, a saturation and a value, and the string it hands back is derived from them. An incoming `value` that names the colour the panel already holds, such as `#FF0000` for `#ff0000`, leaves the panel where it is, so the hue rail stays put across the bottom of the square, where every colour is black.

It reads hex in all four lengths, and `rgb()`, `rgba()`, `hsl()` and `hsla()` in both the comma and the space syntax. It does not read named colours or `color()`, and it depends on no colour library. [Design language](../../design/design-language#no-library-for-what-the-platform-already-knows) has the reasons for both.

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### inline

Draws the panel in the page with no trigger, for a sidebar or a settings pane where the colour is the thing being edited rather than one field among ten.

<Demo src="color-picker/inline" :min-height="360">

::: fw react

<<< @/.vitepress/demos/color-picker/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/inline.dart

:::

</Demo>

### format

Which notation the value is written in on the way out: `hex`, `rgb` or `hsl`.

All three drop their alpha when the colour is opaque, a caller who never turned `alpha` on should never see `rgba(…, 1)` come out of a control they only used three channels of.

<Demo src="color-picker/formats" :min-height="160">

::: fw react

<<< @/.vitepress/demos/color-picker/formats.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/formats.dart

:::

</Demo>

### alpha

Adds a third rail and lets the value carry a fourth channel. The rail is drawn over a chequerboard, which shows through as the colour grows more transparent.

<Demo src="color-picker/alpha" :min-height="420">

::: fw react

<<< @/.vitepress/demos/color-picker/alpha.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/alpha.dart

:::

</Demo>

### swatches

The handful of colours a product actually uses, one click away. Pass an array to replace the built-in set, or `false` to draw none.

The built-in set is a plain spectrum plus the greys, and it is deliberately **not** the library's own six families: those are semantic roles, and a picker is asked for a colour rather than for a meaning.

A chosen swatch is ticked in black or white, decided by relative luminance. A fixed white tick disappears on yellow, and lightness alone puts it the wrong way round on green.

<Demo src="color-picker/swatches" :min-height="380">

::: fw react

<<< @/.vitepress/demos/color-picker/swatches.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/swatches.dart

:::

</Demo>

### readOnly · disabled · error

`error` turns the control invalid, which re-points the whole colour family at `danger`, the edge, the ring and the message turn over together. `invalid` does the same without a message.

A `readOnly` picker shows its colour and takes nothing: the rails keep their values and lose their tab stops. A `disabled` one leaves the tab order.

<Demo src="color-picker/states" :min-height="180">

::: fw react

<<< @/.vitepress/demos/color-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/color_picker/states.dart

:::

</Demo>

## Accessibility

- The square and each rail are real `slider`s with `aria-valuenow`, moved by the arrow keys, one step, or ten with <kbd>Shift</kbd>, which is the same pair every slider in the library uses.
- A rail lies across and still answers the keys any slider does: <kbd>→</kbd> and <kbd>↑</kbd> are more, <kbd>←</kbd> and <kbd>↓</kbd> are less, and <kbd>Home</kbd> and <kbd>End</kbd> go to its two ends.
- The square reports both of its channels: `aria-valuenow` is the saturation and `aria-valuetext` is `"saturation%, brightness%"`, because one number cannot describe a point on a plane.
- The hue rail **wraps** rather than stopping: a step back from red is 358°, not 0°. The wheel is a circle and the rail is a picture of one.
- A key the picker does not answer to is left alone, so <kbd>Tab</kbd> moves on rather than being swallowed by a gradient.
- Every swatch is a real `<button>` named by its own colour, with `aria-pressed` on the chosen one.
- `labels` renames any of the parts that have no text on them. They are all named by default, in English.
- A drag takes pointer capture on the element, so a pointer that leaves the panel mid-drag keeps changing the colour rather than dropping it.
- With `clearable`, the × is a tab stop of its own after the trigger. Clearing the value from it hands the focus back to the trigger, so the reader stays on the field they emptied.

::: fw react

- An `inline` picker is a `role="group"` named by `label` and described by `description` and `error`, so two of them on one page are not two sets of sliders called "Hue". An `error` also marks the square and the rails `aria-invalid`.

:::

::: fw flutter

- An `inline` picker is one semantics node over its `label`, `description` and `error`, with the square and the rails inside it, so two of them on one screen are not two sets of sliders called "Hue". An `error` also marks the square and the rails invalid.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `value` / `defaultValue` | `value`, nullable | `null` is "the picker's own blue"; the caller owns the string from the first change onwards, as it does for every other field in this package. |
| `swatches: false` | `swatches: []` | An empty list is the same statement without a second type. |
| `open` / `defaultOpen` / `onOpenChange` | — | The popup is the picker's own; there is no route guard shape here that needs to hold it. |
| `name`, the hidden input | — | There is no native form submission to be part of. |
| a chequer of four linear gradients | a painter | A `CustomPainter` has no seam to avoid and no tiling to fight. |
| `labels` as a partial | `PlColorPickerLabels`, a class with defaults | Dart names its optional fields; a partial of a record is not a thing it has. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
