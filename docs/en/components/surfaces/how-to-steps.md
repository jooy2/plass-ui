---
title: PlHowToSteps
order: 12
---

# PlHowToSteps

<p class="plass-lede">Instructions, numbered, with what to do under each one. A stepper and a timeline both say where you are; this one says what to do, so every step's body is open at once.</p>

<Demo src="how-to-steps/hero" :min-height="280" />

::: fw react

```tsx
import { PlHowToStep, PlHowToSteps } from 'plass-ui';

<PlHowToSteps>
  <PlHowToStep title="Add the package">npm install plass-ui</PlHowToStep>
  <PlHowToStep title="Import the stylesheet">One line in your CSS entry point.</PlHowToStep>
</PlHowToSteps>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHowToSteps(
  steps: const <PlHowToStep>[
    PlHowToStep(title: Text('Add the package'), child: Text('flutter pub add plass_ui')),
    PlHowToStep(title: Text('Import it'), child: Text('One line at the top of the file.')),
  ],
);
```

:::

## Props

<PropsTable name="PlHowToSteps" />

### PlHowToStep

<PropsTable name="PlHowToStep" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## PlHowToSteps, PlStepper or PlTimeline

Three components put things in order, and the difference is not the drawing.

|  |  |
| --- | --- |
| [`PlStepper`](../navigation/stepper) | **Where you are** in a process you are moving through now. The steps are buttons and one of them owns the panel. |
| [`PlTimeline`](../display/timeline) | **Where you are** in a sequence that has already happened. |
| `PlHowToSteps` | **What to do.** Every step's body is open at once. |

That last row is the shape everything else follows from. Somebody following instructions reads ahead, goes back a step, and works at their own pace, so a guide that showed one step at a time would be hiding the answer to "what am I about to be asked for".

It is also why **`active` is optional here** and required-in-spirit on the other two. A guide that claimed to know how far a reader had got would be guessing; pass it only for the guide that genuinely knows, such as a setup wizard reporting what it has already done for them.

## numbered

On by default, because that is what instructions are: "do this, then this" is an order, and the number is how a reader finds their place again after looking away.

Turn it off for a set of things to do in **any** order (which is a checklist, not a how-to) usually alongside `connector="none"`, since a line between steps is the other half of the same claim.

<Demo src="how-to-steps/plain" :min-height="220">

::: fw react

<<< @/.vitepress/demos/how-to-steps/plain.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/how_to_steps/plain.dart

:::

</Demo>

An `icon` replaces the number in the disc and **keeps the step's place in the order**. The guide numbers its children as it walks them, so what changes is only what is drawn.

## Examples

### A step inserted in the middle

Nothing is renumbered by hand, because nothing was numbered by hand. A step never takes an index; the guide counts its children as it walks them, and a step that was conditional and rendered nothing does not take a number with it.

```tsx
<PlHowToSteps>
  <PlHowToStep title="Install">…</PlHowToStep>
  {needsAuth ? <PlHowToStep title="Sign in">…</PlHowToStep> : null}
  <PlHowToStep title="Deploy">…</PlHowToStep>
</PlHowToSteps>
```

### One step marked done

`status` on a step overrides what the guide worked out, for the guide where "done" is not simply "before where I am".

```tsx
<PlHowToStep title="Install the CLI" status="complete">
  …
</PlHowToStep>
```

## Notes

- The bullet, the halo and the connector are the same three the [stepper](../navigation/stepper) and the [timeline](../display/timeline) draw, from one table. A haloed bullet must not mean two things in one library.
- The connector belongs to the step it **leaves**, so its colour says whether that step has been reached, and the last step has nothing to leave for.
- It draws no surface. A guide sits in a [`PlCard`](./card) or on the page.

## Accessibility

::: fw react

- It is a real `<ol>` of `<li>`s, and the numbers a reader sees are the ones the list carries. A screen reader announces "list, five items, item two" on its own, which is the position information a heading per step would only approximate.
- The current step carries `aria-current="step"`, and only when `active` named one.
- The disc is `aria-hidden`: the number in it is the list's own, and hearing "2" before every step is noise.

:::

::: fw flutter

- **The position is written into each step's semantics**, which is the one place this parts company with the React build: there a real `<ol>` gives it for nothing, and Flutter has no ordered list to inherit it from. `semanticStepLabel` is what says the words, and it is a callback rather than a pair of strings because there is no `Intl` in the framework.

:::
