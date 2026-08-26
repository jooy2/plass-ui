---
title: PlAlert
order: 1
---

# PlAlert

<p class="plass-lede">A message about something that happened, set into the page it is about. Three shapes — a bare line, a line with a glyph, or a headline with the detail under it — are one component with different slots filled.</p>

<Demo src="alert/hero" :min-height="200" />

::: fw react

```tsx
import { PlAlert } from 'plass-ui';

<PlAlert color="success">Your changes are live.</PlAlert>;
<PlAlert color="danger" title="The deploy failed">
  Two of the health checks never came back.
</PlAlert>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAlert(color: PlassColor.success, child: Text('Your changes are live.'));
const PlAlert(
  color: PlassColor.danger,
  title: Text('The deploy failed'),
  child: Text('Two of the health checks never came back.'),
);
```

:::

## Props

<PropsTable name="PlAlert" />

::: fw react

Every native `<div>` attribute passes straight through, `role` included — see the note on live regions below. `color` and `title` are excluded from the pass-through because both are Plass props here.

:::

::: fw flutter

`icon` is a `Widget?` and `showIcon` is the switch beside it. React says both with one three-way prop, which Dart has no value for — there is `null` and there is a widget, and nothing that means "take it away".

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

An alert **is** the thing being coloured — a notice about a severity, not a container holding someone else's content — so unlike a `PlCard` its sheet takes the tint.

`solid` is the family's gradient with that family's shadow under it and no gloss line, exactly as a filled `PlButton` has none. `glass` wears the family in its hairline, its glyph and its title. `ghost` is the tint alone, for an alert set among form fields where a second bordered rectangle is one rectangle too many.

<Demo src="alert/variants" :min-height="260">

::: fw react

<<< @/.vitepress/demos/alert/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/variants.dart

:::

</Demo>

### color

The default is `info`, not `primary`. This is the one place `primary` would be a lie: an alert is not the primary anything, it is a note, and the palette already has the word for that.

Each family draws its own shape as well as its own colour. An alert that says "this went wrong" only in red says it only to some readers.

<Demo src="alert/colors" :min-height="240">

::: fw react

<<< @/.vitepress/demos/alert/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/colors.dart

:::

</Demo>

### The three shapes

<Fw react="icon={false}" flutter="showIcon: false" code /> for a bare line, the default for a line with a glyph, and `title` plus the body for a headline with the detail under it. Nothing about the surface changes between them — only how much of it is used.

<Demo src="alert/shapes" :min-height="200">

::: fw react

<<< @/.vitepress/demos/alert/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/shapes.dart

:::

</Demo>

### action and onClose

`action` stays on the first line while the message wraps beside it, which is why it is a slot of its own rather than something appended to the body.

Passing `onClose` is what makes the dismiss button appear. The component does not hide itself — what happens on dismiss is the caller's, because an alert that vanished on its own would have to be told when to come back.

<Demo src="alert/dismiss" :min-height="160">

::: fw react

<<< @/.vitepress/demos/alert/dismiss.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/dismiss.dart

:::

</Demo>

### size

<Demo src="alert/sizes" :min-height="280">

::: fw react

<<< @/.vitepress/demos/alert/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- The alert is a live region, and which one depends on the severity: `warning` and `danger` get `role="alert"` and interrupt whatever a screen reader is saying; the rest get `role="status"` and wait for a pause. "This failed" is worth interrupting for and "saved" is not.
- A `role` you pass wins — the props spread after the default.
- The glyph is decorative and `aria-hidden`; the severity is carried by the role, the shape and the colour together, never by the colour alone.
- The glyph is centred on the message's **first** line with `1lh`, so a three-line alert still has its glyph at the top.
- `action` and the dismiss button are real buttons with their own tab stops. Give the action an accessible name; the dismiss button has one already.

:::

::: fw flutter

- The severity decides whether the alert interrupts. `warning` and `danger` are live regions and are announced as they appear; the rest are read when the reader reaches them. "This failed" is worth interrupting for and "saved" is not.
- Flutter has one live region rather than two politeness levels, so what the React build says with `role="alert"` against `role="status"` becomes whether the alert is a live region at all.
- The glyph is excluded from semantics; the severity is carried by the shape and the colour together, never by the colour alone.
- The glyph is centred on the message's **first** line — a box the height of one line box, whatever the type scale turns out to be — so a three-line alert still has its glyph at the top.
- `action` and the dismiss button are real focus stops. Give the action a name; the dismiss button has one already.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `role="alert"` / `role="status"` | a live region, or not one | Flutter has one live-region flag and no politeness levels. The severity still decides; what it decides between is narrower. |
| a `role` you pass wins | — | There is no role to override. A caller who needs different semantics wraps the alert in their own `Semantics`. |
| `icon={false}` | `showIcon: false` | Dart has no value that is neither `null` nor a widget, so "take it away" gets its own name. |
| `children` | `child` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
