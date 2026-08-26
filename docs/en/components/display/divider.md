---
title: PlDivider
order: 4
---

# PlDivider

<p class="plass-lede">A rule between two things. With no children it is a hairline and a real <code>role="separator"</code>; with children the line breaks around a label set into it.</p>

<Demo src="divider/hero" :min-height="160" />

::: fw react

```tsx
import { PlDivider } from 'plass-ui';

<PlDivider />;
<PlDivider>OR</PlDivider>;
<PlDivider orientation="vertical" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlDivider();
const PlDivider(child: Text('OR'));
const PlDivider(orientation: PlassOrientation.vertical);
```

:::

## Props

<PropsTable name="PlDivider" />

::: fw react

Every native `<div>` attribute passes straight through. `color` and `children` are excluded from the pass-through because both are Plass props here.

:::

::: fw flutter

`color` is a `PlassColor?` and defaults to `null`, which is how "no family, the neutral hairline" is spelled in a language with no `undefined`.

:::

There is no `variant` and no `elevation`. A divider is not a surface: it is not made of glass, it catches no light and it casts no shadow.

What the shared axes (`orientation` `color` `size` `textAlign`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### orientation

A vertical divider has no height of its own — it takes the height of whatever gives it one, which is what a rule between two toolbar groups should do. Give it a `length` when it has to be shorter than the row it is in.

::: fw flutter

"Whatever gives it one" is doing more work here than in CSS. A `Row` hands its children the height it was given, so a vertical divider inside one needs an `IntrinsicHeight` above it — or a `length` — before it has anything to stretch to. The demo below uses the first.

:::

<Demo src="divider/orientation" :min-height="200">

::: fw react

<<< @/.vitepress/demos/divider/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/orientation.dart

:::

</Demo>

### children and textAlign

`center` splits the line in half. `start` and `end` leave a short stub on the near side, so the label still reads as set _into_ the rule rather than floating above it.

<Demo src="divider/label" :min-height="200">

::: fw react

<<< @/.vitepress/demos/divider/label.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/label.dart

:::

</Demo>

### color

There is no default, which is the same choice `PlTextLink` makes. Left out, the rule is the neutral hairline — the one that is visible on every ground the library has: a page wash, a glass sheet, a card. The sheet's own white hairline is white light on a translucent pane and disappears the moment a divider is set on something opaque.

Passing a family tints the rule instead.

<Demo src="divider/colors" :min-height="240">

::: fw react

<<< @/.vitepress/demos/divider/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/colors.dart

:::

</Demo>

### length and thickness

`length` rather than `width`, because a divider is the one component whose long axis turns with `orientation`.

::: fw react

A number is pixels; a string is any CSS length, so `'50%'` and `'12rem'` both work.

:::

::: fw flutter

Both are `double`s — logical pixels, which is what every other length in the package is. There is no percentage: a fraction of the parent is a `FractionallySizedBox` around the divider, and inventing a second spelling for it inside the component would be a second spelling.

`length` wins over a tight parent, which is not what a bare `SizedBox` would do. A divider very often sits in a `Column` with `crossAxisAlignment: stretch`, and there it would be handed a tight width and lose — so the box is wrapped in an `Align`, which passes loose constraints down.

:::

<Demo src="divider/length" :min-height="200">

::: fw react

<<< @/.vitepress/demos/divider/length.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/length.dart

:::

</Demo>

### size

`size` is the label's type scale and nothing else — a divider with no label has no size to set.

<Demo src="divider/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/divider/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- It renders Base UI's `Separator`, so it is a real `role="separator"` carrying the matching `aria-orientation`.
- `separator` is not a name-from-content role, so a visible label does not become the accessible name on its own. A **string** label is copied into `aria-label`; a richer one is left alone, because only the caller knows which part of it is the name.
- A divider that is purely decorative — a rule inside a card that is already separated by space — is better given `role="presentation"`, which passes straight through.
- The two stubs either side of a label are `aria-hidden`; the label is announced once, as the separator's name.

:::

::: fw flutter

- A divider says nothing unless it is given a `semanticLabel`, which is the honest default: a rule between two things is usually the layout speaking, not the content.
- Naming one makes it a semantics node with that name. Pass it when the rule is carrying meaning — an "OR" between two sign-in routes is, a rule inside a card is not.
- The label set into the line is still drawn as text, so it is read where it sits; `semanticLabel` is for the divider itself.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `role="separator"` with `aria-orientation` | a named semantics node, or nothing | Flutter's semantics tree has no separator role. An unnamed rule is decoration and says so by staying out of the tree. |
| `children` | `child` | Flutter's name. |
| a string label becomes `aria-label` | `semanticLabel` | Nothing here can tell which part of a `Widget` is the name, so the name is asked for rather than guessed. |
| `length`/`thickness` as a CSS length | `double` | Logical pixels, as everywhere else in the package. A fraction of the parent is a `FractionallySizedBox`. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
