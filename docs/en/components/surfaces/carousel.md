---
title: PlCarousel
order: 6
---

# PlCarousel

<p class="plass-lede">A strip of slides, one of which is in view. A scroll container with snap points underneath, so swiping and dragging are the browser's own rather than a gesture handler pretending to be one.</p>

<Demo src="carousel/hero" :flutter="false" :min-height="260" />

::: fw react

```tsx
import { PlCarousel } from 'plass-ui';

<PlCarousel label="Places">
  <img src="/harbour.jpg" alt="The harbour at dawn" />
  <img src="/dunes.jpg" alt="Dunes" />
</PlCarousel>;
```

:::

## Props

<PropsTable name="PlCarousel" />

::: fw react

Every other `<div>` attribute passes through to the region.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## What it is made of

A **scroll container with scroll snapping**, and everything good about this component follows from that one choice.

Swiping on a phone and two-finger dragging on a trackpad both work because they are the platform's own scrolling and not a gesture handler imitating it — momentum, rubber-banding and the scrollbar all come with them. The strip runs the other way under RTL without being told, because scrolling is directional and a `translate` is not. And **nothing is transformed**, so the [house rule](../../design/design-language) against moving a surface holds here for free, where a translated track would have had to argue for an exception.

Slides are not a sub-component. Every top-level child is wrapped in its own slide, so `<PlCarousel><img /><img /></PlCarousel>` is the whole API — and the wrapper is what carries the snap point, the width and the `role="group"` / `aria-roledescription="slide"` pair a screen reader needs, none of which a caller should have to remember to put on a photograph.

## Examples

### variant

The frame, on the same three materials as every other container, and never dyed — a carousel holds other people's pictures. `ghost` has no frame at all, which is what to reach for when the pictures already have edges of their own.

<Demo src="carousel/variants" :flutter="false" :min-height="380">

<<< @/.vitepress/demos/carousel/variants.tsx

</Demo>

### loop

On by default: the arrows wrap from the last slide back to the first. Turn it off and they go inert at the ends instead, which is the honest thing for a set that has a beginning and an end — a gallery of three photographs does, a rotating banner does not.

<Demo src="carousel/loop" :flutter="false" :min-height="360">

<<< @/.vitepress/demos/carousel/loop.tsx

</Demo>

### autoPlay

**Off by default, and deliberately so.** A carousel that moves while it is being read is the most complained-about pattern on the web, and every one of the guards below exists because of a way that goes wrong:

- it pauses on hover;
- it pauses on focus **anywhere inside it**, which is the important one — a keyboard reader who has tabbed into a slide is reading it;
- it stops while the tab is in the background;
- it does not start at all for a reader who has asked for reduced motion;
- and the live region that announces the current slide goes **silent** while it is running, because a screen reader saying a new slide's name every five seconds is what makes a page unusable.

<Demo src="carousel/auto-play" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/carousel/auto-play.tsx

</Demo>

### The dots

The current dot is a short **bar** rather than a bigger circle. It grows along the row it is in, so the row's height never changes and the dots either side of it do not move — width and colour are the only two things that travel, which is what keeps the indicator inside the rule against scaling anything.

Every dot is a real button named after the slide it goes to, so the row is a way to navigate rather than a read-out.

## Accessibility

- The whole thing is a `region` with `aria-roledescription="carousel"`, and every slide a `group` with `aria-roledescription="slide"` and a name of its own.
- No off-screen slide is hidden. A slide can hold a link or a button, and an `aria-hidden` subtree that is still in the tab order is the exact shape of the bug where a keyboard reader lands somewhere their screen reader refuses to describe. The strip is scrollable, so everything in it is genuinely reachable.
- Where the reader is is announced as a sentence in a polite live region — and never while `autoPlay` is on.
- The arrows and the dots are real buttons with real names. `label`, `previousLabel`, `nextLabel` and `slideLabel` decide what those names are.

::: fw react

- The strip itself is focusable and scrolls with the arrow keys, which is the browser's own key handling on a scroll container — so it is already right under RTL.

:::
