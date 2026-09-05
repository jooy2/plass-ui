---
title: PlHighlight
order: 11
---

# PlHighlight

<p class="plass-lede">Marks the words a reader is looking for, inside text they were already reading. The component is the search, not just the styling. <code>query</code> is what a search box holds.</p>

<Demo src="highlight/hero" :min-height="240" />

::: fw react

```tsx
import { PlHighlight } from 'plass-ui';

<PlHighlight query={search}>{result.summary}</PlHighlight>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHighlight(result.summary, query: search);
```

:::

## Props

<PropsTable name="PlHighlight" />

::: fw react

Every native `<span>` attribute passes straight through, onto the wrapper. `color` is excluded from the pass-through because it is a Plass prop here.

:::

::: fw flutter

The text is the first positional argument and it is a `String`, not a widget. See [nested content](#nested-content) below for what that costs and why.

`query` is typed `Object`, which is Dart's way of writing a union it does not have: a `String`, a `RegExp`, or a `List` of either. The constructor asserts it.

:::

There is no `size`, and it is the one prop a reader will look for. A mark sits inside running text and has to be the size of the text it is inside; a `size` prop would only offer ways to be wrong.

What the shared axes (`variant` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### query

A string is one term. An array is several, and the longest is tried first. Alternation in a regular expression is first-match-wins, so without that `['data', 'database']` would mark `data` and leave `base` outside the mark.

A `RegExp` is used as written. `caseSensitive` and `wholeWord` are ignored for it, because a regular expression already says both of those things itself.

<Demo src="highlight/matching" :min-height="220">

::: fw react

<<< @/.vitepress/demos/highlight/matching.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/matching.dart

:::

</Demo>

### Nested content

::: fw react

`children` is a tree, not a string. Elements are walked into and left otherwise untouched, so a match inside a `<strong>` is still marked and the `<strong>` survives. Requiring a string is what most libraries do, and it fails on the first search result that has markup in it.

<Demo src="highlight/nested" :min-height="140">

<<< @/.vitepress/demos/highlight/nested.tsx

</Demo>

:::

::: fw flutter

The Flutter build takes a `String`, and that is a real difference rather than an omission. React's `children` is a tree of elements with `props.children` to walk into; Flutter's `Widget` is opaque. There is no way to reach the text inside a `Text` you were handed, let alone rebuild the widget around it with that text marked.

So the text arrives as characters and the marking produces the spans. Text that already changes style part of the way through is the case this cannot serve; a search result, which is what the component is for, arrives as a string.

:::

### variant

`glass` is deliberately not blurred here, which is the one place in the library the material is quoted rather than used. A mark is a 20px-tall inline box sitting on a line of text: there is no backdrop behind it worth smearing.

<Demo src="highlight/variants" :min-height="180">

::: fw react

<<< @/.vitepress/demos/highlight/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/variants.dart

:::

</Demo>

### color

`warning` is the default, and not arbitrarily. It is the one family whose gradient is light with dark ink on it, so a `solid` `warning` mark is a yellow highlighter over black text rather than a white word on a block of colour.

<Demo src="highlight/colors" :min-height="200">

::: fw react

<<< @/.vitepress/demos/highlight/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/colors.dart

:::

</Demo>

## Accessibility

::: fw react

- The mark is a real `<mark>`, which is the element for text of relevance to the reader, and is announced as such.
- That has one consequence worth knowing: marking eleven words in a paragraph tells a screen reader that eleven things are important, which is a way of saying nothing. A highlight is for a handful of matches.
- The full text is always present and in order. Marking splits a string, it never rewrites or drops any of it.
- The mark adds a hair of padding and takes the same hair back as a negative margin, so a marked line is exactly as long as it was. A mark must not move the text around it.

:::

::: fw flutter

- The whole string is what reaches a screen reader, said once and in order. The marks are widgets laid into the paragraph, so without that the reader would get a run of placeholders with the unmarked text between them.
- Marking is still for a handful of matches. Nothing announces a mark here, so the reason is the sighted one: eleven marked words in a paragraph is a way of marking nothing.
- The full text is always present and in order. Marking splits a string, it never rewrites or drops any of it.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `children` as a tree | the text, as a `String` | A `Widget` is opaque: there is no way to reach the text inside one you were handed. See [nested content](#nested-content). |
| a real `<mark>`, announced | a widget span, with the whole string as the label | Flutter has no mark role. What it has instead is a paragraph that must still read as one sentence. |
| the mark cancels its own padding | it does not | A negative margin is not something Flutter's `Padding` will take. A mark is 4px wider than the word it marks; on a line of running text that is the difference that matters. |
| `box-decoration-clone` across a line break | a mark does not break | The mark is one widget in the line, so a long marked phrase moves to the next line whole rather than wrapping inside its own surface. |
| `caseSensitive`, `wholeWord` | the same, and the same two rules | `wholeWord` counts letters, digits and underscores in any script here too, so it means what it should for `café` and very little for Korean. |

:::
