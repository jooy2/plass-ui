---
title: PlButtonGroup
order: 2
---

# PlButtonGroup

<p class="plass-lede">A run of buttons that belong together. The corners that face a neighbour are squared off, and <code>variant</code>, <code>size</code>, <code>color</code>, <code>density</code>, <code>elevation</code> and <code>disabled</code> are stated once for the set.</p>

<Demo src="button-group/hero" :min-height="120" />

::: fw react

```tsx
import { PlButton, PlButtonGroup } from 'plass-ui';

<PlButtonGroup variant="glass" color="secondary">
  <PlButton>Day</PlButton>
  <PlButton>Week</PlButton>
  <PlButton>Month</PlButton>
</PlButtonGroup>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlButtonGroup(
  variant: PlassVariant.glass,
  color: PlassColor.secondary,
  children: <Widget>[
    PlButton(onPressed: showDay, child: const Text('Day')),
    PlButton(onPressed: showWeek, child: const Text('Week')),
    PlButton(onPressed: showMonth, child: const Text('Month')),
  ],
);
```

:::

## Props

<PropsTable name="PlButtonGroup" />

::: fw react

Every native `<div>` attribute passes straight through. `color` is excluded because it collides with the `color` in the table above.

:::

::: fw flutter

`children` is a list rather than one `child`, and not only because that is Flutter's usual shape: the group has to know which member is at each end to decide which corners to square, and a widget handed one opaque subtree could not.

The axes are **nullable on `PlButton` and `PlIconButton` too** (`PlassVariant?`, `PlassSize?`, `int?`), because Dart has no way to tell a default apart from a value that was passed. `null` there means _this button did not say_, which is what leaves the run free to answer.

:::

The five style axes have **no default of their own**: an axis the group does not state is one each button falls back to its own default on, so a group with no props changes nothing except the corners. A button that states an axis itself still wins. A run of secondary actions with one `danger` button in it is a real thing.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## PlButtonGroup or PlSegmentedButton

The buttons stay real [`PlButton`](./button)s and nothing about them is replaced: the group squares four corners and hands down six props. It does not manage selection, it has no value, and none of its buttons is ever _the chosen one_.

For one-of-a-set (a view switcher, a mode toggle) use [`PlSegmentedButton`](./segmented-button), which is that control and carries the roving focus and the `radiogroup` semantics that go with it.

## Examples

### variant

`glass` is the one variant with a seam to handle. It is also the only one that draws an edge, and two glass keys meeting would otherwise show both of their hairlines, twice the weight of every other edge on the page, so the second is pulled back a pixel and the two share one line.

`solid` must not do that. Its keys have no border to double up, and overlapping would put one gradient over the start of the next.

<Demo src="button-group/variants" :min-height="140">

::: fw react

<<< @/.vitepress/demos/button-group/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/variants.dart

:::

</Demo>

### size

Stated once, so it cannot be a size out on one button. The heights are the library's control ladder, unchanged.

<Demo src="button-group/sizes" :min-height="260">

::: fw react

<<< @/.vitepress/demos/button-group/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/sizes.dart

:::

</Demo>

### orientation

`vertical` stacks the run and squares the top and bottom edges instead of the sides. It is for a stacked menu of equal actions; `horizontal` is the default because that is what a toolbar is.

<Demo src="button-group/orientation" :min-height="180">

::: fw react

<<< @/.vitepress/demos/button-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/orientation.dart

:::

</Demo>

### fullWidth

Stretches the group to its container and divides the width evenly between the buttons, so three actions across the bottom of a card are three equal thirds rather than three different lengths of word.

<Demo src="button-group/full-width" :min-height="120">

::: fw react

<<< @/.vitepress/demos/button-group/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/full_width.dart

:::

</Demo>

## Accessibility

- The group is a `role="group"`. Give it an `aria-label` when the run needs a name of its own. A bar with three of these in it is three unnamed groups otherwise.
- It is **not** a `role="toolbar"` and takes no roving focus. That role is a promise about keyboard behaviour, and every button here is its own tab stop, which is what ordinary `<button>` semantics already say.
- The corners are squared with logical properties, so under RTL the first button is on the right and the flattened side follows it.
- Each button gets a stacking context, so a focus ring (drawn outside the border box) is never painted over by the neighbour that comes after it.
- `disabled` on the group disables every button in it; a button that sets `disabled` itself still wins.

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| arbitrary `children` | `children: List<Widget>` | The group has to know which member is at each end to square the right corners. |
| a glass key is pulled back a pixel so two hairlines overlap | the key facing a neighbour does not draw that side at all | Flutter has no negative margin, `EdgeInsets` asserts it is non-negative, and the alternative is a `Transform`, which this library does not put on a control. Both arrive at one hairline per seam. |
| an axis is left off | the same parameters are nullable | Dart cannot tell a default apart from a value that was passed, so _not stated_ has to be a value the type can hold. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
