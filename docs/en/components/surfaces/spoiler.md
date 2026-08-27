---
title: PlSpoiler
order: 9
---

# PlSpoiler

<p class="plass-lede">Content that is covered until somebody asks for it. A plot twist, an answer, a photograph nobody has agreed to look at yet.</p>

<Demo src="spoiler/hero" :min-height="180" />

::: fw react

```tsx
import { PlSpoiler } from 'plass-ui';

<PlSpoiler reversible>
  <p>Rosebud was the name painted on the sled he had as a child.</p>
</PlSpoiler>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSpoiler(
  reversible: true,
  child: const Text('Rosebud was the name painted on the sled he had as a child.'),
);
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

A short spoiler is as tall as its own cover, not as tall as its content: the two share one cell, so a one-line spoiler does not clip the button it is asking somebody to press.

## Examples

### variant

The three materials, read as a _container's_: the sheet is never dyed. What a spoiler holds is a photograph, a paragraph, a plot twist, and it arrives with its own colours — the family shows up on the button and in the hairline and stops there.

`ghost` draws no box at all, which is what a spoiler sitting inside running prose usually wants.

<Demo src="spoiler/variants" :min-height="360">

::: fw react

<<< @/.vitepress/demos/spoiler/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/variants.dart

:::

</Demo>

### maxHeight

Left out, the box is exactly as tall as what it holds — the right default for a paragraph or a picture. Set it for something long enough that a page of blurred content would be a page of nothing.

The clamp is **only ever on the covered state**. Revealing something and leaving it in a box with a scrollbar is answering the wrong question.

<Demo src="spoiler/clamped" :min-height="260">

::: fw react

<<< @/.vitepress/demos/spoiler/clamped.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/clamped.dart

:::

</Demo>

### reversible

Off by default: once it is uncovered, it stays uncovered. Turn it on and a hide button appears under the content, which is what a page full of them wants — a reader who revealed the wrong one can put it back.

### padded and media

Turn the padding off for something that should reach the edges. A covered image is the case this component is most often reached for, and the blur is doing real work there: the shape and the colours are visible, the subject is not.

<Demo src="spoiler/media" :min-height="240">

::: fw react

<<< @/.vitepress/demos/spoiler/media.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/media.dart

:::

</Demo>

## Accessibility

- While it is covered the content is out of the focus order and off the accessibility tree. A spoiler somebody can tab into is not a spoiler.
- `description` is read before the button, which is what tells somebody _why_ they are being asked. Turning it off leaves a cover that says nothing — worth doing only where the surrounding page already has.

::: fw react

- All of that is one attribute: **`inert`**, which also takes the content out of the _selection_. A spoiler that could be defeated by <kbd>Ctrl</kbd>+<kbd>A</kbd> is not a spoiler.
- The reveal button reports the state it controls and points at the content it uncovers, so a screen reader announces it as the disclosure it is.

:::

::: fw flutter

- `ExcludeSemantics`, `ExcludeFocus` and `IgnorePointer` are the three widgets that say what that one attribute says. Text selection needs no third: Flutter's is opt-in, so a covered paragraph is only selectable if the screen wrapped it in a `SelectionArea` — and one that did should not have.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `revealed` / `defaultRevealed` / `onRevealedChange` | `revealed` / `onRevealedChanged` | The one widget in the package that is happy **uncontrolled**, because what is remembered is a thing the reader did to this box rather than a value the screen owns. Leave `revealed` out and it keeps its own. |
| `label`, `hideLabel` as nodes | `label`, `hideLabel` as `String` | They are the button's words _and_ its accessible name, and only a string can be both. |
| `description: ReactNode \| false` | `description: Widget?` | Dart already has a word for "not set". |
| `maxHeight: number \| string` | `maxHeight: double` | Pixels stay pixels. There is no CSS length to accept. |
| `inert` | `ExcludeSemantics` + `ExcludeFocus` + `IgnorePointer` | The same three things, said as the three widgets that do them. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
