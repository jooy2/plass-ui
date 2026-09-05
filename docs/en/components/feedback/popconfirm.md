---
title: PlPopconfirm
order: 15
---

# PlPopconfirm

<p class="plass-lede">A question asked where it was raised, rather than in the middle of the page. The row's own delete button, answered against the row.</p>

<Demo src="popconfirm/hero" :min-height="280" />

::: fw react

```tsx
import { PlPopconfirm } from 'plass-ui';

<PlPopconfirm
  title="Delete this row?"
  description="It cannot be undone."
  confirmLabel="Delete"
  onConfirm={() => remove(row)}
  trigger={<PlButton color="danger">Delete</PlButton>}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPopconfirm(
  open: asking,
  onOpenChanged: (bool next) => setState(() => asking = next),
  title: const Text('Delete this row?'),
  confirmLabel: const Text('Delete'),
  onConfirm: () => remove(row),
  trigger: PlButton(
    color: PlassColor.danger,
    onPressed: () => setState(() => asking = true),
    child: const Text('Delete'),
  ),
);
```

:::

## Props

<PropsTable name="PlPopconfirm" />

::: fw flutter

`open` is **controlled**, like everything stateful in this package. There is no uncontrolled form, and no `defaultOpen`. `onConfirm` returns a `FutureOr<void>`, which is the Dart shape of "a promise is waited for": a plain callback closes at once, a `Future` holds the question up until it completes.

The two buttons sit in a `Wrap` rather than a `Row`, so a translated pair of labels that does not fit the sheet stacks instead of overflowing.

:::

## Popconfirm or confirm dialog

What differs is **how much each one interrupts**.

|  |  |
| --- | --- |
| [`PlConfirmProvider`](./confirm) | Takes the page away. For the question that deserves that, deleting an account, discarding an hour's work |
| `PlPopconfirm` | Appears against the thing it is about. The rest of the table stays readable, and Escape puts the reader back exactly where they were |

The rule of thumb is what happens if they answer by accident. **If the answer is "they can undo it", this is the one.**

`color` defaults to `danger` here and to `primary` on a `PlButton`, and that is not an inconsistency: nobody reaches for a popconfirm to ask whether to save.

## Examples

### A confirm that takes time

`onConfirm` may return a promise. The button shows its loading state until it settles, and **the popup closes only if it resolves**. A failed request leaves the question on screen instead of pretending. Escape is ignored while it is running: a request in flight is not something to abandon halfway.

<Demo src="popconfirm/async" :min-height="180">

::: fw react

<<< @/.vitepress/demos/popconfirm/async.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popconfirm/async.dart

:::

</Demo>

> A rejection is caught and goes no further. Keeping the question up is the whole of what this component owes a failure; what the failure _means_ is yours, and `onConfirm` is where to report it from, a toast, usually.

### side and align

It opens above the trigger by default, which is where it is least likely to cover the next row down. `side` and `align` are [`PlPopover`](./popover)'s own.

```tsx
<PlPopconfirm side="right" align="start" … />
```

## Accessibility

- It is a [`PlPopover`](./popover), so the popup is a `role="dialog"` named by its `title` and described by its `description`, the focus moves into it, and it returns to the trigger when it closes.
- **The focus lands on the confirming button**, which is the other way round from `PlConfirmProvider` and is deliberate: a popconfirm is opened _by_ the button it is asking about, so the reader has already said what they want once. The modal is for the question that has to be argued with.
- There is no close button. The two answers are the two buttons, and a third way out that means neither would be a third answer to a question with two.
- Name the buttons for what they **do**. "Delete" and "Cancel", not "Yes" and "No".
