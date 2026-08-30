---
title: PlDateRangePicker
order: 13
---

# PlDateRangePicker

<p class="plass-lede">A span between two days. Two months side by side, and the band between the ends is drawn as the pointer moves — before the second click lands.</p>

<Demo src="date-range-picker/hero" :min-height="200" />

::: fw react

```tsx
import { PlDateRangePicker } from 'plass-ui';

<PlDateRangePicker label="Stay" startPlaceholder="Check in" endPlaceholder="Check out" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDateRangePicker(
  label: const Text('Stay'),
  startPlaceholder: const Text('Check in'),
  endPlaceholder: const Text('Check out'),
  value: stay,
  onChanged: (PlDateRange next) => setState(() => stay = next),
);
```

The calendars lift themselves out of the tree, so a picker needs an `Overlay` above it.

:::

## Props

<PropsTable name="PlDateRangePicker" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the picker spells it as a value rather than a DOM attribute, and `children` because the calendars are the component.

A `className` lands on the stack that holds the label, the control and the two lines under it. `classNames` reaches the four parts inside it: `label`, `control` — the trigger — `description` and `error`.

:::

::: fw flutter

The picker is **controlled**: `value` with `onChanged`, and `value` is never `null` — an empty range is `PlDateRange.empty`.

:::

Everything a [`PlDatePicker`](./date-picker) says about `locale`, the header, the bounds and the absence of a date library holds here unchanged — this is that component with a second end.

### PlDateRange

<PropsTable name="PlDateRange" />

### PlDateRangePreset

<PropsTable name="PlDateRangePreset" />

## The value is one object

Not a `[Date, Date]` tuple, and not two props. A range is **one value**: it is chosen in one gesture, cleared in one gesture and validated as a whole, and the two names are what stop a caller writing the end into the start.

Half a range is a real state — it is what the picker holds between the first press and the second — so the callback reports a range with only a `start` after the first press and the complete range after the second. A controlled caller is never handed a range mid-gesture that it did not ask for: the pending anchor lives inside the component, not in your form.

## The preview is the whole affordance

The band is drawn between the anchor and whatever the pointer is currently over, before the second click lands. Without it the first click has no visible consequence, and the control looks broken for the second or so between the two.

Clicking backwards is not a mistake to be rejected. It is the same range typed in the other order, and it is committed as one.

## Examples

### monthCount

Two months is the default because a range that crosses a month boundary is the ordinary case, not the exception — a one-month picker turns that into a two-step navigation problem.

The two panels are **one calendar in two halves**: the left one has no forward stepper, the right one has no back stepper, and either header's month and year buttons move both. Where a stepper is not drawn, a hole its size is left, so the two headings stay on one centre line.

They also draw **no outside days**, and that is not a matter of taste: with both panels showing six full weeks, the 1st of August would appear twice — once as a trailing day of July and once as itself — and two cells with the same name in one popup is ambiguous to a pointer and outright broken to a screen reader.

<Demo src="date-range-picker/months" :min-height="200">

::: fw react

<<< @/.vitepress/demos/date-range-picker/months.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/months.dart

:::

</Demo>

### presets

A named range beside the calendars, for the ones people actually pick. Give `value` as a **function** when it depends on today, which is almost always: "the last 7 days" computed at module scope is a range that would be wrong for anyone who left the tab open overnight.

<Demo src="date-range-picker/presets" :min-height="200">

::: fw react

<<< @/.vitepress/demos/date-range-picker/presets.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/presets.dart

:::

</Demo>

### minDate · maxDate · shouldDisableDate

The same three as a [`PlDatePicker`](./date-picker), applied to both ends. A blocked day stays in the grid and keeps its place in the arrow-key path, and it does not take the range's tint: a blocked day wearing the band would be advertising that it is part of a range it cannot join.

<Demo src="date-range-picker/bounds" :min-height="200">

::: fw react

<<< @/.vitepress/demos/date-range-picker/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/bounds.dart

:::

</Demo>

### Controlled

Pass `value` with `onValueChange`. The callback is always given an object, so there is no `null` range to guard against — an emptied picker is `{ start: null, end: null }`.

<Demo src="date-range-picker/controlled" :min-height="200">

::: fw react

<<< @/.vitepress/demos/date-range-picker/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/controlled.dart

:::

</Demo>

## Accessibility

- Both grids have a roving tab stop each, and the keyboard is [`PlDatePicker`](./date-picker)'s in full.

::: fw react

- Both grids are `role="grid"`.
- Every cell's accessible name is the **full date**, and no date appears twice in the popup — which is what turning off the outside days buys.
- The footer says which end the next click will fill. The trigger says the same thing with its two halves, but the trigger is behind the popup while the popup is up, so the footer is the only place that can say it where it will be read.
- The arrow between the two halves of the trigger is `aria-hidden` and flips under RTL.
- Each half of the trigger holds its own width open against every date it could show, so filling in the second end does not resize the first. Those samples are `aria-hidden` and drawn as generated content.
- With `name`, two hidden inputs of that name carry the ends as local `YYYY-MM-DD`, so they arrive as `FormData.getAll(name)`.

:::

::: fw flutter

- The trigger carries both ends as its semantic **value** rather than folding them into its label.
- The arrow between the two halves turns under RTL, so it always points from the first end to the second.
- The width samples are behind `ExcludeSemantics`.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `locale` / `format` | `names` / `formatValue` | The same trade [`PlDatePicker`](./date-picker) explains: there is no `Intl` in the framework. |
| `value: PlDateRange \| null` | `value: PlDateRange`, never null | `PlDateRange.empty` says it, and a non-nullable value is one fewer thing for a caller to guard. |
| a preset's `value` may be a range **or** a function | `build` is always a function | A preset almost always depends on today, and the one shape that is always right is cheaper than two. |
| the hidden inputs, `name` | — | There is no native form submission to be part of. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
