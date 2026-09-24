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

::: fw react

Everything a [`PlButton`](./button) takes, it takes: the three materials, the elevation ladder, the pointer light, `loading`, `readOnly` and `disabled`.

:::

::: fw flutter

It takes the parts of a [`PlButton`](./button) a floating button uses: the three materials, the elevation ladder, the pointer light, `color`, `loading`, `readOnly` and `disabled`, and `onLongPress`, `focusNode` and `autofocus`.

:::

`density` changes the padding only while `extended`. The disc has no horizontal padding to change.

- `label` is required and is always the accessible name. `extended` decides whether the words are also drawn, never whether they exist.
- The icon-only form is a **disc**. The extended form takes the house fillet rather than becoming a pill.
- `elevation` defaults to **3**, the top of the ladder, and `size` to `lg`, one step up from a `PlButton`'s, because a floating button is a target for a thumb.
- Put one on a screen, for the action that has nowhere else to live. A screen whose main action is already a button in the content does not want a second copy of it in the corner.

::: fw react

- It is `position: fixed` with **logical** insets written inline, so `offset` wins over any utility class.
- It sits at `z-30`, the same level a [`PlBackTop`](../navigation/back-top) does, above the page and below anything portalled.

:::

::: fw flutter

- While `floating` it is a `PositionedDirectional`, so it belongs in a `Stack`, which is what a screen's body usually already is once anything floats over it.

:::

[Design language](../../design/design-language#the-radius-is-a-fillet) has the reasons for the shape and the elevation, and [prop conventions](../../design/prop-conventions) has what the shared axes mean.

## Examples

### extended

Draws the label beside the glyph. Turn it on for an action a first-time reader would not guess from a glyph, and off again once they would.

<Demo src="floating-action-button/extended" :min-height="180">

::: fw react

<<< @/.vitepress/demos/floating-action-button/extended.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_action_button/extended.dart

:::

</Demo>

### corner · offset

`corner` is one of the four, spelled `start`/`end` rather than left/right so the button crosses the screen under RTL with everything else. `offset` is how far it stands off the two edges it is against.

::: fw react

```tsx
<PlFloatingActionButton corner="bottom-start" offset={16} icon={<PlusGlyph />} label="Add" />
```

:::

::: fw flutter

```dart
PlFloatingActionButton(
  corner: PlassCorner.bottomStart,
  offset: 16,
  icon: const PlusGlyph(),
  label: 'Add',
  onPressed: add,
);
```

:::

The safe area on those two edges is added on top of `offset`, so on an edge-to-edge screen the button clears the home indicator, the navigation bar and a camera cutout.

::: fw react

That space is `env(safe-area-inset-*)`, and a browser gives a page those insets only when its viewport meta tag has `viewport-fit=cover`. Without it, nothing is added.

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
```

:::

::: fw flutter

That space is `MediaQuery.paddingOf`, which a `SafeArea` above the button has already set to zero, so a screen that clears its edges itself does not get the space twice.

:::

### floating

<Fw react="floating={false}" flutter="floating: false" code /> keeps the shape and the shadow and drops the positioning, for the same button at the end of a card or in a toolbar.

::: fw react

```tsx
<PlFloatingActionButton floating={false} extended icon={<PlusGlyph />} label="New project" />
```

:::

::: fw flutter

```dart
PlFloatingActionButton(
  floating: false,
  extended: true,
  icon: const PlusGlyph(),
  label: 'New project',
  onPressed: create,
);
```

:::

## Accessibility

- The name is `label`, always, and it is the same words `extended` would draw. There is no way to make one of these without a name.
- It is a real button and nothing else: it takes the focus in document order, answers <kbd>Enter</kbd> and <kbd>Space</kbd>, and reports `loading` and `disabled` exactly as a `PlButton` does.
- **It covers content.** A button pinned to a corner sits over whatever is under it, so leave room for it at the end of a scrolling list. The last row of a list under a floating button is a row nobody can press.
