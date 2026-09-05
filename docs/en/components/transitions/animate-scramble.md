---
title: PlAnimateScramble
order: 16
---

# PlAnimateScramble

<p class="plass-lede">A line of text resolving out of noise, and the noise is made of the line's own characters, which is what makes it work in a script that has no Latin letters in it.</p>

<Demo src="animate-scramble/hero" :min-height="200" />

::: fw react

```tsx
import { PlAnimateScramble } from 'plass-ui';

<PlAnimateScramble>Ship it on Friday</PlAnimateScramble>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateScramble(text: 'Ship it on Friday');
```

:::

## Props

<PropsTable name="PlAnimateScramble" />

## The noise characters

Every scrambler that ships with a default alphabet ships an **English** one. Over a Korean, Greek or Arabic headline that is not a word resolving. It is a different script flickering where a word is about to be, and a reader watching their own language arrive out of somebody else's is watching a bug.

Shuffling the line's own glyphs is right in every script and costs nothing. It also keeps the line's **colour and width steady**, because every frame is drawn out of exactly the characters the finished line is made of.

`characters` overrides it for the caller who genuinely wants a terminal look:

```tsx
<PlAnimateScramble characters="01">Ship it on Friday</PlAnimateScramble>
```

## The settle order

Not at random. A word arriving is something a reader can follow, and a reader who looks away and back has not lost their place; a line of glyphs settling in random order is a slot machine.

**Whitespace is never scrambled.** The gaps between words are what keeps a line of noise looking like a sentence, and a space that flickered into a letter would change the word count on every frame.

## Text only

Not a node, for the same reason a [`PlAnimateCounter`](./animate-counter) takes a number: there is no character to scramble inside a `<strong>`. Style the component, not the text inside it.

Like the counter it also **waits to be seen** rather than starting on mount: a line that resolved off screen delivered text that was simply already there.

## Notes

- The redraw is stepped at `tick`, 45ms by default, rather than taken every frame. At sixty a second a line of changing glyphs strobes, which is unpleasant to look at and is exactly the flicker a reader with a sensitivity to it must never be handed.
- Changing the line runs it again, from noise.

## Accessibility

- **A screen reader is told the line, once**, and never the noise. The settling text is hidden from the accessibility tree and the real line sits beside it in a clipped span.
- Where a reader has asked for less motion there is no scramble at all: the line is simply there.
- Until it starts, what is drawn is noise rather than the line (the same rule every effect here follows about its own first frame), so nothing is quietly readable before it was meant to be.
