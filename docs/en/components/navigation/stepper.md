---
title: PlStepper
order: 7
---

# PlStepper

<p class="plass-lede">A process the reader is moving through, and where they are in it. The steps are buttons, the current one owns a panel, and pressing one moves the reader.</p>

<Demo src="stepper/hero" :min-height="320" />

::: fw react

```tsx
import { PlStep, PlStepper } from 'plass-ui';

<PlStepper active={step} onActiveChange={setStep}>
  <PlStep label="Account">…</PlStep>
  <PlStep label="Verify">…</PlStep>
  <PlStep label="Profile" optional>
    …
  </PlStep>
</PlStepper>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlStepper(
  active: step,
  onActiveChanged: (int next) => setState(() => step = next),
  steps: const <PlStep>[
    PlStep(label: Text('Account'), child: Text('…')),
    PlStep(label: Text('Verify'), child: Text('…')),
    PlStep(label: Text('Profile'), optional: Text('Optional'), child: Text('…')),
  ],
);
```

:::

## Props

<PropsTable name="PlStepper" />

### PlStep

<PropsTable name="PlStep" />

Every native `<div>` attribute passes through to the stepper, and every `<li>` attribute to a step. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

::: fw flutter

The steps are a **list** rather than children, for the reason `PlTimeline`'s are: the stepper has to _reason_ about them — which one is complete is arithmetic on an index, and which one can be reached is arithmetic on the same index — and neither question can be asked of an opaque `Widget`. That also settles the sharp edge the React build has to warn about: there is no way to hand it a wrapper that holds three steps.

`optional` takes a `Widget` rather than a `bool`, because there is no default string to fall back to: the package ships no translations, and a word it invented would be in one language.

:::

## Stepper or timeline

They draw the **same rail** — the same three bullet states, the same connector — and share it in the source, because a haloed bullet must not mean two things. The difference is what each one is _for_:

|  |  |
| --- | --- |
| [`PlTimeline`](../display/timeline) | **Reports.** A sequence that already happened, as text. Nothing on it can be pressed |
| `PlStepper` | **Is** the sequence. The steps are buttons, the current one owns a panel, and the reader is inside it |

If nothing on it should be clickable, it is a timeline.

## Examples

### active

An **index**, not a value, exactly as a timeline's is — a stepper has no selection. Everything before it is complete, the step at it is current, everything after it is ahead.

Uncontrolled with `defaultActive`, or controlled with `active` and `onActiveChange`, which is what a form wizard wants: the Next button is the caller's, and so is the validation that decides whether it moves.

### linear

On by default, and it is what makes this a process rather than a row of tabs: the third step of a sign-up cannot be filled in before the second. A step **behind** the reader is always reachable — going back to correct an answer is the whole reason a stepper is not a wizard with one door.

Turn it off for a review screen, where every step has been answered and the reader is going back to check one.

```tsx
<PlStepper active={3} linear={false}>
  …
</PlStepper>
```

### orientation

Horizontal puts the panel under the whole rail. **Vertical puts each step's panel inside the step**, which is the reason to lay one out vertically at all: the answer sits under the question rather than under the rail.

**It is responsive**, so a set can run one way on a phone and the other on a laptop. <Fw react="It is resolved in JavaScript rather than in CSS — an orientation decides the DOM, the ARIA and the way the arrow keys walk, and no stylesheet can do that, so a server renders the xs entry and the browser corrects it on hydration; a bare value subscribes to nothing at all." flutter="It is resolved against the window's width in build, so it is right on the first frame — and it is the window's width rather than this widget's own box, which is what makes two of these side by side agree about which rung they are on." /> See [breakpoints](../../design/breakpoints).

<Demo src="stepper/vertical" :min-height="340">

::: fw react

<<< @/.vitepress/demos/stepper/vertical.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stepper/vertical.dart

:::

</Demo>

### status and color

`active` decides all three states, and `status` overrides one of them. That is for the step that failed validation while the reader was three steps further on — it is `current` again without the stepper moving, and `color="danger"` says why.

<Demo src="stepper/status" :min-height="160">

::: fw react

<<< @/.vitepress/demos/stepper/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stepper/status.dart

:::

</Demo>

### optional

`true` draws the word "Optional". A node draws that node instead, which is how the word is translated — there is no `optionalLabel` prop, because one prop that takes both is one prop.

```tsx
<PlStep label="Profile" optional="건너뛸 수 있음" />
```

## Notes

::: fw react

> **The steps have to be the stepper's own children.** It numbers them by walking them, so a component of your own that returns three steps is _one_ child holding three, and every step in it would be step one. Build the list with `.map()` or an array — both are flattened — rather than with a wrapper component.

- A conditional step that rendered nothing does not shift the numbering of the ones after it.
- A step outside a stepper still renders. It is one step with nothing before or after it.

:::

::: fw flutter

The steps are a list, so there is no wrapper to get wrong — see the note above the props table.

:::

## Accessibility

- A real `<ol>` of `<li>`s, and the current step carries `aria-current="step"`.
- It is deliberately **not** a `role="tablist"`. A tab list owes a keyboard reader one tab stop and arrow keys, and a screen reader a panel per tab; a stepper is a sequence of separate controls, and claiming the role without the behaviour is worse than never claiming it. Each reachable step is its own tab stop, which is what a stepper's steps are.
- A step that cannot be reached is not a button at all, rather than a disabled one — there is nothing there to press yet.
- The panel is named by the step it belongs to, so a screen reader landing in it is told which step it is the panel for.

::: fw flutter

The current step is marked `selected`, which is the nearest thing the framework has to `aria-current="step"`. A step that cannot be reached is not a button — it is a plain box, rather than a disabled one.

:::
