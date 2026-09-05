---
title: PlContainer
order: 2
---

# PlContainer

<p class="plass-lede">Horizontal breathing room, and optionally a measure. It is the outermost element on a page, which is exactly why it draws nothing at all.</p>

<Demo src="container/hero" :min-height="200" />

::: fw react

```tsx
import { PlContainer } from 'plass-ui';

<PlContainer maxWidth="lg" render={<main />}>
  {page}
</PlContainer>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlContainer(
  maxWidth: const PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.lg)),
  child: page,
);
```

:::

## Props

<PropsTable name="PlContainer" />

::: fw react

Every native `<div>` attribute passes straight through.

:::

::: fw flutter

`maxWidth` takes a `PlassResponsive<PlContainerWidth?>`. `PlContainerWidth.rung(PlassSize.lg)` is a rung of the ladder and `PlContainerWidth.pixels(720)` is an exact width, two constructors rather than one nullable pair, because only one of them can be true at a time and Dart has no untagged union. `null` is "no limit", where React spells that `'none'`: a TypeScript union can carry an extra word, and Dart has `null` for exactly this.

:::

There is no `variant`, no `color` and no `elevation`. The outermost element on a page is the one thing that must not decide what the page looks like, and a container that carried a sheet would put a second pane behind every card on it. Wrap it in a `PlCard` when the sheet is what you want. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### maxWidth

The same ladder the breakpoints use (`xs` 30rem, `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem) written in `rem` rather than taken from a framework's own container scale, so a container's `lg` and an `lg:` utility change at the same width. Two ladders called `lg` on one page is how a layout drifts by a few pixels for no reason anybody can find later.

<Fw react="'none'" flutter="null" code /> is the default. A container's job is the gutter; a measure is a second decision, and a page should have to ask for one.

::: fw react

**It also takes any length**, and that is not a convenience: the five rungs are `rem`, and the measure a paragraph actually wants is in _characters_. `maxWidth="72ch"` is the one no ladder can spell. A number is pixels.

**And it is responsive**. `maxWidth` takes `{ xs: 'none', md: 'lg' }`. It resolves in **CSS** rather than in JavaScript, which is what makes it free: the first paint a server sends is already right at every width, and a window being dragged costs no re-render. See [breakpoints](../../design/breakpoints).

:::

<Demo src="container/widths" :min-height="220">

::: fw react

<<< @/.vitepress/demos/container/widths.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/container/widths.dart

:::

</Demo>

### padded, size and density

The gutter is the **sheet** padding track, not the control one. What sits inside a container is a page, and the margin a page keeps from the edge of a window is the margin a card keeps around a paragraph, not the room a label needs beside the edge of the key it is printed on.

`size` here is the size of the sheet: it never touches a height or a type scale, and it has nothing to do with `maxWidth`, which is how wide the content gets rather than how far it sits from the edge. Turning `padded` off gives the gutter up and keeps everything else, which is what a container nested inside one that already pads wants.

The gutter is measured **inside** the limit rather than outside it, so a `lg` container is 64rem of container and not 64rem of content plus two margins. <Fw react="That is box-sizing: border-box, which the bundled reset already sets." flutter="That is the ConstrainedBox sitting outside the Padding rather than inside it." />

<Demo src="container/padding" :min-height="280">

::: fw react

<<< @/.vitepress/demos/container/padding.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/container/padding.dart

:::

</Demo>

### centered

On by default, and inert until `maxWidth` is narrower than the page, with no measure there is nothing left over to centre in.

Turned off, the content sits against the **start** edge rather than the left one, so it moves to the right under RTL.

<Demo src="container/centered" :min-height="260">

::: fw react

<<< @/.vitepress/demos/container/centered.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/container/centered.dart

:::

</Demo>

## Accessibility

- The box adds no role and no semantics node of its own. A container is a margin, and a margin is not something a screen reader should have to announce.

::: fw react

- `render={<main />}` is how it becomes the landmark a page actually needs. That is a decision about the document, so the component never guesses it: a `<main>` rendered twice on one page is worse than none at all.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `maxWidth="none"` | `maxWidth: null` | Dart already has a word for "not set", and a `PlassSize` with a sixth value in it would be a second size ladder. |
| `render` | — | There is no element to swap, and no landmark role to claim. An app that needs a scaffold puts this inside one. |
| `children` | `child` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

The measure ladder is the same ladder, unit for unit: the React package writes it in `rem` against a 16px root, and a logical pixel is that same unit, so `sm` is `40rem` there and 640 here.

:::
