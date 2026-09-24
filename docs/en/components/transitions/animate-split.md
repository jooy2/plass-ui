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

Whitespace is left as whitespace. A gap between two words is never given an entrance of its own and does not take a step of the stagger, so the second word starts one step after the first.

The line wraps as the same text would. Cut by character, the characters of a word stay together, so the line wraps between words; a word wider than the whole line wraps inside itself, and a script written without spaces between its words, such as Chinese, Japanese or Thai, still wraps between its characters. Cut by word, a line with no spaces in it is one part, which starts on a new line when it does not fit and wraps between its characters.

## Examples

### by

`word`, the default, is what a headline wants: a word arriving is something a reader can follow. `character` cuts by grapheme, the unit a reader counts as one character, so a Devanagari conjunct, a flag and an emoji built out of several code points each stay in one part.

**`character` is not safe in every script.** A character part breaks the shaping between letters, so **Arabic stops joining**, and a line that was one word becomes a row of unrelated glyphs.

<Demo src="animate-split/by" :min-height="200">

::: fw react

<<< @/.vitepress/demos/animate-split/by.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_split/by.dart

:::

</Demo>

### <Fw react="effect" flutter="from · distance · fade" />

::: fw react

`effect` picks one of the seven entrances, and each part starts where the component of that name starts when it is given nothing: a `slide` part rises from its own height below its place, a `zoom` part grows from 0.4 of its size and a `grow` part from 0.8.

:::

::: fw flutter

The entrance is a side, a distance and a fade, as [`PlAnimateAppear`](./animate-appear) spells it. The React build names an entrance instead, because there an effect is a keyframe the stylesheet knows by name, and here every effect is built out of widgets.

:::

<Demo src="animate-split/effect" :min-height="320">

::: fw react

<<< @/.vitepress/demos/animate-split/effect.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_split/effect.dart

:::

</Demo>

### stagger

How long after one part the next one starts. This component is the **splitting** and nothing more:

::: fw react

`stagger`, `durationStep` and `reverse` mean exactly what they mean on a [`PlAnimateFade`](./animate-fade) around a list of `<li>`s.

:::

::: fw flutter

`stagger` and `reverse` mean exactly what they mean on a [`PlAnimateAppear`](./animate-appear).

:::

<Demo src="animate-split/stagger" :min-height="240">

::: fw react

<<< @/.vitepress/demos/animate-split/stagger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_split/stagger.dart

:::

</Demo>

## Accessibility

- **A screen reader is told the line, once.** The parts are hidden from the accessibility tree and the whole line sits beside them, which is what stops a split headline being read out one word, or one letter, at a time. That is the defect this pattern is known for everywhere it appears without it.
- Text selection and copying still give you the line, gaps included, and give it once: the clipped copy a screen reader reads is left out of the selection.
- Where a reader has asked for less motion nothing plays, and the line is simply there.
