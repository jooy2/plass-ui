---
title: PlSegmentedButton
order: 10
---

# PlSegmentedButton

<p class="plass-lede">Two or more choices in one pill, exactly one of them taken. The tile slides from the segment you left to the one you chose.</p>

<Demo src="segmented-button/hero" :min-height="120" />

::: fw react

```tsx
import { PlSegment, PlSegmentedButton } from 'plass-ui';

<PlSegmentedButton aria-label="Period" value={period} onValueChange={setPeriod}>
  <PlSegment value="day">Day</PlSegment>
  <PlSegment value="week">Week</PlSegment>
</PlSegmentedButton>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSegmentedButton<String>(
  semanticLabel: 'Period',
  value: period,
  onChanged: (String next) => setState(() => period = next),
  segments: const <PlSegment<String>>[
    PlSegment<String>(value: 'day', label: Text('Day')),
    PlSegment<String>(value: 'week', label: Text('Week')),
  ],
);
```

:::

## Props

<PropsTable name="PlSegmentedButton" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, `defaultValue` and `onChange` because the set spells them `defaultValue` (a segment value) and `onValueChange`.

:::

::: fw flutter

The set is generic in its segment's type — `PlSegmentedButton<String>`, `PlSegmentedButton<Period>` — so `value` and `onChanged` are typed rather than `dynamic`, and it is **controlled**, like every other control in the package.

:::

### PlSegment

<PropsTable name="PlSegment" />

::: fw react

`variant`, `size` and `density` are read from the `PlSegmentedButton` around the segment, not set on it. A segmented button whose third segment is a size out is not a segmented button.

:::

::: fw flutter

A segment is a **`PlSegment`, a description rather than a widget**, for the reason a [radio option](./radio-group) is one: the set owns the roving focus, the arrow keys and the tile that slides between the segments, so it has to know which one is taken and where each one is.

It carries no `variant`, no `size` and no `density`, and could not. A segmented button whose third segment is a size out is not a segmented button.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Segmented button, tabs or select?

- **Segmented button** — a handful of short, mutually exclusive choices that filter what is already on screen: a period, a scope, a layout.
- **Tabs** — the choice swaps whole panels of content.
- **Select** — more than about five options, or long ones.

## Examples

### variant

The groove carries `--plass-well`, the one inset shadow in the library and the same one a `solid` field is drawn with. Those two are the whole of its use: a groove and a filled field are both a box something _sits in_. A slider's rail is not one, and no longer takes it — a rail is a line you look along.

`solid` puts the family's gradient in the tile with that family's tinted shadow under it, which is the design language's own sentence with nothing added: a key of tinted glass riding in a groove. `glass` and `ghost` lift a pane of clear glass instead and leave the label in the accent.

<Demo src="segmented-button/variants" :min-height="220">

::: fw react

<<< @/.vitepress/demos/segmented-button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/variants.dart

:::

</Demo>

### color

<Demo src="segmented-button/colors" :min-height="220">

::: fw react

<<< @/.vitepress/demos/segmented-button/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/colors.dart

:::

</Demo>

### size

The same height ladder as `PlButton`, so a segmented button in a toolbar lines up with the buttons beside it.

<Demo src="segmented-button/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/segmented-button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/sizes.dart

:::

</Demo>

### fullWidth

The segments share the row and take an equal part of it each. The tile is re-measured after every layout, so it stays under its segment while the container changes width.

<Demo src="segmented-button/full-width" :min-height="120">

::: fw react

<<< @/.vitepress/demos/segmented-button/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/full_width.dart

:::

</Demo>

### startIcon and endIcon

Both are sized against the label rather than against the row. An icon-only segment still needs a name of its own.

<Demo src="segmented-button/icons" :min-height="120">

::: fw react

<<< @/.vitepress/demos/segmented-button/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/icons.dart

:::

</Demo>

## Accessibility

::: fw react

- The set is a `role="radiogroup"` and each segment is a real radio, which is the whole accessibility argument: a segmented button **is** "exactly one of these". Built out of `aria-pressed` toggles it would announce four independent switches, three of which happen to be off.
- One tab stop for the whole set; <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd> move within it. Base UI owns the roving tab index.
- Give the set an `aria-label`. It has no visible label of its own, and a group with no name is a group a screen reader announces as "radio group".

:::

::: fw flutter

- Each segment is announced as one of a mutually exclusive set, taken or not — a segmented button **is** "exactly one of these". Built out of toggles it would announce four independent switches, three of which happen to be off.
- **One** focus stop for the whole set: exactly one segment is in the tab order and the rest are wrapped in an `ExcludeFocus`. <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd> move the choice, wrapping at both ends.
- A segment's focus ring turns **inward**, because a ring drawn outside one inside a groove would be painted over its neighbours.
- Give the set a `semanticLabel`. It has no visible label of its own.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlSegment>` children | `segments`, as descriptions | The set owns the roving focus, the arrow keys and the sliding tile, so it has to know which one is taken and where each one is. |
| `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| a value of `string \| number` | a generic `T` | Dart has generics, so the type is checked rather than restrained by convention. |
| four CSS custom properties on the tile | a measured `Rect` and an `AnimatedPositioned` | The same idea — measure the chosen segment, animate the box — in Flutter's words. Nothing is transformed either way. |
| `aria-label` | `semanticLabel` | Flutter's name. |
| `name`, and a hidden input | — | There is no native form submission to be part of. |

:::

- The focus ring is drawn **inset**, because an offset ring on a segment inside a groove would be painted over its neighbours.
- The tile animates `left`, `top`, `width` and `height` rather than a `transform`: it is an empty box, so no label is resampled while it travels. That is what lets the house no-transform rule survive a component whose entire point is that something moves.
- The first choice of an empty set appears **in place** rather than flying in from the left edge — the tile is not mounted until there is something to sit under.
