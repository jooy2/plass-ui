---
title: PlPortal
order: 13
---

# PlPortal

<p class="plass-lede">Children, rendered somewhere else in the document. <code>createPortal</code> with the class every portalled surface in this library carries, a container that can be a ref, and a server render that is correctly nothing.</p>

<Demo src="portal/hero" :min-height="240" :flutter="false" />

::: fw react

```tsx
import { PlPortal } from 'plass-ui';

<PlPortal>
  <div className="fixed inset-x-4 bottom-4 z-(--plass-z-portal)">Nothing clips this.</div>
</PlPortal>;
```

:::

::: fw flutter

This one is React-only, and it is not an omission. What it works around is a DOM problem — an ancestor with `overflow: hidden`, a `z-index` that cannot be escaped from inside a stacking context — and Flutter has neither. A widget that has to be painted above the rest of the screen goes into the `Overlay`, which every Flutter app already has:

```dart
Overlay.of(context).insert(
  OverlayEntry(builder: (BuildContext context) => const Positioned(bottom: 16, child: Note())),
);
```

:::

## Props

<PropsTable name="PlPortal" />

Every native `<div>` attribute passes straight through. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## Why not `createPortal`

Reach for `createPortal` and three things are yours to remember. This component is those three, and the first is the only real reason it exists.

### It carries `plass-portal`

Every surface the library sends through a portal — a [modal](../feedback/modal), a [drawer](../feedback/drawer), a [menu](../navigation/menu), a [popover](../feedback/popover), a [tooltip](../feedback/tooltip), a [toast](../feedback/toast) — lands with that class on it. A portalled subtree leaves whatever element a host had scoped its CSS reset to, and the class is how that host finds it again. A caller's own portal without it is the one subtree on the page the reset misses.

It is a hook and not a style: the library declares nothing for it.

### It renders nothing until it has mounted

There is no `document` on a server, so the HTML that ships never contains a portalled subtree, and neither does the render that hydrates it.

That is not a limitation to work around — it is what a portal **is**. Anything that has to be in the server's HTML for a crawler, for a no-JavaScript reader, or for the first paint does not belong in one.

### `container` is resolved after mount

Which is what lets it be a **ref**. The element a portal targets is usually one React has not created yet at the moment the prop is being written, so a ref is `null` and a `getElementById` finds nothing — reading the prop during render would get the wrong answer every time.

<Demo src="portal/container" :min-height="260" :flutter="false">

::: fw react

<<< @/.vitepress/demos/portal/container.tsx

:::

</Demo>

An element and a `DocumentFragment` are taken as they are, a function is called, and anything that resolves to nothing falls back to `document.body` rather than dropping the children on the floor.

## What it does not carry

**The colour scheme.** The stylesheet answers to a `.dark` or a `[data-theme]` on any ancestor, and a portal to `document.body` has left every ancestor it had — so a subtree pinned to one theme goes back to the page's.

That is true of the library's own popups too, and the fix is the same for both: give `container` an element that is inside the theme.

```tsx
<div data-theme="dark" ref={host}>
  …<PlPortal container={host}>…</PlPortal>
</div>
```

**Nothing else.** React context crosses a portal, because the tree it is read from is the React one and not the DOM one. A [`PlassProvider`](../../guide/defaults) above the portal still decides `size`, `color`, `density` and `locale` for everything inside it.

## Examples

### Escaping a clipping ancestor

The ordinary case, and the one worth naming: an ancestor with `overflow: hidden`, or a `transform` that turned a subtree into a containing block for `position: fixed`. Neither can be escaped from the inside at any `z-index`.

```tsx
<div className="overflow-hidden">
  <PlPortal>
    <div className="fixed inset-0 z-(--plass-z-portal)">…</div>
  </PlPortal>
</div>
```

`--plass-z-portal` is the level every portalled surface in the library paints at, and it is a token so that an app with a header, a cookie bar or a video player of its own can move the whole set with one line. Use it rather than a number.

### An element that is not a `<div>`

`render` swaps the wrapper for whatever the target actually accepts as a child.

```tsx
<PlPortal container={listRef} render={<li />}>
  Appended to a list
</PlPortal>
```

### Turning it off

`disabled` renders in place. Decide it **once, at mount**: a portalled subtree and an inline one are different children as far as React is concerned, so flipping it remounts everything inside and throws away a half-filled form, a scroll position, or a video that was playing. That is reconciliation rather than a shortcoming here, and no portal escapes it.

## Notes

- The wrapper is a real element rather than a fragment, because it is what carries the class and what a caller positions the subtree with.
- It does not trap focus, block the page, or close on <kbd>Escape</kbd>. Those belong to the thing being portalled — a [`PlModal`](../feedback/modal) has all three — and a portal that had opinions about them would be a dialog with a worse name.

## Accessibility

- **A portal moves the pixels and the reading order together.** A screen reader walks the document, so a subtree portalled to the end of `<body>` is read at the end of the page however near the trigger it is painted. For anything a reader is meant to meet next — a dialog, a menu, a message about what just happened — move the focus into it, or give the trigger an `aria-controls` and an `aria-expanded`.
- The same goes for the <kbd>Tab</kbd> key: it follows the document, not the screen. A portalled panel painted beside its button is tabbed to after everything else on the page unless something moves the focus there.
