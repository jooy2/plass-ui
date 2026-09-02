---
title: PlAnimateFade
order: 3
---

# PlAnimateFade

<p class="plass-lede">Content arriving or leaving on opacity alone. Nothing moves, so nothing reflows and nothing is resampled — the one entrance that is safe on a block of text at any size.</p>

<Demo src="animate-fade/hero" :min-height="260" />

::: fw react

```tsx
import { PlAnimateFade } from 'plass-ui';

<PlAnimateFade>
  <p>Two services restarted, no errors.</p>
</PlAnimateFade>;

<PlAnimateFade trigger="visible" duration={600}>
  <PlCard title="Usage">…</PlCard>
</PlAnimateFade>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateFade(child: Text('Two services restarted, no errors.'));

const PlAnimateFade(
  trigger: PlassAnimateTrigger.visible,
  duration: Duration(milliseconds: 600),
  child: PlCard(title: Text('Usage'), child: Text('…')),
);
```

:::

## Props

<PropsTable name="PlAnimateFade" />

::: fw react

Every native `<div>` attribute passes straight through, and `render` swaps the element for another one — a `<section>`, an `<li>`, whatever the surrounding markup needs.

:::

::: fw flutter

`duration` and `delay` are `Duration`s, and `curve` is a `Curve`. `repeat` is an `int?` where **`null` never stops** — there is no `'infinite'` to write.

:::

The ten shared settings — `duration`, `delay`, `easing`, `repeat`, `alternate`, `paused`, `trigger`, `play`, `once`, `threshold` — are the same on every `PlAnimate*` component and mean the same thing on each. What the shared style axes mean across the library is in [prop conventions](../../design/prop-conventions).

::: fw react

Three more move the effect off the box and onto the things inside it — `stagger`, `durationStep` and `reverse`. See [Telling the children apart](#telling-the-children-apart) below.

:::

## Examples

### trigger

Four ways in, and they are the whole of what the shared settings are for. `mount` needs nothing from the caller. `visible` waits for the element to be scrolled into view — paused on its own first frame while it waits, so it is not fully drawn and then blinked out at the moment it arrives. `hover` starts on the pointer **and on focus**, or the effect would be unreachable without a mouse. `manual` never runs on its own, and each `false` → `true` on `play` starts it over.

<Demo src="animate-fade/triggers" :min-height="280">

::: fw react

<<< @/.vitepress/demos/animate-fade/triggers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/triggers.dart

:::

</Demo>

### mode

`out` is the same keyframe run backwards rather than a second animation, which is why it costs nothing — and why it is **held at the end**: a faded-out element stays faded out instead of snapping back into view when the run finishes.

<Demo src="animate-fade/mode" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-fade/mode.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/mode.dart

:::

</Demo>

### delay

A delay per element is what turns a set of things into a sequence. For a list where every child takes the same effect one after another, [PlAnimateAppear](./animate-appear) counts the steps for you.

<Demo src="animate-fade/timing" :min-height="140">

::: fw react

<<< @/.vitepress/demos/animate-fade/timing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/timing.dart

:::

</Demo>

### Telling the children apart

::: fw react

`stagger` moves the effect **off the box and onto the things inside it**, one after another. It is milliseconds added to each child's delay, and `0` — the default — plays the box, which is what an effect should go on doing when it wraps one thing.

The box stops animating entirely once it is on: eight children fading in under a box that is also fading in is the same content faded twice, and the second one is not free.

<Demo src="animate-fade/stagger" :min-height="140">

<<< @/.vitepress/demos/animate-fade/stagger.tsx

</Demo>

`durationStep` gives each child a longer run than the last, or — negative — a shorter one, floored at `0`. `reverse` starts from the end of the set: the **order** turns round and nothing else, because an effect that runs backwards is `mode="out"`.

The step is per _child_, so what you pass matters — five children are five steps, and one child holding five things is one step. That is also how to opt part of a set out: group it.

The animation is written onto the children themselves rather than onto wrappers, so a row of `<li>`s stays a row of `<li>`s and a grid's cells stay its direct children. The cost is that a child has to accept a `className` and a `style`; one that does not is a child that will not animate. A bare string has no element to write onto and is the one case that gets a `<span>`.

All six single-keyframe effects take these three. [`PlAnimateMarquee`](./animate-marquee), [`PlAnimateHeadline`](./animate-headline), [`PlAnimateTyping`](./animate-typing) and [`PlAnimateLighting`](./animate-lighting) do not, and cannot: the first three already read their children, and the last keeps its motion on a pseudo-element, which there is no way to put on somebody else's child. [`PlAnimateAppear`](./animate-appear) is the same three props under the same names, with a `stagger` that defaults to `70` — a set with no stagger is not a set.

**There is no `PlAnimateStagger`, on purpose.** A stagger is a differential rather than an effect, and a wrapper would be a second way to spell something the effects can already say. It is the same rule that keeps a `Pulse` (`blink` + `alternate`) and a `Bounce` (`grow` + `alternate`) out of the library.

:::

::: fw flutter

A staggered set is [`PlAnimateAppear`](./animate-appear). The React build can write an effect onto arbitrary children because the caller's own CSS is still laying them out; here there is no stylesheet to do that, so a staggered effect has to own the row or the column too — which is what `PlAnimateAppear` is, and six more of it would be six more of it.

:::

## Accessibility

::: fw react

- Under `prefers-reduced-motion` the animation is dropped entirely and the content is simply there. That is the opposite of what the loading indicators do, and the difference is what each of them is saying: a spinner that stops is lying about whether anything is happening, while an entrance that never plays has still delivered everything it was carrying.
- The wrapper adds no role and no label. It is a `<div>` around content that already says what it is.
- Nothing here is a way to hide content. A `mode="out"` element is still in the document and still read out; if it should be gone, unmount it.
- `trigger="hover"` also starts on focus, so an effect on something keyboard-reachable runs for a reader who is not holding a mouse.

:::

::: fw flutter

- When the platform has animations turned off (`MediaQuery.disableAnimations`) the effect is dropped entirely and the content is simply there. That is the opposite of what the loading indicators do, and the difference is what each of them is saying: a spinner that stops is lying about whether anything is happening, while an entrance that never played has still delivered everything it was carrying.
- The widget adds no semantics of its own. It is an `Opacity` around content that already says what it is.
- Nothing here is a way to hide content. A `PlassAnimateMode.exit` widget is still in the tree and still in the semantics; if it should be gone, take it out.
- `PlassAnimateTrigger.hover` also starts on focus, so an effect on something keyboard-reachable runs for a reader who is not holding a mouse.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `duration`, `delay` in milliseconds | `Duration` | The framework already has the type, and a package taking `int` milliseconds would be the odd one out in every file that used it. |
| `easing` as a CSS string | `curve`, a `Curve` | Dart's own name for the same thing. |
| `repeat: number \| 'infinite'` | `int?`, `null` never stops | There is no `'infinite'` to write, and `-1` would be a sentinel a caller has to look up. The same trade `PlProgressLinear` makes with a null `value`. |
| `mode="in" \| "out"` | `PlassAnimateMode.enter` / `.exit` | `in` is a reserved word in Dart and cannot be an enum value. |
| `trigger="visible"` via `IntersectionObserver` | watches the nearest `Scrollable` | There is no observer here. With no scrollable above it there is nothing to watch, so it runs — exactly as the React build does when the browser has none. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | The platform's own signal. |
| `render` | — | Flutter has no polymorphic element. |
| `stagger`, `durationStep`, `reverse` | — | The React build writes the effect onto the children themselves, so the caller's own layout is untouched. Flutter has no stylesheet to lay a set out with, so a staggered effect would have to own the row or the column as well — which is what [`PlAnimateAppear`](./animate-appear) is, and six more of it would be six more of it. |
| `className`, `style` | — | There is no class list and no style attribute to pass through. |

:::
