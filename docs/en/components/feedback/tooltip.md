---
title: PlTooltip
order: 6
---

# PlTooltip

<p class="plass-lede">A short label that appears when the pointer rests on something. The whole component is a wrapper. It adds no element to the layout, and the child stays whatever it was.</p>

<Demo src="tooltip/hero" :min-height="140" />

::: fw react

```tsx
import { PlTooltip } from 'plass-ui';

<PlTooltip content="Copy to clipboard">
  <PlButton aria-label="Copy">
    <CopyIcon />
  </PlButton>
</PlTooltip>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTooltip(
  content: const Text('Copy to clipboard'),
  child: PlButton(
    semanticLabel: 'Copy',
    onPressed: copy,
    child: const PlIcon(icon: CopyGlyph()),
  ),
);
```

A tooltip lifts its plate out of the tree, so it needs an `Overlay` above it, `WidgetsApp` with a navigator and `MaterialApp` both provide one. The wrapper itself adds no box to the layout.

:::

## Props

<PropsTable name="PlTooltip" />

::: fw react

Every native `<div>` attribute passes straight through, onto the plate. `color`, `content` and `children` are excluded from the pass-through because all three are Plass props here.

:::

::: fw flutter

`open` is a `bool?`, and `null` (the default) is the tooltip driving itself from the pointer, a long press and focus. It is the **one place in the package where a component owns its own state**: everything else is controlled because a caller has an opinion about the value, and nobody has an opinion about whether a pointer is resting on a button. `onOpenChanged` reports either way.

There is no `color`. A tooltip is a note about something, never the thing itself, so the plate is always the neutral sheet. A red tooltip on a delete button would be saying something the tooltip does not know.

:::

There is no `variant` and no `elevation`. The plate is the same floating sheet a `PlSelect`'s popup is (the glass at its most opaque, a white hairline round it, a shadow at the top of the ladder under it) rather than the filled key most libraries draw a tooltip as. A tooltip is a note _about_ something, not a thing to press, and a second kind of floating sheet on one screen is one too many.

What the shared axes (<Fw react="`size` `color` `density` `side` `align`" flutter="`size` `density` `side` `align`" />) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### side and align

`side` flips to the opposite edge when there is no room, which is the right behaviour: a tooltip half off the screen says nothing.

::: fw flutter

It is a **flip and not a slide**. When the side that was asked for has no room the plate goes to the opposite one; it never shifts along the edge it is on. Sliding needs the plate's position recomputed against the viewport every frame, which is exactly what the layer link that keeps it stuck to a scrolling anchor exists to avoid, and a plate that creeps sideways as its trigger nears the edge is a plate whose wedge no longer points at anything.

:::

<Demo src="tooltip/sides" :min-height="200">

::: fw react

<<< @/.vitepress/demos/tooltip/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/sides.dart

:::

</Demo>

<Demo src="tooltip/align" :min-height="180">

::: fw react

<<< @/.vitepress/demos/tooltip/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/align.dart

:::

</Demo>

### PlTooltipProvider

Shares one delay across a group of tooltips: once any of them has opened, its neighbours open instantly, and the wait comes back after a pause.

Worth wrapping a toolbar in. Without it, moving along a row of icon buttons means waiting out the full delay at every stop, which is what makes tooltips feel like they are fighting the pointer.

<PropsTable name="PlTooltipProvider" />

<Demo src="tooltip/provider" :min-height="120">

::: fw react

<<< @/.vitepress/demos/tooltip/provider.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/provider.dart

:::

</Demo>

### delay, closeDelay and disabled

`disabled` stops the tooltip from opening without disabling the trigger, for the tooltip that only exists while a label is truncated.

::: fw flutter

Both delays are `Duration`s rather than numbers. A tooltip opened by a **long press** is on its own clock: it stays up for a second and a half after the finger lifts, because a pointer leaving is a reader who has stopped looking and a finger lifting is a reader who has just started.

:::

<Demo src="tooltip/delay" :min-height="120">

::: fw react

<<< @/.vitepress/demos/tooltip/delay.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/delay.dart

:::

</Demo>

### size

<Demo src="tooltip/sizes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/tooltip/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- The plate carries `role="tooltip"` and the trigger an `aria-describedby` pointing at it. **only while it is open**, because a reference to an element that is not in the document is a reference to nothing. Base UI leaves both to the caller, since a popup can be many things; here it is always a tooltip, so the component wires them.
- Base UI's Trigger merges onto the child rather than rendering a box of its own, so the tooltip adds no element to the layout and no tab stop of its own.
- It opens on focus, but not on a focus that arrived from a click, and it closes on Escape. All three are the primitive's.
- **A tooltip is not a label.** It describes; it does not name. An icon-only button needs its own `aria-label` as well. A trigger with no accessible name is unreachable by voice control, and its tooltip is not on the page to supply one.
- Nothing inside a tooltip can be clicked, and on a touch screen there is no pointer to rest. Content that needs either belongs somewhere that stays put.

:::

::: fw flutter

- The **trigger** carries what the plate says, as its tooltip, which is how a screen reader gets it: the plate itself is excluded from semantics, because a floating node repeating the phrase is a screen reader reading it twice. A `Text` in `content` supplies that string on its own; anything else needs `semanticLabel`.
- The wrapper adds no box to the layout and no focus stop of its own. The child stays whatever it was.
- It opens on hover, on a long press and on focus, and the plate goes when any of those ends.
- **A tooltip is not a label.** It describes; it does not name. An icon-only button needs its own `semanticLabel` as well. A trigger with no name of its own is a trigger nothing can announce.
- Nothing inside a tooltip can be pressed, and on a touch screen there is no pointer to rest. Content that needs either belongs somewhere that stays put.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open: bool?` / `onOpenChanged` | `null` is the tooltip driving itself, which is what an uncontrolled tooltip was. Passing a value takes it over. |
| `delay`, `closeDelay` in milliseconds | `Duration`s | Dart's own type for a length of time. |
| `role="tooltip"` and `aria-describedby` | the trigger's own tooltip | Flutter names the state on the node itself; there is no id to point at, and the plate is excluded so the phrase is read once. |
| `content` read out by the plate | `content` drawn, `semanticLabel` read | A widget cannot be read out. A `Text` supplies the string on its own; anything else says what it means. |
| `color` | — | It reached the slots the content read, and content here arrives with its own colours. |
| collision handling in both axes | a flip, never a slide | Sliding needs the position recomputed against the viewport every frame, and a wedge that has slid off its trigger points at nothing. |
| opens on focus, but not a focus from a click | opens on focus | Flutter has no equivalent of "this focus came from a pointer" at the node the tooltip wraps. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

The delay group is here too, spelled the same: wrap a toolbar in a `PlTooltipProvider`.

:::
