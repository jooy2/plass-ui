---
title: PlAccordion
order: 1
---

# PlAccordion

<p class="plass-lede">A stack of sections that fold open one at a time. Use it for reference material a reader scans before choosing what to read — settings groups, specifications, an FAQ.</p>

<Demo src="accordion/hero" :min-height="240" />

```tsx
import { PlAccordion, PlAccordionItem } from 'plass-ui';

<PlAccordion defaultValue={['shipping']}>
  <PlAccordionItem value="shipping" title="Shipping">
    Three to five working days.
  </PlAccordionItem>
  <PlAccordionItem value="returns" title="Returns">
    Thirty days from delivery.
  </PlAccordionItem>
</PlAccordion>;
```

## Props

<PropsTable name="PlAccordion" />

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `defaultValue` and `onChange` because the accordion spells them `defaultValue` (an array) and `onValueChange`.

### PlAccordionItem

<PropsTable name="PlAccordionItem" />

`size`, `density` and `dividers` are read from the `PlAccordion` around the item, not set on it.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

The three materials, read the way a **container** reads them. `solid` is the clear glass at its most opaque, for a pane that has to sit forward of everything around it. `glass` is the canonical Plass sheet and the default. `ghost` has no sheet at all — reach for it inside a `PlCard`, where a second bordered rectangle is a second rectangle.

None of the three is dyed. What an accordion holds arrives with its own colours; the family reaches the hover tint, the open section's title and the focus ring, and stops.

<Demo src="accordion/variants" :min-height="200">

<<< @/.vitepress/demos/accordion/variants.tsx

</Demo>

### multiple

By default opening a section closes the one that was open, which is the whole reason an accordion is not a stack of collapsibles: closing the last as you open the next is what keeps the page from growing under the reader. `multiple` lifts that.

<Demo src="accordion/multiple" :min-height="220">

<<< @/.vitepress/demos/accordion/multiple.tsx

</Demo>

### dividers

On by default: a hairline reaching both edges is what says the folds are parts of one pane. Turn it off and each section becomes its own tile, told apart by space.

<Demo src="accordion/dividers" :min-height="180">

<<< @/.vitepress/demos/accordion/dividers.tsx

</Demo>

### title · subtitle · startIcon · action

`action` is rendered **outside** the trigger. A header that both folds and holds a button has two things to press, and one of them cannot be nested inside the other — the browser rewrites a `<button>` inside a `<button>` on parse.

<Demo src="accordion/slots" :min-height="220">

<<< @/.vitepress/demos/accordion/slots.tsx

</Demo>

### size

Moves the title, the body and the padding around both together. It is set on the accordion and inherited by every section, so a stack cannot end up with two type scales in it.

<Demo src="accordion/sizes" :min-height="320">

<<< @/.vitepress/demos/accordion/sizes.tsx

</Demo>

### Controlled

Pass `value` with `onValueChange` to own the open set. Both are arrays even when `multiple` is off — a closed accordion is `[]`.

<Demo src="accordion/controlled" :min-height="280">

<<< @/.vitepress/demos/accordion/controlled.tsx

</Demo>

## Accessibility

- Each header is a real `<button>` carrying `aria-expanded`, pointed at its panel with `aria-controls`. The panel is a `region` labelled by its header.
- <kbd>Enter</kbd> and <kbd>Space</kbd> fold a section; <kbd>Tab</kbd> moves between headers and into an open panel.
- `hiddenUntilFound` renders closed panels with `hidden="until-found"`, so the browser's own page search finds text inside them and opens the section it is in.
- The chevron is decorative and `aria-hidden`; the open state is carried by `aria-expanded`, never by the rotation alone.
- Anything in `action` is a separate control with its own tab stop, and needs its own accessible name.
- The panel animates its height rather than a `transform`, so no text is resampled and nothing shifts inside the panel while it opens.
