---
title: PlTimeline
order: 13
---

# PlTimeline

<p class="plass-lede">A sequence of steps, in the order they happen in. <code>active</code> says how far along it is, and the timeline works out what each step's bullet should be.</p>

<Demo src="timeline/hero" :min-height="360" />

::: fw react

```tsx
import { PlTimeline, PlTimelineItem } from 'plass-ui';

<PlTimeline active={2}>
  <PlTimelineItem title="Ordered" meta="Mon 09:12" bullet="1" />
  <PlTimelineItem title="Packed" meta="Mon 14:40" bullet="2" />
  <PlTimelineItem title="Shipped" meta="Tue 07:05" bullet="3" />
</PlTimeline>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlTimeline(
  active: 2,
  items: <PlTimelineItem>[
    PlTimelineItem(title: Text('Ordered'), meta: Text('Mon 09:12'), bullet: Text('1')),
    PlTimelineItem(title: Text('Packed'), meta: Text('Mon 14:40'), bullet: Text('2')),
    PlTimelineItem(title: Text('Shipped'), meta: Text('Tue 07:05'), bullet: Text('3')),
  ],
);
```

:::

## Props

<PropsTable name="PlTimeline" />

::: fw react

Every native `<ol>` attribute passes straight through. `color` is excluded from the pass-through because it is a Plass prop here.

:::

::: fw flutter

The steps are `items` rather than children, and a `PlTimelineItem` is a **description rather than a widget**, the same call [`PlBreadcrumb`](./breadcrumb) makes, and Flutter's own idiom. Which step is complete is arithmetic on an index, and the last step's connector has to know it is the last; neither question can be asked of an opaque `Widget`.

:::

There is no `variant` and no `elevation`: a timeline is a run of marks down the page, not a sheet laid on it. Put one inside a `PlCard` when it needs a surface.

### PlTimelineItem

<PropsTable name="PlTimelineItem" />

::: fw react

Every native `<li>` attribute passes straight through. `size`, `density` and `orientation` are inherited from the `PlTimeline` around it.

:::

An item's **index is not a property and cannot be**. An item that had to be told where it was in the list would be an item every caller could put in the wrong place, and `active` would stop meaning anything. The timeline numbers its steps as it walks them.

What the shared axes (`size` `color` `density` `orientation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### active

An index rather than a value, because a timeline has no selection. Nothing here is chosen, and the only question is how far down the list reality has reached. Omit it and every item is `upcoming`; pass the item count to mark the whole sequence done.

<Demo src="timeline/active" :min-height="340">

::: fw react

<<< @/.vitepress/demos/timeline/active.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/active.dart

:::

</Demo>

### status

Three states rather than two, because "the one you are on" is not the same claim as "done", and a sequence that cannot say which step is current is a list.

Each state is a different **axis**, never a different opacity: `complete` is the family's gradient, `current` is that gradient with a halo of the soft tint around it, and `upcoming` is a hairline ring on the page's own surface. A reader who cannot tell the colours apart still has a filled shape, a haloed shape and an empty one.

`status` on an item overrides what `active` computed for it, a step that failed and stopped the sequence, a step that was skipped.

<Demo src="timeline/status" :min-height="300">

::: fw react

<<< @/.vitepress/demos/timeline/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/status.dart

:::

</Demo>

### connector

::: fw react

The line is drawn as one border edge rather than as a filled `<div>`, so `dashed` and `dotted` are the browser's own dashes and land on the device pixel grid the way every other edge in the library does.

:::

::: fw flutter

Flutter's `BorderSide` has no dashes, so the line is painted: `dashed` and `dotted` are runs laid down by hand, at the same weight the solid one is drawn at. A dot is a round cap on a zero-length run, which is what makes it a circle rather than a short square.

:::

It belongs to the item it leaves rather than the one it arrives at, which is what lets its colour say whether that step has been reached. The last item's line is never drawn. It would run off the end of the sequence into nothing.

<Demo src="timeline/connectors" :min-height="280">

::: fw react

<<< @/.vitepress/demos/timeline/connectors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/connectors.dart

:::

</Demo>

### orientation

`vertical` is the default and the one that takes an arbitrary number of steps with an arbitrary amount to say about each. `horizontal` is the stepper across the top of a checkout, and it is only honest while every label is short.

**It is responsive**, so a set can run one way on a phone and the other on a laptop. <Fw react="A server renders the xs entry and the browser corrects it on hydration." flutter="It is resolved against the window's width during build, so the first frame is already right." /> See [breakpoints](../../design/breakpoints).

<Demo src="timeline/orientation" :min-height="160">

::: fw react

<<< @/.vitepress/demos/timeline/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/orientation.dart

:::

</Demo>

### size

<Demo src="timeline/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/timeline/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- It is an `<ol>` for the reason it exists at all: the order **is** the content. A screen reader announcing "list of 5 items" over an unordered list would be describing something else.
- `role="list"` is written out because Tailwind's reset takes the markers off every `<ol>`, and Safari takes the list semantics off with them.
- The current step carries `aria-current="step"`. That is the value for a sequence. `"page"` is a trail of documents and `"true"` is one of a set of options.
- The bullets and the connectors are `aria-hidden`. The status is in `aria-current` and in the text of each step, never in a shape alone.
- There is no Base UI primitive under this. A timeline has no selection, no roving focus and no keyboard contract, and using a composite primitive would hand a record of events the semantics of a widget.

:::

::: fw flutter

- The steps are read in order, which is what the sequence is. Each is its own node.
- The bullets and the connectors are excluded from semantics. A bullet drawn as a number says nothing a screen reader needs that the step's own title does not.
- Which is the consequence worth knowing: **status does not reach a screen reader here.** Flutter's semantics tree has no `current` for a sequence, so a step that is complete and a step that is upcoming are announced the same way. Where the status matters, say it, in the step's `meta`, or in its body.
- A timeline has no selection, no roving focus and no keyboard contract, and it claims none.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `<PlTimelineItem>` children | `items`, as descriptions | Which step is complete is arithmetic on an index, and the last connector has to know it is the last. Neither can be asked of a `Widget`. |
| `aria-current="step"` | — | Flutter's semantics tree has no `current`. Say the status in the step's own text where it matters. |
| `<ol>` and `role="list"` | a grouped semantics node | There are no markers to reset and no list semantics for a reset to take away. |
| a `border` with `dashed`/`dotted` | a painted line | `BorderSide` has no dashes, so the runs are laid down by hand at the same weight. |
| `render` | — | Flutter has no polymorphic element. |
| `children` on a step | `child` | Flutter's name. |

:::
