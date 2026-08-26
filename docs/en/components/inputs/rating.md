---
title: PlRating
order: 9
---

# PlRating

<p class="plass-lede">A score out of five, as a row of stars. Underneath an interactive one is a real radio group — one tab stop, arrow keys, and a value in a form submission.</p>

<Demo src="rating/hero" :min-height="140" />

::: fw react

```tsx
import { PlRating } from 'plass-ui';

<PlRating value={score} onValueChange={setScore} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlRating(
  value: score,
  onChanged: (double next) => setState(() => score = next),
);
```

:::

## Props

<PropsTable name="PlRating" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above, and `onChange` because the row spells it `onValueChange`.

:::

::: fw flutter

The rating is **controlled**: it is handed a `value` and reports the one that should replace it. There is no `defaultValue` anywhere in this package, because that is how Flutter's own controls work.

:::

There is no `variant` and no `elevation`: a star is a mark on the page, not a surface. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### precision

The smallest step that can be **chosen**, as a fraction of one star. `0.5` gives half stars, `1` whole ones.

It bounds what a reader can pick and nothing else. A `value` of `4.3` is drawn as four stars and a third at every precision, because an average is not a choice — rounding it to the nearest half would be reporting a different number from the one the component was handed.

<Demo src="rating/precision" :min-height="200">

::: fw react

<<< @/.vitepress/demos/rating/precision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/precision.dart

:::

</Demo>

### readOnly

A product's average, or a rating somebody else left.

It is a different component in the same clothes: no inputs, no radio group, and one <Fw react="role=&quot;img&quot;" flutter="image semantics node" /> carrying the score as a sentence. A star display that kept twenty focusable radios would be twenty tab stops on a page that was only reporting a number.

This is also the one `readOnly` in the library that does **not** drain the saturation. It is not a control being held still — there are no controls left — and a row of grey stars would say the score itself was unavailable.

<Demo src="rating/average" :min-height="200">

::: fw react

<<< @/.vitepress/demos/rating/average.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/average.dart

:::

</Demo>

### The fraction

The filled star is laid **over** the empty one and clipped to a percentage of the width. Nothing is transformed and no glyph is scaled, so a half star is the left half of exactly the star beside it — which is the house no-transform rule holding on a component whose whole job is a partial shape.

The clip runs from the inline start, so it fills from the right under RTL without anything being told to.

### icon and emptyIcon

Both, or neither. The two drawings are laid one over the other and the top one is cropped, so a filled heart over an outlined star would show as a rim that does not line up with what is inside it.

<Demo src="rating/icons" :min-height="120">

::: fw react

<<< @/.vitepress/demos/rating/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/icons.dart

:::

</Demo>

### size

The standalone-glyph ladder — the same one `PlIcon` uses — because a star is content rather than a control. It is measured against the text it sits beside, not against the row it sits in.

<Demo src="rating/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/rating/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/sizes.dart

:::

</Demo>

### color

`warning` by default — the amber a star is expected to be — rather than the `primary` everything else takes. It is the one place in the library where a component's default colour is chosen by what the object *is* instead of by what it means.

<Demo src="rating/colors" :min-height="200">

::: fw react

<<< @/.vitepress/demos/rating/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/colors.dart

:::

</Demo>

### clearable and disabled

Choosing the score that is already chosen clears it back to `0`, which is the only way to take a rating back once one has been left. Turn it off where a score is required.

`disabled` is the house treatment: the light goes out of the row, the page shows through it, and the family stays. A grey row would be a second vocabulary for the same state.

<Demo src="rating/states" :min-height="200">

::: fw react

<<< @/.vitepress/demos/rating/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/states.dart

:::

</Demo>

## Accessibility

- An interactive rating is a **radio group**, because a score is exactly one of these. One tab stop for the row, arrow keys within it, the chosen score marked, and a value in a form submission — none of which a row of buttons would have.
- Every choice is named by the score it stands for (`3 out of 5`). `valueLabel` is where another language sets its own; nothing here is ever drawn.
- A read-only rating drops the radios entirely and becomes one image with the score as its name.
- The glyphs are decorative. What is announced is the sentence, not the drawing.

::: fw react

- The inputs are real `<input type="radio">`s in a visually hidden box, one under each fraction of a star. `name` submits with the form; `required` blocks the submit until a star is chosen.
- Clearing rides on `click` rather than on `change`: clicking a radio that is already checked fires a click and no change at all, and that click is exactly the gesture being listened for.

:::

::: fw flutter

- Every choosable fraction is its own semantics node, marked as one of a mutually exclusive set and carrying the score it stands for. A screen reader can activate one directly.
- The row is one focus stop and the arrow keys move the score by one `precision` step, which is what a radio group gives the React build for free. <kbd>Home</kbd> clears it and <kbd>End</kbd> takes it to the top. The arrows follow the writing direction, so they run the other way under RTL.
- The shortcuts are declared on the row rather than inherited, so the widget behaves the same in a bare `WidgetsApp` or with no app widget above it at all.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| a radio group of hidden `<input>`s | semantics nodes and one focus stop | There is no form to submit into and no native radio to inherit a keyboard from, so the arrows are bound on the row. |
| `name`, `required` | — | Both are about an HTML form submission, which Flutter has no equivalent of. |
| a focus ring per star | one ring round the row | The row is one focus node here, so the ring is round what actually holds focus. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
