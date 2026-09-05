---
title: PlBreadcrumb
order: 9
---

# PlBreadcrumb

<p class="plass-lede">The trail of pages above the one being read. The last step is where the reader already is, so it stops being a link on its own, and a trail too long to read folds its middle away behind a <code>…</code>.</p>

<Demo src="breadcrumb/hero" :min-height="120" />

::: fw react

```tsx
import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

<PlBreadcrumb>
  <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
  <PlBreadcrumbItem href="/settings">Settings</PlBreadcrumbItem>
  <PlBreadcrumbItem>Billing</PlBreadcrumbItem>
</PlBreadcrumb>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBreadcrumb(
  items: <PlBreadcrumbItem>[
    PlBreadcrumbItem(label: const Text('Home'), onPressed: goHome),
    PlBreadcrumbItem(label: const Text('Settings'), onPressed: goSettings),
    const PlBreadcrumbItem(label: Text('Billing')),
  ],
);
```

:::

## Props

<PropsTable name="PlBreadcrumb" />

::: fw react

Every native `<nav>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

:::

::: fw flutter

The steps are `items` rather than children, and a `PlBreadcrumbItem` is a **description rather than a widget**, Flutter's own idiom, the one `DataColumn` and `BottomNavigationBarItem` use. The reason is that the trail has to _reason_ about its steps: which one is the current page, how many there are, and which ones a fold takes out. A `Widget` is opaque and none of those questions can be asked of one.

:::

There is no `variant` and no `elevation`: a trail is a line of text above the page, not a surface laid on it.

### PlBreadcrumbItem

<PropsTable name="PlBreadcrumbItem" />

::: fw react

Every native `<li>` attribute passes straight through, onto the `<li>` rather than onto the link inside it. `size` is inherited from the `PlBreadcrumb` around it, a step that disagreed with its neighbours about the type scale would be a trail with a hole in it.

:::

::: fw flutter

A step carries no `size` of its own. The trail sets the type scale for all of them, a step that disagreed with its neighbours about it would be a trail with a hole in it.

:::

What the shared axes (`size` `color` `density`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### The current step

The last step is the page you are on, so it is not a link at all: it is announced as where the reader is and stops being pressable, even with something to press. The component works that out rather than asking every caller to remember it.

Exactly one step in a trail may carry the mark, so a step that claims it with `current` takes it off the last one. Doing that by hand would mean writing <Fw react="current={false}" flutter="current: false" code /> on a step that never asked for it.

<Demo src="breadcrumb/current" :min-height="200">

::: fw react

<<< @/.vitepress/demos/breadcrumb/current.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/current.dart

:::

</Demo>

### separator

Four named marks rather than a free-for-all, because a separator is read hundreds of times a day and the difference between them is meaning, not decoration: a `chevron` and an `arrow` say "and then", a `slash` says "path", a `dot` says "these are peers of one thing". Anything else can still be passed as a node.

The two that point are drawn once and turned, and they turn back under RTL. A trail runs the way the language does. Anything else goes in <Fw react="separator" flutter="separatorWidget" code />.

<Demo src="breadcrumb/separators" :min-height="260">

::: fw react

<<< @/.vitepress/demos/breadcrumb/separators.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/separators.dart

:::

</Demo>

### maxItems

A trail seven levels deep is a trail nobody reads, so the middle collapses to a `…` that puts it back when pressed. `itemsBeforeCollapse` and `itemsAfterCollapse` decide how much stays at each end, and <Fw react="expandable={false}" flutter="expandable: false" code /> leaves the fold as a plain mark.

The fold only happens when it actually removes something: on a three-step trail with one kept at each end, the `…` would stand in for exactly one step, which is longer than the step it replaced.

<Demo src="breadcrumb/collapse" :min-height="160">

::: fw react

<<< @/.vitepress/demos/breadcrumb/collapse.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/collapse.dart

:::

</Demo>

::: fw react

### structuredData

Correct markup alone is not what puts a path under a search result. The structured data is. `structuredData` emits the trail a second time as a `schema.org` `BreadcrumbList`, beside the `<ol>` rather than instead of it.

It is off by default, because a page can only have one of these and a great many apps already emit theirs from an SEO layer of their own. Turn it on where this component _is_ the trail.

```tsx
<PlBreadcrumb structuredData baseUrl="https://example.com">
  <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
  <PlBreadcrumbItem href="/docs">Docs</PlBreadcrumbItem>
  <PlBreadcrumbItem>Breadcrumb</PlBreadcrumbItem>
</PlBreadcrumb>
```

Every step goes in, including the ones a `maxItems` fold is hiding: what is collapsed is a matter of how much room the row has, and the path is the path either way. `baseUrl` is what makes the URLs absolute, which is what a crawler wants.

:::

### size

<Demo src="breadcrumb/sizes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/breadcrumb/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- The trail is a `<nav>` with an accessible name, holding an `<ol>`. The order is the meaning, so it is an ordered list.
- `role="list"` is written out because Tailwind's reset takes the bullets off every `<ol>`, and Safari takes the list semantics off with them.
- The current step carries `aria-current="page"` rather than `"true"`. A trail is navigation, and the step the reader is on is a _page_, not the chosen one of a set of options.
- The separators are `aria-hidden`: a screen reader reading "greater-than" between every step is reading the punctuation.
- A step with only an `onClick` is a real `<button>`, and one with an `href` a real `<a>`. Neither is a `<span>` with a handler on it.

:::

::: fw flutter

- The trail is a named group, and `label` is that name.
- A step that goes somewhere is announced as a **link**, which is what puts it in a screen reader's list of links. <kbd>Enter</kbd> follows it; <kbd>Space</kbd> deliberately does not.
- The current step is announced as a heading rather than as a link. It is where the reader is, not somewhere to go.
- The separators are excluded from semantics: a screen reader reading "greater-than" between every step is reading the punctuation.
- The `…` is a real focus stop with a name of its own, so a folded trail can be opened from a keyboard.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlBreadcrumbItem>` children | `items`, as descriptions | The trail has to reason about its steps, which is current, how many there are, which the fold takes out. A `Widget` is opaque; a description is not. |
| `href` | `onPressed` | Flutter has no link element. A step that navigates calls your router. |
| `aria-current="page"` | announced as a heading | Flutter's semantics tree has no `current`. A heading is the nearest true thing: this is the place, not a way to it. |
| `structuredData`, `baseUrl` | — | There is no crawler reading a Flutter app, and no `<script type="application/ld+json">` to put a `BreadcrumbList` in. |
| `separator` as name-or-node | `separator` and `separatorWidget` | Dart has no union type, so the named marks and a mark of your own are two parameters. |
| `children` on a step | `label` | It is the one slot, and naming it is what lets a step be a description. |

:::
