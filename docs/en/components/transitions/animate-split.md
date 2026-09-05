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

The one thing to know before reaching for it.

A character part breaks the shaping between letters. **Arabic stops joining**, Devanagari conjuncts come apart, and an emoji built out of several code points is cut into its pieces — so a line that was one word becomes a row of unrelated glyphs.

`word` has none of those problems, is the default, and is what a headline wants anyway: a word arriving is something a reader can follow, and a letter arriving is decoration.

## Gaps and parts

Whitespace is left as whitespace and never given an entrance of its own — animating the space between two words is nothing arriving — and it does not take a step of the stagger with it either. The second word starts one step after the first, not two.

::: fw react

Each part is `inline-block`, because a transform does not apply to a non-replaced inline element: without it a slide would fade and never move.

:::

## Writing the entrance

::: fw react

`effect` picks one of the seven keyframes, and `stagger`, `durationStep` and `reverse` mean exactly what they mean on a [`PlAnimateFade`](./animate-fade) around a list of `<li>`s. This component is the **splitting** and nothing more.

:::

::: fw flutter

The entrance is a side, a distance and a fade — exactly as `PlAnimateAppear` spells it, which is the widget that already tells one entrance off across a set of children.

The React build names a CSS keyframe instead, and that difference is not an inconsistency: over there an effect **is** a named thing the stylesheet knows about, and here every effect is built out of widgets. A split takes the parameters the widget beside it takes.

:::

## Accessibility

- **A screen reader is told the line, once.** The parts are hidden from the accessibility tree and the whole line sits beside them, which is what stops a split headline being read out one word — or one letter — at a time. That is the defect this pattern is known for everywhere it appears without it.
- Text selection and copying still give you the line, gaps included.
- Where a reader has asked for less motion nothing plays, and the line is simply there.
