---
title: PlCollapsible
order: 7
---

# PlCollapsible

<p class="plass-lede">One section that folds, standing on its own. The same fold a <code>PlAccordion</code> is a set of, with nothing else beside it, so what it needs is an <code>open</code> of its own rather than a place in somebody's list.</p>

<Demo src="collapsible/hero" :min-height="200" />

::: fw react

```tsx
import { PlCollapsible } from 'plass-ui';

<PlCollapsible title="Advanced" subtitle="Nine settings">
  Everything the form does not need to ask on the first pass.
</PlCollapsible>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCollapsible(
  open: showing,
  onOpenChanged: (bool next) => setState(() => showing = next),
  title: const Text('Advanced'),
  subtitle: const Text('Nine settings'),
  child: const Text('Everything the form does not need to ask on the first pass.'),
);
```

:::

## Props

<PropsTable name="PlCollapsible" />

::: fw react

Every other `<div>` attribute passes through to the sheet.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## PlCollapsible or PlAccordion

A [`PlAccordion`](./accordion) is a **set**, and the set is the point: closing the last section as the next opens is what keeps the page from growing under the reader. A collapsible has nobody to coordinate with.

Reach for this for a "Show more" on a form, an optional block of settings, the details under a row. Reach for an accordion the moment there are two of them and only one should be open at a time.

## How the panel opens

The panel's height **is** animated, which looks like an exception to the [rule against moving things](../../design/design-language) and is not: nothing is transformed, no text is resampled, and the content does not shift relative to the panel it is in. The panel is a window opening onto it.

Content that appears instantly is a page that jumps, which is the failure the rule exists to prevent.

## Examples

### variant

The three materials, read as a _container's_: the sheet is never dyed, because a fold holds other people's content. `ghost` is the one to use inside running prose or inside a card, a bare "Show more" line owes the page no rectangle of its own.

<Demo src="collapsible/variants" :min-height="360">

::: fw react

<<< @/.vitepress/demos/collapsible/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/variants.dart

:::

</Demo>

### The header's slots

`title`, `subtitle` and `startIcon` are the header. `action` is pinned to the end of it and sits **outside the trigger**, which is not a layout preference: a header that both folds and holds a switch has two things to press, and one of them cannot be nested inside the other.

The chevron is turned rather than moved, and it is the only thing on the header that reports the state by moving, which is why the header itself only changes colour.

<Demo src="collapsible/slots" :min-height="220">

::: fw react

<<< @/.vitepress/demos/collapsible/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/slots.dart

:::

</Demo>

### trigger

Replaces the header entirely with a control of your own.

`title` and the slots around it are for the far commoner case of wanting the header that is already there.

::: fw react

The element you pass **becomes** the trigger: it is handed the click handler, `aria-expanded` and the `aria-controls` pointing at the panel, so nothing has to be wired up.

:::

::: fw flutter

`triggerBuilder` is a **builder** rather than a widget, and that is forced: a React element can be cloned with new props, and a Dart widget cannot be handed a tap handler after it was made. So the builder is given the open state and the callback and wires up whatever it likes.

:::

<Demo src="collapsible/trigger" :min-height="200">

::: fw react

<<< @/.vitepress/demos/collapsible/trigger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/trigger.dart

:::

</Demo>

::: fw react

### hiddenUntilFound and keepMounted

A closed panel is not in the document, which is what makes an unopened fold cost nothing. Two props take that back, for two different reasons:

- `hiddenUntilFound` keeps it there as `hidden="until-found"`, so the browser's own page search can find the text inside a closed fold **and open it**. That is the one worth using on a documentation page.
- `keepMounted` keeps it there outright, for content that is expensive to build or that holds form state which should survive being folded away.

`hiddenUntilFound` overrides `keepMounted`; it is the same idea with the browser's find-in-page bolted on.

:::

## Accessibility

- The header is announced as a button, reports whether the panel is open, and answers a press from the keyboard as readily as from a pointer.
- `action` is outside the trigger, so it is its own focus stop rather than a control nested inside another one.
- A disabled fold's trigger is out of the focus order, and the panel stays exactly as it was.

::: fw react

- The header is a real `<button>` and Base UI owns the `aria-expanded` / `aria-controls` wiring between it and the panel.
- With `hiddenUntilFound` the browser's find-in-page opens the fold it found the text in, rather than scrolling to nothing.

:::

::: fw flutter

- With `keepMounted` the closed panel is clipped to nothing **and** taken out of the focus order and off the semantics tree: a panel nobody can see is not one a keyboard should be able to tab into.

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter's own controls are controlled, and so is every stateful widget in this package. |
| `trigger`, an element | `triggerBuilder`, a builder | A React element can be cloned with new props; a Dart widget cannot be handed a tap handler after it was made. The builder gets the state and the callback instead. |
| `hiddenUntilFound` | — | There is no browser find-in-page to open a fold from. |
| `keepMounted` keeps a hidden panel in the DOM | `keepMounted` keeps it in the tree | The same idea and a sharper reason: a Flutter `State` goes with its widget when it leaves the tree, so a folded-away field forgets what was typed into it. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
