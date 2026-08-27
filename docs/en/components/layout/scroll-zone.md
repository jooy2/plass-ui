---
title: PlScrollZone
order: 5
---

# PlScrollZone

<p class="plass-lede">A strip of anything, laid out in one direction and scrolled in it. Cards, chips, avatars or thumbnails run across the box or down it, in as many lines as you ask for, with a pair of buttons for the pointer that has neither a wheel nor a finger.</p>

<Demo src="scroll-zone/hero" :flutter="false" :min-height="240" />

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

## Props

<PropsTable name="PlScrollZone" />

::: fw react

Every other `<div>` attribute passes through to the root.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## What it is made of

The mechanism is an **ordinary scroll container**, and everything the component offers is a way of driving one. Swiping on a phone, two-finger dragging on a trackpad, the wheel, the arrow keys and the scrollbar are the browser's own and are never intercepted; what is added on top is a pair of buttons for the pointer that has neither a wheel nor a finger, and a mouse drag for the strip that reads as something to pull rather than something to page.

Nothing is transformed. A translated track would have to argue for an exception to the [house rule](../../design/design-language); a scroll offset does not — and it is also what makes the strip run the other way under RTL without being told, keeps the scrollbar honest, and lets the browser scroll a focused child into view.

It draws **no sheet of its own**, and there is no `elevation` to give it one. A shelf is a way of laying children out, and the children arrive with their own surfaces. `variant`, `size`, `color` and `density` reach the two buttons, which are real [`PlIconButton`](../inputs/icon-button)s.

## Examples

### orientation and lines

`orientation` decides which way the strip runs and therefore which way it scrolls. `lines` is how many rows a horizontal zone fills before it starts a new column — two lines hold twice as much in the same width, and the strip is still one scroll.

`spacing` is the gap between children, on the same ladder [`PlGrid`](./grid)'s own `spacing` is: `2` is `0.5rem`.

<Demo src="scroll-zone/lines" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/scroll-zone/lines.tsx

</Demo>

### buttons and snap

`auto` — the default — draws only the button that has somewhere to go, and neither of them while everything fits: a control that cannot do anything is worse than no control, and a row that does not overflow is not a scroller. `always` draws both from the first paint and disables the one that cannot move, which is what a strip whose content arrives later wants. `none` draws neither and leaves the strip to the wheel, the arrow keys and dragging.

`snap` brings the nearest child to the leading edge whenever the scrolling stops, however it was scrolled.

<Demo src="scroll-zone/buttons" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/scroll-zone/buttons.tsx

</Demo>

### buttonPlacement

`overlay` — the default — puts the buttons over the ends of the strip, which keeps every pixel of the box for content and lets an item pass under a button. `inline` puts them beside it: the scroller stops where the button starts, so an item is **cut off** at the button's edge rather than sliding beneath it, and the button is legible over the page rather than over whatever it landed on.

An inline button keeps its lane even while it has nowhere to go, or the strip would resize under the pointer that had just reached the end of it.

<Demo src="scroll-zone/placement" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/scroll-zone/placement.tsx

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

An item is **measured** rather than assumed: the children of a scroll zone are whatever the caller put there, so no two of them are necessarily the same width. That measurement is also what makes `lines` work — four children stacked two by two are two columns, and one press should move one column rather than half of one.

:::

### drag

A finger already scrolls the strip, because the mechanism is an ordinary scroll container and touch scrolling is the browser's own — with momentum, rubber-banding and a scrollbar that no handler reproduces. `drag` adds the same gesture for a mouse or a pen, and the click that would otherwise follow a real drag is swallowed, so pulling the strip past a card never opens it.

::: fw react

```tsx
<PlScrollZone drag={false} scrollbar>
  {items}
</PlScrollZone>
```

:::

## Accessibility

- The strip is focusable and scrolls with the arrow keys, which is the browser's own key handling on a scroll container — so it is already right under RTL.
- `label` names the region and is what a screen reader reads before its contents. Without one the strip is focusable but unnamed.
- The scroll buttons are real buttons with real names, and `previousLabel` / `nextLabel` decide what those names are. A disc with a chevron in it has no accessible name of its own, which is the defect [`PlIconButton`](../inputs/icon-button)'s `label` exists to make impossible.
- In `hold` mode the buttons answer <kbd>Enter</kbd> and <kbd>Space</kbd> the same way they answer a press, scrolling while the key is down. A scroll affordance a pointer can use and a keyboard cannot is the one thing this must never be.
- Nothing inside the strip is hidden while it is off screen: it is genuinely reachable by scrolling, and `aria-hidden` on it would be a lie a keyboard reader would fall into.
