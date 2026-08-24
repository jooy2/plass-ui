---
title: PlBadge
order: 7
---

# PlBadge

<p class="plass-lede">A small mark in the corner of something else — unread mail on an inbox icon, a status dot on an avatar, a count on a tab. With no children it lays out inline instead, which is what a standalone status pill is.</p>

<Demo src="badge/hero" :min-height="160" />

```tsx
import { PlBadge, PlButton } from 'plass-ui';

<PlBadge content={4} label="4 unread notifications">
  <PlButton aria-label="Notifications">
    <BellIcon />
  </PlButton>
</PlBadge>;
```

## Props

<PropsTable name="PlBadge" />

Every native `<span>` attribute passes straight through, onto the **marker** rather than onto the shell around the anchor. `color` and `content` are excluded from the pass-through because both are Plass props here.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### content, max and showZero

`content` is usually a count and sometimes a word. A number past `max` is capped with a `+`; a word is left alone, because a badge cannot know how to truncate one.

A count of `0` draws nothing at all unless `showZero` is on. Zero unread messages is not news, and a badge that never goes away stops meaning anything.

<Demo src="badge/counts" :min-height="140">

<<< @/.vitepress/demos/badge/counts.tsx

</Demo>

### dot

Omit `content` and the badge is a dot — the honest shape when there is something to report but nothing to count. `dot` forces it even when there _is_ content, and the content stays in the DOM for a screen reader: a quiet corner is not a silent one.

<Demo src="badge/dot" :min-height="140">

<<< @/.vitepress/demos/badge/dot.tsx

</Demo>

### variant

A badge is the thing being coloured, so its sheet takes the tint — as an alert's does, and unlike a card's. It is also the one component in the library allowed to be a pill: a Plass corner is a moulded fillet on a _surface_, and a badge is a mark laid on one.

<Demo src="badge/variants" :min-height="120">

<<< @/.vitepress/demos/badge/variants.tsx

</Demo>

### placement and overlap

`placement` uses logical properties throughout, so the corner flips with the writing direction rather than staying stuck on the right.

`overlap` is the shape of the thing underneath. A circle's corner is about 15% of its diameter inside the box the badge is positioned against, so a badge tuned for an icon button floats off an avatar with a gap under it.

<Demo src="badge/placement" :min-height="160">

<<< @/.vitepress/demos/badge/placement.tsx

</Demo>

<Demo src="badge/overlap" :min-height="140">

<<< @/.vitepress/demos/badge/overlap.tsx

</Demo>

### color

<Demo src="badge/colors" :min-height="120">

<<< @/.vitepress/demos/badge/colors.tsx

</Demo>

### size

Its own ladder, well below the control one. A control's height is what a _row_ lines up on; a badge lines up on nothing — it hangs off the corner of something else.

<Demo src="badge/sizes" :min-height="120">

<<< @/.vitepress/demos/badge/sizes.tsx

</Demo>

## Accessibility

- `content={3}` beside a bell reads out as "3", which means nothing. Give it `label="3 unread notifications"` and the sentence is what is announced instead of the number.
- A dot draws nothing but still reads whichever of `label` and `content` it was given.
- An `invisible` badge and an empty one are hidden from the accessibility tree entirely, and hold no text at all — text left behind in a clipped box is text a find-on-page still turns up.
- The badge adds no role and no tab stop. What is interactive is the anchor inside it, and the anchor is the caller's own element.
- The shell around the anchor is `inline-flex` and exactly as wide as what it wraps, so a badged icon button still lines up with a bare one beside it.
