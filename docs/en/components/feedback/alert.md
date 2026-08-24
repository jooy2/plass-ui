---
title: PlAlert
order: 1
---

# PlAlert

<p class="plass-lede">A message about something that happened, set into the page it is about. Three shapes — a bare line, a line with a glyph, or a headline with the detail under it — are one component with different slots filled.</p>

<Demo src="alert/hero" :min-height="200" />

```tsx
import { PlAlert } from 'plass-ui';

<PlAlert color="success">Your changes are live.</PlAlert>;
<PlAlert color="danger" title="The deploy failed">
  Two of the health checks never came back.
</PlAlert>;
```

## Props

<PropsTable name="PlAlert" />

Every native `<div>` attribute passes straight through, `role` included — see the note on live regions below. `color` and `title` are excluded from the pass-through because both are Plass props here.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

An alert **is** the thing being coloured — a notice about a severity, not a container holding someone else's content — so unlike a `PlCard` its sheet takes the tint.

`solid` is the family's gradient with that family's shadow under it and no gloss line, exactly as a filled `PlButton` has none. `glass` wears the family in its hairline, its glyph and its title. `ghost` is the tint alone, for an alert set among form fields where a second bordered rectangle is one rectangle too many.

<Demo src="alert/variants" :min-height="260">

<<< @/.vitepress/demos/alert/variants.tsx

</Demo>

### color

The default is `info`, not `primary`. This is the one place `primary` would be a lie: an alert is not the primary anything, it is a note, and the palette already has the word for that.

Each family draws its own shape as well as its own colour. An alert that says "this went wrong" only in red says it only to some readers.

<Demo src="alert/colors" :min-height="240">

<<< @/.vitepress/demos/alert/colors.tsx

</Demo>

### The three shapes

`icon={false}` for a bare line, the default for a line with a glyph, and `title` plus `children` for a headline with the detail under it. Nothing about the surface changes between them — only how much of it is used.

<Demo src="alert/shapes" :min-height="200">

<<< @/.vitepress/demos/alert/shapes.tsx

</Demo>

### action and onClose

`action` stays on the first line while the message wraps beside it, which is why it is a prop rather than something appended to `children`.

Passing `onClose` is what makes the dismiss button appear. The component does not hide itself — what happens on dismiss is the caller's, because an alert that vanished on its own would have to be told when to come back.

<Demo src="alert/dismiss" :min-height="160">

<<< @/.vitepress/demos/alert/dismiss.tsx

</Demo>

### size

<Demo src="alert/sizes" :min-height="280">

<<< @/.vitepress/demos/alert/sizes.tsx

</Demo>

## Accessibility

- The alert is a live region, and which one depends on the severity: `warning` and `danger` get `role="alert"` and interrupt whatever a screen reader is saying; the rest get `role="status"` and wait for a pause. "This failed" is worth interrupting for and "saved" is not.
- A `role` you pass wins — the props spread after the default.
- The glyph is decorative and `aria-hidden`; the severity is carried by the role, the shape and the colour together, never by the colour alone.
- The glyph is centred on the message's **first** line with `1lh`, so a three-line alert still has its glyph at the top.
- `action` and the dismiss button are real buttons with their own tab stops. Give the action an accessible name; the dismiss button has one already.
