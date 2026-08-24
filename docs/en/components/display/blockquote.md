---
title: PlBlockquote
order: 8
---

# PlBlockquote

<p class="plass-lede">Somebody else's words, set apart from your own. An accent rule down the leading edge, the quote at a heading's scale, and — when there is one — an attribution in the markup the HTML spec asks for.</p>

<Demo src="blockquote/hero" :min-height="260" />

```tsx
import { PlBlockquote } from 'plass-ui';

<PlBlockquote author="Ada Lovelace" source="Notes on the Analytical Engine">
  Simplicity is hard.
</PlBlockquote>;
```

## Props

<PropsTable name="PlBlockquote" />

Every native `<figure>` attribute passes straight through, onto the **wrapper** rather than onto the `<blockquote>` inside it. `color` is excluded from the pass-through because it is a Plass prop here.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### author, source and cite

`author` is a person and `source` is a work. That is not a naming preference — `<cite>` is the element for the title of a work and, per the spec, never for the name of a person, so the two cannot share a slot.

An attribution is _about_ the quote and is not part of what was said, which is why passing one turns the wrapper into a `<figure>` with a `<figcaption>` outside the `<blockquote>`. Without one the wrapper is a plain `<div>`: a `<figure>` with no `<figcaption>` in it is a figure of nothing.

`cite` is the URL, and it lands on the `<blockquote>`'s own attribute — machine-readable and shown to nobody.

<Demo src="blockquote/attribution" :min-height="320">

<<< @/.vitepress/demos/blockquote/attribution.tsx

</Demo>

### variant

The sheet is never dyed, exactly as on a `PlCard`. A quote holds somebody else's words, and words on a tinted pane are words on a background nobody chose them against — so the family reaches the rule and stops.

`ghost` is the default and the one that belongs in running prose: a rule in the margin and nothing else, which is what a quote has looked like since long before there were surfaces to put one on.

<Demo src="blockquote/variants" :min-height="320">

<<< @/.vitepress/demos/blockquote/variants.tsx

</Demo>

### color

<Demo src="blockquote/colors" :min-height="280">

<<< @/.vitepress/demos/blockquote/colors.tsx

</Demo>

### size

<Demo src="blockquote/sizes" :min-height="420">

<<< @/.vitepress/demos/blockquote/sizes.tsx

</Demo>

## Accessibility

- The quote is a real `<blockquote>` and the attribution a real `<figcaption>` outside it. A name inside the quote claims the speaker said their own name.
- The quotation mark is decorative and `aria-hidden`. So is the em dash before the author — a screen reader announcing "em dash" before a name is reading the typography rather than the text.
- Nothing is drawn on the `<blockquote>` element itself. `blockquote` is one of the handful of tags a host stylesheet still styles by name, and moving the surface and the rule onto the wrapper is what lets a host reset undo its own version without also undoing this one.
