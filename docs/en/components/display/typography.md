---
title: PlTypography
order: 14
---

# PlTypography

<p class="plass-lede">The library's type scale on its own, so a page can use it without wrapping its prose in a card. <code>level</code> sets the size and the element at once.</p>

<Demo src="typography/hero" :min-height="260" />

```tsx
import { PlTypography } from 'plass-ui';

<PlTypography level="h2">A material rather than a theme</PlTypography>;
<PlTypography>Every surface answers one question.</PlTypography>;
```

## Props

<PropsTable name="PlTypography" />

Every native `<p>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

There is no `variant`, no `elevation` and no `size`. `level` **is** the size — a `size` prop alongside it would let a caller ask for an `h1` at `xs`, which is a heading that is not a heading.

What the shared axes (`color` `align`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### level

Body sits on the same ladder a `PlCard`'s body does at `md` — 13px on 22px — so a paragraph inside a card and a standalone one are the same text. The headings step up from there by roughly a major third, and the leading tightens as they grow: a 30px line does not want the same 1.7 ratio a 13px one does.

`caption` and `overline` are muted by default. Everything else takes the page's own foreground — a heading that arrived pre-greyed is a heading a designer has to undo.

<Demo src="typography/levels" :min-height="420">

<<< @/.vitepress/demos/typography/levels.tsx

</Demo>

### render

`level` sets the scale _and_ the element, which is the common case. When they have to differ — a subheading that should not enter the document outline, a `<p>` that has to look like an `h3` — `render` breaks the tie.

<Demo src="typography/render" :min-height="200">

<<< @/.vitepress/demos/typography/render.tsx

</Demo>

### weight

Resolved in JavaScript rather than stacked as a second class, so exactly one `font-*` utility is ever emitted. Two of equal specificity would be decided by their order in the generated stylesheet, where `font-semibold` beats `font-normal` no matter which one was asked for.

<Demo src="typography/weight" :min-height="180">

<<< @/.vitepress/demos/typography/weight.tsx

</Demo>

### lines

One line is `text-overflow: ellipsis`, which keeps the text on its own baseline. More than one needs the line-clamp box, which only ellipsises because WebKit says so.

<Demo src="typography/lines" :min-height="240">

<<< @/.vitepress/demos/typography/lines.tsx

</Demo>

### color

<Demo src="typography/colors" :min-height="200">

<<< @/.vitepress/demos/typography/colors.tsx

</Demo>

## Accessibility

- A `level` of `h1`–`h6` renders that heading, so it enters the document outline. Choose the level for what the section _is_, not for how big it should look, and use `render` when the two disagree.
- `lines` clips text visually and leaves the whole string in the DOM, so a screen reader and a find-on-page both still get all of it.
- `gutter` is off by default. A component that injects margins is one a layout has to fight, and spacing is the page's decision.
