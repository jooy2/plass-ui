---
title: PlToast
order: 5
---

# PlToast

<p class="plass-lede">A message that appears on its own, says what happened, and leaves. Wrap the application in a <code>PlToastProvider</code> once, and raise one from anywhere with <code>usePlToast</code>.</p>

<Demo src="toast/hero" :min-height="120" />

```tsx
import { PlToastProvider, usePlToast } from 'plass-ui';

<PlToastProvider>
  <App />
</PlToastProvider>;

// anywhere under it
const toast = usePlToast();

toast.add({ color: 'success', title: 'Saved', description: 'Your changes are live.' });
```

## Props

### PlToastProvider

<PropsTable name="PlToastProvider" />

Everything about how a toast _looks_ is decided on the provider — where the stack sits, how wide it is, which material it wears, how long it lasts — so the call site stays the one thing it should be: what happened.

There is no `elevation`. A toast floats over the page, so its shadow is always level 3, the same as the `PlSelect` popup, the `PlModal` sheet and the `PlTooltip` plate.

### usePlToast

<PropsTable name="usePlToast" />

A hook rather than a component, because the thing a caller has at the moment a toast is warranted is a click handler, not a place in the tree — and a `<PlToast open={…} />` they would have to keep mounted, with a piece of state per message, is the shape this component exists to avoid.

### PlToastOptions

<PropsTable name="PlToastOptions" />

What the shared axes (`variant` `size` `color` `density`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### position

One word rather than a `side` plus an `align` pair, because the two are not independent: a toast stack is always pinned to the top or the bottom, never to a side, and offering `left`/`right` as a "side" would invite a stack down the middle of the screen that nothing in the layout survives.

<Demo src="toast/positions" :min-height="200">

<<< @/.vitepress/demos/toast/positions.tsx

</Demo>

### variant and color

Both are provider defaults that a single toast overrides, so a page can have one house style and still make the one error look like an error.

Each family draws its own shape as well as its own colour — a toast that says "this went wrong" only in red says it only to some readers.

<Demo src="toast/variants" :min-height="120">

<<< @/.vitepress/demos/toast/variants.tsx

</Demo>

<Demo src="toast/colors" :min-height="120">

<<< @/.vitepress/demos/toast/colors.tsx

</Demo>

### The action, and timeout: 0

Passing `actionLabel` is what makes the action button appear. Anything the reader has to act on should also carry `timeout: 0`, because a toast that leaves before it is read said nothing.

### update

Reusing an id updates that toast in place and restarts its timer, which is what "uploading… / uploaded" wants: one toast that changed its mind, not two stacked on each other.

<Demo src="toast/update" :min-height="120">

<<< @/.vitepress/demos/toast/update.tsx

</Demo>

### promise

One toast that follows a promise: the loading message while it runs, then the success or the error. Base UI applies `timeout: 0` to the loading state, so a slow request cannot dismiss its own toast.

<Demo src="toast/promise" :min-height="120">

<<< @/.vitepress/demos/toast/promise.tsx

</Demo>

## Accessibility

- Base UI owns the parts that are genuinely hard and invisible when they work: the timers and their pausing on hover and on window blur, the limit, the swipe, the F6 focus hotkey, and the live region that makes a message which appeared out of nowhere reach a screen reader at all.
- `priority` picks the live region. `high` interrupts whatever is being read and `low` waits for a pause — an error is worth interrupting for and a save confirmation is not.
- The × is deliberately not in the page's tab order and is hidden from the accessibility tree. A screen reader reaches a toast with **F6** and is given the close action there, rather than finding a stray button from a message that may already be gone.
- A toast pushed out by `limit` stays in the DOM so it can come back, and says nothing while it waits.
- The stack is `pointer-events-none` across its full width, so the strip along the top or the bottom of the page is not a wall the rest of the app is behind. The toasts themselves take their events back.
