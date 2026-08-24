---
title: PlAvatar
order: 6
---

# PlAvatar

<p class="plass-lede">A picture of a person or a thing, at a known size, that is never an empty box. When there is no picture there are initials; when there are no initials there is a silhouette.</p>

<Demo src="avatar/hero" :min-height="140" />

```tsx
import { PlAvatar } from 'plass-ui';

<PlAvatar name="Ada Lovelace" src="/portrait-1.svg" />;
<PlAvatar name="Ada Lovelace" />;
```

## Props

<PropsTable name="PlAvatar" />

Every native `<span>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

There is no `density`: an avatar has no padding to tighten. It carries no status dot of its own either — an avatar with a green mark on it is a [`PlBadge`](./badge) with an avatar in it.

What the shared axes (`variant` `size` `color` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### The fallback

Three things can be drawn and exactly one of them is at a time: the picture, if `src` is given and it loads; otherwise whatever stands in for it — `children`, or `initials`, or the initials derived from `name`; and failing all of those, a silhouette.

Which one is showing is Base UI's `Avatar` to decide, because "has the image loaded" is a question with four answers and a race in the middle of it.

The derivation is the first character of the first word plus the first character of the last — "Jane Doe" is `JD`. A single-token name gives one character, because two characters of a Korean, Japanese or Chinese name at 40px is a smudge where one is a name.

<Demo src="avatar/fallback" :min-height="180">

<<< @/.vitepress/demos/avatar/fallback.tsx

</Demo>

### variant

An avatar **is** the thing being coloured — a portrait of one particular person — so its sheet takes the tint, as a `PlAlert`'s does and unlike a `PlCard`'s.

`ghost` is the default rather than `solid`, which is the other way round from a `PlButton`. A directory is a page of avatars, and a page of saturated circles is a page nobody can read a name off.

<Demo src="avatar/variants" :min-height="120">

<<< @/.vitepress/demos/avatar/variants.tsx

</Demo>

### shape

`circle` is the default, because that is what a portrait has been for as long as there have been portraits. `square` takes the library's own fillet instead, which is what a logo or a repository icon wants — those are drawn to the edges of a rectangle and a round crop eats them.

<Demo src="avatar/shapes" :min-height="120">

<<< @/.vitepress/demos/avatar/shapes.tsx

</Demo>

### size

The control heights, so an avatar and the button beside it in a toolbar sit on the same baseline.

<Demo src="avatar/sizes" :min-height="120">

<<< @/.vitepress/demos/avatar/sizes.tsx

</Demo>

### color

<Demo src="avatar/colors" :min-height="120">

<<< @/.vitepress/demos/avatar/colors.tsx

</Demo>

### A stack of them

There is no `PlAvatarGroup`. A stack is a negative margin and a ring — a layout decision about how far they overlap and what the ring is drawn against, both of which belong to the page rather than to the component.

<Demo src="avatar/group" :min-height="120">

<<< @/.vitepress/demos/avatar/group.tsx

</Demo>

## Accessibility

- The picture takes `alt`, falling back to `name`, falling back to an **empty** `alt`. Empty rather than absent: an avatar beside the person's own name in a row is decoration, and `alt` left off is what makes a screen reader read the file name out instead.
- `JD` read out loud is two letters, not a person. When there is a name it becomes the fallback's accessible name and the initials are hidden as the picture they are standing in for.
- A silhouette says nothing at all. There is no name to announce, and "graphic" is not information.
- An avatar that is also a link or a button has to be one: put it inside a real `<a>` or `<button>` and give that element the name.
