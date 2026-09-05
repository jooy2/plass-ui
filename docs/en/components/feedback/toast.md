---
title: PlToast
order: 5
---

# PlToast

<p class="plass-lede">A message that appears on its own, says what happened, and leaves. Wrap the application in a <code>PlToastProvider</code> once, and raise one from anywhere under it.</p>

<Demo src="toast/hero" :min-height="120" />

::: fw react

```tsx
import { PlToastProvider, usePlToast } from 'plass-ui';

<PlToastProvider>
  <App />
</PlToastProvider>;

// anywhere under it
const toast = usePlToast();

toast.add({ color: 'success', title: 'Saved', description: 'Your changes are live.' });
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlToastProvider(child: const App());

// anywhere under it
PlToastProvider.of(context).show(
  const PlToast(
    color: PlassColor.success,
    title: Text('Saved'),
    description: Text('Your changes are live.'),
  ),
);
```

:::

## Props

### PlToastProvider

<PropsTable name="PlToastProvider" />

Everything about how a toast _looks_ is decided on the provider (where the stack sits, how wide it is, which material it wears, how long it lasts), so the call site stays the one thing it should be: what happened.

There is no `elevation`. A toast floats over the page, so its shadow is always at the top of the ladder, the same as the `PlSelect` list, the `PlModal` sheet and the `PlTooltip` plate.

::: fw react

### usePlToast

<PropsTable name="usePlToast" />

A hook rather than a component, because the thing a caller has at the moment a toast is warranted is a click handler, not a place in the tree, and a `<PlToast open={…} />` they would have to keep mounted, with a piece of state per message, is the shape this component exists to avoid.

### PlToastOptions

<PropsTable name="PlToastOptions" />

:::

::: fw flutter

### PlToastController

<PropsTable name="PlToastController" />

`PlToastProvider.of(context)` hands one back. A controller rather than a widget, because the thing a caller has at the moment a toast is warranted is a callback, not a place in the tree, and a `PlToast(open: …)` they would have to keep mounted, with a piece of state per message, is the shape this exists to avoid.

### PlToast

<PropsTable name="PlToast" />

`PlToast` is the **message**, not a widget: it is what `show` is handed. Nothing here is put in the tree by the caller.

:::

What the shared axes (`variant` `size` `color` `density`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### position

One word rather than a `side` plus an `align` pair, because the two are not independent: a toast stack is always pinned to the top or the bottom, never to a side, and offering `left`/`right` as a "side" would invite a stack down the middle of the screen that nothing in the layout survives.

<Demo src="toast/positions" :min-height="200">

::: fw react

<<< @/.vitepress/demos/toast/positions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/positions.dart

:::

</Demo>

### variant and color

Both are provider defaults that a single toast overrides, so a page can have one house style and still make the one error look like an error.

Each family draws its own shape as well as its own colour, a toast that says "this went wrong" only in red says it only to some readers.

<Demo src="toast/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/toast/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/variants.dart

:::

</Demo>

<Demo src="toast/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/toast/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/colors.dart

:::

</Demo>

### The action, and timeout: 0

Passing `actionLabel` is what makes the action button appear. Anything the reader has to act on should also carry `timeout: 0`, because a toast that leaves before it is read said nothing.

### update

Reusing an id updates that toast in place and restarts its timer, which is what "uploading… / uploaded" wants: one toast that changed its mind, not two stacked on each other.

<Demo src="toast/update" :min-height="120">

::: fw react

<<< @/.vitepress/demos/toast/update.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/update.dart

:::

</Demo>

### <Fw react="promise" flutter="showFuture" />

One toast that follows a <Fw react="promise" flutter="future" />: the loading message while it runs, then the success or the failure. The loading state is held open whatever it asked for, so a slow request cannot dismiss its own toast, and the same toast becomes the answer, so a reader who watched it start sees it finish rather than seeing a second one appear beside it.

<Demo src="toast/promise" :min-height="120">

::: fw react

<<< @/.vitepress/demos/toast/promise.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/future.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI owns the parts that are genuinely hard and invisible when they work: the timers and their pausing on hover and on window blur, the limit, the swipe, the F6 focus hotkey, and the live region that makes a message which appeared out of nowhere reach a screen reader at all.
- `priority` picks the live region. `high` interrupts whatever is being read and `low` waits for a pause. An error is worth interrupting for and a save confirmation is not.
- The × is deliberately not in the page's tab order and is hidden from the accessibility tree. A screen reader reaches a toast with **F6** and is given the close action there, rather than finding a stray button from a message that may already be gone.
- A toast pushed out by `limit` stays in the DOM so it can come back, and says nothing while it waits.
- The stack is `pointer-events-none` across its full width, so the strip along the top or the bottom of the page is not a wall the rest of the app is behind. The toasts themselves take their events back.

:::

::: fw flutter

- `priority` decides whether a toast is a live region. `high` is announced the moment it arrives and `low` waits until the reader reaches it. An error is worth interrupting for and a save confirmation is not. Flutter has one live-region flag rather than two politeness levels, so what the React build says with two `role`s this says with one switch.
- The pointer resting on the stack stops the clock, because a pointer resting on a toast is a reader reading it. It starts over when the pointer leaves, rather than resuming where it left off.
- A toast waiting behind `limit` has no clock at all: it is not being read, so its life has not started. It gets one when it reaches the screen.
- Nothing here is told to ignore the pointer, and nothing has to be: the strip is an `Align`, which hit-tests its child and not the room around it, so the page under the empty part of the strip is reached normally.
- The × and the action are ordinary focus stops on the toast itself.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `usePlToast()` | `PlToastProvider.of(context)` | Flutter's own way of reaching the thing above you. |
| `add`, `close`, `update`, `promise` | `show`, `close`, `update`, `showFuture` | The same four, in Dart's words. |
| `PlToastOptions` | `PlToast` | The message is the thing named after the component, because it is the thing a caller writes. |
| `timeout` in milliseconds | `Duration` | Dart's own type for a length of time. `Duration.zero` still means "until it is closed". |
| `icon: false` | `showIcon: false` | Dart has no value that is neither `null` nor a widget, so "take it away" gets its own name. |
| `priority: 'high' \| 'low'` | a live region, or not | Flutter has one live-region flag rather than two politeness levels. |
| a portal, and `pointer-events-none` | a layer inside the provider | The provider is already above everything it has to cover, so there is nothing to portal into, and an `Align` lets the pointer past without being told to. |
| swipe to dismiss, the F6 hotkey | — | Neither has a Flutter equivalent that is not a second gesture competing with the app's own. The × is always there. |
| timers pause and resume on hover | the clock starts over when the pointer leaves | A toast the reader has just finished reading deserves its full life back rather than the two seconds it had left. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
