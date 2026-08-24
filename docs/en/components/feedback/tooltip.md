---
title: PlTooltip
order: 6
---

# PlTooltip

<p class="plass-lede">A short label that appears when the pointer rests on something. The whole component is a wrapper — it adds no element to the layout, and the child stays whatever it was.</p>

<Demo src="tooltip/hero" :min-height="140" />

```tsx
import { PlTooltip } from 'plass-ui';

<PlTooltip content="Copy to clipboard">
  <PlButton aria-label="Copy">
    <CopyIcon />
  </PlButton>
</PlTooltip>;
```

## Props

<PropsTable name="PlTooltip" />

Every native `<div>` attribute passes straight through, onto the plate. `color`, `content` and `children` are excluded from the pass-through because all three are Plass props here.

There is no `variant` and no `elevation`. The plate is the same floating sheet a `PlSelect`'s popup is — the glass at its most opaque, a white hairline round it, shadow 3 under it — rather than the filled key most libraries draw a tooltip as. A tooltip is a note _about_ something, not a thing to press, and a second kind of floating sheet on one screen is one too many.

What the shared axes (`size` `color` `density` `side` `align`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### side and align

`side` may flip to the opposite edge when there is no room, which is Base UI's doing and is the right behaviour: a tooltip half off the screen says nothing.

<Demo src="tooltip/sides" :min-height="200">

<<< @/.vitepress/demos/tooltip/sides.tsx

</Demo>

<Demo src="tooltip/align" :min-height="180">

<<< @/.vitepress/demos/tooltip/align.tsx

</Demo>

### PlTooltipProvider

Shares one delay across a group of tooltips: once any of them has opened, its neighbours open instantly, and the wait comes back after a pause.

Worth wrapping a toolbar in. Without it, moving along a row of icon buttons means waiting out the full delay at every stop, which is what makes tooltips feel like they are fighting the pointer.

<Demo src="tooltip/provider" :min-height="120">

<<< @/.vitepress/demos/tooltip/provider.tsx

</Demo>

### delay, closeDelay and disabled

`disabled` stops the tooltip from opening without disabling the trigger — for the tooltip that only exists while a label is truncated.

<Demo src="tooltip/delay" :min-height="120">

<<< @/.vitepress/demos/tooltip/delay.tsx

</Demo>

### size

<Demo src="tooltip/sizes" :min-height="220">

<<< @/.vitepress/demos/tooltip/sizes.tsx

</Demo>

## Accessibility

- The plate carries `role="tooltip"` and the trigger an `aria-describedby` pointing at it — **only while it is open**, because a reference to an element that is not in the document is a reference to nothing. Base UI leaves both to the caller, since a popup can be many things; here it is always a tooltip, so the component wires them.
- Base UI's Trigger merges onto the child rather than rendering a box of its own, so the tooltip adds no element to the layout and no tab stop of its own.
- It opens on focus, but not on a focus that arrived from a click, and it closes on Escape. All three are the primitive's.
- **A tooltip is not a label.** It describes; it does not name. An icon-only button needs its own `aria-label` as well — a trigger with no accessible name is unreachable by voice control, and its tooltip is not on the page to supply one.
- Nothing inside a tooltip can be clicked, and on a touch screen there is no pointer to rest. Content that needs either belongs somewhere that stays put.
