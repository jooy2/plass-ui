---
title: PlContainer
order: 2
---

# PlContainer

<p class="plass-lede">Horizontal breathing room, and optionally a measure. It is the outermost element on a page, which is exactly why it draws nothing at all.</p>

<Demo src="container/hero" :min-height="200" :flutter="false" />

::: fw react

```tsx
import { PlContainer } from 'plass-ui';

<PlContainer maxWidth="lg" render={<main />}>
  {page}
</PlContainer>;
```

:::

## Props

<PropsTable name="PlContainer" />

::: fw react

Every native `<div>` attribute passes straight through.

:::

There is no `variant`, no `color` and no `elevation`. The outermost element on a page is the one thing that must not decide what the page looks like, and a container that carried a sheet would put a second pane behind every card on it. Wrap it in a `PlCard` when the sheet is what you want. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### maxWidth

The same ladder the breakpoints use — `xs` 30rem, `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem — written in `rem` rather than taken from a framework's own container scale, so a container's `lg` and an `lg:` utility change at the same width. Two ladders called `lg` on one page is how a layout drifts by a few pixels for no reason anybody can find later.

`none` is the default. A container's job is the gutter; a measure is a second decision, and a page should have to ask for one.

<Demo src="container/widths" :min-height="220" :flutter="false">

::: fw react

<<< @/.vitepress/demos/container/widths.tsx

:::

</Demo>

### padded, size and density

The gutter is the **sheet** padding track, not the control one. What sits inside a container is a page, and the margin a page keeps from the edge of a window is the margin a card keeps around a paragraph — not the room a label needs beside the edge of the key it is printed on.

`size` here is the size of the sheet: it never touches a height or a type scale, and it has nothing to do with `maxWidth`, which is how wide the content gets rather than how far it sits from the edge. `padded={false}` gives the gutter up and keeps everything else, which is what a container nested inside one that already pads wants.

<Demo src="container/padding" :min-height="280" :flutter="false">

::: fw react

<<< @/.vitepress/demos/container/padding.tsx

:::

</Demo>

### centered

On by default, and inert until `maxWidth` is narrower than the page — with no measure there is nothing left over to centre in.

<Demo src="container/centered" :min-height="260" :flutter="false">

::: fw react

<<< @/.vitepress/demos/container/centered.tsx

:::

</Demo>

## Accessibility

- The box adds no role. A container is a margin, and a margin is not something a screen reader should have to announce.

::: fw react

- `render={<main />}` is how it becomes the landmark a page actually needs. That is a decision about the document, so the component never guesses it: a `<main>` rendered twice on one page is worse than none at all.

:::
