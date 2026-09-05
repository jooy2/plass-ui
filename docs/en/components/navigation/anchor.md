---
title: PlAnchor
order: 9
---

# PlAnchor

<p class="plass-lede">A table of contents that follows the reader down the page. What is lit is the last heading whose top has passed the reading line, not whichever heading happens to be on screen.</p>

<Demo src="anchor/hero" :min-height="340" />

::: fw react

```tsx
import { PlAnchor } from 'plass-ui';

<PlAnchor
  label="On this page"
  offset={64}
  items={[
    { href: '#overview', label: 'Overview' },
    { href: '#install', label: 'Install' },
    { href: '#options', label: 'Options', depth: 1 }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnchor(
  controller: _scroll,
  label: const Text('On this page'),
  items: <PlAnchorItem>[
    PlAnchorItem(target: _overview, label: const Text('Overview')),
    PlAnchorItem(target: _install, label: const Text('Install')),
    PlAnchorItem(target: _options, label: const Text('Options'), depth: 1),
  ],
);
```

:::

## Props

<PropsTable name="PlAnchor" />

### PlAnchorItem

<PropsTable name="PlAnchorItem" />

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Tracking

Anyone can draw a list of links. What is worth writing once is deciding **which one is lit**, and the rule is not the obvious one.

> The lit row is the last heading whose top has **passed the reading line**.

Not "the heading that is visible": three headings can be on screen at once, and the one a reader is inside is the highest of them that is already above them. That is why the tracking is a measurement rather than an `IntersectionObserver`. An observer answers "is it visible", and the question here is "which one did I pass last".

Two ends need saying separately, and both are the kind of thing a hand-rolled version gets wrong:

- **Above the first heading nothing is lit.** The reader has not reached a section yet, and lighting the first row before they arrive is a claim about where they are.
- **At the very bottom the last row is lit**, whatever the measurement says. A short final section never reaches the line, so a list without this goes dead exactly where a reader is looking for it.

## offset

Where the reading line sits, measured down from the top of the viewport: the height of whatever is pinned over the page.

Without it a heading goes on counting as the **next** one after it has already slid out of sight behind a sticky header, so the list sits a section behind the reader for the whole height of the bar.

```tsx
<PlAnchor offset={64} items={items} />
```

::: fw react

`scroll-margin-top` on the headings is the other half of the same number, and it is the page's to set: it is what stops a heading landing underneath the header when the browser jumps to it.

```css
:target {
  scroll-margin-top: 64px;
}
```

:::

## The items array

The headings arrive as an **array**, which is the opposite of most of this library. A table of contents is generated, from a Markdown file, from a CMS, from the document's own headings, and the thing that generates it produces a flat list, in document order, with a level on each entry.

**It stays flat.** A nested list would have to be built from that flat one, and real documents skip levels, so the nesting would be a guess at a shape nobody wrote. The depth is carried by the indent; the reading order is the document's own.

::: fw react

An item points at a fragment: `href: '#install'`, and the `id` it names is what the list measures. A heading with no `id` cannot be tracked, and is skipped rather than throwing.

:::

::: fw flutter

An item points at a `GlobalKey` on the heading itself, because a Flutter screen has no URL to point into. What is tracked is a render object's position, and a key is the only handle on one. Pressing a row calls `Scrollable.ensureVisible`.

:::

## Examples

### Driven by something else

`active` takes the tracking over, for a list whose sections are separate pages rather than parts of one.

```tsx
<PlAnchor items={items} active={route.hash} />
```

### Beside the content

The ordinary arrangement: a sticky column that does not scroll with the page.

```tsx
<PlFlex spacing={8} alignItems="start">
  <article>…</article>
  <PlAnchor className="sticky top-20 w-56" items={items} offset={64} />
</PlFlex>
```

## Notes

- It measures once per frame at most. Scroll fires far more often than a page paints, and the answer cannot change between two paints.
- A row is truncated rather than wrapped. A table of contents is scanned, not read, and a two-line entry breaks the rhythm that makes scanning work.

## Accessibility

::: fw react

- It is a `<nav>` with a name, so it is not one more unnamed navigation landmark in a page's list of them. `navLabel` sets that name.
- The lit row carries `aria-current="location"`, where the reader is **within** the document, which is the one thing that value exists for. Not `page`, which is for the current page in a set of them.
- The rows are real links with real fragments, so they can be opened in a new tab, copied, and followed with JavaScript off.

:::

::: fw flutter

- The list is a named container, and the lit row is marked `selected`, the Dart equivalent of `aria-current="location"`.

:::

- The colour is not the only thing carrying the position: the lit row also takes a rule down its leading edge and a heavier weight.
