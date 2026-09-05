---
title: PlAspectRatio
order: 1
---

# PlAspectRatio

<p class="plass-lede">A box that keeps a proportion whatever width it is given. It draws nothing. What it does is reserve the space, so a picture that arrives late does not reflow the page around it.</p>

<Demo src="aspect-ratio/hero" :min-height="240" />

::: fw react

```tsx
import { PlAspectRatio } from 'plass-ui';

<PlAspectRatio ratio="16 / 9" rounded>
  <img src="/cover.jpg" alt="" />
</PlAspectRatio>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAspectRatio(
  ratio: 16 / 9,
  rounded: true,
  child: Image(image: cover),
);
```

:::

## Props

<PropsTable name="PlAspectRatio" />

::: fw react

Every native `<div>` attribute passes straight through.

:::

::: fw flutter

`ratio` is a `double` written as the division, `16 / 9`, which is how Flutter states an aspect ratio everywhere else, and it asserts rather than clamping: a ratio of zero is a mistake, not a shape.

:::

`size` is the only shared axis here, and it is the size of the _sheet_, which radius step `rounded` uses. There is no `variant`, no `color` and no `elevation`: a layout component that drew a surface would make a proportion a visual decision. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### ratio

CSS's own `aspect-ratio`, untranslated, a number or a ratio, both reaching the property as written. A caller who already knows `16 / 9` has nothing to look up.

<Demo src="aspect-ratio/ratios" :min-height="220">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/ratios.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/ratios.dart

:::

</Demo>

### fit

The one convenience on top of the proportion. The four words are `object-fit`'s own: `cover` fills the box and crops, `contain` letterboxes, `fill` stretches, `none` draws at the content's own size.

`cover` is the one a thumbnail wants, a thumbnail that letterboxes itself is a thumbnail with two grey bands in it. `contain` is for the picture whose whole subject matters: a diagram, a logo, a scan.

::: fw react

A single `img`, `video`, `canvas`, `svg` or `picture` that is a direct child is stretched to the full box and then fitted, which is the pair of declarations every use of this component would otherwise start with. Anything else is laid out normally and `fit` does not reach it. An `iframe` takes the sizing but not the fit: an embed lays its own content out, and `object-fit` has nothing to act on.

:::

::: fw flutter

**It is `null` by default here, where React defaults it to `cover`.** In a browser `object-fit` is a property only a replaced element answers, so React can default it and have it quietly not reach a `<div>` full of text. Flutter has no such distinction. A fit is a `FittedBox` around whatever the child happens to be, and one applied by default would scale a column of prose. So it is opt-in, and it applies to everything.

An `Image` that already carries its own `BoxFit` needs nothing here.

:::

<Demo src="aspect-ratio/fit" :min-height="240">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/fit.dart

:::

</Demo>

### rounded

Off by default. A photograph with its corners cut is a decision about the photograph, not about the box holding it, but it is such a common one that making the caller reach for <Fw react="a className" flutter="a ClipRRect" /> would be perverse, so it is a boolean and `size` picks the step.

The box clips whatever it holds either way. Without that, a `cover` image would spill straight out of the proportion it was just given and the component would only be reserving space rather than holding anything to it.

<Demo src="aspect-ratio/embed" :min-height="240">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/embed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/embed.dart

:::

</Demo>

## Accessibility

- The box adds no role and no semantics node of its own. It is a measurement, and a measurement is not something a screen reader should have to announce.
- Nothing here supplies a description of the picture inside. That picture is the caller's, and so is what it means.

::: fw react

- `render` is how the box becomes the element the content actually calls for, a `<figure>` around a picture with a caption, an `<a>` around a card's cover.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `fit` defaults to `'cover'` | `fit` defaults to `null` | `object-fit` reaches only a replaced element, so React can default it harmlessly. A `FittedBox` reaches whatever it is given, and one applied by default would scale a column of text. |
| `ratio` takes `'16 / 9'` | `ratio` takes `16 / 9` | A `double` written as the division, which is how Flutter states an aspect ratio everywhere else. There is no string form to parse. |
| `render` | — | There is no element to swap. A widget that has to be a link or a figure is wrapped in one. |
| `children` | `child` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
