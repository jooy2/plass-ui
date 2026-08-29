---
title: PlAnimateTyping
order: 10
---

# PlAnimateTyping

<p class="plass-lede">Text appearing one character at a time. The whole string is in the document from the first frame, so the effect costs a reader who cannot see it nothing and reflows nothing for a reader who can.</p>

<Demo src="animate-typing/hero" :min-height="160" />

::: fw react

```tsx
import { PlAnimateTyping } from 'plass-ui';

<PlAnimateTyping text="npm install plass-ui" speed={14} hold={1600} erase repeat="infinite" />;
```

:::

## Props

<PropsTable name="PlAnimateTyping" />

::: fw react

Every native `<div>` attribute passes straight through, except `children`, which is the text. There is no `render`, no `easing` and no `alternate`: the component owns its two spans, and a typewriter advances a character at a time rather than along a curve.

:::

**Only text is typed.** Pass a string, or strings; an element among the children contributes its text and nothing about its markup, because there is no honest way to reveal half of a link.

`duration` is honoured as the time for the **whole string**, and it overrides `speed`. `speed` is the natural unit here — a long paragraph and a short one should be typed at the same pace, not in the same time — so it is the default.

## Examples

### speed

Characters per second. Around 24 reads as somebody typing; below 10 is a machine printing, and above 60 is closer to the line simply appearing.

<Demo src="animate-typing/speed" :min-height="240">

::: fw react

<<< @/.vitepress/demos/animate-typing/speed.tsx

:::

</Demo>

### erase

`repeat`, `hold` and `erase` are what make it a loop: type, hold, delete, type again. Without `erase` a repeat clears in one frame, which is right for a line being **replaced** rather than rewritten.

<Demo src="animate-typing/erase" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-typing/erase.tsx

:::

</Demo>

## Accessibility

::: fw react

- The whole string sits in a clipped box that a screen reader reads **once**, and the visible copy that animates is `aria-hidden`. Nobody is made to sit through the performance.
- Under `prefers-reduced-motion` the text is simply there. Not "nothing happens" — that is the only outcome that still delivers what the component was carrying.
- The advance is by **grapheme**, not by code point. `👩‍👩‍👧` is one character to a reader and seven code points to JavaScript, and a typewriter that advanced by code points would spend four frames assembling it out of parts that mean nothing on their own.
- The box is not laid out from the characters that have arrived, so the text around it does not reflow on every frame. It will, however, be as wide as its container allows — give a one-line effect a `white-space: nowrap` or a width if the wrap matters.

:::
