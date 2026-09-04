---
title: PlTour
order: 16
---

# PlTour

<p class="plass-lede">A guided walk over a screen that already exists — the three things a new reader has to be shown once, pointed at where they actually are.</p>

<Demo src="tour/hero" :min-height="320" />

::: fw react

```tsx
import { PlTour } from 'plass-ui';

const filter = useRef<HTMLDivElement>(null);

<PlTour
  open={running}
  onOpenChange={setRunning}
  steps={[
    { target: filter, title: 'Narrow the list', content: 'Type here.' },
    { target: '#export', title: 'Take it with you', side: 'left' },
    { title: 'That is all of it' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTour(
  open: _running,
  onOpenChanged: (bool next) => setState(() => _running = next),
  steps: <PlTourStep>[
    PlTourStep(target: _filterKey, title: const Text('Narrow the list')),
    PlTourStep(target: _exportKey, title: const Text('Take it with you')),
    const PlTourStep(title: Text('That is all of it')),
  ],
);
```

:::

## The one thing worth knowing first

**The dimming takes the pointer and the light does not.**

The scrim is one layer covering the whole <Fw react="viewport" flutter="screen" /> with the target cut out of it, and the cut-out is a _clip_ rather than a painted hole. A clipped-away region is not hit-tested, so the reader can use the control being pointed at and nothing else — which is the difference between a tour and a dialog with a picture of a control in it.

That falls out of the geometry rather than being a second mechanism that has to agree with it, and it is what the whole component is built on:

<Demo src="tour/mask" :min-height="280">

::: fw react

<<< @/.vitepress/demos/tour/mask.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tour/mask.dart

:::

</Demo>

The same clip buys the second thing: the dimming can **blur**. A hole drawn as a shadow or as four rectangles around the target can only paint a colour, where a clipped layer carries a backdrop filter — so the page around the light is out of focus as well as dark, which is this library's own material rather than a grey wash over it.

## It is `PlHowToSteps` turned inside out

[`PlHowToSteps`](../surfaces/how-to-steps) puts the instructions **in** the page and the reader follows them. `PlTour` leaves the page as it is and stands over it.

So a step _says what it is about_ rather than describing it. What a tour points at is already on screen, and a second copy inside the card is a second copy to keep in step — which is why there is no `image` or `example` on a step and why the card is as small as it is.

Reach for the steps when the reader will come back to them, and for a tour when they will not.

## Props

<PropsTable name="PlTour" />

::: fw react

`variant` and `elevation` are absent. The card is the frosted panel a [`PlPopover`](popover) draws, at the top of the shadow ladder, and it is meant to float — a tour card made of `solid` would be a control, and one at elevation `0` would be flat against a page it is standing over.

:::

::: fw flutter

`variant` and `elevation` are absent for the same reason the React build gives.

It is **not** built on the internal portal every other layer in this package uses, and the reason is the whole design: that helper holds focus inside itself, which is right for a modal and wrong here. A tour whose reader cannot reach the control it is pointing at has pointed at a picture.

The widget draws nothing where it is written, so it can go anywhere under an `Overlay` — `WidgetsApp` with a navigator and `MaterialApp` both provide one.

:::

### PlTourStep

<PropsTable name="PlTourStep" />

::: fw react

**Three forms of `target`, and the first is the one to reach for.** A **ref** is checked by the compiler and survives a rename. A **selector** is a string that can stop matching the moment somebody renames a class, and the tour would go on running with the hole over an empty piece of background — it is here because it is the only form that works when the target belongs to something this page does not render. The **getter** is for the case where finding it takes more than one query.

:::

::: fw flutter

`target` is a `GlobalKey` and nothing else. Every widget on the screen was written by somebody who can put a key on it, and a key is checked by the compiler; the React build offers a selector as well only because a web page can contain elements it did not render.

:::

What the shared axes (`size` `color` `density`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Where the card goes

`side` and `align` place the card against the light, and it flips to the opposite side when the one asked for has no room. A step with **no target** puts the card in the middle of the <Fw react="viewport" flutter="screen" /> and cuts nothing out — which is what a welcome step and a closing step are.

<Demo src="tour/sides" :min-height="280">

::: fw react

<<< @/.vitepress/demos/tour/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tour/sides.dart

:::

</Demo>

::: fw flutter

The flip is a flip and **not a slide**, which is the same bargain `PlPopover` makes: a card that crept sideways as its target neared the edge would be a card that no longer looks like it is pointing at anything. What does move is the cross axis, and only far enough to keep the card on screen.

:::

### Following the target

A tour runs over a live page. Something below it can finish loading, an image can arrive, the window can be resized — and the light would be left over a piece of empty background.

::: fw react

The measurement is re-read on a scroll, on a resize and on the target changing size, coalesced to one read per frame: a scroll fires far more often than the page paints, and each read forces a layout.

The page is **not** pinned while the tour runs, which is deliberate — the reader is meant to be able to use what is being pointed at, and that sometimes means scrolling to it.

:::

::: fw flutter

The light is measured when the step changes and when the window changes size. For a screen that scrolls, hand the tour the `ScrollController` the targets live in: it is lifted into the `Overlay` and cannot see a scroll notification from down there, so the one thing it cannot work out for itself is given to it. It is the same parameter [`PlAnchor`](../navigation/anchor) takes, for the same reason.

:::

`scrollIntoView` brings each target on screen as the tour reaches it, and is on by default. Turn it off for a tour whose targets are all visible already — a smooth scroll that moves nothing is a frame spent on nothing.

### Controlled, or not

`open` and `step` are each controllable on their own. A tour that runs once on a first visit is `defaultOpen` and nothing else; a tour whose progress is saved somewhere passes `step` and `onStepChange`.

`onFinish` is called when the last step's button is pressed, **before** the tour closes, which is where "remember that this reader has seen it" goes.

## Accessibility

::: fw react

- The card is a dialog, named by the step's `title` and described by its `content`.
- The dimming is `aria-hidden`: it is a drawing, and everything it says is already in the card.
- <kbd>Escape</kbd> ends the tour unless `dismissible` is `false`. A press **outside** the card does not, and neither does the focus leaving it — using the page is exactly what a tour is for, so the only ways out are Escape, the ×, Skip and Done.
- The counter is two numbers rather than a sentence. "3 of 7" is a string that has to be translated and a word order that differs by language; the count itself does not.
- The buttons take their words from [the label set](../../guide/locales), so a tour in a translated application is translated with it.

:::

::: fw flutter

- The card is announced as its own thing and the screen under it is still there to be reached. It deliberately does not take the route: a tour that did would be a modal, and the reader could not get to the control the tour is telling them about.
- <kbd>Escape</kbd> ends the tour unless `dismissible` is `false`.
- The counter is two numbers, for the reason the React build gives.
- The card's buttons wrap to a second line rather than running off the edge, because a translation whose words are longer than English's is three buttons wider than the card.

:::

## Notes

- **A tour is not documentation.** Three steps is a tour; nine is a manual that nobody will read standing up, and every one of them is between the reader and the thing they opened the product to do.
- **`mask={false}` is a real option**, not a degraded one. A tour over a page the reader is meant to keep working in — a walkthrough beside a form they are filling — is better without the dimming at all.
- **Nothing is remembered.** Whether this reader has seen the tour is the application's to store, and `onFinish` is where to store it.
