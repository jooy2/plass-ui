---
title: PlConfirmProvider
order: 13
---

# PlConfirmProvider

<p class="plass-lede">One dialog, asked for from anywhere under it. <code>await confirm(…)</code> returns the answer, so the branch after a question stays in the handler that asked it.</p>

<Demo src="confirm/hero" :min-height="220" />

::: fw react

```tsx
import { PlConfirmProvider, usePlConfirm } from 'plass-ui';

// once, near the root
<PlConfirmProvider>
  <App />
</PlConfirmProvider>;

// anywhere under it
const { confirm } = usePlConfirm();

if (await confirm({ title: 'Delete this project?', color: 'danger' })) {
  await remove(project);
}
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

// once, near the root
PlConfirmProvider(child: MyApp());

// anywhere under it
if (await PlConfirmProvider.of(context).confirm(
  const PlConfirmOptions(title: Text('Delete this project?'), color: PlassColor.danger),
)) {
  await remove(project);
}
```

:::

## Props

<PropsTable name="PlConfirmProvider" />

The provider's props are defaults for every question asked under it. A single call can override any of them, see `PlConfirmOptions` below.

### PlConfirmOptions

<PropsTable name="PlConfirmOptions" />

::: fw flutter

`PlConfirmProvider.of(context)` rather than a hook, the same lookup `PlToastProvider` offers, and the framework's own shape for this. It **asserts** outside a provider rather than returning `null`, for the reason the React build throws.

`initialFocus` takes a `PlConfirmFocus` rather than a string. There is no `dismissible: false` equivalent to worry about: a press outside and the × both report through the same path.

:::

## The hook form

The thing a caller has at the moment a question is warranted is a **click handler**, not a place in the tree. Without this, the same delete button needs a piece of state, a `<PlModal>` kept mounted beside it, and the work after the answer torn in half across a callback, three edits to add a confirmation to one button, repeated at every button that needs one.

It is [`PlToastProvider`](./toast)'s arrangement for the same reason and with the same trade: one component near the root, and a hook everywhere else.

## Examples

### alert

One button and no answer. It resolves when the message has been acknowledged, which is what makes it awaitable in the middle of a sequence.

<Demo src="confirm/alert" :min-height="160">

::: fw react

<<< @/.vitepress/demos/confirm/alert.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/confirm/alert.dart

:::

</Demo>

### initialFocus

**Cancel holds the focus by default**, and that is the decision worth stating: a confirm dialog exists to make somebody stop, and an Enter key that lands on the destructive action defeats the whole thing.

Move it for a question whose yes is the harmless answer, "Save before closing?", where making somebody reach for the mouse to agree is its own kind of rude.

<Demo src="confirm/focus" :min-height="160">

::: fw react

<<< @/.vitepress/demos/confirm/focus.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/confirm/focus.dart

:::

</Demo>

### One vocabulary for the application

```tsx
<PlConfirmProvider confirmLabel="확인" cancelLabel="취소" acknowledgeLabel="확인">
  <App />
</PlConfirmProvider>
```

### A question that has to be answered

```tsx
await confirm({
  title: 'Your changes have not been saved.',
  confirmLabel: 'Discard',
  cancelLabel: 'Go back',
  dismissible: false
});
```

`dismissible` is on by default, because Escape is the universal "no" and a question that cannot be escaped is a trap. Turn it off for the one that genuinely has to be answered, and mean it.

## Notes

- **Questions asked while one is open are queued**, in the order they were asked, and the dialog's content changes rather than the sheet closing and reopening. The alternative is a promise nobody ever resolves, which is a hung button rather than a visible bug.
- A provider that unmounts with questions outstanding **resolves them all with `false`**. A promise that is never settled is a handler that never runs its `finally`, so a route change would otherwise leave a button spinning for the rest of the session.
- `usePlConfirm` **throws** outside a provider rather than resolving `false`. A silent `false` is a delete button that quietly does nothing, which is worse than a missing provider, since that fails on the first press.
- Escape and a click outside answer **no**, never yes.

## Accessibility

- It is a real modal dialog: the focus is trapped inside it, the page behind is inert, and the focus returns to whatever opened it.
- `title` is the `<h2>` that names the dialog and `description` is its accessible description, so a screen reader reads the question and the consequence before either button.
- The two buttons are named by their labels. Name them for what they **do** ("Delete", "Discard", "Save") rather than "Yes" and "No", which are unreadable out of context and are exactly what a screen reader reads out of context.
