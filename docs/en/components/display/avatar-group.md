---
title: PlAvatarGroup
order: 15
---

# PlAvatarGroup

<p class="plass-lede">A stack of avatars, overlapping, with the ones that did not fit as a count. It sets the axes once for the whole stack, and any one avatar can still be marked out from the rest.</p>

<Demo src="avatar-group/hero" :min-height="120" />

::: fw react

```tsx
import { PlAvatar, PlAvatarGroup } from 'plass-ui';

<PlAvatarGroup max={4} total={11}>
  <PlAvatar name="Ada Lovelace" src="/ada.jpg" />
  <PlAvatar name="Grace Hopper" />
</PlAvatarGroup>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAvatarGroup(
  max: 4,
  total: 11,
  avatars: <PlAvatar>[
    PlAvatar(name: 'Ada Lovelace', image: NetworkImage('/ada.jpg')),
    PlAvatar(name: 'Grace Hopper'),
  ],
);
```

:::

## Props

<PropsTable name="PlAvatarGroup" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it is a Plass prop here.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## The axes belong to the stack

`size`, `shape`, `variant`, `color` and `elevation` are set here rather than on every avatar. A stack whose fourth face is a size out is not a stack.

An avatar's own prop still wins, which is what lets one of them be marked out from the rest — the person on call, the account that owns the thing, the one you are about to remove.

<Demo src="avatar-group/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar-group/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar_group/variants.dart

:::

</Demo>

::: fw react

It reaches an avatar wherever it ended up, not only a direct child, so wrapping one in a [`PlTooltip`](../feedback/tooltip) or producing the row from a `.map()` changes nothing.

:::

::: fw flutter

An avatar reads the axes off the stack through an inherited widget, so it holds however deep the face ends up.

:::

## Examples

### max and total

`max` is how many faces are drawn; everything past it becomes a `+n`.

`total` is for the common case where the group was handed only the first few — five avatars out of a hundred and twenty-eight. Without it the count is worked out from what was passed, which is right only when all of them were.

<Demo src="avatar-group/max" :min-height="200">

::: fw react

<<< @/.vitepress/demos/avatar-group/max.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar_group/max.dart

:::

</Demo>

### overlap

How far each avatar sits under the one before it. Left out it is a fraction of `size` — roughly a third of the box at every step, which is enough that the stack reads as a stack and not so much that a face is hidden behind the next one.

`0` puts them in a row that touches, which is what a set of logos usually wants.

::: fw flutter

A `double` of logical pixels rather than a CSS length, and the step is measured from the group's own `size` — so an avatar that overrides its `size` inside a stack still overlaps by the stack's step.

:::

<Demo src="avatar-group/overlap" :min-height="200">

::: fw react

<<< @/.vitepress/demos/avatar-group/overlap.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar_group/overlap.dart

:::

</Demo>

### size

<Demo src="avatar-group/sizes" :min-height="280">

::: fw react

<<< @/.vitepress/demos/avatar-group/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar_group/sizes.dart

:::

</Demo>

### The ring is a hole, not an edge

Two circles of similar tone laid over each other have no boundary between them at all, and the stack reads as one smeared shape. A translucent hairline would not help, because what is behind it is the other avatar.

So each face carries a ring in `--plass-surface` — the page's own sheet colour, and the one opaque outline in the library. It reads as space rather than as a line drawn around anything, which is why the stack is the one place a Plass surface is allowed a hard edge.

Each face overlaps the one before it, so the last avatar in the list is the one in front — and the `+n`, which comes last, sits over all of them.

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| composed children | `avatars: List<PlAvatar>` | The stack has to know how wide a face is to lay the next one over it, and a typed list is what it can measure. |
| a negative `margin-inline-start` | a `Stack` of faces each pushed one step along | `EdgeInsets` asserts it is non-negative and there is no negative margin to be had. The stack takes the size of its widest child, so the row still measures exactly as wide as it draws. |
| `overlap` as a number **or** a CSS length | `double?` | There is no stylesheet to resolve `1.5rem` against. |
| a 2px `ring` outside the box | a plate 2px larger behind the face | A Flutter `Border` is drawn inside the box it is on. A filled box two pixels bigger is the same picture, and it is the same idea either way: the hole the near face is cut out of. |
| an avatar's own `size` still overlaps correctly | the step comes from the group's `size` | The step is arithmetic here rather than layout, so a face that is a size out is still stepped by the stack's own measure. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::

## Accessibility

- The group has no role of its own. A stack of faces is a picture of a set, and what it is a set _of_ is the sentence beside it — name it when the stack is the only thing saying so, with an `aria-label` in React and `semanticLabel` in Flutter.
- Each avatar names itself exactly as it does on its own: the picture takes the `name`, and a fallback showing initials is read as the name rather than as two letters.
- The `+n` is drawn as an avatar with no name, so it is read as the characters it shows. When the number needs to be a sentence — "and 38 more" — put that on the group instead.
