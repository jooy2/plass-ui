---
title: PlTextLink
order: 2
---

# PlTextLink

<p class="plass-lede">A link, in a sentence or on its own. No surface, no height and no colour unless you ask — what it has is the one mark a reader already knows means "this goes somewhere".</p>

<Demo src="text-link/hero" :min-height="120" />

```tsx
import { PlTextLink } from 'plass-ui';

<PlTextLink href="/pricing">the colour reference</PlTextLink>;
<PlTextLink href="https://www.w3.org/TR/WCAG22/" newTab>
  WCAG 2.2
</PlTextLink>;
```

## Props

<PropsTable name="PlTextLink" />

Every native `<a>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above. `rel` is the one thing a caller's value is **merged** with rather than replaced by — see below.

What the shared axes (`size` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### underline

`always` is the default, and the reason is `color`: a link takes no colour family unless one is asked for, so with the line off there would be nothing at all distinguishing it from the sentence around it.

Hover deliberately leaves the **text** colour alone and only darkens the line. A link inside running prose that changes colour under the pointer drags the reader's eye off the line they were reading.

<Demo src="text-link/underline" :min-height="160">

<<< @/.vitepress/demos/text-link/underline.tsx

</Demo>

### color

Unlike every control in the library this has **no default**. A component that arrived pre-dyed is one a page has to undo, and a link in a paragraph is usually the paragraph's own colour with a line under it.

<Demo src="text-link/colors" :min-height="100">

<<< @/.vitepress/demos/text-link/colors.tsx

</Demo>

### newTab

A window changing under the reader is the one thing about a link that cannot be seen before it happens. So `newTab` does three things at once: `target="_blank"`, a `rel` that stops the new page reaching back through `window.opener`, and a mark — visible as an arrow, and read out as a line a screen reader hears after the label.

`rel` is merged, never replaced. The common reason to write one by hand is `nofollow` or `sponsored`, which is an SEO decision; as a plain override it would silently take the protection off a link that still opens a new tab.

### icon

`true` draws the arrow leaving its box when `newTab` is on and the chain otherwise; `false` draws nothing; a node of your own replaces the glyph. Left out, it follows `newTab` — a link that takes over the window should say so, and a caller should have to ask for the silent version.

The glyph rides at `0.95em` rather than the `1.2em` an icon inside a control takes: this one sits in a sentence, and an icon as tall as the line spaces the words around it apart.

<Demo src="text-link/icons" :min-height="160">

<<< @/.vitepress/demos/text-link/icons.tsx

</Demo>

### size

Also has no default: a link inside a sentence is the size of the sentence. Set it for a link that stands on its own.

<Demo src="text-link/sizes" :min-height="200">

<<< @/.vitepress/demos/text-link/sizes.tsx

</Demo>

### render

Takes the router's own `Link` while keeping the line, the mark and the focus ring. `href` still goes through, so it is written once.

```tsx
import NextLink from 'next/link';

<PlTextLink href="/pricing" render={<NextLink href="/pricing" />}>
  Pricing
</PlTextLink>;
```

## Accessibility

- Renders a real `<a href>`, so it is in the browser's link list, follows on <kbd>Enter</kbd>, and can be opened in a new tab or copied by the reader.
- `newTab` is announced, not only drawn. The arrow says "new tab" to a reader who can see it; the visually hidden line says it to everyone else.
- The underline is the primary signal, and colour is never the only one. `underline="none"` is for a link whose surroundings already say what it is.
- The focus ring appears on `:focus-visible` and takes a small radius, so it traces the label rather than a rectangle around the whole line box.
- The component's class is doubled in the stylesheet (`.plass-link.plass-link`) so a host page's `.prose a` or `.vp-doc a` cannot take its colour and its line away.
