---
title: PlHoverCard
order: 11
---

# PlHoverCard

<p class="plass-lede">A preview of what is behind a link, shown when the pointer rests on it. Long enough to open that it does not fire at every link on the way somewhere else, and slow enough to close that it can be reached.</p>

<Demo src="hover-card/hero" :min-height="240" />

::: fw react

```tsx
import { PlHoverCard, PlTextLink } from 'plass-ui';

<PlHoverCard
  title="Ada Lovelace"
  description="Mathematician, 1815–1852"
  trigger={<PlTextLink href="/ada">Ada Lovelace</PlTextLink>}
>
  Wrote the first algorithm intended to be carried out by a machine.
</PlHoverCard>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHoverCard(
  title: const Text('Ada Lovelace'),
  description: const Text('Mathematician, 1815–1852'),
  trigger: PlTextLink(onPressed: open, child: const Text('Ada Lovelace')),
  child: const Text('Wrote the first algorithm intended to be carried out by a machine.'),
);
```

:::

## Props

<PropsTable name="PlHoverCard" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Hover card, tooltip or popover

Three of them, and what tells them apart is **what opens them and what you can do once they are open**, not how they look. All three are the same sheet.

|  | Opened by | Once it is open |
| --- | --- | --- |
| [`PlTooltip`](../feedback/tooltip) | resting on something | one phrase, and nothing in it can be reached |
| `PlHoverCard` | resting on something | the pointer can move onto it; a title, a picture, a figure |
| [`PlPopover`](../feedback/popover) | a press | it stays until dismissed, and can be typed into |

## Nothing may live only in here

The rule that decides whether a hover card is the right component at all.

**A card that opens on hover does not open for a finger.** A link, a button or a fact that exists nowhere else on the page is a link, a button or a fact that every touch reader misses. So everything inside is a preview of something already reachable. The page the trigger goes to, a profile that has its own screen, a figure repeated in the table below.

That is what makes it safe to have at all, and it is also why it needs no dismiss button, no focus trap and no scroll lock. Nothing is lost by never seeing it.

## The delays

`delay` is **600ms** and that is deliberately long. A card that opens the moment a pointer crosses a link opens on every link a reader passes on the way somewhere else, which turns a page of prose into a page that flinches.

`closeDelay` is **300ms** and it cannot be zero. The gap between the trigger and the card has no pointer in it, so a card that closed the instant the pointer left the trigger could never be reached, and reaching it is the whole difference from a tooltip.

<Demo src="hover-card/delays" :min-height="220">

::: fw react

<<< @/.vitepress/demos/hover-card/delays.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hover_card/delays.dart

:::

</Demo>

Shorten `delay` for a page whose links are **all** previews (a table of people, a list of issues), and leave it alone everywhere else.

## Examples

### A person

The ordinary case, and the shape the component was drawn for.

```tsx
<PlHoverCard
  title="Ada Lovelace"
  description="Mathematician"
  trigger={<PlTextLink href="/people/ada">Ada Lovelace</PlTextLink>}
>
  <div className="flex items-center gap-3">
    <PlAvatar name="Ada Lovelace" />
    <p>Wrote the first algorithm intended for a machine.</p>
  </div>
</PlHoverCard>
```

### Somewhere other than under the link

`side`, `align` and the two offsets are the same four a [popover](../feedback/popover) takes, and the card flips to the opposite side when there is no room.

```tsx
<PlHoverCard side="right" align="start" arrow trigger={…}>…</PlHoverCard>
```

## Notes

- The trigger is **rendered, not wrapped**: a link stays a link, keeps its `href`, its styling and its place in the tab order, and the card adds no box to the layout.
- The sheet is the same frosted panel a [popover](../feedback/popover) draws, one rung wider at every `size` step. A popover is a detail beside a control, and a preview squeezed to the width of a hint is a preview nobody reads.
- `arrow` is off by default, as it is on a popover: the sheet is translucent over a blurred backdrop, and a wedge sticking out past its own box cannot carry that backdrop with it.

::: fw react

- Base UI's `PreviewCard` owns the anchoring, the flip at the window edge, the two delays and the dismissal.

:::

::: fw flutter

- The pointer is tracked on the trigger **and** on the card, as two flags rather than one, which is what lets it cross the gap between them.
- Needs an `Overlay` above it, which `WidgetsApp` with a navigator and `MaterialApp` both provide.

:::

## Accessibility

- **It opens on keyboard focus as well as on hover**, so a reader tabbing along a paragraph of links gets the same preview a pointer would. That is the half a hover-only card loses, and it is free here.
- <kbd>Escape</kbd> closes it.
- It is not a dialog and does not take the focus. What is inside can be reached with the pointer; what is inside must also be reachable **without** it, per the rule above.
- The trigger keeps whatever role it already had. A link that opens a card is still a link, and it still goes where it says it goes.
