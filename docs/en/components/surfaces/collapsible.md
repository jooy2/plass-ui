---
title: PlCollapsible
order: 7
---

# PlCollapsible

<p class="plass-lede">One section that folds, standing on its own. The same fold a <code>PlAccordion</code> is a set of, with nothing else beside it — so what it needs is an <code>open</code> of its own rather than a place in somebody's list.</p>

<Demo src="collapsible/hero" :flutter="false" :min-height="200" />

::: fw react

```tsx
import { PlCollapsible } from 'plass-ui';

<PlCollapsible title="Advanced" subtitle="Nine settings">
  Everything the form does not need to ask on the first pass.
</PlCollapsible>;
```

:::

## Props

<PropsTable name="PlCollapsible" />

::: fw react

Every other `<div>` attribute passes through to the sheet.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Why it is not an accordion

A [`PlAccordion`](./accordion) is a **set**, and the set is the point: closing the last section as the next opens is what keeps the page from growing under the reader. A collapsible has nobody to coordinate with.

Reach for this for a "Show more" on a form, an optional block of settings, the details under a row. Reach for an accordion the moment there are two of them and only one should be open at a time.

## The panel is a window

The panel's height **is** animated, which looks like an exception to the [rule against moving things](../../design/design-language) and is not: nothing is transformed, no text is resampled, and the content does not shift relative to the panel it is in — the panel is a window opening onto it.

Content that appears instantly is a page that jumps, which is the failure the rule exists to prevent.

## Examples

### variant

The three materials, read as a _container's_: the sheet is never dyed, because a fold holds other people's content. `ghost` is the one to reach for inside running prose or inside a card — a bare "Show more" line owes the page no rectangle of its own.

<Demo src="collapsible/variants" :flutter="false" :min-height="360">

<<< @/.vitepress/demos/collapsible/variants.tsx

</Demo>

### The header's slots

`title`, `subtitle` and `startIcon` are the header. `action` is pinned to the end of it and sits **outside the trigger**, which is not a layout preference: a header that both folds and holds a switch has two things to press, and one of them cannot be nested inside the other.

The chevron is turned rather than moved, and it is the only thing on the header that reports the state by moving — which is why the header itself only changes colour.

<Demo src="collapsible/slots" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/collapsible/slots.tsx

</Demo>

### trigger

Replaces the header entirely with a control of your own. The element you pass **becomes** the trigger: it is handed the click handler, the open state and the pointer at the panel, so nothing has to be wired up.

`title` and the slots around it are for the far commoner case of wanting the header that is already there.

<Demo src="collapsible/trigger" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/collapsible/trigger.tsx

</Demo>

::: fw react

### hiddenUntilFound and keepMounted

A closed panel is not in the document, which is what makes an unopened fold cost nothing. Two props take that back, for two different reasons:

- `hiddenUntilFound` keeps it there as `hidden="until-found"`, so the browser's own page search can find the text inside a closed fold **and open it**. That is the one worth reaching for on a documentation page.
- `keepMounted` keeps it there outright, for content that is expensive to build or that holds form state which should survive being folded away.

`hiddenUntilFound` overrides `keepMounted`; it is the same idea with the browser's find-in-page bolted on.

:::

## Accessibility

- The header is a real `<button>` that reports whether the panel is open and points at the panel it opens. Base UI owns that wiring.
- `action` is outside the trigger, so it is its own focus stop rather than an element nested inside a button — which the browser would rewrite on parse.
- A disabled fold's trigger is a disabled button: out of the tab order, and the panel stays exactly as it was.

::: fw react

- With `hiddenUntilFound` the browser's find-in-page opens the fold it found the text in, rather than scrolling to nothing.

:::
