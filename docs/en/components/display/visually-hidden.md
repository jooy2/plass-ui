---
title: PlVisuallyHidden
order: 16
---

# PlVisuallyHidden

<p class="plass-lede">Content for a screen reader and for nobody else. It stays in the accessibility tree and takes no space on the screen, which is what makes it the right way to name a control that draws only a glyph.</p>

<Demo src="visually-hidden/hero" :min-height="200" />

::: fw react

```tsx
import { PlVisuallyHidden } from 'plass-ui';

<button type="button">
  <span aria-hidden="true">✕</span>
  <PlVisuallyHidden>Close</PlVisuallyHidden>
</button>;
```

:::

::: fw flutter

This one is React-only, and it is not an omission. What it works around is a DOM problem, text that must be in the accessibility tree and off the screen at once, and Flutter's tree is not the render tree. The Dart answer is `Semantics`:

```dart
Semantics(
  label: 'Close',
  child: ExcludeSemantics(child: Text('✕')),
);
```

:::

## Props

<PropsTable name="PlVisuallyHidden" />

::: fw react

Every native `<span>` attribute passes straight through, `aria-live` and `id` included. There is no `variant`, no `size` and no `color`: nothing is drawn, so there is nothing for them to decide.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Naming a control that draws a glyph

The most common use, and the defect it fixes: a button whose whole label is an icon has no accessible name at all. The glyph takes `aria-hidden` so it is not read as a second one.

<Demo src="visually-hidden/naming" :min-height="160">

::: fw react

<<< @/.vitepress/demos/visually-hidden/naming.tsx

:::

</Demo>

### focusable

Brings the content back into the page while anything inside it holds the focus. That is one element in a document, the skip link, and it cannot be done from the outside: the clip is `position: absolute`, so revealing it means putting the element back in the flow.

It answers `:focus-within` rather than `:focus`, because what is tabbed to is almost always a link _inside_ the box rather than the box itself.

<Demo src="visually-hidden/focusable" :min-height="160">

::: fw react

<<< @/.vitepress/demos/visually-hidden/focusable.tsx

:::

</Demo>

> A revealed box is `position: static` and takes its space back. Put it somewhere that can hold it, a positioned ancestor, or the top of the page, which is where a skip link belongs anyway.

### A live region

An announcement with nothing to draw. `aria-live` on a hidden element is how a change that is obvious on screen (a count going up, a filter narrowing a list) reaches a reader who cannot see it happen.

<Demo src="visually-hidden/live" :min-height="180">

::: fw react

<<< @/.vitepress/demos/visually-hidden/live.tsx

:::

</Demo>

### render

Renders something other than a `<span>`. A heading that structures the page for a screen reader without appearing in the design, or the `<div>` a live region wants.

```tsx
<PlVisuallyHidden render={<h2 />}>Search results</PlVisuallyHidden>
```

## Accessibility

- The content is **in** the accessibility tree. `hidden`, `display: none` and `visibility: hidden` all take it off; `opacity: 0` leaves a clickable ghost the size of the words. A one-pixel clipped box is the only form that is absent to a sighted reader and present to every other kind.
- It does not set `aria-hidden` on itself, and putting one on it would defeat the component entirely.
- Text inside it is still selected by a find-in-page and still copied by a select-all. That is the platform's behaviour and not something to work around.
- A hidden name and a visible one on the same control give it **two** names. Mark the glyph beside it `aria-hidden="true"`.
