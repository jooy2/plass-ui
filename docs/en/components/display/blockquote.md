---
title: PlBlockquote
order: 8
---

# PlBlockquote

<p class="plass-lede">Somebody else's words, set apart from your own. An accent rule down the leading edge, the quote at a heading's scale, and — when there is one — an attribution in the markup the HTML spec asks for.</p>

<Demo src="blockquote/hero" :min-height="260" />

::: fw react

```tsx
import { PlBlockquote } from 'plass-ui';

<PlBlockquote author="Ada Lovelace" source="Notes on the Analytical Engine">
  Simplicity is hard.
</PlBlockquote>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlBlockquote(
  author: Text('Ada Lovelace'),
  source: Text('Notes on the Analytical Engine'),
  child: Text('Simplicity is hard.'),
);
```

:::

## Props

<PropsTable name="PlBlockquote" />

::: fw react

Every native `<figure>` attribute passes straight through, onto the **wrapper** rather than onto the `<blockquote>` inside it. `color` is excluded from the pass-through because it is a Plass prop here.

:::

::: fw flutter

There is no `cite`: it is a machine-readable URL on an element Flutter does not have, read by nobody and by nothing. Use `source` for the part a reader should see.

`icon` is a `Widget?` and `showIcon` is the switch beside it. React says both with one three-way prop, which Dart has no value for — there is `null` and there is a widget, and nothing that means "take it away".

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### author and source

`author` is a person and `source` is a work. That is not a naming preference — `<cite>` is the element for the title of a work and, per the spec, never for the name of a person, so the two cannot share a slot.

An attribution is _about_ the quote and is not part of what was said, which is why passing one turns the wrapper into a `<figure>` with a `<figcaption>` outside the `<blockquote>`. Without one the wrapper is a plain `<div>`: a `<figure>` with no `<figcaption>` in it is a figure of nothing.

::: fw react

`cite` is the URL, and it lands on the `<blockquote>`'s own attribute — machine-readable and shown to nobody.

:::

<Demo src="blockquote/attribution" :min-height="320">

::: fw react

<<< @/.vitepress/demos/blockquote/attribution.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/attribution.dart

:::

</Demo>

### variant

The sheet is never dyed, exactly as on a `PlCard`. A quote holds somebody else's words, and words on a tinted pane are words on a background nobody chose them against — so the family reaches the rule and stops.

`ghost` is the default and the one that belongs in running prose: a rule in the margin and nothing else, which is what a quote has looked like since long before there were surfaces to put one on.

<Demo src="blockquote/variants" :min-height="320">

::: fw react

<<< @/.vitepress/demos/blockquote/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/variants.dart

:::

</Demo>

### color

<Demo src="blockquote/colors" :min-height="280">

::: fw react

<<< @/.vitepress/demos/blockquote/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/colors.dart

:::

</Demo>

### size

<Demo src="blockquote/sizes" :min-height="420">

::: fw react

<<< @/.vitepress/demos/blockquote/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- The quote is a real `<blockquote>` and the attribution a real `<figcaption>` outside it. A name inside the quote claims the speaker said their own name.
- The quotation mark is decorative and `aria-hidden`. So is the em dash before the author — a screen reader announcing "em dash" before a name is reading the typography rather than the text.
- Nothing is drawn on the `<blockquote>` element itself. `blockquote` is one of the handful of tags a host stylesheet still styles by name, and moving the surface and the rule onto the wrapper is what lets a host reset undo its own version without also undoing this one.

:::

::: fw flutter

- The quote and its attribution are one semantics node, read in order, with the attribution after the words rather than inside them. A name inside the quote claims the speaker said their own name.
- The quotation mark is drawn rather than typed and is excluded from semantics. So is the em dash before the author — a screen reader announcing "em dash" before a name is reading the typography rather than the text.
- The rule is painted beside the text rather than as a border on it, which is what keeps the corners on that edge square: a 2px rule that curves away from the text it marks is a bracket, not a margin rule.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<figure>` / `<figcaption>` / `<blockquote>` | one semantics node | Flutter has no document markup to get right, so what the React build spends care on — which element the attribution lives in — has no counterpart. What survives is the reading order. |
| `cite` | — | A URL on an element that does not exist, read by nobody. `source` is the part a reader sees. |
| `icon={false}` | `showIcon: false` | Dart has no value that is neither `null` nor a widget, so "take it away" gets its own name. |
| `children` | `child` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

The quotation mark is the same drawing in both, unit for unit out of the same 16-unit box — a real `“` would be set in whatever face the page uses and would change shape, weight and baseline with it, and at 2em it is the largest single glyph in the component.

:::
