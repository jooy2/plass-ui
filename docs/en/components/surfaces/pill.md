---
title: PlPill
order: 8
---

# PlPill

<p class="plass-lede">A floating lozenge holding a small amount of live information. A recording that is running, an upload that is climbing, two updates waiting to be read.</p>

<Demo src="pill/hero" :min-height="140" />

::: fw react

```tsx
import { PlPill } from 'plass-ui';

<PlPill color="danger" title="Recording" description="00:41" startIcon={<Dot />} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPill(
  color: PlassColor.danger,
  title: const Text('Recording'),
  description: const Text('00:41'),
  startIcon: const RecordingDot(),
);
```

:::

## Props

<PropsTable name="PlPill" />

::: fw react

Every other `<div>` attribute passes through to the shell.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## The stadium shape

The shape is a **stadium**, a corner at exactly half the row's height, and the house radius rule otherwise forbids it. Every control is held just short of the 50% that would make it a pill, because the flat run along its top and bottom edge is what still reads as a sheet with the corners cut off it.

This is the exception the rule is drawn against, and it works for the same reason the rule does: **this is not a sheet lying on the page.** It is an object hovering over one, and an object hovering over the page should not look as though it was cut from the same material. The floating bar makes the same argument for its own capsule.

The radius is pinned to the **row**, not written as `rounded-full`, and the difference only shows once the pill grows: a corner half the height of a box that has taken a second line eats the first two words of every line. Pinning it to the row is what lets the lozenge grow into a rounded rectangle with the same corner it always had.

`elevation` defaults to `2` for the same reason. A lozenge lying flat on the content it is floating over reads as a mistake.

## Examples

### variant

The three materials, said the way a **control** says them: the surface takes the tint, as on a [`PlButton`](../inputs/button) and a [`PlChip`](../display/chip), because a pill is the thing being coloured rather than a sheet holding somebody else's content.

<Demo src="pill/variants" :min-height="280">

::: fw react

<<< @/.vitepress/demos/pill/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pill/variants.dart

:::

</Demo>

### The three slots

`startIcon` is a square box clipped to a circle, so an image lands in it as readily as a glyph does. It fills the box and is cropped rather than letterboxed, which is what a 20px portrait wants.

`title` and `description` are the **middle**, centred in a column of their own and padded well clear of both neighbours at roughly double the control track. The glyph and the trailing slot are the pill's furniture; what it is _about_ is the column between them.

`endIcon` sits **outside** the pressable area, so it can be a control of its own, a stop button, a dismiss. A button holding another button is markup a browser rewrites on parse.

### details

The second half, revealed when `expanded`. The pill grows downward into it rather than swapping to a different shape: one object saying more.

The height is **the body's own**, not a number written down somewhere, so a details area whose content changes (which is what live information does) grows with it. And nothing is transformed: the pill is a window that opens, exactly as a [`PlCollapsible`](./collapsible)'s panel is.

::: fw react

A `ResizeObserver` is what keeps the measured height honest as the content changes.

:::

<Demo src="pill/details" :min-height="220">

::: fw react

<<< @/.vitepress/demos/pill/details.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pill/details.dart

:::

</Demo>

### size

A collapsed pill lines up with a [`PlButton`](../inputs/button) of the same `size` beside it. The row's floor is the control ladder. It is a **minimum** rather than a height, because a pill carrying a description is two lines tall and a fixed height would clip the second.

<Demo src="pill/sizes" :min-height="300">

::: fw react

<<< @/.vitepress/demos/pill/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pill/sizes.dart

:::

</Demo>

### Width

::: fw react

A pill is `inline-flex`, so it is always as wide as its content, in a block, in a flex row, anywhere. Give it a width by putting it in something that has one.

:::

::: fw flutter

**A pill fills a width it is given and takes its own where it is given none.** Inside a `SizedBox`, a `PlCard` or a `Wrap` it spans the room offered, so a pill in a column of cards lines up with them. Inside a `Row`, or a `Positioned` that named only one corner, there is no width to fill and the pill is as wide as its widest part:

```dart
Stack(
  children: <Widget>[
    const MyScreen(),
    PositionedDirectional(
      top: 16,
      start: 16,
      child: PlPill(title: const Text('Recording'), description: const Text('00:41')),
    ),
  ],
)
```

Neither case needs an `Expanded` or a `SizedBox` around it. A loose constraint still counts as a width, which is why a `Wrap` of pills is a column of them rather than a row. Reach for a [`PlChip`](../display/chip) where that is what was wanted.

:::

::: fw react

### position

`static` leaves it in the flow. `sticky` holds it against an edge once the page has scrolled that far. `fixed` pins it to the viewport and centres it, which is the arrangement this shape exists for.

The centring is `mx-auto` inside a full-width box rather than a translate of half its own width: the [rule against transforming a surface](../../design/design-language) holds here too, and `auto` margins are direction-agnostic, so the lozenge stays centred under RTL.

```tsx
<PlPill position="fixed" side="bottom" title="Recording" />
```

:::

::: fw flutter

There is no `position` here, for the reason [`PlFloatingBottomNavigation`](../navigation/floating-bottom-navigation) has none: a `fixed` element has to span something to be centred in it, and a Flutter widget goes exactly where the screen puts it. A `Stack` with a `Positioned` is where a pinned pill goes, and it is the app's own.

:::

## Accessibility

- A pill with nothing to press is not a control and claims nothing. Giving it a handler makes the middle a real button, reachable from a keyboard and announced as what it is.
- `endIcon` is outside that button, so a control put there is its own focus stop.
- A collapsed `details` panel is taken out of the focus order **and** off the accessibility tree. A zero-height box is still perfectly focusable inside, and hiding it from a screen reader alone would leave a keyboard reader tabbing into something they have been told does not exist.

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `position`, `side` | — | A `fixed` element has to span something to be centred in it. A Flutter widget goes exactly where the screen puts it, and a pinned pill is a `Positioned` in the app's own `Stack`. |
| `onClick` | `onPressed` | The package's name for the thing a press calls. |
| `children` | `child` | One slot, and Dart spells it `child`. |
| `inert` on the collapsed panel | `ExcludeFocus` + `ExcludeSemantics` | The same two things that attribute does, said as the two widgets that do them. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |
| Always as wide as its content | Fills a bounded width | `inline-flex` shrink-wraps wherever it is put. A Flutter widget offered a width takes it, which is the framework's own convention. See [Width](#width) for the two cases and what each is for. |

:::
