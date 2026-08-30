---
title: PlScrollZone
order: 5
---

# PlScrollZone

<p class="plass-lede">A strip of anything, laid out in one direction and scrolled in it. Cards, chips, avatars or thumbnails run across the box or down it, in as many lines as you ask for, with a pair of buttons for the pointer that has neither a wheel nor a finger.</p>

<Demo src="scroll-zone/hero" :min-height="240" />

::: fw react

```tsx
import { PlCard, PlScrollZone } from 'plass-ui';

<PlScrollZone label="Continue watching" spacing={3}>
  {shows.map((show) => (
    <PlCard key={show.name} className="w-40" title={show.name} />
  ))}
</PlScrollZone>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlScrollZone(
  label: 'Continue watching',
  spacing: 12,
  children: <Widget>[
    for (final Show show in shows)
      SizedBox(width: 160, child: PlCard(title: Text(show.name))),
  ],
);
```

:::

## Props

<PropsTable name="PlScrollZone" />

::: fw react

Every other `<div>` attribute passes through to the root.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## What it is made of

The mechanism is an **ordinary scroll container**, and everything the component offers is a way of driving one. Swiping, two-finger dragging on a trackpad and the scrollbar are the platform's own and are never intercepted; what is added on top is a pair of buttons for the pointer that has neither a wheel nor a finger, a mouse drag for the strip that reads as something to pull rather than something to page, and the vertical wheel a horizontal strip would otherwise have no use for.

Nothing is transformed. A translated track would have to argue for an exception to the [house rule](../../design/design-language); a scroll offset does not — and it is also what makes the strip run the other way under RTL without being told, and keeps the scrollbar honest.

It draws **no sheet of its own**, and there is no `elevation` to give it one. A shelf is a way of laying children out, and the children arrive with their own surfaces. `variant`, `size` and `color` reach the two buttons, which are real [`PlIconButton`](../inputs/icon-button)s.

## Examples

### orientation and lines

`orientation` decides which way the strip runs and therefore which way it scrolls. `lines` is how many rows a horizontal zone fills before it starts a new column — two lines hold twice as much in the same width, and the strip is still one scroll.

`spacing` is the gap between children.

::: fw react

It is on the same ladder [`PlGrid`](./grid)'s own `spacing` is: `2` is `0.5rem`.

:::

::: fw flutter

It is a length in logical pixels. Dart has no `rem`, and every other measurement in this package is already the same number the other one writes in `rem`.

:::

<Demo src="scroll-zone/lines" :min-height="240">

::: fw react

<<< @/.vitepress/demos/scroll-zone/lines.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/lines.dart

:::

</Demo>

### buttons and snap

`auto` — the default — draws only the button that has somewhere to go, and neither of them while everything fits: a control that cannot do anything is worse than no control, and a row that does not overflow is not a scroller. `always` draws both from the first paint and disables the one that cannot move, which is what a strip whose content arrives later wants. `none` draws neither and leaves the strip to the wheel, the arrow keys and dragging.

`snap` brings the nearest child to the leading edge whenever the scrolling stops, however it was scrolled.

<Demo src="scroll-zone/buttons" :min-height="300">

::: fw react

<<< @/.vitepress/demos/scroll-zone/buttons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/buttons.dart

:::

</Demo>

### buttonPlacement

`inline` — the default — puts the buttons beside the strip: the scroller stops where the button starts, so an item is **cut off** at the button's edge rather than sliding beneath it, and the button is legible over the page rather than over whatever it landed on. `overlay` puts them over the ends of the strip instead, which keeps every pixel of the box for content and lets an item pass under a button.

An inline button keeps its lane even while it has nowhere to go, or the strip would resize under the pointer that had just reached the end of it.

<Demo src="scroll-zone/placement" :min-height="300">

::: fw react

<<< @/.vitepress/demos/scroll-zone/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_zone/placement.dart

:::

</Demo>

### mode

What a press of a button does. `item` moves to the next child along and `step` says how many at a time; `page` moves by everything currently on screen; `hold` scrolls for as long as the button is held, at `speed` pixels a second.

A press too short to be a hold moves one item instead, so a quick tap is never a dead press.

::: fw react

```tsx
<PlScrollZone mode="hold" speed={1200} buttons="always">
  {items}
</PlScrollZone>
```

:::

::: fw flutter

```dart
PlScrollZone(
  mode: PlScrollZoneMode.hold,
  speed: 1200,
  buttons: PlScrollZoneButtons.always,
  children: items,
);
```

:::

An item is **measured** rather than assumed: the children of a scroll zone are whatever the caller put there, so no two of them are necessarily the same width. That measurement is also what makes `lines` work — four children stacked two by two are two columns, and one press should move one column rather than half of one.

### drag

A finger already scrolls the strip, because the mechanism is an ordinary scroll container and touch scrolling is the platform's own — with momentum, rubber-banding and a scrollbar that no handler reproduces. `drag` adds the same gesture for a mouse.

::: fw react

```tsx
<PlScrollZone drag={false} scrollbar>
  {items}
</PlScrollZone>
```

The click that would otherwise follow a real drag is swallowed, so pulling the strip past a card never opens it.

:::

::: fw flutter

```dart
PlScrollZone(drag: false, scrollbar: true, children: items);
```

Flutter leaves the mouse out of `dragDevices` by default, which is the same judgement the browser's own scroll containers make and the same one this reverses: dragging a shelf with a mouse is unusual enough to have to be asked for, and a shelf is exactly the place that asks.

:::

### wheel

A vertical wheel over a strip that runs across the box scrolls it along. A mouse has one wheel and it points the wrong way for a horizontal strip, and what happens there is the platform's own business — which is the problem, since it makes the answer depend on which browser or which machine the reader is on. The pointer being on the strip is them saying which of the two things under it they meant to move.

Only the vertical half of a gesture, and only while the strip has somewhere to go: a trackpad's two fingers and a tilt wheel already scroll it sideways and are left alone, and the moment the strip reaches an end the wheel goes back to the page — so a reader on their way down a long page is held up by one shelf rather than caught in it. A vertical zone is left alone entirely, since the wheel already runs the way it does.

::: fw react

```tsx
<PlScrollZone wheel={false}>{items}</PlScrollZone>
```

Shift held down is a horizontal gesture too, and is the browser's.

:::

::: fw flutter

```dart
PlScrollZone(wheel: false, children: items);
```

A horizontal `Scrollable` reads the horizontal half of a scroll and a mouse wheel only ever produces the vertical one, so without this a shelf under the pointer does not move at all.

:::

## Accessibility

- `label` names the region and is what a screen reader reads before its contents. Without one the strip has no name at all.
- The scroll buttons are real buttons with real names, and `previousLabel` / `nextLabel` decide what those names are. A disc with a chevron in it has no accessible name of its own, which is the defect [`PlIconButton`](../inputs/icon-button)'s `label` exists to make impossible.
- Nothing inside the strip is hidden while it is off screen: it is genuinely reachable by scrolling, and hiding it would be a lie a keyboard reader would fall into.

::: fw react

- The strip is focusable and scrolls with the arrow keys, which is the browser's own key handling on a scroll container — so it is already right under RTL.
- In `hold` mode the buttons answer <kbd>Enter</kbd> and <kbd>Space</kbd> the same way they answer a press, scrolling while the key is down. A scroll affordance a pointer can use and a keyboard cannot is the one thing this must never be.

:::

::: fw flutter

- In `hold` mode a key press moves one item and the platform's own key repeat carries it, rather than the frame loop a held pointer gets. Either way the buttons are reachable from a keyboard, which is the thing that matters.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `children` as JSX | `children: List<Widget>` | The idiom the rest of the package uses. |
| `spacing` on the spacing scale | `spacing`, in logical pixels | There is no `rem`. The numbers are the same either way. |
| a CSS grid with `grid-template-rows` | a row of columns | `lines` is a fixed number of rows and as many columns as it takes, which is what `grid-auto-flow: column` says there. One thing does not carry over: a CSS grid gives every column the same row heights, and a row of columns does not. |
| — | `controller` | Flutter drives a scroll view with a `ScrollController`, and a caller who wants the offset should be handed the object that has it. |
| a pointer-held frame loop **and** a key-held one | a pointer-held frame loop | A held key repeats on its own here, and one item per repeat is what that produces. |
| `density` | — | The buttons are `PlIconButton`s, and Flutter's has no `density`. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
