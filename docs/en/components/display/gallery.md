---
title: PlGallery
order: 23
---

# PlGallery

<p class="plass-lede">A set of pictures, arranged. Four layouts (a contact sheet, a masonry, a justified library and a quilt) with captions, a pointer treatment and an optional lightbox on all four.</p>

<Demo src="gallery/hero" :min-height="420" />

::: fw react

```tsx
import { PlGallery } from 'plass-ui';

<PlGallery
  items={[
    { src: '/harbour.jpg', alt: 'A harbour at dusk', ratio: 4 / 3 },
    { src: '/bridge.jpg', alt: 'A bridge over a river', ratio: 3 / 2 }
  ]}
  layout="masonry"
  preview
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlGallery(
  items: <PlGalleryItem>[
    PlGalleryItem(
      image: const NetworkImage('/harbour.jpg'),
      semanticLabel: 'A harbour at dusk',
      ratio: 4 / 3,
    ),
  ],
  layout: PlGalleryLayout.masonry,
  preview: true,
);
```

A viewer lifts itself out of the tree, so a gallery with `preview` on needs an `Overlay` above it, `WidgetsApp` with a navigator and `MaterialApp` both provide one.

:::

The four layouts are the component: everything else (the captions, the pointer treatment, the viewer) is the same in all of them, and choosing between them is one prop rather than four components.

## Props

<PropsTable name="PlGallery" />

### PlGalleryItem

<PropsTable name="PlGalleryItem" />

::: fw react

Every native `<ul>` attribute passes straight through. `children` is excluded because the pictures are `items`, and `onSelect` because the component's is `onItemSelect` and reports an item rather than an event.

A `className` lands on the list. `classNames` reaches the five parts inside it: `item`, `image`, `caption`, `title` and `description`.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### layout

`grid` is a contact sheet: every tile the same shape, whatever shape the files are. `masonry` keeps each picture's own proportion and stacks the columns. `justified` keeps the proportions **and** fills every row to the edge, the arrangement a photograph library uses, and the only one where no tile is cropped and no space is left over. `quilted` is a grid whose tiles may take more than one cell.

<Demo src="gallery/layouts" :min-height="460">

::: fw react

<<< @/.vitepress/demos/gallery/layouts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/layouts.dart

:::

</Demo>

A masonry deals **across before it deals down**. CSS `columns` fills the first column top to bottom before it starts the second, so a set numbered 1 to 12 reads down the left edge and the first three pictures a reader meets are stacked on top of each other. Dealt this way the first row is items 1, 2 and 3, which is the order they were given in.

### ratio

Every layout is laid out from the item's own `ratio` rather than from anything measured, which is why a wall of forty photographs is right in the first frame and does not reflow as the files arrive. A set without one falls back to the gallery's `ratio` and comes out as a grid of squares in a masonry's clothing.

```tsx
{ src: '/dunes.jpg', alt: 'Dunes at first light', ratio: 2 }
{ src: '/terrace.jpg', alt: 'A stepped terrace', ratio: '2 / 3' }
```

::: fw react

A number or the way CSS writes one, `2` and `'2 / 3'` both work, because that is how a ratio is written and this library does not make a caller translate it.

:::

::: fw flutter

A `double`: width over height. There is no string form, because Dart has no CSS to be consistent with.

**Two of the layouts measure here and neither does on React.** CSS does a justified row with `flex-grow` and a quilt with `grid-auto-flow: dense`; there is no such thing in Flutter, so those two pack themselves inside a `LayoutBuilder`. The arrangement is the same; what differs is who computed it.

:::

### caption

`below` puts the two lines under the picture, `overlay` writes them across the foot of it on a wash dark enough to survive a pale photograph, and `hover` is `overlay` that arrives with the pointer.

<Demo src="gallery/captions" :min-height="520">

::: fw react

<<< @/.vitepress/demos/gallery/captions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/captions.dart

:::

</Demo>

A tile with neither a `title` nor a `description` draws no caption at all, whatever `caption` says. A row of pictures with one caption under it and three gaps is worse than a row with none.

### hover

`lift` and `dim` are depth and colour, which is how everything else in the library answers a pointer. `zoom` is the one that scales, and it is the exception [the design language names](../../design/design-language): what moves is a photograph inside a frame that stays exactly where it was, with no text on it to resample.

### quilted

A tile takes `cols` columns and `rows` rows of the grid. The flow is **dense**: a tile too wide for the space left on a row does not push everything down, it drops to the next row that fits it and a later, narrower tile fills the hole.

<Demo src="gallery/quilted" :min-height="320">

::: fw react

<<< @/.vitepress/demos/gallery/quilted.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/quilted.dart

:::

</Demo>

A span wider than the grid is clamped rather than refused, which is what the caller meant by `cols: 99`.

### preview

Opens the picture full size, with the rest of the set an arrow key away. It is not a carousel: a carousel is a set somebody is being shown in order, and this is one picture with a way to the next, so there is no autoplay, no wrap, and the arrows stop at the ends rather than looping back to a photograph the reader has already seen.

`full` is the larger file, when the tile is a thumbnail. A set that has only one size of each picture needs nothing.

```tsx
{ src: '/thumb/harbour.jpg', full: '/full/harbour.jpg', alt: 'A harbour at dusk' }
```

::: fw react

The viewer is behind a `React.lazy`, so a wall of thumbnails costs nothing for a lightbox nobody opened. The same bargain [`PlImage`](image) makes with the same prop.

:::

## Accessibility

- A real `role="list"` with a name, and one `role="listitem"` per picture. A masonry's lanes are list items holding lists of their own rather than `<div>`s between the `<ul>` and its `<li>`s, which is markup a screen reader reads as a list with nothing in it.
- A tile is only a button when something happens when it is pressed. Its name is **the picture's own words plus where it sits**: "A harbour at dusk — 1 of 6", so a reader tabbing a wall of thumbnails is told which one of how many they are on.
- `itemLabel` is how that sentence is written in another language, and it is a callback rather than a string with slots because the word order differs.
- The viewer's arrow keys are bound on the sheet rather than on its buttons: the focus is wherever the reader last put it, and a key that only worked from one place is a key that looks broken everywhere else.
- The viewer's counter is a live region, so an arrow key says where it landed to a reader who cannot see the picture it landed on.
