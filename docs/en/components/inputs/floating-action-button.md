---
title: PlFloatingActionButton
order: 2
---

# PlFloatingActionButton

<p class="plass-lede">The one action a screen is about, floating over it. A <code>PlButton</code> in a corner, plus the pinning, the shape, and one rule: the label always exists, whether or not it is drawn.</p>

<Demo src="floating-action-button/hero" :min-height="260" />

::: fw react

```tsx
import { PlFloatingActionButton } from 'plass-ui';

<PlFloatingActionButton icon={<PlusGlyph />} label="New project" onClick={create} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlFloatingActionButton(
  icon: const PlusGlyph(),
  label: 'New project',
  onPressed: create,
);
```

:::

## Props

<PropsTable name="PlFloatingActionButton" />

Everything a [`PlButton`](./button) takes, it takes: the three materials, the elevation ladder, the pointer light, `loading`, `readOnly` and `disabled`. What the shared axes mean is in [prop conventions](../../design/prop-conventions).

## label is not optional

A floating button is a disc with a mark in it nine times out of ten. `extended` decides whether the **words are also drawn** — never whether they exist.

That is why `label` is required and is always the accessible name. An icon-only button with no name is the single most common accessibility defect this pattern ships with, and making the prop required is the only fix that survives review.

<Demo src="floating-action-button/extended" :min-height="180">

::: fw react

<<< @/.vitepress/demos/floating-action-button/extended.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_action_button/extended.dart

:::

</Demo>

Turn `extended` on for an action a first-time reader would not guess from a glyph, and off again once they would.

## The two shapes

The icon-only form is a **disc**. That is [`PlIconButton`](./icon-button)'s deliberate exception to the radius rule: the flat run along a control's edge is there for a line of text to sit on, and a glyph has no line of text.

The extended form is **not a pill**, for exactly that reason. It has words along its edge, so it takes the house fillet like every other labelled control.

## One per screen

Two floating buttons in one corner is two primary actions, which is none.

And a screen whose main action is already a button in the content does not want a second copy of it in the corner — the floating one is for the action that has nowhere else to live, on a screen that is a list of things you are about to add to.

## Examples

### Somewhere other than the bottom trailing corner

`corner` is one of the four, spelled `start`/`end` rather than left/right so the button crosses the screen under RTL with everything else. `offset` is how far it stands off the two edges it is against.

```tsx
<PlFloatingActionButton corner="bottom-start" offset={16} icon={<PlusGlyph />} label="Add" />
```

### In the flow instead

`floating={false}` keeps the shape and the shadow and drops the positioning, for the same button at the end of a card or in a toolbar.

```tsx
<PlFloatingActionButton floating={false} extended icon={<PlusGlyph />} label="New project" />
```

## Notes

- `elevation` defaults to **3**, the top of the ladder, and unlike every other default in the library it is not a compromise: this is the one control that genuinely floats over the content rather than resting on it.
- `size` defaults to `lg`, one step up from a `PlButton`'s. A floating button is a target for a thumb.

::: fw react

- It is `position: fixed` with **logical** insets, written inline: a caller's `offset` is a value rather than a class, and an inline declaration is the one form that wins over a utility deterministically.
- It sits at `z-30`, the same level a [`PlBackTop`](../navigation/back-top) does — above the page and below anything portalled.

:::

::: fw flutter

- While `floating` it is a `PositionedDirectional`, so it belongs in a `Stack` — which is what a screen's body usually already is once anything floats over it.

:::

## Accessibility

- The name is `label`, always, and it is the same words `extended` would draw. There is no way to make one of these without a name.
- It is a real button and nothing else: it takes the focus in document order, answers <kbd>Enter</kbd> and <kbd>Space</kbd>, and reports `loading` and `disabled` exactly as a `PlButton` does.
- **It covers content.** A button pinned to a corner sits over whatever is under it, so leave room for it at the end of a scrolling list — the last row of a list under a floating button is a row nobody can press.
