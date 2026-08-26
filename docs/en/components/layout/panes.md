---
title: PlPanes
order: 4
---

# PlPanes

<p class="plass-lede">A set of regions with draggable handles between them. Sized in fractions, so the split survives the window being resized without a line of JavaScript running.</p>

<Demo src="panes/hero" :min-height="260" :flutter="false" />

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

## Props

<PropsTable name="PlPanes" />

### PlPane

<PropsTable name="PlPane" />

::: fw react

Every native `<div>` attribute passes through on both. `color` is excluded on the split because it is a Plass prop there.

:::

A pane carries no surface of its own, and neither does the split: this is layout, and the moment a pane drew a sheet it would stop being usable as the thing a `PlCard`, a `PlTable` or an editor is put inside. Put a `PlCard` in it when a surface is wanted. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### How a split is measured

The panes are sized in **fractions**, written out as `flex-basis: calc((100% − gutters) × fraction)`.

That is the one decision the rest of the component follows from. A split described as a percentage survives the window being resized without anything running, so the component measures itself only twice: once on mount, to turn a `'240px'` default into a fraction, and once at the start of each drag, to know what a pixel of pointer movement is worth.

The measurement is a `ResizeObserver` rather than a single read, because a split inside a closed `PlAccordion` or an unselected `PlTab` is zero wide when it mounts — and dividing by that would put every pane at nothing.

### defaultSize, minSize and maxSize

A bare number is a **percentage**, which is how a split is usually described and what keeps its meaning when the window changes size. A string is an absolute length (`'240px'`, `'15rem'`, `'20%'`), which is what a sidebar with a minimum actually needs: "at least 200 pixels" does not survive being written down as a percentage of a width nobody knows yet.

Panes with no `defaultSize` split whatever is left over equally.

The three props are read by the **split** rather than used by the pane. A pane cannot know what "half" is; only the thing holding all of them can. Which is also why the direct children of a `PlPanes` have to *be* `PlPane`s — a pane wrapped in something else is a pane with no minimum.

<Demo src="panes/constraints" :min-height="240" :flutter="false">

::: fw react

<<< @/.vitepress/demos/panes/constraints.tsx

:::

</Demo>

### orientation

`horizontal` puts the panes side by side with upright handles between them; `vertical` stacks them. Nesting one inside a pane of the other is how a three-region layout is built.

<Demo src="panes/orientation" :min-height="260" :flutter="false">

::: fw react

<<< @/.vitepress/demos/panes/orientation.tsx

:::

</Demo>

### resizable

Turn it off for a split that is a layout rather than a control. The handles stay — they are still the line between two regions — but they stop taking the pointer and leave the tab order.

<Demo src="panes/fixed" :min-height="200" :flutter="false">

::: fw react

<<< @/.vitepress/demos/panes/fixed.tsx

:::

</Demo>

### size and color

`size` is how thick a handle is. What is *drawn* is a hairline; what can be **grabbed** is the track around it — the same split a scrollbar makes between the two, and the reason a one-pixel line is not a target.

The split draws no sheet, so `color` reaches three things and stops: the handle's hairline when the pointer is on it, the tint under it, and the focus ring.

<Demo src="panes/sizes" :min-height="360" :flutter="false">

::: fw react

<<< @/.vitepress/demos/panes/sizes.tsx

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
