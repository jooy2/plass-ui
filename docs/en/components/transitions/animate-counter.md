---
title: PlAnimateCounter
order: 15
---

# PlAnimateCounter

<p class="plass-lede">A number counting up to what it is. The one effect here that animates content rather than a box — and the one that starts when it is seen rather than when it mounts.</p>

<Demo src="animate-counter/hero" :min-height="200" />

::: fw react

```tsx
import { PlAnimateCounter } from 'plass-ui';

<PlAnimateCounter value={48120} format={{ style: 'currency', currency: 'GBP' }} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnimateCounter(
  value: 48120,
  formatValue: (double value) => NumberFormat.simpleCurrency(locale: 'en_GB').format(value),
);
```

:::

## Props

<PropsTable name="PlAnimateCounter" />

## It waits to be seen

**`trigger` defaults to `visible`**, and it is the one component in the library that does not start on mount.

That is deliberate rather than an oversight. An entrance played off screen has still delivered its content — the words are there when the reader arrives, which is all a fade was ever carrying. A count that ran off screen delivered a number that was **already sitting there**, which is the one thing a counter cannot afford: being watched is the whole point of it.

## Why it is not a keyframe

CSS can animate a number. A registered custom property and a `counter()` in a pseudo-element tick one perfectly well, and that would be the neater implementation.

It cannot **format** one. No thousands separator, no currency symbol, no folding 1,200,000 into `1.2M` — and a counter that cannot be formatted is a counter nobody can put on a dashboard. So the frame loop only decides which number is being drawn, and `Intl.NumberFormat` decides what it looks like.

::: fw react

Which is also why `easing` is a **function** here rather than a CSS string: there is no CSS animation running to hand a string to. It eases out by default, which is what a number arriving should do — quick enough to read as counting, slow enough at the end to land on the figure rather than snap to it.

:::

::: fw flutter

`formatValue` is a callback rather than an options object for `PlProgressLinear`'s reason: there is no `Intl` in the framework, and pulling `package:intl` in to provide one would be a dependency decision made on a consumer's behalf.

:::

## Examples

### A row of figures on a landing page

The case it exists for, and the reason `visible` is the default.

```tsx
<PlStat label="Deploys" value={<PlAnimateCounter value={4812} />} />
```

`PlStat` takes a **node** for its value precisely so that this can go in it.

### Counting to a new number

Changing `value` counts again, from wherever the last one landed. A dashboard whose figure updates every minute does not need to be told to replay.

```tsx
<PlAnimateCounter value={deploys} />
```

### From somewhere other than zero

```tsx
<PlAnimateCounter from={4000} value={4812} duration={800} />
```

## Accessibility

- **A screen reader is told the answer, once.** The ticking figure is hidden from the accessibility tree and the final number sits beside it in a clipped span, because a number changing sixty times a second in that tree is either silence or sixty announcements — and neither of those is the figure.
- Where a reader has asked for less motion there is no count at all: the number is simply there, which is the only thing it was ever carrying.
- Until it starts, the figure shown is the one it will count **from** — the same rule every keyframe here follows about its own first frame — so nothing claims a value it has not reached.
- The digits are `tabular-nums`, so the figure does not jitter as it counts.
