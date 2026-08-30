---
title: PlFooter
order: 8
---

# PlFooter

<p class="plass-lede">The sheet at the end of a page. A real <code>&lt;footer&gt;</code>, which is what makes it the site's own information rather than more of the article — and it has no slots, because a footer's content is nobody's to guess.</p>

<Demo src="footer/hero" :flutter="false" :min-height="280" />

::: fw react

```tsx
import { PlFooter } from 'plass-ui';

<PlFooter>
  <p>© 2026 Acme</p>
</PlFooter>;
```

:::

## Props

<PropsTable name="PlFooter" />

::: fw react

Every native `<footer>` attribute passes straight through. `color` and `title` are excluded because both are Plass props here.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## It has no slots, and that is the point

[`PlHeader`](./header) has three, because a header's regions are a fixed arrangement — brand, middle, actions — worth writing once so that two pages of the same site cannot drift.

A footer is not like that. It is four columns of links on one site, a copyright line on the next, and a language switcher and an address on the third. A component that guessed at the arrangement would be one every second site fights, so this one decides the **sheet** and nothing else: the surface, the gutter, the measure, the hairline that says the document ended, and whether the bar stays in reach.

## Examples

### position

`static` is the default, and it is the opposite of a header's. A footer is the end of the document and is reached by scrolling to it.

`sticky` and `fixed` are for the other kind of bar at the bottom of a screen — a form's save row, a cookie notice, a bulk-action strip. Inside a [`PlPageLayout`](./page-layout) the height a `fixed` one takes out of the flow is reserved, so it does not sit on top of the last paragraph.

<Demo src="footer/position" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/footer/position.tsx

</Demo>

### variant

The three materials, read the way a **container** reads them. The sheet is never dyed: what is on a footer is links and text, and they arrive with colours of their own.

`divider` is on by default and rules the **top** edge — the one that faces content. A footer is the one sheet on a page with something directly above it and nothing below, so that line is the whole of what says the document ended.

<Demo src="footer/variants" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/footer/variants.tsx

</Demo>

### size

`size` is the size of the _sheet_: its gutter and the air above and below whatever is in it. Nothing here is a height — a footer is as tall as its content — and nothing here touches the type scale, which the content brings with it.

`density` moves the padding and nothing else.

<Demo src="footer/sizes" :flutter="false" :min-height="380">

<<< @/.vitepress/demos/footer/sizes.tsx

</Demo>

### maxWidth

Holds the content to a measure and centres it while the sheet still spans the window, on the same `rem` ladder [`PlContainer`](./container)'s `maxWidth` uses — so the last line of the page and the first line of the footer sit on one edge.

<Demo src="footer/measure" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/footer/measure.tsx

</Demo>

## Accessibility

- It renders a real `<footer>`. At the top level of a document that is the `contentinfo` landmark, which is what a screen reader's landmark list and a reader mode read.
- `label` names the bar. Worth writing when a page has two of them — an article's own footer and the site's — because the landmark list otherwise offers "contentinfo" twice.
- A footer **inside** an `<article>` or a `<section>` is not `contentinfo`; the browser only promotes the tag at the top level of the document. That is the tag's own rule, not this component's.
- Columns of links belong in a `<nav>` with a name of their own, put inside the footer. The footer names the region; the `<nav>` names the list.
