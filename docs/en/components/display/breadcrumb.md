---
title: PlBreadcrumb
order: 9
---

# PlBreadcrumb

<p class="plass-lede">The trail of pages above the one being read. The last step is where the reader already is, so it stops being a link on its own — and a trail too long to read folds its middle away behind a <code>…</code>.</p>

<Demo src="breadcrumb/hero" :min-height="120" />

```tsx
import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

<PlBreadcrumb>
  <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
  <PlBreadcrumbItem href="/settings">Settings</PlBreadcrumbItem>
  <PlBreadcrumbItem>Billing</PlBreadcrumbItem>
</PlBreadcrumb>;
```

## Props

<PropsTable name="PlBreadcrumb" />

Every native `<nav>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

There is no `variant` and no `elevation`: a trail is a line of text above the page, not a surface laid on it.

### PlBreadcrumbItem

<PropsTable name="PlBreadcrumbItem" />

Every native `<li>` attribute passes straight through, onto the `<li>` rather than onto the link inside it. `size` is inherited from the `PlBreadcrumb` around it — a step that disagreed with its neighbours about the type scale would be a trail with a hole in it.

What the shared axes (`size` `color` `density`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### The current step

The last step is the page you are on, so it is not a link at all: it carries `aria-current="page"` and stops being pressable, even with an `href`. The component works that out rather than asking every caller to remember it.

Exactly one element in a trail may carry the mark, so a step that claims it with `current` takes it off the last one. Doing that by hand would mean writing `current={false}` on a step that never asked for it.

<Demo src="breadcrumb/current" :min-height="200">

<<< @/.vitepress/demos/breadcrumb/current.tsx

</Demo>

### separator

Four named marks rather than a free-for-all, because a separator is read hundreds of times a day and the difference between them is meaning, not decoration: a `chevron` and an `arrow` say "and then", a `slash` says "path", a `dot` says "these are peers of one thing". Anything else can still be passed as a node.

The two that point are drawn once and turned, and they turn back under RTL — a trail runs the way the language does.

<Demo src="breadcrumb/separators" :min-height="260">

<<< @/.vitepress/demos/breadcrumb/separators.tsx

</Demo>

### maxItems

A trail seven levels deep is a trail nobody reads, so the middle collapses to a `…` that puts it back when pressed. `itemsBeforeCollapse` and `itemsAfterCollapse` decide how much stays at each end, and `expandable={false}` leaves the fold as a plain mark.

The fold only happens when it actually removes something: on a three-step trail with one kept at each end, the `…` would stand in for exactly one step, which is longer than the step it replaced.

<Demo src="breadcrumb/collapse" :min-height="160">

<<< @/.vitepress/demos/breadcrumb/collapse.tsx

</Demo>

### structuredData

Correct markup alone is not what puts a path under a search result — the structured data is. `structuredData` emits the trail a second time as a `schema.org` `BreadcrumbList`, beside the `<ol>` rather than instead of it.

It is off by default, because a page can only have one of these and a great many apps already emit theirs from an SEO layer of their own. Turn it on where this component _is_ the trail.

```tsx
<PlBreadcrumb structuredData baseUrl="https://example.com">
  <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
  <PlBreadcrumbItem href="/docs">Docs</PlBreadcrumbItem>
  <PlBreadcrumbItem>Breadcrumb</PlBreadcrumbItem>
</PlBreadcrumb>
```

Every step goes in, including the ones a `maxItems` fold is hiding: what is collapsed is a matter of how much room the row has, and the path is the path either way. `baseUrl` is what makes the URLs absolute, which is what a crawler wants.

### size

<Demo src="breadcrumb/sizes" :min-height="220">

<<< @/.vitepress/demos/breadcrumb/sizes.tsx

</Demo>

## Accessibility

- The trail is a `<nav>` with an accessible name, holding an `<ol>` — the order is the meaning, so it is an ordered list.
- `role="list"` is written out because Tailwind's reset takes the bullets off every `<ol>`, and Safari takes the list semantics off with them.
- The current step carries `aria-current="page"` rather than `"true"`. A trail is navigation, and the step the reader is on is a _page_, not the chosen one of a set of options.
- The separators are `aria-hidden`: a screen reader reading "greater-than" between every step is reading the punctuation.
- A step with only an `onClick` is a real `<button>`, and one with an `href` a real `<a>`. Neither is a `<span>` with a handler on it.
