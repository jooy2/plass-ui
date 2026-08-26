---
title: PlTextLink
order: 2
---

# PlTextLink

<p class="plass-lede">A link, in a sentence or on its own. No surface, no height and no colour unless you ask — what it has is the one mark a reader already knows means "this goes somewhere".</p>

<Demo src="text-link/hero" :min-height="120" />

::: fw react

```tsx
import { PlTextLink } from 'plass-ui';

<PlTextLink href="/pricing">the colour reference</PlTextLink>;
<PlTextLink href="https://www.w3.org/TR/WCAG22/" newTab>
  WCAG 2.2
</PlTextLink>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTextLink(onPressed: () => go('/pricing'), child: const Text('the colour reference'));
PlTextLink(onPressed: openWcag, external: true, child: const Text('WCAG 2.2'));
```

:::

## Props

<PropsTable name="PlTextLink" />

::: fw react

Every native `<a>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above. `rel` is the one thing a caller's value is **merged** with rather than replaced by — see below.

:::

::: fw flutter

There is no `href`, and it is the one real difference: Flutter has no navigation of its own, so where a link _goes_ is the app's to decide and `onPressed` is where it is decided. Leaving it out makes the link inert, which is what a link to the page you are already on should be.

:::

What the shared axes (`size` `color`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### underline

`always` is the default, and the reason is `color`: a link takes no colour family unless one is asked for, so with the line off there would be nothing at all distinguishing it from the sentence around it.

Hover deliberately leaves the **text** colour alone and only darkens the line. A link inside running prose that changes colour under the pointer drags the reader's eye off the line they were reading.

The line rests at 45% of whatever the text is and goes to the full colour under the pointer, so it works the same on an inherited colour as on an accent one.

<Demo src="text-link/underline" :min-height="160">

::: fw react

<<< @/.vitepress/demos/text-link/underline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/underline.dart

:::

</Demo>

### color

Unlike every control in the library this has **no default**. A component that arrived pre-dyed is one a page has to undo, and a link in a paragraph is usually the paragraph's own colour with a line under it.

<Demo src="text-link/colors" :min-height="100">

::: fw react

<<< @/.vitepress/demos/text-link/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/colors.dart

:::

</Demo>

### <Fw react="newTab" flutter="external" />

Something changing out from under the reader is the one thing about a link that cannot be seen before it happens.

::: fw react

So `newTab` does three things at once: `target="_blank"`, a `rel` that stops the new page reaching back through `window.opener`, and a mark — visible as an arrow, and read out as a line a screen reader hears after the label.

`rel` is merged, never replaced. The common reason to write one by hand is `nofollow` or `sponsored`, which is an SEO decision; as a plain override it would silently take the protection off a link that still opens a new tab.

:::

::: fw flutter

So `external` does two: it draws the arrow leaving its box, and it gives the link a hint a screen reader reads after the label. There is no `target` and no `rel` — nothing here opens a browsing context, so there is no opener to protect against; what "leaves the app" means is the app's own business, and `onPressed` is where it happens.

:::

### icon

::: fw react

`true` draws the arrow leaving its box when `newTab` is on and the chain otherwise; `false` draws nothing; a node of your own replaces the glyph. Left out, it follows `newTab` — a link that takes over the window should say so, and a caller should have to ask for the silent version.

:::

::: fw flutter

`showIcon` decides whether a mark is drawn and `icon` decides what it is. Left out, `showIcon` follows `external` — a link that takes the reader out of the app should say so, and a caller should have to ask for the silent version. That is the whole reason it is a `bool?` rather than a `bool`.

:::

The glyph rides at `0.95em` rather than the `1.2em` an icon inside a control takes: this one sits in a sentence, and an icon as tall as the line spaces the words around it apart.

<Demo src="text-link/icons" :min-height="160">

::: fw react

<<< @/.vitepress/demos/text-link/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/icons.dart

:::

</Demo>

### size

Also has no default: a link inside a sentence is the size of the sentence. Set it for a link that stands on its own.

<Demo src="text-link/sizes" :min-height="200">

::: fw react

<<< @/.vitepress/demos/text-link/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/sizes.dart

:::

</Demo>

::: fw react

### render

Takes the router's own `Link` while keeping the line, the mark and the focus ring. `href` still goes through, so it is written once.

```tsx
import NextLink from 'next/link';

<PlTextLink href="/pricing" render={<NextLink href="/pricing" />}>
  Pricing
</PlTextLink>;
```

:::

## Accessibility

::: fw react

- Renders a real `<a href>`, so it is in the browser's link list, follows on <kbd>Enter</kbd>, and can be opened in a new tab or copied by the reader.
- `newTab` is announced, not only drawn. The arrow says "new tab" to a reader who can see it; the visually hidden line says it to everyone else.
- The underline is the primary signal, and colour is never the only one. `underline="none"` is for a link whose surroundings already say what it is.
- The focus ring appears on `:focus-visible` and takes a small radius, so it traces the label rather than a rectangle around the whole line box.
- The component's class is doubled in the stylesheet (`.plass-link.plass-link`) so a host page's `.prose a` or `.vp-doc a` cannot take its colour and its line away.

:::

::: fw flutter

- Announced as a link rather than as a button, which is what puts it in a screen reader's list of links.
- <kbd>Enter</kbd> and the numpad <kbd>Enter</kbd> follow it. <kbd>Space</kbd> deliberately does not: a link is not a button, and the space bar belongs to whatever is scrolling.
- `external` is announced, not only drawn. The arrow says "leaves the app" to a reader who can see it; the hint says it to everyone else.
- The underline is the primary signal, and colour is never the only one. `PlTextLinkUnderline.none` is for a link whose surroundings already say what it is.
- The focus ring only appears on what CSS calls `:focus-visible` — a keyboard reaching the link, never a pointer clicking it — and takes a small radius, so it traces the label.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `href` | `onPressed` | Flutter has no navigation of its own. Where a link goes is the app's, and this is where it is decided. |
| `newTab`, `target`, `rel` | `external` | Nothing here opens a browsing context, so there is no opener to protect against. What survives is the part that matters to a reader: the mark and the announcement. |
| `icon` as node-or-boolean | `icon` and `showIcon` | Dart has no value that is neither `null` nor a widget, so "draw one" and "which one" are two questions. |
| `render` | — | Flutter has no polymorphic element. A router's own navigation is called from `onPressed`. |
| `.plass-link.plass-link` | — | There is no host stylesheet to outrank. |
| `children` | `child` | Flutter's name. |

:::
