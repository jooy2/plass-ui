---
title: PlIconButton
order: 2
---

# PlIconButton

<p class="plass-lede">A round button with a glyph in it and nothing else. Everything about it is a <code>PlButton</code> except the shape and the one prop that is required. The words the drawing does not say.</p>

<Demo src="icon-button/hero" :min-height="120" />

::: fw react

```tsx
import { PlIconButton } from 'plass-ui';

<PlIconButton icon={<TrashIcon />} label="Delete" variant="glass" color="danger" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlIconButton(
  icon: const Icon(Icons.delete_outline),
  label: 'Delete',
  variant: PlassVariant.glass,
  color: PlassColor.danger,
  onPressed: remove,
);
```

:::

## Props

<PropsTable name="PlIconButton" />

::: fw react

Every prop `PlButton` takes passes through untouched except `children`, `startIcon` and `endIcon`, which the glyph has taken over. Every native `<button>` attribute passes through as well.

:::

::: fw flutter

Every parameter `PlButton` takes passes through except `child`, `startIcon`, `endIcon` and `fullWidth`. The glyph has taken the first three, and a disc that stretches is not a disc. There is no `density` either: it changes horizontal padding, and an icon-only button has none.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### label

Required, and the one prop here that is.

A button whose whole label is a drawing has no accessible name at all, and "an icon button with no <Fw react="aria-label" flutter="semantic label" code />" is the single most common accessibility defect a component library ships. Making it required is the only fix that survives review. A lint rule is something a project has to install and a default of `''` is something nobody notices.

It is never drawn. What a reader sees is the glyph; what everything else reads is the sentence.

### The shape

A `PlButton` with an icon and no label already goes square, same height, same width, the house fillet cut off it. This is the other shape: a disc.

That disc is a deliberate exception to the radius rule, which holds every corner well short of the 50% that would make a control a pill. The rule is about _labelled_ controls: the flat run along the top and bottom edge is where a line of text sits, and a glyph has no line of text. A circle with a single mark centred in it reads as a punched token rather than a moulded key.

<Demo src="icon-button/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/icon-button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/variants.dart

:::

</Demo>

### size

The same height ladder as `PlButton`, so a disc and a labelled button on one row keep their baseline. The glyph inside is sized in `em` against the button rather than off the standalone-icon ladder, which is what keeps it in proportion at every step.

<Demo src="icon-button/sizes" :min-height="300">

::: fw react

<<< @/.vitepress/demos/icon-button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/sizes.dart

:::

</Demo>

### color

<Demo src="icon-button/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/icon-button/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/colors.dart

:::

</Demo>

### loading, readOnly and disabled

All three are `PlButton`'s, unchanged. `loading` puts a spinner where the glyph was and stops the button firing while leaving it focusable; `readOnly` keeps the colour and drains the saturation; `disabled` takes the light out and leaves the focus order.

<Demo src="icon-button/states" :min-height="120">

::: fw react

<<< @/.vitepress/demos/icon-button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/states.dart

:::

</Demo>

## Accessibility

- `label` is the accessible name and it is required. Nothing else here can supply one.
- The glyph is decorative. It is inside a control that is already named, so a second name from the drawing would be the name read twice.
- Everything else is `PlButton`'s: the focus ring, the keyboard activation, `aria-busy` while loading, and dropping out of the focus order only when disabled.

::: fw react

- The disc is still a real `<button>`. `render={<a href="…" />}` makes it a real link instead, announced as one and followed by a crawler.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `onClick` | `onPressed` | Flutter's name, and leaving it out is how a button is disabled. |
| `render` | — | There is no element to swap and no link semantics to claim. |
| `density`, `fullWidth` | — | Density changes horizontal padding, which an icon-only button has none of; a disc that stretches is not a disc. |
| an inline `style` for the radius | `PlButton.borderRadius` | Flutter has no inline style, so `PlButton` carries one escape hatch and this is the widget it exists for. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

The radius is half the control height rather than a number large enough to be clamped: the paint scales a radius that is too big for its box, and a disc scaled that way stops being one at the ends.

:::
