---
title: PlTypography
order: 14
---

# PlTypography

<p class="plass-lede">The library's type scale on its own, so a page can use it without wrapping its prose in a card. <code>level</code> sets the size and the element at once.</p>

<Demo src="typography/hero" :min-height="260" />

::: fw react

```tsx
import { PlTypography } from 'plass-ui';

<PlTypography level="h2">A material rather than a theme</PlTypography>;
<PlTypography>Every surface answers one question.</PlTypography>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlTypography('A material rather than a theme', level: PlTypographyLevel.h2);
const PlTypography('Every surface answers one question.');
```

:::

## Props

<PropsTable name="PlTypography" />

::: fw react

Every native `<p>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

:::

::: fw flutter

The text is the first positional argument, the way it is on Flutter's own `Text`. `PlTypography.rich` takes an `InlineSpan` instead, for a line that changes style part of the way through.

:::

There is no `variant`, no `elevation` and no `size`. `level` **is** the size — a `size` prop alongside it would let a caller ask for an `h1` at `xs`, which is a heading that is not a heading.

What the shared axes (`color` `align`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### level

Body sits on the same ladder a `PlCard`'s body does at `md` — 13px on 22px — so a paragraph inside a card and a standalone one are the same text. The headings step up from there by roughly a major third, and the leading tightens as they grow: a 30px line does not want the same 1.7 ratio a 13px one does.

`caption` and `overline` are muted by default. Everything else takes the page's own foreground — a heading that arrived pre-greyed is a heading a designer has to undo.

<Demo src="typography/levels" :min-height="420">

::: fw react

<<< @/.vitepress/demos/typography/levels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/typography/levels.dart

:::

</Demo>

::: fw react

### render

`level` sets the scale _and_ the element, which is the common case. When they have to differ — a subheading that should not enter the document outline, a `<p>` that has to look like an `h3` — `render` breaks the tie.

<Demo src="typography/render" :min-height="200">

<<< @/.vitepress/demos/typography/render.tsx

</Demo>

:::

### weight

Overrides the weight the level would otherwise pick.

::: fw react

Resolved in JavaScript rather than stacked as a second class, so exactly one `font-*` utility is ever emitted. Two of equal specificity would be decided by their order in the generated stylesheet, where `font-semibold` beats `font-normal` no matter which one was asked for.

:::

::: fw flutter

A heading is `semibold`, and **not every font has one.** Flutter's engine carries a single face — Roboto Regular — and synthesises anything else by widening its strokes; Roboto's own family goes 400 → 500 → 700 with no 600 in it. An app on a font with no real SemiBold gets headings that are heavier and visibly softer than the ones here. Any of Inter, Pretendard, SF or Noto Sans has the weight.

:::

<Demo src="typography/weight" :min-height="180">

::: fw react

<<< @/.vitepress/demos/typography/weight.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/typography/weight.dart

:::

</Demo>

### lines

Clamps the text to this many lines with an ellipsis. Omit it and the text wraps as far as it needs to.

::: fw react

One line is `text-overflow: ellipsis`, which keeps the text on its own baseline. More than one needs the line-clamp box, which only ellipsises because WebKit says so.

:::

::: fw flutter

One mechanism at every count: `maxLines` with `TextOverflow.ellipsis`. Which is also why `semanticsLabel` exists — the clipped characters are genuinely gone from the render tree here, so a line whose full text matters to a screen reader has to say it.

:::

<Demo src="typography/lines" :min-height="240">

::: fw react

<<< @/.vitepress/demos/typography/lines.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/typography/lines.dart

:::

</Demo>

### color

<Demo src="typography/colors" :min-height="200">

::: fw react

<<< @/.vitepress/demos/typography/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/typography/colors.dart

:::

</Demo>

## Accessibility

::: fw react

- A `level` of `h1`–`h6` renders that heading, so it enters the document outline. Choose the level for what the section _is_, not for how big it should look, and use `render` when the two disagree.
- `lines` clips text visually and leaves the whole string in the DOM, so a screen reader and a find-on-page both still get all of it.
- `gutter` is off by default. A component that injects margins is one a layout has to fight, and spacing is the page's decision.

:::

::: fw flutter

- A `level` of `h1`–`h6` is announced as a heading. Choose the level for what the section _is_ rather than for how big it should look.
- `lines` really does drop the characters it clips, so pass `semanticsLabel` when the whole string matters to a screen reader.
- `gutter` is off by default. A component that injects margins is one a layout has to fight, and spacing is the page's decision.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `render` | — | Flutter has no polymorphic element. `level` decides the scale and whether the line is announced as a heading, and the two cannot be separated. |
| `h1`–`h6` as six outline levels | one heading flag | Flutter's accessibility tree has `header: true` and no depth to go with it. The scale still differs; what does not carry across is the outline's shape. |
| `children` | the first positional argument | Flutter's name, and `Text`'s shape. `PlTypography.rich` is the span form. |
| `overline` upper-cases in CSS | upper-cases the string | There is no `text-transform`, so the one case that can be handled is the one where the library owns the characters — which is why `PlTypography.rich` leaves a span's case alone. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
