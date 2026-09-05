---
title: PlAppLogo
order: 15
---

# PlAppLogo

<p class="plass-lede">A product's mark, and its name beside it. The whole component is the framing — and <code>bare</code> is the default, because artwork that was drawn with its own background must not be put on a plate.</p>

<Demo src="app-logo/hero" :min-height="240" />

::: fw react

```tsx
import { PlAppLogo } from 'plass-ui';

<PlAppLogo shape="plate" name="Acme" render={<a href="/" />}>
  <AcmeGlyph />
</PlAppLogo>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAppLogo(
  shape: PlAppLogoShape.plate,
  name: const Text('Acme'),
  onPressed: goHome,
  child: const AcmeGlyph(),
);
```

:::

## Props

<PropsTable name="PlAppLogo" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## shape is the component

Three answers to one question — how is this artwork framed — and the default is the one project after project gets wrong.

|  |  |
| --- | --- |
| `bare` | Drawn as it was given, at the height `size` asks for and whatever width that comes to. **The default.** |
| `plate` | A tile with the artwork inset in it, corners cut to the house radius. |
| `circle` | The same tile, round. |

**`bare` is the default because most marks already have a frame.** A mark drawn with its own background, its own margin, or the product's name set into it is finished artwork: putting it on a plate gives it two edges, and cropping it to a circle cuts the name in half. Reach for `plate` or `circle` only for a mark drawn as a bare glyph, which cannot sit next to anything else until it has been given an edge.

<Demo src="app-logo/shapes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/app-logo/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/app_logo/shapes.dart

:::

</Demo>

`bare` sets the **height** and lets the width follow, which is what a wordmark needs and what a square would destroy. A plate insets the artwork to about seventy percent of the tile rather than filling it, so a glyph has the margin every app icon has.

## PlAppLogo or PlAvatar

They look alike and they answer different questions.

[`PlAvatar`](./avatar) is a picture of a **person or a thing**: always a circle or a fillet, with initials behind it when the picture does not arrive, because there is always something to draw. `PlAppLogo` is artwork the **product owns**: it has no fallback worth inventing, and its shape is a decision somebody already made — which is why the shape is a prop here and a house rule there.

## Examples

### A header's brand slot

The ordinary place for one, and the reason `render` is worth reaching for: a logo is nearly always the way back to the front page.

```tsx
<PlHeader
  brand={
    <PlAppLogo shape="plate" name="Acme" render={<a href="/" />}>
      <AcmeGlyph />
    </PlAppLogo>
  }
/>
```

### Saying which copy this is

`description` is the line under the name — an environment, a tenant, a plan. It is the cheapest way to stop somebody editing production because it looked like staging.

```tsx
<PlAppLogo shape="plate" name="Acme" description="Staging" color="warning">
  <AcmeGlyph />
</PlAppLogo>
```

### A picture rather than a glyph

::: fw react

`src` draws an `<img>` for you, sized the way the shape asks.

```tsx
<PlAppLogo src="/logo.svg" alt="Acme" />
```

:::

::: fw flutter

The mark is a widget, so it is whatever draws the artwork — a `PlImage`, an `Image.asset`, a `CustomPaint`.

```dart
PlAppLogo(semanticLabel: 'Acme', child: Image.asset('assets/logo.png'));
```

:::

## Notes

- `variant` and `color` are read **only when there is a plate**. A bare mark is the product's own artwork and the library does not tint it.
- The mark's height is the `size` ladder: `md` is 32px, which sits inside a `md` [header](../layout/header)'s 64px floor with room either side rather than filling it.
- The name is a `<span>` and not a heading. A logo names the product, and the page's heading names the page.

## Accessibility

- **With a `name`, the mark is decorative** and is taken off the accessibility tree. The wordmark beside it already says what the product is called, and a picture that says it again is a screen reader reading the name twice.
- Without a `name`, the mark speaks: `alt` in React, `semanticLabel` in Flutter. An empty `alt` is a real answer and the default — it says the picture carries nothing the text does not.
- A logo that goes home should say so. `render={<a href="/" />}` makes it a real link with a real destination, rather than a click handler on a picture.
