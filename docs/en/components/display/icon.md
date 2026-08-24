---
title: PlIcon
order: 5
---

# PlIcon

<p class="plass-lede">A glyph at a known size, in a known colour. Plass draws no icon set of its own — this gives whichever set an app chose the same two axes everything else here has.</p>

<Demo src="icon/hero" :min-height="140" />

```tsx
import { PlIcon } from 'plass-ui';

<PlIcon icon={<BoltIcon />} />;
<PlIcon icon={<BoltIcon />} size="lg" color="warning" label="Fast" />;
```

## Props

<PropsTable name="PlIcon" />

Every native `<span>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

There is no `variant` and no `elevation`. An icon is not a surface — it is ink, and the only thing the design language has to say about ink is which family it is drawn in.

What the shared axes (`size` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### icon

The glyph is a prop rather than `children`. An icon set hands back an element you did not draw, and the two things you always want to change about it — how big it is and what colour it is — are the two you cannot reach once it is a child of something.

The box is `inline-flex` with the glyph told to fill it, and `font-size` is set to the same length. So an `<svg>` with its own `width`, an `<svg>` sized in `em`, a bare character and an `<img>` all come out the same size.

<Demo src="icon/anything" :min-height="140">

<<< @/.vitepress/demos/icon/anything.tsx

</Demo>

### size

Its own ladder — 14, 16, 20, 24 and 28px — rather than a step off the control heights, because an icon is not a control. It is content, measured against the text it sits beside rather than against the row it sits in.

<Demo src="icon/sizes" :min-height="160">

<<< @/.vitepress/demos/icon/sizes.tsx

</Demo>

### color

`inherit` is the default, and this is the one component in the library where `color` is not `primary`. An icon usually sits inside something that has already decided what colour its content is — a button's label, a muted caption, an alert's own family — and one that arrived pre-dyed would have to be turned off again at every one of them.

<Demo src="icon/colors" :min-height="120">

<<< @/.vitepress/demos/icon/colors.tsx

</Demo>

### Inside another component

A glyph passed to a `PlButton` or a `PlAlert` is already sized in `em` by that component, so it tracks the label. Wrapping it in a `PlIcon` is for when it should be a fixed size instead — or when it is standing on its own.

<Demo src="icon/inside" :min-height="220">

<<< @/.vitepress/demos/icon/inside.tsx

</Demo>

## Accessibility

- Without `label` the icon is `aria-hidden` and carries no role. That is the right default: most icons sit next to a word that already says the same thing, and reading both out loud is worse than reading one.
- With `label` it becomes `role="img"` with that name. Pass it only when the glyph is carrying meaning on its own.
- There is no third case. `role="img"` on a decorative glyph is the most common way a screen reader ends up announcing "graphic".
- An icon that is the whole of a button belongs inside the button, not beside it: give the `PlButton` an `aria-label` and leave the icon hidden.
