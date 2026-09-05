---
title: PlAvatar
order: 6
---

# PlAvatar

<p class="plass-lede">A picture of a person or a thing, at a known size, that is never an empty box. When there is no picture there are initials; when there are no initials there is a silhouette.</p>

<Demo src="avatar/hero" :min-height="140" />

::: fw react

```tsx
import { PlAvatar } from 'plass-ui';

<PlAvatar name="Nadia Rowan" src="/nadia-rowan.webp" />;
<PlAvatar name="Nadia Rowan" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAvatar(name: 'Nadia Rowan', image: NetworkImage('/nadia-rowan.webp'));
const PlAvatar(name: 'Nadia Rowan');
```

:::

## Props

<PropsTable name="PlAvatar" />

::: fw react

Every native `<span>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

:::

::: fw flutter

`image` is an `ImageProvider` rather than a URL, which is the shape every image in Flutter has: a `NetworkImage`, an `AssetImage`, a `MemoryImage` or a provider from a caching package all fit without the component having to know which.

:::

There is no `density`: an avatar has no padding to tighten. It carries no status dot of its own either. An avatar with a green mark on it is a [`PlBadge`](./badge) with an avatar in it.

What the shared axes (`variant` `size` `color` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### The fallback

Three things can be drawn and exactly one of them is at a time: the picture, if `src` is given and it loads; otherwise whatever stands in for it, `children`, or `initials`, or the initials derived from `name`; and failing all of those, a silhouette.

::: fw react

Which one is showing is Base UI's `Avatar` to decide, because "has the image loaded" is a question with four answers and a race in the middle of it.

:::

::: fw flutter

Which one is showing is decided by the `Image` itself: its `frameBuilder` shows the fallback until the first frame arrives, and its `errorBuilder` shows it for good if none ever does. There is no loading enum, because a picture that has not arrived and a picture that never will are the same case for as long as they last.

There is no `delay`. It exists in the React build so the initials do not flash up in front of a cached image; here a picture already in the image cache is decoded synchronously and the fallback is never built at all.

:::

The derivation is the first character of the first word plus the first character of the last. "Jane Doe" is `JD`. A single-token name gives one character, because two characters of a Korean, Japanese or Chinese name at 40px is a smudge where one is a name.

<Demo src="avatar/fallback" :min-height="180">

::: fw react

<<< @/.vitepress/demos/avatar/fallback.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/fallback.dart

:::

</Demo>

### variant

An avatar **is** the thing being coloured, a portrait of one particular person, so its sheet takes the tint, as a `PlAlert`'s does and unlike a `PlCard`'s. The edge is the neutral hairline rather than the sheet's own white one: an avatar is very often laid on something opaque, where white light on a cut edge is a claim about a page wash that is not behind it.

`ghost` is the default rather than `solid`, which is the other way round from a `PlButton`. A directory is a page of avatars, and a page of saturated circles is a page nobody can read a name off.

<Demo src="avatar/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/variants.dart

:::

</Demo>

### shape

`circle` is the default, because that is what a portrait has been for as long as there have been portraits. `square` takes the library's own fillet instead, which is what a logo or a repository icon wants. Those are drawn to the edges of a rectangle and a round crop eats them.

<Demo src="avatar/shapes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/shapes.dart

:::

</Demo>

### size

The control heights, so an avatar and the button beside it in a toolbar sit on the same baseline.

<Demo src="avatar/sizes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/sizes.dart

:::

</Demo>

### color

<Demo src="avatar/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/colors.dart

:::

</Demo>

### A stack of them

A stack of overlapping faces with a `+n` on the end is a [`PlStack`](../layout/stack) with avatars in it. It is a general pile rather than an avatar component, so it sets no axes on what it holds. Put a `PlassProvider` around it for `size` and `color`, and write the rest on the avatars.

## Accessibility

::: fw react

- The picture takes `alt`, falling back to `name`, falling back to an **empty** `alt`. Empty rather than absent: an avatar beside the person's own name in a row is decoration, and `alt` left off is what makes a screen reader read the file name out instead.
- `JD` read out loud is two letters, not a person. When there is a name it becomes the fallback's accessible name and the initials are hidden as the picture they are standing in for.
- A silhouette says nothing at all. There is no name to announce, and "graphic" is not information.
- An avatar that is also a link or a button has to be one: put it inside a real `<a>` or `<button>` and give that element the name.

:::

::: fw flutter

- The avatar takes `semanticLabel`, falling back to `name`, falling back to nothing at all. Nothing rather than a guess: an avatar beside the person's own name in a row is decoration, and saying the name twice is worse than saying it once.
- `JD` read out loud is two letters, not a person. When there is a name it becomes the accessible name and the initials are excluded as the picture they are standing in for. With no name the initials are all there is, and they are read.
- A silhouette says nothing at all. There is no name to announce, and "graphic" is not information.
- An avatar that is also a link or a button belongs inside one: a `PlButton` or a `PlCard` with `onPressed`, named there.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `src` / `srcSet` / `imageProps` | `image` | An `ImageProvider` is the shape every image in Flutter has, and it already covers resolution variants, headers and caching. |
| `alt` | `semanticLabel` | Flutter's name. It names the avatar rather than an inner element, because there is no inner element to name. |
| `delay` | — | A cached image decodes synchronously here, so the fallback never flashes and there is nothing to wait out. |
| `onLoadingStatusChange` | — | There is no four-state machine to report: the fallback is shown until a frame arrives and for good if none does. An `ImageProvider`'s own `ImageStream` is where a caller who needs the states goes. |
| `children` | `child` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
