---
title: PlDivider
order: 4
---

# PlDivider

<p class="plass-lede">A rule between two things. With no children it is a hairline and a real <code>role="separator"</code>; with children the line breaks around a label set into it.</p>

<Demo src="divider/hero" :min-height="160" />

```tsx
import { PlDivider } from 'plass-ui';

<PlDivider />;
<PlDivider>OR</PlDivider>;
<PlDivider orientation="vertical" />;
```

## Props

<PropsTable name="PlDivider" />

Every native `<div>` attribute passes straight through. `color` and `children` are excluded from the pass-through because both are Plass props here.

There is no `variant` and no `elevation`. A divider is not a surface: it is not made of glass, it catches no light and it casts no shadow.

What the shared axes (`orientation` `color` `size` `textAlign`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### orientation

A vertical divider has no height of its own — it stretches to its flex parent, which is what a rule between two toolbar groups should do. Give it a `length` when it has to be shorter than the row it is in.

<Demo src="divider/orientation" :min-height="200">

<<< @/.vitepress/demos/divider/orientation.tsx

</Demo>

### children and textAlign

`center` splits the line in half. `start` and `end` leave a short stub on the near side, so the label still reads as set _into_ the rule rather than floating above it.

<Demo src="divider/label" :min-height="200">

<<< @/.vitepress/demos/divider/label.tsx

</Demo>

### color

There is no default, which is the same choice `PlTextLink` makes. Left out, the rule is the neutral hairline — the one that is visible on every ground the library has: a page wash, a glass sheet, a card. The sheet's own white hairline is white light on a translucent pane and disappears the moment a divider is set on something opaque.

Passing a family tints the rule instead.

<Demo src="divider/colors" :min-height="240">

<<< @/.vitepress/demos/divider/colors.tsx

</Demo>

### length and thickness

A number is pixels; a string is any CSS length, so `'50%'` and `'12rem'` both work. `length` rather than `width`, because a divider is the one component whose long axis turns with `orientation`.

<Demo src="divider/length" :min-height="200">

<<< @/.vitepress/demos/divider/length.tsx

</Demo>

### size

`size` is the label's type scale and nothing else — a divider with no label has no size to set.

<Demo src="divider/sizes" :min-height="240">

<<< @/.vitepress/demos/divider/sizes.tsx

</Demo>

## Accessibility

- It renders Base UI's `Separator`, so it is a real `role="separator"` carrying the matching `aria-orientation`.
- `separator` is not a name-from-content role, so a visible label does not become the accessible name on its own. A **string** label is copied into `aria-label`; a richer one is left alone, because only the caller knows which part of it is the name.
- A divider that is purely decorative — a rule inside a card that is already separated by space — is better given `role="presentation"`, which passes straight through.
- The two stubs either side of a label are `aria-hidden`; the label is announced once, as the separator's name.
