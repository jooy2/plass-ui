---
title: PlHighlight
order: 11
---

# PlHighlight

<p class="plass-lede">Marks the words a reader is looking for, inside text they were already reading. The component is the search, not just the styling — <code>query</code> is what a search box holds.</p>

<Demo src="highlight/hero" :min-height="240" />

```tsx
import { PlHighlight } from 'plass-ui';

<PlHighlight query={search}>{result.summary}</PlHighlight>;
```

## Props

<PropsTable name="PlHighlight" />

Every native `<span>` attribute passes straight through, onto the wrapper. `color` is excluded from the pass-through because it is a Plass prop here.

There is no `size`, and it is the one prop a reader will look for. A mark sits inside running text and has to be the size of the text it is inside; a `size` prop would only offer ways to be wrong.

What the shared axes (`variant` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### query

A string is one term. An array is several, and the longest is tried first — alternation in a regular expression is first-match-wins, so without that `['data', 'database']` would mark `data` and leave `base` outside the mark.

A `RegExp` is used as written, with the global flag forced on. `caseSensitive` and `wholeWord` are ignored for it, because a regular expression already says both of those things itself.

<Demo src="highlight/matching" :min-height="220">

<<< @/.vitepress/demos/highlight/matching.tsx

</Demo>

### Nested content

`children` is a tree, not a string. Elements are walked into and left otherwise untouched, so a match inside a `<strong>` is still marked and the `<strong>` survives. Requiring a string is what most libraries do, and it fails on the first search result that has markup in it.

<Demo src="highlight/nested" :min-height="140">

<<< @/.vitepress/demos/highlight/nested.tsx

</Demo>

### variant

`glass` is deliberately not blurred here, which is the one place in the library the material is quoted rather than used. A mark is a 20px-tall inline box sitting on a line of text: there is no backdrop behind it worth smearing, and a mark that wraps across a line break would smear two.

<Demo src="highlight/variants" :min-height="180">

<<< @/.vitepress/demos/highlight/variants.tsx

</Demo>

### color

`warning` is the default, and not arbitrarily. It is the one family whose gradient is light with dark ink on it, so a `solid` `warning` mark is a yellow highlighter over black text rather than a white word on a block of colour.

<Demo src="highlight/colors" :min-height="200">

<<< @/.vitepress/demos/highlight/colors.tsx

</Demo>

## Accessibility

- The mark is a real `<mark>`, which is the element for text of relevance to the reader, and is announced as such.
- That has one consequence worth knowing: marking eleven words in a paragraph tells a screen reader that eleven things are important, which is a way of saying nothing. A highlight is for a handful of matches.
- The full text is always present and in order — marking splits a string, it never rewrites or drops any of it.
- The mark adds a hair of padding and takes the same hair back as a negative margin, so a marked line is exactly as long as it was. A mark must not move the text around it.
