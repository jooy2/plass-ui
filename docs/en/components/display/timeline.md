---
title: PlTimeline
order: 13
---

# PlTimeline

<p class="plass-lede">A sequence of steps, in the order they happen in. <code>active</code> says how far along it is, and the timeline works out what each step's bullet should be.</p>

<Demo src="timeline/hero" :min-height="360" />

```tsx
import { PlTimeline, PlTimelineItem } from 'plass-ui';

<PlTimeline active={2}>
  <PlTimelineItem title="Ordered" meta="Mon 09:12" bullet="1" />
  <PlTimelineItem title="Packed" meta="Mon 14:40" bullet="2" />
  <PlTimelineItem title="Shipped" meta="Tue 07:05" bullet="3" />
</PlTimeline>;
```

## Props

<PropsTable name="PlTimeline" />

Every native `<ol>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

There is no `variant` and no `elevation`: a timeline is a run of marks down the page, not a sheet laid on it. Put one inside a `PlCard` when it needs a surface.

### PlTimelineItem

<PropsTable name="PlTimelineItem" />

Every native `<li>` attribute passes straight through. `size`, `density` and `orientation` are inherited from the `PlTimeline` around it.

An item's **index is not a prop and cannot be**. An item that had to be told where it was in the list would be an item every caller could put in the wrong place, and `active` would stop meaning anything. The timeline numbers its children as it walks them.

What the shared axes (`size` `color` `density` `orientation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### active

An index rather than a value, because a timeline has no selection — nothing here is chosen, and the only question is how far down the list reality has reached. Omit it and every item is `upcoming`; pass the item count to mark the whole sequence done.

<Demo src="timeline/active" :min-height="340">

<<< @/.vitepress/demos/timeline/active.tsx

</Demo>

### status

Three states rather than two, because "the one you are on" is not the same claim as "done", and a sequence that cannot say which step is current is a list.

Each state is a different **axis**, never a different opacity: `complete` is the family's gradient, `current` is that gradient with a halo of the soft tint around it, and `upcoming` is a hairline ring on the page's own surface. A reader who cannot tell the colours apart still has a filled shape, a haloed shape and an empty one.

`status` on an item overrides what `active` computed for it — a step that failed and stopped the sequence, a step that was skipped.

<Demo src="timeline/status" :min-height="300">

<<< @/.vitepress/demos/timeline/status.tsx

</Demo>

### connector

The line is drawn as one border edge rather than as a filled `<div>`, so `dashed` and `dotted` are the browser's own dashes and land on the device pixel grid the way every other edge in the library does.

It belongs to the item it leaves rather than the one it arrives at, which is what lets its colour say whether that step has been reached. The last item's line is never drawn — it would run off the end of the sequence into nothing.

<Demo src="timeline/connectors" :min-height="280">

<<< @/.vitepress/demos/timeline/connectors.tsx

</Demo>

### orientation

`vertical` is the default and the one that takes an arbitrary number of steps with an arbitrary amount to say about each. `horizontal` is the stepper across the top of a checkout, and it is only honest while every label is short.

<Demo src="timeline/orientation" :min-height="160">

<<< @/.vitepress/demos/timeline/orientation.tsx

</Demo>

### size

<Demo src="timeline/sizes" :min-height="240">

<<< @/.vitepress/demos/timeline/sizes.tsx

</Demo>

## Accessibility

- It is an `<ol>` for the reason it exists at all: the order **is** the content. A screen reader announcing "list of 5 items" over an unordered list would be describing something else.
- `role="list"` is written out because Tailwind's reset takes the markers off every `<ol>`, and Safari takes the list semantics off with them.
- The current step carries `aria-current="step"`. That is the value for a sequence — `"page"` is a trail of documents and `"true"` is one of a set of options.
- The bullets and the connectors are `aria-hidden`. The status is in `aria-current` and in the text of each step, never in a shape alone.
- There is no Base UI primitive under this. A timeline has no selection, no roving focus and no keyboard contract, and reaching for a composite primitive would hand a record of events the semantics of a widget.
