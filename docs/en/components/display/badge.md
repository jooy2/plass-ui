---
title: PlBadge
order: 7
---

# PlBadge

<p class="plass-lede">A small mark in the corner of something else — unread mail on an inbox icon, a status dot on an avatar, a count on a tab. With no children it lays out inline instead, which is what a standalone status pill is.</p>

<Demo src="badge/hero" :min-height="160" />

::: fw react

```tsx
import { PlBadge, PlButton } from 'plass-ui';

<PlBadge content={4} label="4 unread notifications">
  <PlButton aria-label="Notifications">
    <BellIcon />
  </PlButton>
</PlBadge>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBadge(
  count: 4,
  label: '4 unread notifications',
  child: PlButton(semanticLabel: 'Notifications', startIcon: const BellGlyph(), onPressed: open),
);
```

:::

## Props

<PropsTable name="PlBadge" />

::: fw react

Every native `<span>` attribute passes straight through, onto the **marker** rather than onto the shell around the anchor. `color` and `content` are excluded from the pass-through because both are Plass props here.

:::

::: fw flutter

`content` and `count` are two parameters rather than one. `max` and `showZero` only mean anything for a number, and React's single prop has to ask at runtime what it was handed; here the type is the question, and passing both is an error the constructor asserts on.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### content, max and showZero

<Fw react="content" flutter="count" code /> is usually a count and sometimes a word. A number past `max` is capped with a `+`; a word is left alone, because a badge cannot know how to truncate one.

A count of `0` draws nothing at all unless `showZero` is on. Zero unread messages is not news, and a badge that never goes away stops meaning anything.

::: fw flutter

An `invisible` badge keeps its box — a `Visibility` with `maintainSize` on — so nothing around it moves when it comes back. Visibility rather than opacity: a half-faded badge is a badge you have to squint at to find out whether it is there.

:::

<Demo src="badge/counts" :min-height="140">

::: fw react

<<< @/.vitepress/demos/badge/counts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/counts.dart

:::

</Demo>

### dot

Omit the content and the badge is a dot — the honest shape when there is something to report but nothing to count. `dot` forces it even when there _is_ content, and the content is still announced: a quiet corner is not a silent one.

<Demo src="badge/dot" :min-height="140">

::: fw react

<<< @/.vitepress/demos/badge/dot.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/dot.dart

:::

</Demo>

### variant

A badge is the thing being coloured, so its sheet takes the tint — as an alert's does, and unlike a card's. It is also the one component in the library allowed to be a pill: a Plass corner is a moulded fillet on a _surface_, and a badge is a mark laid on one.

<Demo src="badge/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/badge/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/variants.dart

:::

</Demo>

### placement and overlap

`placement` is logical throughout, so the corner flips with the writing direction rather than staying stuck on the right.

::: fw flutter

Pinned with a directional `Stack` rather than a `transform`, which is the same choice the React build makes with a negative margin: the house rule against moving a control with a transform is absolute, and a corner is two alignments and a pair of insets either way.

:::

`overlap` is the shape of the thing underneath. A circle's corner is about 15% of its diameter inside the box the badge is positioned against, so a badge tuned for an icon button floats off an avatar with a gap under it.

<Demo src="badge/placement" :min-height="160">

::: fw react

<<< @/.vitepress/demos/badge/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/placement.dart

:::

</Demo>

<Demo src="badge/overlap" :min-height="140">

::: fw react

<<< @/.vitepress/demos/badge/overlap.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/overlap.dart

:::

</Demo>

### color

<Demo src="badge/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/badge/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/colors.dart

:::

</Demo>

### size

Its own ladder, well below the control one. A control's height is what a _row_ lines up on; a badge lines up on nothing — it hangs off the corner of something else.

<Demo src="badge/sizes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/badge/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/badge/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- `content={3}` beside a bell reads out as "3", which means nothing. Give it `label="3 unread notifications"` and the sentence is what is announced instead of the number.
- A dot draws nothing but still reads whichever of `label` and `content` it was given.
- An `invisible` badge and an empty one are hidden from the accessibility tree entirely, and hold no text at all — text left behind in a clipped box is text a find-on-page still turns up.
- The badge adds no role and no tab stop. What is interactive is the anchor inside it, and the anchor is the caller's own element.
- The shell around the anchor is `inline-flex` and exactly as wide as what it wraps, so a badged icon button still lines up with a bare one beside it.

:::

::: fw flutter

- `count: 3` beside a bell reads out as "3", which means nothing. Give it `label: '3 unread notifications'` and the sentence is what is announced instead of the number.
- A dot draws nothing but still reads whichever of `label` and the count it was given.
- An `invisible` badge and an empty one are excluded from the semantics tree entirely.
- The badge adds no role and no focus stop. What is interactive is the anchor inside it, and the anchor is the caller's own widget.
- The shell around the anchor is measured by the anchor alone, so a badged icon button still lines up with a bare one beside it.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| one `content` prop | `content` and `count` | `max` and `showZero` only mean anything for a number. Two parameters make the type the question rather than a runtime `typeof`. |
| a negative margin | a directional `Stack` | The same decision for the same reason — neither one moves the marker with a transform. |
| `visibility: hidden` | `Visibility(maintainSize: true)` | The same thing said in Flutter's words: the box stays, so nothing moves when the badge comes back. |
| `children` | `child` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
