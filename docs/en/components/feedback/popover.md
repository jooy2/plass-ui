---
title: PlPopover
order: 8
---

# PlPopover

<p class="plass-lede">A sheet that opens beside the thing that opened it. Unlike a tooltip it can be reached; unlike a modal it does not take the page.</p>

<Demo src="popover/hero" :flutter="false" :min-height="140" />

::: fw react

```tsx
import { PlButton, PlPopover } from 'plass-ui';

<PlPopover trigger={<PlButton>How is this worked out?</PlButton>} title="Effective rate">
  Your rate is the base rate plus whatever your plan adds to it.
</PlPopover>;
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

Which edge of the trigger it appears on, and where it sits along that edge. It **flips** to the opposite side when there is no room, which is the right behaviour and is not something this component had to write.

<Demo src="popover/sides" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/popover/sides.tsx

</Demo>

### arrow

Off by default, unlike on a [`PlTooltip`](./tooltip). A tooltip is a filled plate and its wedge is the same solid colour; this surface is translucent over a blurred backdrop, and **a wedge sticking out past the popup's own box cannot carry that backdrop with it**.

Turn it on where the trigger is far enough away that the popup needs to say what it belongs to.

### A popover can hold a form

This is the whole reason it is not a tooltip. What is inside can take focus, so a rename, a filter or a date range belongs here rather than in a modal that would have taken the page away to ask one question.

<Demo src="popover/form" :flutter="false" :min-height="140">

<<< @/.vitepress/demos/popover/form.tsx

</Demo>

### dismissible

On by default: Escape and a click outside both close it. Turn it off only for a popup that has its own way out, **and then give it one** — a close button, an action that answers it — because there will be no other.

::: fw react

`PlPopoverClose` still works while `dismissible` is off, which is what keeps a refusal from being a trap.

:::

## Accessibility

- The popup is a dialog anchored to its trigger: `title` names it, `description` describes it, and focus goes back to the trigger on the way out.
- The page behind is **not** taken away unless `modal` says so. A popover that hid the page would be a modal with a worse shape.
- Escape and a click outside are both real dismissals, and both are cancellable together with `dismissible={false}`.

::: fw react

- Base UI owns the anchoring, the flip at the window edge, the outside-press and Escape handling, the focus return and the `aria-labelledby` / `aria-describedby` wiring.

:::
