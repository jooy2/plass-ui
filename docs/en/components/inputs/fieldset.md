---
title: PlFieldset
order: 19
---

# PlFieldset

<p class="plass-lede">A group of controls that answer one question together, with a name on it. It draws no surface. A grouping is not a sheet, and the sheet already exists.</p>

<Demo src="fieldset/hero" :min-height="300" />

::: fw react

```tsx
import { PlFieldset, PlTextField } from 'plass-ui';

<PlFieldset legend="Billing address" description="Where the invoice goes.">
  <PlTextField label="Street" />
  <PlTextField label="City" />
</PlFieldset>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlFieldset(
  legend: const Text('Billing address'),
  description: const Text('Where the invoice goes.'),
  children: <Widget>[streetField, cityField],
);
```

:::

## Props

<PropsTable name="PlFieldset" />

::: fw react

Every native `<fieldset>` attribute passes straight through. `color` is excluded because a fieldset has no surface to colour.

The border, the padding and the margin a browser gives a `<fieldset>` are undone, and so is its `min-width: min-content`, so a fieldset holding a wide table shrinks inside a flex row as any other box does.

:::

It owns three things, and nothing else:

- **The legend**, <Fw react="which names the group." flutter="which is read first, before the controls." />
- **The gap** the controls stand at, on the sheet ladder.
- **`disabled`**, which reaches every control inside, including one a component three levels down rendered and never heard of.

It draws no surface and takes no `color`, `variant` or `elevation`. Put it inside a [`PlCard`](../surfaces/card) or a [`PlBox`](../surfaces/box) when a sheet is wanted.

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### disabled

The reason to use a fieldset rather than a <Fw react="`<div>`" flutter="`Column`" />. Turning it on takes every control inside out of the tab order <Fw react="and out of the form" flutter="and out of the pointer's reach, and drains the group" />, without the fieldset knowing what any of them are.

<Demo src="fieldset/disabled" :min-height="280">

::: fw react

<<< @/.vitepress/demos/fieldset/disabled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/disabled.dart

:::

</Demo>

### size

The legend's type scale and the gap between the controls, on the sheet ladder, the same one a [`PlCard`](../surfaces/card) scores its sections with, because a fieldset is a section of a form rather than a control in one.

<Demo src="fieldset/sizes" :min-height="360">

::: fw react

<<< @/.vitepress/demos/fieldset/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/sizes.dart

:::

</Demo>

### Inside a sheet

Two fieldsets on one card is the usual arrangement, and it is what makes the no-surface rule pay: the card is the sheet, and each group is a name and a gap on it.

<Demo src="fieldset/on-a-sheet" :min-height="360">

::: fw react

<<< @/.vitepress/demos/fieldset/on-a-sheet.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/on_a_sheet.dart

:::

</Demo>

## Accessibility

- The legend is read out with the controls inside, so write a phrase that still reads correctly in front of each of them: "Billing address", not "Where should we send it?".
- A fieldset with neither `legend` nor `description` draws no heading block at all. An empty name is worse than none: it puts a blank in front of every control's own.

::: fw react

- It is a real `<fieldset>`, which is a `group`, and the legend names it.
- The legend is a `<div>` pointed at by `aria-labelledby` rather than a rendered `<legend>`. That is Base UI's decision, and it is what makes the group an ordinary flex container: a real `<legend>` is lifted out of its fieldset's content box by every browser, so a `gap` would put no space under it at all.
- `disabled` on the fieldset is the native attribute, so it disables descendants the way the platform does, no context, no prop threading, and nothing to forget on a control that was added later.

:::

::: fw flutter

- It is one semantics container, and the legend and the description are the first things in it, so a screen reader reads them before the controls. The container itself has no name: Flutter's semantics have no group role for a legend to name.
- `disabled` takes the pointer and the focus away from everything inside, a control a widget three levels down drew included, and drains the group. A control inside still reports itself to a screen reader as enabled, because Flutter has no attribute that every widget below reads the way a browser applies `<fieldset disabled>`. Give a field that has to say it is unavailable its own `disabled`.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `disabled` as the native `<fieldset>` attribute | the pointer taken away, the focus taken away, the group drained | There is no such cascade in Flutter. This does the three things the attribute actually buys; what it cannot do is make a field inside _report_ itself as unavailable, so a field that has to say so is given its own `disabled`. |
| a `<fieldset>` whose browser border, padding, margin and `min-width` are undone | a `Column` | There is nothing to undo. |
| the legend as part of every control's accessible name | the legend as plain text at the top of one unnamed semantics container, not marked as a header | Flutter's semantics have no group role for a legend to name, and prefixing every control's own name would say the group's name once per control. |
| `children` | `children: List<Widget>` | The stack is laid out here, so it counts what it is given. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
