---
title: PlEmpty
order: 14
---

# PlEmpty

<p class="plass-lede">The place where there is nothing, an empty list, a search that found nothing, a flow that has finished. A mark, a line, a sentence, and a way out.</p>

<Demo src="empty/hero" :min-height="300" />

::: fw react

```tsx
import { PlEmpty } from 'plass-ui';

<PlEmpty
  icon={<InboxIcon />}
  title="No projects yet"
  description="Start one and it will show up here."
  actions={<PlButton>New project</PlButton>}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlEmpty(
  icon: const Icon(Icons.inbox),
  title: const Text('No projects yet'),
  description: const Text('Start one and it will show up here.'),
  actions: <Widget>[PlButton(onPressed: create, child: const Text('New project'))],
);
```

:::

## Props

<PropsTable name="PlEmpty" />

Every native `<div>` attribute passes straight through. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

::: fw flutter

`actions` is a `List<Widget>` laid out in a `Wrap`, rather than the single slot the React build takes. A Dart caller has no fragment to put two buttons in.

:::

## One component

An empty list, a search with no results, a request that failed and a flow that finished are the **same arrangement** (a mark, a line, a sentence, a way out), which is why they are one component. What tells them apart is `color`:

|  |  |
| --- | --- |
| `secondary` (the default) | Nothing here **yet**. Nothing has gone wrong |
| `danger` | Something has |
| `success` | You are done, which is the "your order is confirmed" screen, without a second component |

<Demo src="empty/kinds" :min-height="280">

::: fw react

<<< @/.vitepress/demos/empty/kinds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/kinds.dart

:::

</Demo>

## No surface of its own

An empty state is always **inside** something (a card, a table, a panel), and a sheet inside a sheet is two sheets. What this decides is the arrangement and the space around it.

<Demo src="empty/table" :min-height="280">

::: fw react

<<< @/.vitepress/demos/empty/table.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/table.dart

:::

</Demo>

`PlTable`'s `empty` prop takes a node, and this is the node it was waiting for.

## The action

The one thing worth getting right. A screen that says "No projects" and stops is a dead end; the same screen with a "New project" button is the best moment in the whole flow to offer one. The reader is looking straight at the space the thing would go in.

If there is genuinely nothing to do (a search with no results, where the action is "type something else") say that in the description rather than inventing a button.

## Accessibility

- The glyph is `aria-hidden`. The title says what it says, and a reader should not be told twice.
- It has **no role of its own**. Put `role="status"` on it when the emptiness is the _result_ of something the reader just did (clearing a filter, running a search), so the change is announced. Leave it off for a list that was empty when the page loaded, which has already been read.
- The title is a `<p>` rather than a heading. Where it belongs in a document's outline is the page's decision and not this component's; pass `render` on a `PlTypography` above it if it needs to be one.

::: fw flutter

The glyph is wrapped in an `ExcludeSemantics`, and there is no role: put the empty state inside a `Semantics(liveRegion: true)` when the emptiness is the _result_ of something the reader just did.

:::
