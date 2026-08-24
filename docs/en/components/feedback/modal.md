---
title: PlModal
order: 2
---

# PlModal

<p class="plass-lede">A sheet that takes the page away until it is answered. The header and the actions stay put while only the body scrolls.</p>

<Demo src="modal/hero" :min-height="120" />

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

## Props

<PropsTable name="PlModal" />

Every native `<div>` attribute passes straight through to the sheet. `color`, `title` and `children` are excluded because all three are Plass props here.

There is no `variant`: the three materials answer "how much does this surface assert itself against the page around it", and a modal has already taken the page. There is no `elevation` either — a modal that could be told to sit flat on the page would be one that could be told to stop being a modal, so its shadow is fixed at the top of the ladder.

### PlModalClose

`PlModalClose` closes the modal it is inside. It exists because an uncontrolled modal has no `setOpen` for its Cancel button to call, and the alternative — making every modal controlled — is a piece of state per modal that exists only to answer a button.

```tsx
<PlModalClose render={<PlButton variant="ghost">Cancel</PlButton>} />
```

What the shared axes (`size` `color` `density`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### size

The width and the type scale move together, and their steps are further apart than the control ladder's because they answer a different question: not how big is this thing, but how long a line of text is comfortable inside it. `width` is the escape hatch for the modal whose content decides — a wide table, a narrow confirmation.

<Demo src="modal/sizes" :min-height="120">

<<< @/.vitepress/demos/modal/sizes.tsx

</Demo>

### dividers

Off by default. Turn it on the moment the body scrolls: the hairlines are what say the header stayed put rather than scrolling away with the content.

<Demo src="modal/dividers" :min-height="120">

<<< @/.vitepress/demos/modal/dividers.tsx

</Demo>

### Controlled

Pass `open` with `onOpenChange` when something other than the trigger has to open it, or when an action has work to do before it closes.

<Demo src="modal/controlled" :min-height="120">

<<< @/.vitepress/demos/modal/controlled.tsx

</Demo>

### dismissible

Off, <kbd>Esc</kbd> and a click outside both stop closing the modal. Pair it with `showClose={false}` only when the actions genuinely answer it — otherwise there is no way out at all.

<Demo src="modal/dismissible" :min-height="120">

<<< @/.vitepress/demos/modal/dismissible.tsx

</Demo>

## Accessibility

- Base UI owns everything hard about it: the focus trap, the scroll lock, restoring focus to the trigger when it closes, and marking the page behind inert.
- `title` becomes the `<h2>` that names the dialog and `description` its accessible description — both wired by Base UI, so no `aria-labelledby` is needed.
- <kbd>Esc</kbd> closes it unless `dismissible` is off; `modal="trap-focus"` keeps the page behind scrollable while still holding focus inside.
- The × is on by default, unlike most booleans in the library. A modal takes the page away until it is answered, and the visible way out should not have to be remembered.
- The sheet caps its own height and scrolls its body rather than growing past the viewport, so a tall modal never has its top pushed off the top of the screen where nothing can reach it.
- Opening and closing animate opacity only. A modal that scaled or slid in would drag its own text across the screen — and unlike a control, this one is full of text.
