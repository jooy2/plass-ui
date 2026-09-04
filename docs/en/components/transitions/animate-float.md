---
title: PlAnimateFloat
order: 13
---

# PlAnimateFloat

<p class="plass-lede">Content drifting gently, and not going anywhere. The odd one out here: every other effect is an entrance, played once when content arrives. This one never finishes.</p>

<Demo src="animate-float/hero" :min-height="220" />

::: fw react

```tsx
import { PlAnimateFloat } from 'plass-ui';

<PlAnimateFloat>
  <EmptyStateMark />
</PlAnimateFloat>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateFloat(child: EmptyStateMark());
```

:::

## Props

<PropsTable name="PlAnimateFloat" />

What the shared animation props mean is on any of the other [transitions](./animate-fade).

## Not an entrance

The rest of this group answers "how does this content arrive". This one answers "what does weightless look like", and three things follow from that.

**It never finishes.** `repeat` is infinite by default, because a single drift out and back is a nudge and nobody asks for a nudge.

**It is not in the effect union.** `PlassAnimation` — the set `mode`, `stagger` and the shared effect map are built on — is the set of ways content can _arrive_. A drift is not an arrival, and every component that imports that map pays for each row in it whether or not it uses the effect, so a row nothing else could want does not go in. It runs its own keyframe instead.

**It has no `mode`.** There is no reverse of a drift: the cycle is symmetric already, and running it backwards is the same cycle.

## The cycle is symmetric

Home, out, home. However many times it runs it ends where it started, so a float stopped mid-cycle does not leave the element permanently a few pixels out of place — which reads as a layout bug rather than as an effect that ended.

That is the same shape a [`PlAnimateBlink`](./animate-blink) takes and for the same reason.

## easing

It defaults to `ease-in-out`, and it is the one component in the library that does not take the house curve.

The house curve is an **entrance's**: fast out of the gate, slow into place. A drift with it lurches at each end of the cycle instead of turning around, because there is no gate — the element is already there and is only breathing.

## Examples

### A mark over an empty state

The ordinary use, and about the only one: something decorative that is meant to be noticed at the edge of attention.

```tsx
<PlEmpty title="No projects yet">
  <PlAnimateFloat>
    <ProjectsMark />
  </PlAnimateFloat>
</PlEmpty>
```

### Sideways, and further

```tsx
<PlAnimateFloat orientation="horizontal" distance={16} duration={5000}>
  <Cloud />
</PlAnimateFloat>
```

`distance` is small by default on purpose. Past about a dozen pixels a drift stops being a drift and starts being something moving on the page.

## Notes

- Up, not down. That is what "float" means everywhere it is used, and a downward default would be a fall.
- It moves with the independent `translate` property rather than the `transform` shorthand, as every effect here does, so a caller's own transform on the same element survives.

## Accessibility

- **A reader who asked for less motion sees none of it.** Nothing may depend on the movement, and there is nothing here that could: it is decoration, and the content is delivered either way.
- Do not put anything readable inside one. Text that drifts while it is being read is text that has to be chased.
- Something that never stops moving in the corner of a page is the one kind of motion this library otherwise refuses. It is here for the illustration, not for the notice.
