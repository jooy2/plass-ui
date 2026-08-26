---
title: PlChip
order: 10
---

# PlChip

<p class="plass-lede">A compact token: a tag, a filter, a status, an entity plucked out of a list. It can carry a count, be pressed, be removed, or all three at once.</p>

<Demo src="chip/hero" :min-height="180" />

::: fw react

```tsx
import { PlChip } from 'plass-ui';

<PlChip>design</PlChip>;
<PlChip selected onClick={toggle} count={12}>
  open
</PlChip>;
<PlChip onDelete={remove}>infra</PlChip>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlChip(child: Text('design'));
PlChip(selected: on, onPressed: toggle, count: const Text('12'), child: const Text('open'));
PlChip(onDeleted: remove, child: const Text('infra'));
```

:::

## Props

<PropsTable name="PlChip" />

::: fw react

Every native `<span>` attribute passes straight through, onto the shell. `color` is excluded from the pass-through because it is a Plass prop here.

:::

::: fw flutter

`count` is a `Widget?` rather than a number, because unlike a badge's it is never capped — the plate holds whatever it is given.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### <Fw react="onClick and onDelete" flutter="onPressed and onDeleted" />

::: fw react

The shell is always a `<span>`. What changes is what is inside it: a plain run of content, or — when `onClick` is given — a real `<button>` wrapping that content, plus a second button for `onDelete`.

That is not indirection. A `<button>` inside a `<button>` is invalid HTML that browsers un-nest on parse, so keeping the shell a `<span>` is what lets "activate this chip" and "remove this chip" both be real, focusable buttons.

:::

::: fw flutter

A chip that can be pressed and a chip that can be removed are two separate focus stops, and neither is inside the other's gesture recogniser. The reason is the same one the React build has for keeping the shell a `<span>`, arrived at from the other end: a tap that reached both would fire both.

A chip with no `onPressed` takes no focus stop and is announced as content rather than as a button. It is a tag, and a tag is not something you press.

:::

<Demo src="chip/interactive" :min-height="140">

::: fw react

<<< @/.vitepress/demos/chip/interactive.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/interactive.dart

:::

</Demo>

### variant

A chip **is** the thing being coloured — a tag names one particular thing — so unlike a `PlCard` its sheet takes the tint. `ghost` keeps a wash at rest rather than being bare, which is the difference between a token and a control: a ghost _button_ has nothing until the pointer arrives.

`glass` is the default rather than `solid`. A filter bar is a row of chips, and a row of gradient keys is a row in which nothing is the primary action because everything is.

<Demo src="chip/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/chip/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/variants.dart

:::

</Demo>

### selected

Chosen moves the chip one step up the ladder its own variant already sits on, rather than changing the colour family: a filter that is on is still the same filter.

`solid` has no opacity ladder to climb, because a gradient fill is the fill. So it answers the other way the design language allows — it casts its own colour onto the sheet under it. A chosen key lifts; an unchosen one lies flat.

<Demo src="chip/selected" :min-height="200">

::: fw react

<<< @/.vitepress/demos/chip/selected.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/selected.dart

:::

</Demo>

### startIcon, endIcon and count

`count` is drawn on its own small plate, so "Errors 12" reads as one token with a count rather than as two words.

<Demo src="chip/slots" :min-height="120">

::: fw react

<<< @/.vitepress/demos/chip/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/slots.dart

:::

</Demo>

### color

<Demo src="chip/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/chip/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/colors.dart

:::

</Demo>

### size

A chip sits one step down the control ladder from everything else: a `md` chip is a `sm` control, 32px rather than 40px. At full control height a `glass` chip and a `glass` button are the same object, and a screen full of them says nothing about which one can be pressed.

<Demo src="chip/sizes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/chip/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- A chip with `onClick` is a real `<button>` carrying `aria-pressed`, so a filter that is on says so. A chip without one adds no role and takes no tab stop — an inert `<span>` with a click handler on it is the single most common way a component library loses its keyboard users.
- The label and the delete button are two separate tab stops, and neither is nested inside the other.
- The delete button has an accessible name already; `deleteLabel` is what changes it.
- `disabled` stops the label from being a button at all rather than leaving a focusable one that does nothing, and marks the shell `aria-disabled` so the state is still announced.

:::

::: fw flutter

- A chip with `onPressed` is announced as a button and reports whether it is selected, so a filter that is on says so. A chip without one adds no role and takes no focus stop.
- The label and the delete affordance are two separate focus stops, and neither is inside the other.
- The delete affordance has a name already — "Remove"; `deleteLabel` is what changes it.
- <kbd>Enter</kbd>, <kbd>Space</kbd> and the numpad <kbd>Enter</kbd> activate a pressable chip. They are bound on the chip itself, so it behaves the same with or without an app widget above it.
- `disabled` takes the chip out of the focus order and stops it firing, and the delete affordance with it.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `onClick` | `onPressed` | Flutter's name. |
| `onDelete` | `onDeleted` | Flutter's name for the same slot. |
| a `<button>` inside a `<span>` | two sibling focus stops | The same shape for the same reason. HTML forbids the nesting; here a nested recogniser would take one tap twice. |
| `count` as a `ReactNode` | `count` as a `Widget?` | The same thing, spelled in Flutter. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
