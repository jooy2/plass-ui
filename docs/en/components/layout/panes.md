---
title: PlPanes
order: 4
---

# PlPanes

<p class="plass-lede">A set of regions with draggable handles between them. Sized in fractions, so the split survives the window being resized without a line of JavaScript running.</p>

<Demo src="panes/hero" :min-height="260" />

::: fw react

```tsx
import { PlPane, PlPanes } from 'plass-ui';

<PlPanes>
  <PlPane defaultSize="240px" minSize="180px" maxSize="50%">
    {sidebar}
  </PlPane>
  <PlPane>{body}</PlPane>
</PlPanes>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPanes(
  panes: <PlPane>[
    PlPane(
      defaultSize: const PlPaneSize.pixels(240),
      minSize: const PlPaneSize.pixels(180),
      maxSize: const PlPaneSize.percent(50),
      child: sidebar,
    ),
    PlPane(child: body),
  ],
);
```

:::

## Props

<PropsTable name="PlPanes" />

### PlPane

<PropsTable name="PlPane" />

::: fw react

Every native `<div>` attribute passes through on both. `color` is excluded on the split because it is a Plass prop there.

:::

::: fw flutter

A `PlPane` is a **description rather than a widget**, the idiom this package uses for an accordion's folds and a table's columns — and it is the same reason: the three sizing values are read by the split, so it has to be able to read them.

:::

A pane carries no surface of its own, and neither does the split: this is layout, and the moment a pane drew a sheet it would stop being usable as the thing a `PlCard`, a `PlTable` or an editor is put inside. Put a `PlCard` in it when a surface is wanted. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### How a split is measured

The panes are sized in **fractions**, written out as `flex-basis: calc((100% − gutters) × fraction)`.

That is the one decision the rest of the component follows from. A split described as a percentage survives the window being resized without anything running, so the component measures itself only twice: once on mount, to turn a `'240px'` default into a fraction, and once at the start of each drag, to know what a pixel of pointer movement is worth.

::: fw react

The measurement is a `ResizeObserver` rather than a single read, because a split inside a closed `PlAccordion` or an unselected `PlTab` is zero wide when it mounts — and dividing by that would put every pane at nothing.

:::

::: fw flutter

This is the one place Flutter makes the same idea easier rather than harder. CSS measures itself, so the React build needs a `ResizeObserver` and a mounted split that is zero wide is a real hazard; a `LayoutBuilder` is handed the extent on every layout pass, so there is nothing to observe and nothing to re-measure. A split with no room yet simply lays its panes out evenly until there is some.

:::

### defaultSize, minSize and maxSize

A **percentage** is how a split is usually described and what keeps its meaning when the window changes size. An absolute **length** is what a sidebar with a minimum actually needs: "at least 200 pixels" does not survive being written down as a percentage of a width nobody knows yet.

<Fw react="A bare number is the percentage and a string is the length — '240px', '15rem', '20%'." flutter="Dart has no number | string union, so the two are two constructors: PlPaneSize.percent and PlPaneSize.pixels." />

Panes with no `defaultSize` split whatever is left over equally.

The three props are read by the **split** rather than used by the pane. A pane cannot know what "half" is; only the thing holding all of them can. Which is also why the direct children of a `PlPanes` have to _be_ `PlPane`s — a pane wrapped in something else is a pane with no minimum.

<Demo src="panes/constraints" :min-height="240">

::: fw react

<<< @/.vitepress/demos/panes/constraints.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/constraints.dart

:::

</Demo>

### orientation

`horizontal` puts the panes side by side with upright handles between them; `vertical` stacks them. Nesting one inside a pane of the other is how a three-region layout is built.

<Demo src="panes/orientation" :min-height="260">

::: fw react

<<< @/.vitepress/demos/panes/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/orientation.dart

:::

</Demo>

### resizable

Turn it off for a split that is a layout rather than a control. The handles stay — they are still the line between two regions — but they stop taking the pointer and leave the tab order.

<Demo src="panes/fixed" :min-height="200">

::: fw react

<<< @/.vitepress/demos/panes/fixed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/fixed.dart

:::

</Demo>

### size and color

`size` is how thick a handle is. What is _drawn_ is a hairline; what can be **grabbed** is the track around it — the same split a scrollbar makes between the two, and the reason a one-pixel line is not a target.

The split draws no sheet, so `color` reaches three things and stops: the handle's hairline when the pointer is on it, the tint under it, and the focus ring.

<Demo src="panes/sizes" :min-height="360">

::: fw react

<<< @/.vitepress/demos/panes/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/sizes.dart

:::

</Demo>

## Accessibility

- Every handle is a `role="separator"` carrying `aria-valuenow` as the share of the pane before it, so a screen reader can say where the boundary is rather than that there is one.
- A handle is a tab stop while the split can be resized, and the arrow keys move it. It leaves the tab order entirely when `resizable` is off — a control that cannot be operated should not be a stop on the way to one that can.
- A key press is a whole gesture on its own, so `onResizeEnd` fires with it. There is no "let go" to wait for.

::: fw react

- The handle is focused by the browser on a press, not by the component. Focusing it by hand would put a keyboard focus ring on every handle somebody merely dragged.
- A drag takes the page's text selection away for its own length instead of calling `preventDefault` on the press, which is what would have stopped the focus above. The property is written as `-webkit-user-select` through `setProperty`, because WebKit implements only the prefixed name and `style.userSelect = 'none'` silently does nothing there.
- A drag in flight is torn down if the split unmounts. The `pointerup` that would have ended it never arrives after a route change, and what is left behind is not only two listeners on a detached node — it is a page whose text can no longer be selected.

:::

::: fw flutter

- A handle is a **slider** rather than a separator, which is what it actually is to a screen reader here: Flutter's semantics tree has no separator role and no `valuenow`, but it has a control with a value that can be turned up and down, and `label` names it.
- The arrow keys move it, and they follow the writing direction — so they run the other way under RTL, exactly as a drag does.
- None of the three drag hazards the other build has exists here. There is no document selection to take away, no browser focusing anything on a press, and a gesture recogniser is disposed with the widget that owns it.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlPane>` children | `panes: List<PlPane>` | The split reads the three sizing values off its members, and a `Widget` is opaque. |
| `number \| string` sizes | `PlPaneSize.percent` / `.pixels` | Dart has no union. The two constructors are the two halves of it. |
| a `ResizeObserver` | a `LayoutBuilder` | CSS measures itself; Flutter hands the extent to whoever asks in the layout pass. |
| `role="separator"`, `aria-valuenow` | slider semantics | Flutter's tree has neither, and a control with a value is the honest description. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
