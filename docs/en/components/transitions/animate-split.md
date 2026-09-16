---
title: PlAnimateSplit
order: 17
---

# PlAnimateSplit

<p class="plass-lede">A line of text arriving one part at a time. The other effects tell themselves off across their children; a line of text has none, so this one makes them.</p>

<Demo src="animate-split/hero" :min-height="200" />

::: fw react

```tsx
import { PlAnimateSplit } from 'plass-ui';

<PlAnimateSplit effect="slide" stagger={60}>
  One design language, two libraries
</PlAnimateSplit>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateSplit(text: 'One design language, two libraries');
```

:::

## Props

<PropsTable name="PlAnimateSplit" />

## by="character" is not safe in every script

The one thing to know before using it.

A character part breaks the shaping between letters. **Arabic stops joining**, so a line that was one word becomes a row of unrelated glyphs.

The cut is by grapheme, the unit a reader counts as one character, so a Devanagari conjunct, a flag and an emoji built out of several code points each stay in one part.

`word` has none of those problems, is the default, and is what a headline wants anyway: a word arriving is something a reader can follow, and a letter arriving is decoration.

## Gaps and parts

Whitespace is left as whitespace and never given an entrance of its own, animating the space between two words is nothing arriving, and it does not take a step of the stagger with it either. The second word starts one step after the first, not two.

Cut by character, the characters of a word are kept together, so the line wraps between words rather than partway through one. A word wider than the whole line wraps inside itself instead of running out of its box, and a script written without spaces between its words, such as Chinese, Japanese or Thai, still wraps between its characters.

A part wraps inside itself as well, which is what a line with no spaces in it needs. A Chinese or Japanese sentence has no gap to cut at, so cut by word the whole line is one part; that part starts on a new line when it does not fit, and wraps between its characters rather than running out of its box.

::: fw react

Each part is `inline-block`, because a transform does not apply to a non-replaced inline element: without it a slide would fade and never move. A line may wrap before and after every inline-block, so the characters of one word sit together in one more inline-block. That box is as wide as the word, or as the line when the word is wider, so the word moves to the next line whole and wraps inside only when it has to.

:::

## Writing the entrance

::: fw react

`effect` picks one of the seven entrances, and each part starts where the component of that name starts when it is given nothing: a `slide` part rises from its own height below its place, a `zoom` part grows from 0.4 of its size and a `grow` part from 0.8. `stagger`, `durationStep` and `reverse` mean exactly what they mean on a [`PlAnimateFade`](./animate-fade) around a list of `<li>`s. This component is the **splitting** and nothing more.

:::

::: fw flutter

The entrance is a side, a distance and a fade, exactly as `PlAnimateAppear` spells it, which is the widget that already tells one entrance off across a set of children.

The React build names a CSS keyframe instead, and that difference is not an inconsistency: over there an effect **is** a named thing the stylesheet knows about, and here every effect is built out of widgets. A split takes the parameters the widget beside it takes.

:::

## Accessibility

- **A screen reader is told the line, once.** The parts are hidden from the accessibility tree and the whole line sits beside them, which is what stops a split headline being read out one word, or one letter, at a time. That is the defect this pattern is known for everywhere it appears without it.
- Text selection and copying still give you the line, gaps included, and give it once: the clipped copy a screen reader reads is left out of the selection.
- Where a reader has asked for less motion nothing plays, and the line is simply there.
