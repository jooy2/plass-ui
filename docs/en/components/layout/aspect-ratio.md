---
title: PlAspectRatio
order: 1
---

# PlAspectRatio

<p class="plass-lede">A box that keeps a proportion whatever width it is given. It draws nothing — what it does is reserve the space, so a picture that arrives late does not reflow the page around it.</p>

<Demo src="aspect-ratio/hero" :min-height="240" :flutter="false" />

::: fw react

```tsx
import { PlAspectRatio } from 'plass-ui';

<PlAspectRatio ratio="16 / 9" rounded>
  <img src="/cover.jpg" alt="" />
</PlAspectRatio>;
```

:::

## Props

<PropsTable name="PlAspectRatio" />

::: fw react

Every native `<div>` attribute passes straight through.

:::

`size` is the only shared axis here, and it is the size of the *sheet* — which radius step `rounded` uses. There is no `variant`, no `color` and no `elevation`: a layout component that drew a surface would make a proportion a visual decision. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### ratio

CSS's own `aspect-ratio`, untranslated — a number or a ratio, both reaching the property as written. A caller who already knows `16 / 9` has nothing to look up.

<Demo src="aspect-ratio/ratios" :min-height="220" :flutter="false">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/ratios.tsx

:::

</Demo>

### fit

The one convenience on top of the proportion: a single `img`, `video`, `canvas`, `svg` or `picture` that is a direct child is stretched to the full box and then fitted, which is the pair of declarations every use of this component would otherwise start with.

`cover` is the default, because a thumbnail that letterboxes itself is a thumbnail with two grey bands in it. `contain` is for the picture whose whole subject matters — a diagram, a logo, a scan.

Anything that is not one of those tags is laid out normally and `fit` does not reach it. An `iframe` takes the sizing but not the fit: an embed lays its own content out, and `object-fit` has nothing to act on.

<Demo src="aspect-ratio/fit" :min-height="240" :flutter="false">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/fit.tsx

:::

</Demo>

### rounded

Off by default. A photograph with its corners cut is a decision about the photograph, not about the box holding it — but it is such a common one that making the caller reach for a `className` would be perverse, so it is a `boolean` and `size` picks the step.

The box clips whatever it holds either way. Without that, a `cover` image would spill straight out of the proportion it was just given and the component would only be reserving space rather than holding anything to it.

<Demo src="aspect-ratio/embed" :min-height="240" :flutter="false">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/embed.tsx

:::

</Demo>

## Accessibility

- The box is a plain `<div>` with no role. It is a measurement, and a measurement is not something a screen reader should have to announce.
- Nothing here supplies an `alt`. The picture inside is the caller's, and so is what it means.
- `render` is how the box becomes the element the content actually calls for — a `<figure>` around a picture with a caption, an `<a>` around a card's cover.
