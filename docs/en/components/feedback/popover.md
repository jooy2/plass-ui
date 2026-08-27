---
title: PlPopover
order: 8
---

# PlPopover

<p class="plass-lede">A sheet that opens beside the thing that opened it. Unlike a tooltip it can be reached; unlike a modal it does not take the page.</p>

<Demo src="popover/hero" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlPopover } from 'plass-ui';

<PlPopover trigger={<PlButton>How is this worked out?</PlButton>} title="Effective rate">
  Your rate is the base rate plus whatever your plan adds to it.
</PlPopover>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPopover(
  open: explaining,
  onOpenChanged: (bool next) => setState(() => explaining = next),
  title: const Text('Effective rate'),
  trigger: PlButton(
    onPressed: () => setState(() => explaining = true),
    child: const Text('How is this worked out?'),
  ),
  child: const Text('The base rate plus whatever your plan adds to it.'),
);
```

:::

## Props

<PropsTable name="PlPopover" />

::: fw react

Every other `<div>` attribute passes through to the popup.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Not a tooltip, not a modal

Three floating surfaces, three different jobs, and the difference between them is what you can _do_ with them.

- A [`PlTooltip`](./tooltip) is a **note** about something else. It appears on hover, it goes away when you leave, and nothing in it can be reached — a link inside one is a link nobody can click.
- A **popover** stays up until it is dismissed. It can be entered with the pointer or the keyboard, and what is inside it can be clicked and typed into.
- A [`PlModal`](./modal) takes the page away until it is answered.

A popover is the middle one: anchored to a control, and the page behind goes on working. That is what `modal` defaults to `false` says.

## There is no variant and no elevation

The three materials answer "how much does this surface assert itself against the page", and a popup that had to be **asked for** has already answered it. And a popover genuinely floats, which is the one case the elevation ladder exists for — so it is fixed at its top rung rather than offered as a decision that could sit it flat.

## Examples

### side and align

Which edge of the trigger it appears on, and where it sits along that edge. It **flips** to the opposite side when there is no room, and never _slides_ along the edge it is on — which is what keeps an arrow pointing at the thing it belongs to.

<Demo src="popover/sides" :min-height="220">

::: fw react

<<< @/.vitepress/demos/popover/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popover/sides.dart

:::

</Demo>

### arrow

Off by default, unlike on a [`PlTooltip`](./tooltip). A tooltip is a filled plate and its wedge is the same solid colour; this surface is translucent over a blurred backdrop, and **a wedge sticking out past the popup's own box cannot carry that backdrop with it**.

Turn it on where the trigger is far enough away that the popup needs to say what it belongs to.

### A popover can hold a form

This is the whole reason it is not a tooltip. What is inside can take focus, so a rename, a filter or a date range belongs here rather than in a modal that would have taken the page away to ask one question.

<Demo src="popover/form" :min-height="140">

::: fw react

<<< @/.vitepress/demos/popover/form.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popover/form.dart

:::

</Demo>

### dismissible

On by default: a press outside closes it. Turn it off only for a popup that has its own way out, **and then give it one** — a close button, an action that answers it — because there will be no other.

::: fw react

Escape closes it too, and `dismissible={false}` cancels both. `PlPopoverClose` still works while it is off, which is what keeps a refusal from being a trap.

:::

::: fw flutter

`showClose` and the actions inside it still work while it is off, which is what keeps a refusal from being a trap.

:::

## Accessibility

- `title` names the popup and is announced as a heading; `description` sits under it.
- The screen behind is **not** taken away. A popover that hid the page would be a modal with a worse shape.
- A press outside is a real dismissal, and it can be refused with `dismissible`.

::: fw react

- The popup is a dialog anchored to its trigger, and focus goes back to the trigger on the way out. Base UI owns the anchoring, the flip at the window edge, the outside-press and Escape handling, the focus return and the `aria-labelledby` / `aria-describedby` wiring.
- `modal="trap-focus"` holds focus inside without locking the page's scroll.

:::

::: fw flutter

- The lift, the anchoring, the flip and the press outside are `PlassAnchoredPortal`'s — the same layer a `PlTooltip` and a `PlSelect`'s list stand on, so the three stay stuck to their anchors through a scroll for the same reason.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter's own controls are controlled, and so is every stateful widget in this package. |
| `trigger` is optional | `trigger` is required | A browser can position a popup against the viewport with no anchor; a `LayerLink` has nothing to follow without one. |
| `modal` | — | There is no page scroll to lock and no inert tree to build. The press outside is the whole of what a popover needs to answer. |
| `alignOffset` | — | The anchoring is a flip and never a slide, so there is no along-the-edge shift to offset. |
| `PlPopoverClose` | — | It exists over there so an _uncontrolled_ popover's button has something to call. Every popover here is controlled. |
| `width: number \| string` | `width: double` | Pixels stay pixels. There is no CSS length to accept. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
