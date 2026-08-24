---
title: PlCard
order: 2
---

# PlCard

<p class="plass-lede">The sheet everything else on a screen is grouped onto, with the parts a card is made of already laid out on it: a title, a subtitle, a body and a footer.</p>

<Demo src="card/hero" :min-height="240" />

```tsx
import { PlButton, PlCard } from 'plass-ui';

<PlCard title="Team plan" subtitle="Billed yearly" footer={<PlButton>Upgrade</PlButton>}>
  Shared projects, audit logs and a seat for anyone you invite.
</PlCard>;
```

## Props

<PropsTable name="PlCard" />

Every native `<div>` attribute passes straight through. `color` and `title` are excluded because both are Plass props here.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### variant

The three materials, read the way a **container** reads them. `solid` is the clear glass at its most opaque, for a panel that has to sit forward of everything around it. `glass` is the canonical Plass sheet and the default. `ghost` has no sheet at all — for a card inside a card, where a second bordered rectangle is a second rectangle.

None of the three is dyed. What a card holds arrives with its own colours, and tinting the sheet under them would put every one on a background it was not chosen against.

<Demo src="card/variants" :min-height="160">

<<< @/.vitepress/demos/card/variants.tsx

</Demo>

### title · subtitle · headerAction · footer

The sections are props rather than sub-components, for the same reason `PlTextField` takes `label` and `description` as props: the arrangement is fixed, and what a caller decides is what goes in each slot.

A slot that is empty draws nothing — a card with only `children` is one section, not three.

<Demo src="card/slots" :min-height="360">

<<< @/.vitepress/demos/card/slots.tsx

</Demo>

### dividers

Off by default: a card's sections are told apart by space. Turn it on and they are scored with a hairline instead — the same `--plass-glass-line` as the sheet's own edge, so it reads as the pane being scored. The rules have to reach both edges, so the padding moves from the card onto each section.

<Demo src="card/dividers" :min-height="200">

<<< @/.vitepress/demos/card/dividers.tsx

</Demo>

### padded

Off, the sheet keeps no inset at all and the content brings its own — a banner image reaching all four corners, a table drawing its own rows. Pair it with `overflow-hidden` so the content is clipped to the card's radius.

<Demo src="card/padded" :min-height="280">

<<< @/.vitepress/demos/card/padded.tsx

</Demo>

### interactive

Lifts the sheet under the pointer and puts a level of elevation under it. This is the one place the library allows a `transform`, and the exception is the rule rather than a hole in it: what may not move is the thing under the finger. A sheet that _holds_ content is the other kind of surface.

It changes how the card looks and nothing else. A card that is genuinely clickable has to be a real element — `render={<a href="…" />}` or `render={<button type="button" />}` — so it is focusable, announced as what it is, and reachable from a keyboard.

<Demo src="card/interactive" :min-height="160">

<<< @/.vitepress/demos/card/interactive.tsx

</Demo>

### size

Moves the radius, the type scale and the inner padding together. Unlike a control, `size` on a card does not set a height: a card is as tall as what it holds.

<Demo src="card/sizes" :min-height="360">

<<< @/.vitepress/demos/card/sizes.tsx

</Demo>

## Accessibility

- Renders a plain `<div>` with no role, which is correct for a container. Use `render` to make it a `<section>`, an `<li>`, an `<article>` or a link when the markup should say more.
- A plain string `title` is a styled `<div>`, not a heading. Pass `title={<h2>…</h2>}` when the card belongs in the document outline; it inherits the card's typography rather than the browser's.
- `interactive` is a visual state. It adds no role, no `tabIndex` and no key handling — give the card a real element with `render` instead of putting an `onClick` on a `<div>`.
- The focus ring is drawn on `:focus-visible` and traces the sheet's own edge, so it only appears once the card is genuinely focusable.
