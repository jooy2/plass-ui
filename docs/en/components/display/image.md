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

Every native `<img>` attribute passes straight through, `srcSet`, `sizes` and `crossOrigin` included. `onLoad` and `onError` are the two exceptions — the component owns them, and `onStatusChange` is what it offers instead.

::: fw flutter

`image` is an `ImageProvider` rather than a URL, because that is the shape every source has in common — a network image, an asset, a file, a memory buffer — and `semanticLabel` is what `alt` is: `null` marks the picture decorative.

**Without a `ratio` the widget is the picture's own intrinsic size**, which is `Image`'s behaviour and is deliberately not overridden. `ratio` is what makes it fill the width it is given, which is the other half of reserving the space.

:::

## What this adds to an `<img>`

An `<img>` is one tag and it works, so it is worth saying what this is for rather than assuming it. Three things:

1. **The space is reserved** before the picture arrives, so the paragraph under it does not move when it does. That is `ratio`, and it is the prop worth reaching for every time — without it there is nothing to reserve, because the box is however tall the picture turns out to be and nobody knows that until it lands.
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

`placeholder` replaces the skeleton — `null` draws nothing and leaves the reserved box empty. `fallback` replaces the alt text, which is the default because it is the one thing that is certainly available and certainly describes what is missing.

### filter

A treatment laid over the picture. Six of them have names — `grayscale`, `sepia`, `saturate`, `desaturate`, `contrast` and `dim` — and anything else you pass is a CSS `filter` chain, used exactly as written.

<Demo src="image/filter" :min-height="220">

::: fw react

<<< @/.vitepress/demos/image/filter.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/filter.dart

:::

</Demo>

It rides the same transition as the picture's own fade, so a filter swapped on hover travels rather than snapping while the fade is still moving. Nothing is applied to the placeholder or to the fallback — a greyed-out skeleton is not what `grayscale` was asked for.

::: fw flutter

The escape hatch is `colorFilter`, which takes a `ColorFilter` of your own and wins over a named `filter`. A CSS chain has nothing to mean here, and a `ColorFilter` is what the same idea is in Flutter. The named ones resolve to the same amounts the React build writes, so `sepia` is one colour across the two packages rather than two that look alike.

:::

### watermark

A mark laid over the picture. A bare string sits in the bottom corner; an object says where it goes, how visible it is and at what angle. `placement: 'tile'` covers the whole picture instead, which is what a proof or a preview wants — a mark in a corner is cropped off in a second.

<Demo src="image/watermark" :min-height="240">

::: fw react

<<< @/.vitepress/demos/image/watermark.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/watermark.dart

:::

</Demo>

A tiled mark is **one repeating background**, not a wall of elements. A photograph wants the mark often enough that forty or fifty copies is the usual count, and forty or fifty of them would be forty or fifty things to lay out, to hide from a screen reader and to trip the caller's own CSS over. The layer is turned **as one layer** rather than each copy being turned on its own, which is what keeps the repeat seamless: turning the tiles inside a straight grid leaves the grid's lines showing through.

It is drawn only once the picture has arrived — a stamp over a skeleton is a claim about a file that has not turned up — and it is `aria-hidden` and takes no pointer. A watermark is a claim about the file rather than something the page is telling a reader; `alt` is where a picture says what it is. It follows the picture into `preview`, because a mark that comes off when the picture is opened large has marked the copy nobody wanted.

### protect

Refuses the four ways a picture is casually taken: the context menu, a drag out of the page, a text selection over it, and the long-press callout on iOS — which is the one that is easy to forget and the one that matters most, because on iOS the long press *is* the context menu.

<Demo src="image/protect" :min-height="220">

::: fw react

<<< @/.vitepress/demos/image/protect.tsx

:::

</Demo>

**It is a deterrent and not a lock.** The file is still one request away: it is in the network tab, it is in the cache, and a screenshot needs neither. What this stops is the casual right-click-and-save, which for most pictures is the whole of what was wanted. Anything that genuinely must not be copied does not belong on the page.

A caller's own `onContextMenu` still runs, and does not turn the refusal off — asking to protect a picture and then handing it a handler would otherwise undo the protection without saying so. It follows the picture into `preview`, because a refusal that comes off the moment the picture is opened large is no refusal at all: large is the copy somebody wanted in the first place.

::: fw flutter

There is no `protect` here, and nothing for it to do. A Flutter app paints its pictures onto a canvas rather than into an element of their own, so there is no per-picture context menu to refuse, nothing to drag out and no selection to take. Disabling the browser's own menu on Flutter web is an application-wide decision — `BrowserContextMenu` in `package:flutter/services.dart` — rather than something one widget can ask for.

:::

### preview

Opens the picture over the page when it is pressed. Off by default: a picture that grows when you click it is a promise that there is more of it to see, and most pictures on a page are not making it.

<Demo src="image/preview" :min-height="280">

::: fw react

<<< @/.vitepress/demos/image/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/preview.dart

:::

</Demo>

It is a [`PlOverlay`](../feedback/overlay) at `tone="glass"`, so Escape and a click outside close it. The trigger is disabled until the picture has arrived — there is nothing to preview yet — and it is named after the picture rather than "Preview", because three previews on a page would otherwise be three buttons with the same name.

::: fw react

The overlay is a **separate chunk**, reached through `React.lazy`. It is several times the weight of the picture component that opens it, and `preview` is off by default, so a page drawing a wall of thumbnails does not download a lightbox it never shows. Turn it on and the chunk is fetched once, after the first paint. Nothing to configure either way — but it does mean the overlay appears a moment after the very first press on a cold cache.

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
- `loading="lazy"` by default. Set `loading="eager"` on the one picture that is above the fold — a lazily-loaded hero is a hero that arrives late.

::: fw flutter

The inner `Image` is `excludeFromSemantics`, so the picture is named exactly once — by the wrapper — and never read twice.

:::
