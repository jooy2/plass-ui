---
title: PlModal
order: 2
---

# PlModal

<p class="plass-lede">A sheet that takes the page away until it is answered. The header and the actions stay put while only the body scrolls.</p>

<Demo src="modal/hero" :min-height="120" />

::: fw react

```tsx
import { PlButton, PlModal, PlModalClose } from 'plass-ui';

<PlModal
  trigger={<PlButton color="danger">Delete project</PlButton>}
  title="Delete “Aurora”?"
  description="Everything in it goes with it."
  actions={<PlModalClose render={<PlButton color="danger">Delete</PlButton>} />}
>
  <PlTextField label="Type the project name to confirm" />
</PlModal>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlModal(
  open: deleting,
  onOpenChanged: (bool next) => setState(() => deleting = next),
  title: const Text('Delete “Aurora”?'),
  description: const Text('Everything in it goes with it.'),
  actions: <Widget>[
    PlButton(color: PlassColor.danger, onPressed: destroy, child: const Text('Delete')),
  ],
  child: PlTextField(
    controller: name,
    label: const Text('Type the project name to confirm'),
  ),
);
```

A modal lifts itself out of the tree, so it needs an `Overlay` above it — `WidgetsApp` with a navigator and `MaterialApp` both provide one. Where it is _written_ does not matter, and it takes up no room there.

:::

## Props

<PropsTable name="PlModal" />

::: fw react

Every native `<div>` attribute passes straight through to the sheet. `color`, `title` and `children` are excluded because all three are Plass props here.

:::

::: fw flutter

**Controlled**, like every other stateful thing in the package: the × and a press outside both call `onOpenChanged` rather than closing the modal themselves. There is no `trigger` and no `PlModalClose` — with the open state already in the caller's hands, a button that closes the modal is a button that sets it to `false`.

`actions` is a `List<Widget>` rather than one widget, so a pair of buttons needs no row of its own.

:::

There is no `variant`: the three materials answer "how much does this surface assert itself against the page around it", and a modal has already taken the page. There is no `elevation` either — a modal that could be told to sit flat on the page would be one that could be told to stop being a modal, so its shadow is fixed at the top of the ladder.

::: fw react

### PlModalClose

`PlModalClose` closes the modal it is inside. It exists because an uncontrolled modal has no `setOpen` for its Cancel button to call, and the alternative — making every modal controlled — is a piece of state per modal that exists only to answer a button.

```tsx
<PlModalClose render={<PlButton variant="ghost">Cancel</PlButton>} />
```

:::

What the shared axes (`size` `color` `density`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### size

The width and the type scale move together, and their steps are further apart than the control ladder's because they answer a different question: not how big is this thing, but how long a line of text is comfortable inside it. `width` is the escape hatch for the modal whose content decides — a wide table, a narrow confirmation.

<Demo src="modal/sizes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/modal/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/modal/sizes.dart

:::

</Demo>

### dividers

Off by default. Turn it on the moment the body scrolls: the hairlines are what say the header stayed put rather than scrolling away with the content.

<Demo src="modal/dividers" :min-height="120">

::: fw react

<<< @/.vitepress/demos/modal/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/modal/dividers.dart

:::

</Demo>

### Controlled

<Fw react="Pass `open` with `onOpenChange` when something other than the trigger has to open it, or when an action has work to do before it closes." flutter="This is the only mode: `open` with `onOpenChanged`, which is also what lets an action do its work before the sheet goes." />

<Demo src="modal/controlled" :min-height="120">

::: fw react

<<< @/.vitepress/demos/modal/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/modal/controlled.dart

:::

</Demo>

### dismissible

Off, <kbd>Esc</kbd> and a click outside both stop closing the modal. Pair it with `showClose={false}` only when the actions genuinely answer it — otherwise there is no way out at all.

<Demo src="modal/dismissible" :min-height="120">

::: fw react

<<< @/.vitepress/demos/modal/dismissible.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/modal/dismissible.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI owns everything hard about it: the focus trap, the scroll lock, restoring focus to the trigger when it closes, and marking the page behind inert.
- `title` becomes the `<h2>` that names the dialog and `description` its accessible description — both wired by Base UI, so no `aria-labelledby` is needed.
- <kbd>Esc</kbd> closes it unless `dismissible` is off; `modal="trap-focus"` keeps the page behind scrollable while still holding focus inside.
- The × is on by default, unlike most booleans in the library. A modal takes the page away until it is answered, and the visible way out should not have to be remembered.
- The sheet caps its own height and scrolls its body rather than growing past the viewport, so a tall modal never has its top pushed off the top of the screen where nothing can reach it.
- Opening and closing animate opacity only. A modal that scaled or slid in would drag its own text across the screen — and unlike a control, this one is full of text.

:::

::: fw flutter

- Focus goes in and stays in: the sheet is its own focus scope, and traversal is bounded by the nearest scope, so <kbd>Tab</kbd> cannot land on the page under it. When the modal closes, focus goes back to whatever had it — the button that opened it.
- The layer names a route, which is how a screen reader knows the screen changed, and `title` is announced as a heading rather than read as the first line of the body.
- <kbd>Escape</kbd> closes it unless `dismissible` is off; `modal: false` keeps the page behind clickable while still holding focus inside.
- The × is on by default, unlike most of the switches in the library. A modal takes the page away until it is answered, and the visible way out should not have to be remembered.
- Only the body scrolls, and it is the only section allowed to give way when the sheet runs out of screen — a header that scrolled away would take the modal's name with it.
- Opening and closing animate opacity only. A modal that scaled or slid in would drag its own text across the screen — and unlike a control, this one is full of text. With animations turned off at the OS it appears at once.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter's own controls are controlled, and its name for the callback. |
| `trigger` | — | With the open state already in the caller's hands, the thing that opens a modal is an ordinary button that sets it to `true`. |
| `PlModalClose` | — | It exists in React to give an _uncontrolled_ modal a way to close. There is no uncontrolled modal here. |
| `actions`, one node | `actions`, a `List<Widget>` | Dart has no fragment, and a list is the thing a fragment was standing in for. |
| `modal={true \| 'trap-focus'}` | `modal: bool` | The two values were "does the pointer get through" — a boolean says that in Flutter's words. |
| `fullScreen` | `fullScreen` | Same, except that "the viewport" is the `Overlay` the sheet is lifted into. |
| `width: number \| string` | `width: double` | Logical pixels. There is no CSS length to accept. |
| `title` as an `<h2>`, `aria-describedby` | a heading, and a named route | Flutter names the state on the node itself; there is no id to point at. |
| the scroll lock, the inert page | the barrier | There is no document to lock, and a page behind an opaque barrier is not reachable by pointer. |
| `children` | `child` | Flutter's name. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
