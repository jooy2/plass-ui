---
title: PlCard
order: 2
---

# PlCard

<p class="plass-lede">The sheet everything else on a screen is grouped onto, with the parts a card is made of already laid out on it: a title, a subtitle, a body and a footer.</p>

<Demo src="card/hero" :min-height="240" />

::: fw react

```tsx
import { PlButton, PlCard } from 'plass-ui';

<PlCard title="Team plan" subtitle="Billed yearly" footer={<PlButton>Upgrade</PlButton>}>
  Shared projects, audit logs and a seat for anyone you invite.
</PlCard>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCard(
  title: const Text('Team plan'),
  subtitle: const Text('Billed yearly'),
  footer: PlButton(onPressed: upgrade, child: const Text('Upgrade')),
  child: const Text('Shared projects, audit logs and a seat for anyone you invite.'),
);
```

:::

## Props

<PropsTable name="PlCard" />

::: fw react

Every native `<div>` attribute passes straight through. `color` and `title` are excluded because both are Plass props here.

:::

::: fw flutter

`footer` is one widget, so a footer with two buttons in it brings its own `Row` or `Wrap`. The React build lays out a fragment of children for you; there is no fragment here to lay out.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

The three materials, read the way a **container** reads them. `solid` is the clear glass at its most opaque, for a panel that has to sit forward of everything around it. `glass` is the canonical Plass sheet and the default. `ghost` has no sheet at all — for a card inside a card, where a second bordered rectangle is a second rectangle.

None of the three is dyed. What a card holds arrives with its own colours, and tinting the sheet under them would put every one on a background it was not chosen against.

<Demo src="card/variants" :min-height="160">

::: fw react

<<< @/.vitepress/demos/card/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/variants.dart

:::

</Demo>

### title · subtitle · headerAction · footer

The sections are props rather than sub-components, for the same reason `PlTextField` takes `label` and `description` as props: the arrangement is fixed, and what a caller decides is what goes in each slot.

A slot that is empty draws nothing — a card with only a body is one section, not three.

<Demo src="card/slots" :min-height="360">

::: fw react

<<< @/.vitepress/demos/card/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/slots.dart

:::

</Demo>

### dividers

Off by default: a card's sections are told apart by space. Turn it on and they are scored with a hairline in `--plass-divider`, the neutral ink a `PlList` and a `PlTable` are ruled with, so every internal rule in the library is one line. It is not the sheet's own white edge, which reads only because the page wash is behind it and would have the pane behind it here. The rules have to reach both edges, so the padding moves from the card onto each section.

<Demo src="card/dividers" :min-height="200">

::: fw react

<<< @/.vitepress/demos/card/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/dividers.dart

:::

</Demo>

### padded

Off, the sheet keeps no inset at all and the content brings its own — a banner image reaching all four corners, a table drawing its own rows.

::: fw react

Pair it with `overflow-hidden` so the content is clipped to the card's radius.

:::

::: fw flutter

The sheet already clips to its own radius, so a banner reaching the edges is rounded without being asked.

:::

<Demo src="card/padded" :min-height="280">

::: fw react

<<< @/.vitepress/demos/card/padded.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/padded.dart

:::

</Demo>

### <Fw react="interactive" flutter="onPressed and interactive" />

Lifts the sheet under the pointer and puts a level of elevation under it. This is the one place the library allows a surface to move, and the exception is the rule rather than a hole in it: what may not move is the thing under the finger. A sheet that _holds_ content is the other kind of surface, and lifting one is how a pane of glass says it can be picked up.

::: fw react

`interactive` changes how the card looks and nothing else. A card that is genuinely clickable has to be a real element — `render={<a href="…" />}` or `render={<button type="button" />}` — so it is focusable, announced as what it is, and reachable from a keyboard.

:::

::: fw flutter

`onPressed` is the one to reach for: it makes the card a real focus stop, announced as a button, activated by <kbd>Enter</kbd> or <kbd>Space</kbd>, and it lifts. `interactive` is the same lift without any of that, for a card whose interactive parts are the widgets **inside** it.

:::

<Demo src="card/interactive" :min-height="160">

::: fw react

<<< @/.vitepress/demos/card/interactive.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/interactive.dart

:::

</Demo>

### size

Moves the radius, the type scale and the inner padding together. Unlike a control, `size` on a card does not set a height: a card is as tall as what it holds.

<Demo src="card/sizes" :min-height="360">

::: fw react

<<< @/.vitepress/demos/card/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- Renders a plain `<div>` with no role, which is correct for a container. Use `render` to make it a `<section>`, an `<li>`, an `<article>` or a link when the markup should say more.
- A plain string `title` is a styled `<div>`, not a heading. Pass `title={<h2>…</h2>}` when the card belongs in the document outline; it inherits the card's typography rather than the browser's.
- `interactive` is a visual state. It adds no role, no `tabIndex` and no key handling — give the card a real element with `render` instead of putting an `onClick` on a `<div>`.
- The focus ring is drawn on `:focus-visible` and traces the sheet's own edge, so it only appears once the card is genuinely focusable.

:::

::: fw flutter

- A card with no `onPressed` adds no role and takes no focus stop, which is correct for a container.
- `title` is styled as the title and is not announced as a heading. Wrap it in a `Semantics(header: true, …)` when the card belongs in the screen's outline; the typography is the card's either way.
- `interactive` is a visual state. It adds no role, no focus stop and no key handling — use `onPressed` when the card is genuinely something you press.
- The focus ring only appears on what CSS calls `:focus-visible` — a keyboard reaching the card, never a pointer clicking it — and traces the sheet's own edge.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `render` | `onPressed` | Flutter has no polymorphic element, and the thing `render` was mostly reached for — making the card real — is what `onPressed` does directly. An action that navigates calls your router from it. |
| a fragment in `footer` | one widget | There is no fragment to lay out, so a footer with several things in it brings its own `Row` or `Wrap`. |
| `title={<h2>…</h2>}` | `Semantics(header: true, …)` | Flutter's semantics tree has one heading flag and no depth to go with it. |
| `children` | `child` | Flutter's name. |
| `overflow-hidden` beside `padded={false}` | — | The sheet already clips to its own radius. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
