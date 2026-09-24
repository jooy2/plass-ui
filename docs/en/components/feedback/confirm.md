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

// once, inside the app, under an Overlay of its own
WidgetsApp(
  // …
  builder: (BuildContext context, Widget? child) =>
      Overlay.wrap(child: PlConfirmProvider(child: child!)),
);

// anywhere under it
if (await PlConfirmProvider.of(context).confirm(
  const PlConfirmOptions(title: Text('Delete this project?'), color: PlassColor.danger),
)) {
  await remove(project);
}
```

The provider goes inside the app rather than around it, because around the app there is no `Directionality` yet. In `builder` it sits above the navigator and the navigator's `Overlay`, so it needs one of its own, or `confirm` fails with "No Overlay widget found". [Getting started](../../guide/getting-started#the-one-provider-you-may-need) has the rest.

:::

## Props

<PropsTable name="PlConfirmProvider" />

The provider's props are defaults for every question asked under it. A single call can override any of them, see `PlConfirmOptions` below.

- The provider goes once near the root, and <Fw react="`usePlConfirm`" flutter="`PlConfirmProvider.of(context)`" /> reaches it from any handler under it, the arrangement [`PlToastProvider`](./toast) has.
- **Questions asked while one is open are queued**, in the order they were asked. The dialog's content changes rather than the sheet closing and reopening, and each question places the focus by its own `initialFocus`.
- A provider that unmounts with questions outstanding **answers them all with `false`**.
- Outside a provider, <Fw react="`usePlConfirm` throws" flutter="`PlConfirmProvider.of` asserts" /> rather than answering `false`.
- Escape and a press outside answer **no**, never yes. An `alert`, which has no Cancel, closes on either of them too and completes as its button would.
- The sheet draws no ×. A question is answered by its own buttons, and while it is `dismissible` by Escape and a press outside as well.

[Prop conventions](../../design/prop-conventions#asking-from-a-handler) has the reasons for these rules.

### PlConfirmOptions

<PropsTable name="PlConfirmOptions" />

::: fw flutter

`PlConfirmProvider.of(context)` rather than a hook, the same lookup `PlToastProvider` offers, and the framework's own shape for this.

`initialFocus` takes a `PlConfirmFocus` rather than a string.

:::

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

### confirmLabel · cancelLabel · acknowledgeLabel

The words on the buttons, set once on the provider for the whole application and overridden by a single question when it needs its own.

::: fw react

```tsx
<PlConfirmProvider confirmLabel="확인" cancelLabel="취소" acknowledgeLabel="확인">
  <App />
</PlConfirmProvider>
```

:::

::: fw flutter

```dart
PlConfirmProvider(
  confirmLabel: const Text('확인'),
  cancelLabel: const Text('취소'),
  acknowledgeLabel: const Text('확인'),
  child: child!,
);
```

:::

### dismissible

On by default, so Escape and a press outside answer no. Turn it off for the one question that genuinely has to be answered, and give its buttons words that say what each of them does.

::: fw react

```tsx
await confirm({
  title: 'Your changes have not been saved.',
  confirmLabel: 'Discard',
  cancelLabel: 'Go back',
  dismissible: false
});
```

:::

::: fw flutter

```dart
await PlConfirmProvider.of(context).confirm(
  const PlConfirmOptions(
    title: Text('Your changes have not been saved.'),
    confirmLabel: Text('Discard'),
    cancelLabel: Text('Go back'),
    dismissible: false,
  ),
);
```

:::

## Accessibility

- It is a real modal dialog: the focus is trapped inside it, the page behind is inert, and the focus returns to whatever opened it.
- `title` is the `<h2>` that names the dialog and `description` is its accessible description, so a screen reader reads the question and the consequence before either button.
- The two buttons are named by their labels. Name them for what they **do** ("Delete", "Discard", "Save") rather than "Yes" and "No", which are unreadable out of context and are exactly what a screen reader reads out of context.
