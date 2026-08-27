---
title: PlSpoiler
order: 9
---

# PlSpoiler

<p class="plass-lede">Content that is covered until somebody asks for it. A plot twist, an answer, a photograph nobody has agreed to look at yet.</p>

<Demo src="spoiler/hero" :flutter="false" :min-height="180" />

::: fw react

```tsx
import { PlSpoiler } from 'plass-ui';

<PlSpoiler reversible>
  <p>Rosebud was the name painted on the sled he had as a child.</p>
</PlSpoiler>;
```

:::

## Props

<PropsTable name="PlSpoiler" />

::: fw react

Every other `<div>` attribute passes through to the sheet.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Why a blur and not a hidden box

The cover is a **blur**, and that is the whole design. A reader can see that there is something there, roughly how much of it there is, and — with `maxHeight` — that it has been clamped. What they cannot do is read it by accident, which is the one thing a spoiler is for.

Blur alone is not cover, though. It takes a paragraph apart but leaves its colour and its rhythm, and a photograph blurred at 10px is still recognisably a photograph of a face — so a **wash of the page's own surface** goes over the top. That settles two things at once: the content goes to a wash of its own colours, and the button gets something to stand on rather than floating over whatever happened to be underneath it.

## Examples

### variant

The three materials, read as a _container's_: the sheet is never dyed. What a spoiler holds is a photograph, a paragraph, a plot twist, and it arrives with its own colours — the family shows up on the button and in the hairline and stops there.

`ghost` draws no box at all, which is what a spoiler sitting inside running prose usually wants.

<Demo src="spoiler/variants" :flutter="false" :min-height="360">

<<< @/.vitepress/demos/spoiler/variants.tsx

</Demo>

### maxHeight

Left out, the box is exactly as tall as what it holds — the right default for a paragraph or a picture. Set it for something long enough that a page of blurred content would be a page of nothing.

The clamp is **only ever on the covered state**. Revealing something and leaving it in a box with a scrollbar is answering the wrong question.

<Demo src="spoiler/clamped" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/spoiler/clamped.tsx

</Demo>

### reversible

Off by default: once it is uncovered, it stays uncovered. Turn it on and a hide button appears under the content, which is what a page full of them wants — a reader who revealed the wrong one can put it back.

### padded and media

Turn the padding off for something that should reach the edges. A covered image is the case this component is most often reached for, and the blur is doing real work there: the shape and the colours are visible, the subject is not.

<Demo src="spoiler/media" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/spoiler/media.tsx

</Demo>

## Accessibility

- While it is covered the content is **`inert`**: not tabbable, not readable by a screen reader, and not selectable by a drag across the page. A spoiler that could be defeated by <kbd>Ctrl</kbd>+<kbd>A</kbd> is not a spoiler, and one whose link is still tabbable is worse than that.
- The reveal button reports the state it controls and points at the content it uncovers, so a screen reader announces it as the disclosure it is.
- `description` is read before the button, which is what tells somebody _why_ they are being asked. Turning it off with `description={false}` leaves a cover that says nothing — worth doing only where the surrounding page already has.
