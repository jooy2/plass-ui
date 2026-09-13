---
title: PlImage
order: 18
---

# PlImage

<p class="plass-lede">A picture, and the two states a picture spends most of its life in. It reserves the space before the picture arrives and draws the failure when it does not.</p>

<Demo src="image/hero" :min-height="260" />

::: fw react

```tsx
import { PlImage } from 'plass-ui';

<PlImage src="/cover.jpg" alt="The 2026 team" ratio="16 / 9" rounded />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlImage(
  image: const NetworkImage('https://example.com/cover.jpg'),
  semanticLabel: 'The 2026 team',
  ratio: 16 / 9,
  rounded: true,
);
```

:::

## Props

<PropsTable name="PlImage" />

Every native `<img>` attribute passes straight through, `srcSet`, `sizes` and `crossOrigin` included. `onLoad` and `onError` are the two exceptions. The component owns them, and `onStatusChange` is what it offers instead.

::: fw flutter

`image` is an `ImageProvider` rather than a URL, because that is the shape every source has in common (a network image, an asset, a file, a memory buffer), and `semanticLabel` is what `alt` is: `null` marks the picture decorative.

**Without a `ratio` the widget is the picture's own intrinsic size**, which is `Image`'s behaviour and is deliberately not overridden. `ratio` is what makes it fill the width it is given, which is the other half of reserving the space.

:::

## Beyond a plain `<img>`

An `<img>` is one tag and it works, so it is worth saying what this is for rather than assuming it. Three things:

1. **The space is reserved** before the picture arrives, so the paragraph under it does not move when it does. That is `ratio`, and it is the prop to set every time, without it there is nothing to reserve, because the box is however tall the picture turns out to be and nobody knows that until it lands.
2. **A failure is drawn** rather than left as the browser's broken-image glyph and the alt text in a serif nobody chose.
3. **The two are one state machine**, so the placeholder is not still sitting behind a picture that has already loaded, and a changed `src` starts again rather than inheriting the last one's success.
4. **The picture fades up over the placeholder** rather than replacing it between two frames. A photograph that cuts in reads as the layout changing its mind, and it reads that way hardest on the slow connection the placeholder exists for. A picture that was already decoded is drawn whole, because an entrance for something that never had to be waited for is an entrance for nothing.

## Examples

### The two states

<Demo src="image/states" :min-height="280">

::: fw react

<<< @/.vitepress/demos/image/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/states.dart

:::

</Demo>

`placeholder` replaces the skeleton. `null` draws nothing and leaves the reserved box empty. `fallback` replaces the alt text, which is the default because it is the one thing that is certainly available and certainly describes what is missing.

### placeholder

A small copy of the same picture can stand in while the file arrives, so the reader sees its colours and shape before its detail. It is drawn under the picture with the same `fit`, `position`, `rotate`, `flip` and `filter`, and stays until the picture has finished fading in over it.

<Demo src="image/placeholder" :min-height="320">

::: fw react

<<< @/.vitepress/demos/image/placeholder.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/placeholder.dart

:::

</Demo>

Once the picture has faded in, the stand-in is removed in one step rather than faded out, because a cross-fade of the two would let the page show through halfway. It is removed at once if the picture fails, and the skeleton is not drawn while it stands in. Like the skeleton it fills the box, so it needs a box to fill: a `ratio`, or both `width` and `height`.

::: fw react

Pass `{ src }`, where `src` is a URL, a data URI or a `Blob`. A `Blob` is given an object URL while it is shown, and the URL is revoked when it no longer is. `blur: true` blurs the stand-in by 20 pixels and a number by that many; a copy stretched up from a few pixels looks blocky without it.

:::

::: fw flutter

Pass a `PlImagePlaceholder` with any `ImageProvider`: a `MemoryImage` of a few hundred bytes, an asset, or a small network file. `blur` is a radius in logical pixels, and `20` matches React's `blur: true`. It is a widget, so the parameter can keep its `Widget?` type, and built anywhere else it draws its picture covering its space.

:::

The demo's stand-in is a 24 by 16 pixel copy of the photograph, 186 bytes as WebP.

### fit

How the picture fills its box: `cover` fills it and crops, `contain` fits the whole picture inside, `fill` stretches it, `none` draws it at its own size, and `scale-down` is `contain` that never enlarges a file smaller than the box.

<Demo src="image/fit" :min-height="220">

::: fw react

<<< @/.vitepress/demos/image/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/fit.dart

:::

</Demo>

`width` and `height` given together describe the file, and the box keeps their proportion before it arrives. One given alone sizes the box on that axis instead, and `fit` decides what the picture does with the space:

- A lone `height` is a box that tall, as wide as its container. With a `ratio` as well, the width comes from the ratio.
- A lone `width` is a box that wide, never wider than its container, and as tall as the picture or the `ratio` makes it.

A box narrower than its container sits at its start, and `preview`'s focus ring is drawn around the box rather than the space beside it.

::: fw react

A number, or a string of digits as in `height="200"`, is pixels. Any other string is a CSS length and is used as written, so `height="12rem"` works. Both still reach the `<img>` as attributes.

:::

::: fw flutter

Both are `double`s in logical pixels. A lone `height` with no `ratio` takes the full width it is given, so it needs a width to take: inside a `Row`, wrap it in `Expanded`.

:::

### position

Where the picture sits in its box: which part of it a `cover` crop keeps, and where `contain`, `none` and `scale-down` leave their empty space.

<Demo src="image/position" :min-height="200">

::: fw react

<<< @/.vitepress/demos/image/position.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/position.dart

:::

</Demo>

The position is read on the picture as it is shown, so it holds through `rotate` and `flip`: the top keeps the top of what the reader sees, not the top of the file. It is physical rather than logical, because the subject of a photograph does not move to the other side on a right-to-left page.

::: fw react

`center`, a side (`top`, `right`, `bottom`, `left`), a corner written the CSS way (`'top left'`), or two percentages across and down (`'30% 20%'`). Any other value `object-position` accepts, such as a length, is passed through as written, and is not converted for `rotate` or `flip`.

:::

::: fw flutter

An `Alignment`, which is Flutter's own spelling of the same idea: `Alignment.topCenter` is `top`, and `Alignment(-0.4, -0.6)` is `'30% 20%'`. It is typed `Alignment` rather than `AlignmentGeometry` so that a directional one cannot be passed by mistake.

:::

### letterbox

What fills the part of the box that `contain`, `none` and `scale-down` leave empty. `blur` draws the picture itself behind it, covering the box and blurred, the way a video player fills the sides of a portrait clip.

<Demo src="image/letterbox" :min-height="200">

::: fw react

<<< @/.vitepress/demos/image/letterbox.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/letterbox.dart

:::

</Demo>

The blurred copy is turned, mirrored, placed and treated the way the picture is, and fades in with it. It is hidden from assistive technology and takes no pointer, so a right-click on the empty part of the box does not offer to save a picture. It is drawn only under a `fit` that can leave space, because under `cover` and `fill` there is nothing for it to show through.

::: fw react

Any other string is a CSS `background`: a colour, a token such as `var(--plass-primary-soft)`, or a gradient. It is painted on the box.

The copy is a second `<img>` with the picture's own `src`, `srcSet`, `sizes`, `loading`, `decoding`, `crossOrigin` and `referrerPolicy`, so the browser chooses the same file and fetches it once.

:::

::: fw flutter

`PlImageLetterbox(decoration)` paints any `Decoration` behind the picture: a colour, a gradient. A `Decoration` rather than a colour because that is what covers both here, where React takes a CSS `background` string.

The copy is a second `Image` of the same `ImageProvider`, so it is answered from the same cache entry rather than loaded again.

:::

### rotate

Turns the picture clockwise by `90`, `180` or `270` degrees. Any other number goes to the nearest quarter, so `-90` is `270`.

<Demo src="image/rotate" :min-height="240">

::: fw react

<<< @/.vitepress/demos/image/rotate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/rotate.dart

:::

</Demo>

A picture on its side is laid out on its side. A `ratio` is the shape of the layout, so it is kept, and `fit` decides how the turned picture fills it. Without a `ratio`, the box takes the turned shape of the picture. The placeholder, the fallback and the watermark stay upright, and `preview` opens the picture turned the same way.

::: fw react

`width` and `height` still describe the file, so `width={1200} height={800} rotate={90}` reserves a box two wide by three tall before the file arrives. With neither, the box takes the turned shape once the file has loaded, and is empty until then.

The turn is drawn with the CSS `rotate` property rather than `transform`, so a `transform` of your own, a hover effect for example, still applies on top of it.

:::

::: fw flutter

The picture is turned with a `RotatedBox`, which turns its layout as well as its paint. Without a `ratio`, the box takes the turned shape once the picture has loaded. There are no file dimensions to reserve it from beforehand, because an `ImageProvider` does not carry them the way an `<img>`'s `width` and `height` do.

:::

### flip

Mirrors the picture: `horizontal` swaps left and right, `vertical` swaps top and bottom, and `both` does the two. The axes are the ones the picture is shown on, so `flip="horizontal"` swaps left and right on the screen whether or not `rotate` has turned the picture.

<Demo src="image/flip" :min-height="200">

::: fw react

<<< @/.vitepress/demos/image/flip.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/flip.dart

:::

</Demo>

A mirrored picture keeps its box, and `preview` opens it mirrored the same way.

::: fw react

The mirror is drawn with the CSS `scale` property, so it leaves `transform` free just as `rotate` does.

:::

### filter

A treatment laid over the picture. Six of them have names (`grayscale`, `sepia`, `saturate`, `desaturate`, `contrast` and `dim`), and anything else you pass is a CSS `filter` chain, used exactly as written.

<Demo src="image/filter" :min-height="220">

::: fw react

<<< @/.vitepress/demos/image/filter.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/filter.dart

:::

</Demo>

It rides the same transition as the picture's own fade, so a filter swapped on hover travels rather than snapping while the fade is still moving. Nothing is applied to the skeleton or to the fallback, because a greyed-out skeleton is not what `grayscale` was asked for. A picture stand-in is treated the way the picture is.

::: fw flutter

The escape hatch is `colorFilter`, which takes a `ColorFilter` of your own and wins over a named `filter`. A CSS chain has nothing to mean here, and a `ColorFilter` is what the same idea is in Flutter. The named ones resolve to the same amounts the React build writes, so `sepia` is one colour across the two packages rather than two that look alike.

:::

### watermark

A mark laid over the picture. A bare string sits in the bottom corner; an object says where it goes, how visible it is and at what angle. `placement: 'tile'` covers the whole picture instead, which is what a proof or a preview wants. A mark in a corner is cropped off in a second.

<Demo src="image/watermark" :min-height="240">

::: fw react

<<< @/.vitepress/demos/image/watermark.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/watermark.dart

:::

</Demo>

A tiled mark is **one repeating background**, not a wall of elements. A photograph usually takes forty or fifty copies of the mark, and that many elements would be that many things to lay out, to hide from a screen reader and to trip the caller's own CSS over. The layer is turned **as one layer** rather than each copy being turned on its own, which is what keeps the repeat seamless: turning the tiles inside a straight grid leaves the grid's lines showing through.

It is drawn only once the picture has arrived, a stamp over a skeleton is a claim about a file that has not turned up, and it is `aria-hidden` and takes no pointer. A watermark is a claim about the file rather than something the page is telling a reader; `alt` is where a picture says what it is. It follows the picture into `preview`, because a mark that comes off when the picture is opened large has marked the copy nobody wanted.

### protect

Refuses the four ways a picture is casually taken: the context menu, a drag out of the page, a text selection over it, and the long-press callout on iOS, which is the one that is easy to forget and the one that matters most, because on iOS the long press _is_ the context menu.

<Demo src="image/protect" :min-height="220">

::: fw react

<<< @/.vitepress/demos/image/protect.tsx

:::

</Demo>

**It is a deterrent and not a lock.** The file is still one request away: it is in the network tab, it is in the cache, and a screenshot needs neither. What this stops is the casual right-click-and-save, which for most pictures is the whole of what was wanted. Anything that genuinely must not be copied does not belong on the page.

A caller's own `onContextMenu` still runs, and does not turn the refusal off. Asking to protect a picture and then handing it a handler would otherwise undo the protection without saying so. It follows the picture into `preview`, because a refusal that comes off the moment the picture is opened large is no refusal at all: large is the copy somebody wanted in the first place.

::: fw flutter

There is no `protect` here, and nothing for it to do. A Flutter app paints its pictures onto a canvas rather than into an element of their own, so there is no per-picture context menu to refuse, nothing to drag out and no selection to take. Disabling the browser's own menu on Flutter web is an application-wide decision, `BrowserContextMenu` in `package:flutter/services.dart`, rather than something one widget can ask for.

:::

### preview

Opens the picture over the page when it is pressed. Off by default: a picture that grows when you click it suggests there is more of it to see, which is not true of most pictures on a page.

<Demo src="image/preview" :min-height="280">

::: fw react

<<< @/.vitepress/demos/image/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/preview.dart

:::

</Demo>

It is a [`PlOverlay`](../feedback/overlay) at `tone="glass"`, so Escape and a click outside close it. The trigger is disabled until the picture has arrived, since there is nothing to preview yet, and it is named after the picture rather than "Preview", because three previews on a page would otherwise be three buttons with the same name.

::: fw react

The overlay is a **separate chunk**, reached through `React.lazy`. It is several times the weight of the picture component that opens it, and `preview` is off by default, so a page drawing a wall of thumbnails does not download a lightbox it never shows. Turn it on and the chunk is fetched once, after the first paint. Nothing to configure either way, but it does mean the overlay appears a moment after the very first press on a cold cache.

:::

### priority

When the picture is fetched. `loading="lazy"` is the default, which leaves a picture below the fold until the reader scrolls near it. `priority` marks the picture a page is judged by, usually the largest one above the fold, which is what Largest Contentful Paint measures.

::: fw react

```tsx
<PlImage src="/hero.jpg" alt="The 2026 team" ratio="16 / 9" priority />
```

`priority` sets `loading="eager"` and `fetchPriority="high"`. Anything you write out yourself wins, so `priority loading="lazy"` is still lazy. The native attributes pass through on their own as well: `loading`, `decoding="async"` to decode off the main thread, and `fetchPriority`. A blurred `letterbox` copy is given the same `loading` and fetch priority, so it stays the same request.

A lazy picture still needs its reserved box. It is not fetched until it is near the viewport, so a box without a `ratio` or both dimensions has no height until then and moves the page when the picture lands.

Browsers without `fetchpriority` ignore it and fetch the picture eagerly at their default priority. [Browser support](../../browser-support) lists the versions.

:::

::: fw flutter

There is no `priority` here. An `Image` starts resolving its provider as soon as it is built, so there is no lazy loading to turn off and no fetch priority to raise. To have a picture ready before its screen is shown, call `precacheImage` with its provider first.

:::

### A gallery

For a set of pictures, use [`PlGallery`](./gallery): it arranges them, captions them, and opens each one in a lightbox. Compose the grid yourself when you need a layout or a selection state of your own. The `preview` here shows one picture and has no next or previous control.

```tsx
const [at, setAt] = useState<number | null>(null);

{
  photos.map((photo, index) => (
    <PlImage
      key={photo.id}
      src={photo.thumb}
      alt={photo.alt}
      ratio="1"
      onClick={() => setAt(index)}
    />
  ));
}

<PlOverlay open={at !== null} onOpenChange={() => setAt(null)} tone="glass" dismissible>
  …
</PlOverlay>;
```

## Accessibility

- `alt` is **required**, and `""` is a real answer rather than a missing one: it marks the picture decorative and takes it off the accessibility tree, which is right for a texture or a background and wrong for anything a reader would miss.
- The fallback drawn on failure is the `alt` text, so a sighted reader and a screen reader are told the same thing when the picture does not arrive.
- The `<img>` stays in the document while it loads. An `<img>` that is not in the document never loads, so a placeholder that unmounted it would be a picture that never arrives.
- `loading="lazy"` by default. Set `priority` on the one picture that is above the fold. A lazily-loaded hero is a hero that arrives late.

::: fw flutter

The inner `Image` is `excludeFromSemantics`, so the picture is named exactly once (by the wrapper), and never read twice.

:::
