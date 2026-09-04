---
title: PlStack
order: 8
---

# PlStack

<p class="plass-lede">Things piled up, overlapping — faces, cards, thumbnails, whatever you hand it. The box measures exactly what it draws, so a pile can sit in a sentence or a table cell without lying about its size.</p>

<Demo src="stack/hero" :min-height="140" />

::: fw react

```tsx
import { PlAvatar, PlStack } from 'plass-ui';

<PlStack ring max={4} total={11} overflow={(hidden) => <PlAvatar initials={`+${hidden}`} />}>
  <PlAvatar name="Ada Lovelace" src="/ada.jpg" />
  <PlAvatar name="Grace Hopper" />
</PlStack>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlStack(
  max: 4,
  total: 11,
  ring: BorderRadius.circular(999),
  overflow: (int hidden) => PlAvatar(initials: '+$hidden'),
  children: const <Widget>[
    PlAvatar(name: 'Ada Lovelace'),
    PlAvatar(name: 'Grace Hopper'),
  ],
);
```

:::

## Props

<PropsTable name="PlStack" />

::: fw react

Every native `<div>` attribute passes straight through, `aria-label` included — a row of faces is a picture of a set, and what it is a set of is usually the sentence beside it.

:::

::: fw flutter

`semanticLabel` names the pile, and the items keep their own semantics nodes under it, so a named pile is read as its name and then as what is in it.

:::

`size` picks the default `overlap` off the ladder and **decides nothing else**. A pile draws no surface of its own and has no type in it, so there is no height to set and no ink to colour: the items are whatever they already were.

## It is a layout, not an offset

This is the decision the whole component is built on, and the one that is easy to get wrong.

An overlapping pile is tempting to build by translating each item back over the last. Do that and the pile is **laid out one item wide**: it paints outside its own box, and every element after it on the page is placed against a size the reader never sees. It cannot go in a paragraph, in a table cell, or in a flex row beside a label without pushing something out of place.

So the overlap is real layout — a negative margin in React, and a render object of its own in Flutter, where `EdgeInsets` and `Flex.spacing` both assert they are not negative. Five 32px items at 10px of overlap measure exactly:

| direction    | box      |
| ------------ | -------- |
| `horizontal` | 120 × 32 |
| `vertical`   | 32 × 120 |
| `diagonal`   | 120 × 72 |

The last row is the one worth reading twice. **A flow only overlaps on the axis it flows along**, so `diagonal` flows across like `horizontal` does and takes its vertical step per item instead — one fixed offset in a row would put every item at the same height and the fan would be a row.

Which is also why `diagonal` is a **fan** rather than a true 45°: the horizontal advance is `item width − overlap`, and a component that takes arbitrary children does not know how wide they are. `drop` is the vertical step, stated separately, and the two are independent on purpose.

<Demo src="stack/directions" :min-height="220">

::: fw react

<<< @/.vitepress/demos/stack/directions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stack/directions.dart

:::

</Demo>

**`direction` is responsive**, so a pile can run across on a laptop and down on a phone. <Fw react="It is resolved in JavaScript rather than in CSS: it decides which margin axis each item takes and which one the drop is multiplied on, and those are different declarations rather than one value a slot could carry. A server renders the xs entry; a bare direction subscribes to nothing." flutter="It is resolved against the window's width in build, so it is right on the first frame." /> See [breakpoints](../../design/breakpoints).

## Examples

### max, total and overflow

`max` is how many are drawn; `total` is how many there are, for when the pile was handed only the first few. `overflow` is given the difference and draws the last item.

A **function** rather than a node, and that is the whole point: the number _is_ the item. A node would have to be given a count it has no way to work out, and would then be wrong every time the list changed.

<Demo src="stack/overflow" :min-height="220">

::: fw react

<<< @/.vitepress/demos/stack/overflow.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stack/overflow.dart

:::

</Demo>

### front, scaleStep and opacityStep

`front` says which end of the list is on top. `last` is what the DOM does on its own and what a row of faces wants — the newest arrival in front. `first` is what a deck of cards is: the top card is the one you read first.

`scaleStep` and `opacityStep` compound **away from whichever end is in front**, so the front item is always at full strength and turning `front` round does not also mean turning these round. They are applied at paint time, so an item that recedes still takes the room it took before and the step stays even.

<Demo src="stack/deck" :min-height="260">

::: fw react

<<< @/.vitepress/demos/stack/deck.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stack/deck.dart

:::

</Demo>

### ring

Two shapes of similar tone laid over each other have no boundary between them at all and the pile reads as one smeared shape. The hairline is the page's own surface colour, so it reads as the _hole_ the near item is cut out of rather than as a line around anything — a translucent line would not help, because what is behind it is the other item.

::: fw react

It lands on **the element you passed**, so it takes that element's shape. Wrap an avatar in something square and the ring is square; there is no way for a component that accepts arbitrary children to know better.

:::

::: fw flutter

It takes a `BorderRadius` rather than a `bool`, which is the one place this widget diverges from the React build. There a ring is a box shadow and CSS gives it the element's own `border-radius` for nothing; here nothing can read a child's shape, so the shape has to be said.

:::

## Coming from PlAvatarGroup

`PlAvatarGroup` was this component with one kind of child written into it, and it is gone. A row of faces is one arrangement of a pile, not a component of its own.

What moves:

| `PlAvatarGroup` | `PlStack` |
| --- | --- |
| `<PlAvatarGroup>` | `<PlStack>` |
| `max`, `total`, `overlap` | unchanged |
| the `+n` avatar, drawn for you | `overflow={(n) => <PlAvatar initials={\`+${n}\`} />}` |
| `size`, `color` set once for every avatar | a `PlassProvider` around the stack, or the prop on each avatar |
| `shape`, `variant`, `elevation` set once | the prop on each avatar |
| a ring, always | `ring` |

**The group context is the part that is genuinely lost**, and it could not be kept: a pile that accepts arbitrary children has no way to know one of them is an avatar. `size` and `color` are axes an application already sets once — put a `PlassProvider` (Flutter: a `PlassTheme`) around the stack. The other three were never application-wide axes, and they belong on the avatar.

What is gained is everything the group could not do: any child at all, three directions, a stacking order you can state, depth, and an overflow item you draw yourself.

## Accessibility

::: fw react

- The stack adds no role and no label. It is a `<div>` around content that already says what it is — pass an `aria-label` when a row of faces is standing in for a set that nothing beside it names.
- The items keep their own elements, their own semantics and their own focus order. Nothing is cloned and nothing is replaced.
- The stacking order is `z-index`, so it changes what is painted on top and what a pointer lands on. It does not change the **reading** order, which stays the order you wrote — which is what you want: a screen reader should read a set in the order it was given, whichever face happens to be in front.

:::

::: fw flutter

- `semanticLabel` names the pile, and the items keep their own nodes under it.
- Hit testing runs front to back, which is the reverse of the paint order: the item a reader can see at a point is the one their finger lands on.
- The stacking order changes painting and hit testing only. The semantics order stays the order you wrote.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `ring` as a `bool` | `ring` as a `BorderRadius?` | CSS gives a ring the element's own `border-radius` for nothing; nothing here can read a child's shape, so it has to be said. |
| a negative margin | a render object of its own | `EdgeInsets` asserts it is non-negative and so does `Flex.spacing`, so the only place child sizes are known is a layout of our own. It reports the same box either way. |
| `overflow: (n) => ReactNode` | `overflow: Widget Function(int)?` | The same function, in each framework's own spelling. |
| `overlap`, `drop` as a length or a number | `double?` in logical pixels | There is no CSS length to write here. |
| `aria-label` | `semanticLabel` | Flutter's name. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
