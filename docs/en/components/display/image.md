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

### A gallery

There is no gallery component and no next/previous inside the preview, deliberately: a gallery is a list with a state of its own, and it composes out of what is already here.

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
