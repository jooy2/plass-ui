---
title: PlIcon
order: 5
---

# PlIcon

<p class="plass-lede">A glyph at a known size, in a known colour. Plass draws no icon set of its own — this gives whichever set an app chose the same two axes everything else here has.</p>

<Demo src="icon/hero" :min-height="140" />

::: fw react

```tsx
import { PlIcon } from 'plass-ui';

<PlIcon icon={<BoltIcon />} />;
<PlIcon icon={<BoltIcon />} size="lg" color="warning" label="Fast" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlIcon(icon: BoltGlyph());
const PlIcon(icon: BoltGlyph(), size: PlassSize.lg, color: PlassColor.warning, label: 'Fast');
```

:::

## Props

<PropsTable name="PlIcon" />

::: fw react

Every native `<span>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

:::

::: fw flutter

`color` is a `PlassColor?` rather than a `PlassColor`, and `null` is the default — which is how "inherit" is spelled in a language with no such keyword.

:::

There is no `variant` and no `elevation`. An icon is not a surface — it is ink, and the only thing the design language has to say about ink is which family it is drawn in.

What the shared axes (`size` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### icon

The glyph is a prop rather than `children`. An icon set hands back an element you did not draw, and the two things you always want to change about it — how big it is and what colour it is — are the two you cannot reach once it is a child of something.

::: fw react

The box is `inline-flex` with the glyph told to fill it, and `font-size` is set to the same length. So an `<svg>` with its own `width`, an `<svg>` sized in `em`, a bare character and an `<img>` all come out the same size.

:::

::: fw flutter

The glyph is told how big it is three ways at once — through `IconTheme`, through `DefaultTextStyle` and by the box it is laid into being exactly that size. So an `Icon`, an `ImageIcon`, a `CustomPaint` that reads `IconTheme.of(context)` and a bare character all come out the same size.

:::

<Demo src="icon/anything" :min-height="140">

::: fw react

<<< @/.vitepress/demos/icon/anything.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/anything.dart

:::

</Demo>

### size

Its own ladder — 14, 16, 20, 24 and 28px — rather than a step off the control heights, because an icon is not a control. It is content, measured against the text it sits beside rather than against the row it sits in.

<Demo src="icon/sizes" :min-height="160">

::: fw react

<<< @/.vitepress/demos/icon/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/sizes.dart

:::

</Demo>

### color

`inherit` is the default, and this is the one component in the library where `color` is not `primary`. An icon usually sits inside something that has already decided what colour its content is — a button's label, a muted caption, an alert's own family — and one that arrived pre-dyed would have to be turned off again at every one of them.

<Demo src="icon/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/icon/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/colors.dart

:::

</Demo>

### Inside another component

::: fw react

A glyph passed to a `PlButton` or a `PlAlert` is already sized in `em` by that component, so it tracks the label. Wrapping it in a `PlIcon` is for when it should be a fixed size instead — or when it is standing on its own.

<Demo src="icon/inside" :min-height="220">

<<< @/.vitepress/demos/icon/inside.tsx

</Demo>

:::

::: fw flutter

A glyph passed to a `PlButton` or a `PlAlert` is already sized by that component's own `IconTheme`, at 1.2× the label, so it tracks the label. Wrapping it in a `PlIcon` is for when it should be a fixed size instead — or when it is standing on its own.

<Demo src="icon/inside" :min-height="220">

<<< @/../packages/flutter/example/lib/demos/icon/inside.dart

</Demo>

:::

## Accessibility

::: fw react

- Without `label` the icon is `aria-hidden` and carries no role. That is the right default: most icons sit next to a word that already says the same thing, and reading both out loud is worse than reading one.
- With `label` it becomes `role="img"` with that name. Pass it only when the glyph is carrying meaning on its own.
- There is no third case. `role="img"` on a decorative glyph is the most common way a screen reader ends up announcing "graphic".
- An icon that is the whole of a button belongs inside the button, not beside it: give the `PlButton` an `aria-label` and leave the icon hidden.

:::

::: fw flutter

- Without `label` the icon is excluded from the semantics tree entirely. That is the right default: most icons sit next to a word that already says the same thing, and reading both out loud is worse than reading one.
- With `label` it becomes an image with that name. Pass it only when the glyph is carrying meaning on its own.
- There is no third case. Naming a decorative glyph is the most common way a screen reader ends up announcing "graphic".
- An icon that is the whole of a button belongs inside the button, not beside it: give the `PlButton` a `semanticLabel` and leave the icon unnamed.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `color="inherit"` | `color: null` | Dart has no `inherit` keyword, and a nullable enum says the same thing with one less name in it. |
| `aria-label` | `label` | Same name here, and it does the same job — but what it produces is an image node rather than a `role`. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

The library still draws no icon set. Flutter ships none outside Material, which this package does not import, so the glyphs in these previews are drawn by the gallery — exactly what an app does with whichever set it chose.

:::
