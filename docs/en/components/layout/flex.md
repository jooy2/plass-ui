---
title: PlFlex
order: 4
---

# PlFlex

<p class="plass-lede">A row or a column, and the gap between the things in it. The axis is responsive and is resolved by the stylesheet, so a form that stacks on a phone and lines up on a laptop is one prop and no re-render.</p>

<Demo src="flex/hero" :min-height="200" />

::: fw react

```tsx
import { PlFlex } from 'plass-ui';

<PlFlex direction={{ xs: 'vertical', md: 'horizontal' }} spacing={3} alignItems="center">
  <PlAvatar name="Ada Lovelace" />
  <PlTextField className="flex-1" label="Display name" fullWidth />
  <PlButton>Save</PlButton>
</PlFlex>;
```

:::

::: fw flutter

This one is React-only, and it is not an omission. `Row`, `Column` and `Wrap` are already in `package:flutter/widgets.dart`, they already take a `spacing`, and a widget wrapping them would be a fourth name for three things every Flutter developer has known since their first screen.

```dart
Row(
  spacing: 12,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[…],
);
```

The half worth having in Dart is the responsive axis, and that is a `LayoutBuilder` rather than a widget:

```dart
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    final children = <Widget>[…];

    return constraints.maxWidth >= 768
        ? Row(spacing: 12, children: children)
        : Column(spacing: 12, children: children);
  },
);
```

:::

## Props

<PropsTable name="PlFlex" />

Every native `<div>` attribute passes straight through. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## PlFlex, PlStack or PlGrid

Three components lay children out in a line, and they are not variations on each other.

|  | Reach for it when |
| --- | --- |
| [`PlFlex`](./flex) | The children are whatever size they are. "These, side by side, with a gap." |
| [`PlGrid`](./grid) | The children take a **share of the row** — a `span` out of twelve, with offsets and a wrap that lines up. |
| [`PlStack`](./stack) | The children **overlap** — a run of avatars, a pile of cards. |

`PlFlex` is the one with no arithmetic in it. It is a flex box with the library's own vocabulary on it, which buys three things a `className="flex gap-3"` does not: the axis can change at a breakpoint without Tailwind, `spacing` is the same scale a `PlGrid`'s gutter is, and it works in a project that imports `plass-ui/styles.css` and has no Tailwind of its own.

## direction resolves in CSS

<code v-pre>direction={{ xs: 'vertical', md: 'horizontal' }}</code> is a column below 48rem and a row from it up, and the **stylesheet** decides which — one `--p-dir-*` slot per rung the caller named, cascaded by the same `@variant` blocks a `PlGrid`'s columns use.

So the first paint a server sends is already right at every width, dragging a window costs no re-render, and no listener is installed. That is the same line [breakpoints](../../design/breakpoints) draws for every responsive prop in the library: a value that decides only **style** is resolved in CSS, and a value that decides **structure** — an orientation that changes which DOM a component builds and which way its arrow keys walk — is resolved in JavaScript and pays for it.

<Demo src="flex/direction" :min-height="260">

::: fw react

<<< @/.vitepress/demos/flex/direction.tsx

:::

</Demo>

A rung that was not named inherits the one below it, so `{ xs: 'horizontal', lg: 'vertical' }` is a row at every width until 64rem. Naming one rung never drops the others: the `xs` entry falls back to the documented default rather than to nothing.

## reverse is a painting order

It runs the children the other way along the axis and **changes nothing else**. The DOM order is what a screen reader reads out and what the <kbd>Tab</kbd> key walks, and neither of them moves.

That makes it right for an arrangement — a chat bubble that hangs off the other end, a footer whose actions sit to the trailing side — and wrong for content whose order is the information. If the second thing should be read second, put it second.

It is not responsive, deliberately. It folds into the same slot `direction` writes, so one custom property carries the whole answer and a breakpoint changes the axis without having to restate which end it starts from.

## Examples

### A toolbar that wraps

`wrap` is `false` by default, which is what a flex box already does. A row that wraps is a decision rather than the absence of one — the opposite default would silently reflow a toolbar somebody had sized to fit.

<Demo src="flex/toolbar" :min-height="200">

::: fw react

<<< @/.vitepress/demos/flex/toolbar.tsx

:::

</Demo>

### One gutter per axis

`spacing` sets both. `rowSpacing` and `columnSpacing` each take one and fall back to it, which is what a wrapping row of chips usually wants — tight between the lines, wider along them.

```tsx
<PlFlex wrap spacing={3} rowSpacing={1.5}>
```

### Inline

`inline` lays the box out in a line of text, only as wide as its children. For a run of tokens inside a sentence rather than a block of its own.

```tsx
<p>
  Assigned to{' '}
  <PlFlex inline spacing={1} alignItems="center">
    <PlAvatar size="xs" name="Ada" /> Ada
  </PlFlex>{' '}
  since March.
</p>
```

## Notes

- **It draws nothing.** No surface, no padding, and no `variant`, `color`, `size`, `density` or `elevation`. A flex box is the arrangement of the surfaces inside it, and `spacing` — the space _between_ children — is the only measurement it owns.
- `spacing` is Tailwind's spacing scale and not an eight-pixel one: `spacing={4}` is `1rem`, exactly what `gap-4` means and what a `PlGrid`'s gutter of `4` is. Fractions are on the same ladder, so `1.5` is `0.375rem`.
- `render` swaps the `<div>` for the element the markup actually wants — `<ul>`, `<nav>`, `<fieldset>` — without changing anything about the layout.
- `flex-direction` is declared on the component's own class, so a `className` carrying `flex-col` loses to it. Use `direction`, which is the prop that means the same thing and is responsive besides.

## Accessibility

- **Reordering is visual only.** `reverse`, and any `order` a caller sets on a child, move the pixels and not the document. A reading order that disagrees with the visual one is [a documented failure](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence.html) of meaningful sequence, so put the content in the order it should be read and let the layout follow.
- It has no role and adds none. `render={<ul />}` with `<li>` children is what turns an arrangement into a list for a screen reader; a `<div>` of `<div>`s is what it looks like.
