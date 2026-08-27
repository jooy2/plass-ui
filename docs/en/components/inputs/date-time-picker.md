---
title: PlDateTimePicker
order: 15
---

# PlDateTimePicker

<p class="plass-lede">A day and a time, in one popup. Not a date picker that grew a clock, and not a time picker that grew a calendar — the two panels are the same height on purpose.</p>

<Demo src="date-time-picker/hero" :flutter="false" :min-height="200" />

::: fw react

```tsx
import { PlDateTimePicker } from 'plass-ui';

<PlDateTimePicker label="Starts" placeholder="Pick a moment" minDate={new Date()} />;
```

:::

## Props

<PropsTable name="PlDateTimePicker" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the picker spells it as a value rather than a DOM attribute, and `children` because the panels are the component.

:::

The calendar is [`PlDatePicker`](./date-picker)'s and the columns are [`PlTimePicker`](./time-picker)'s, both unchanged: everything those two pages say about `locale`, the header, the columns and the absence of a date library holds here.

## One rectangle, not two panels

The calendar's grid is seven rows counting its header. The clock's columns are seven of the same cell. They read the same `--p-cell` ladder for exactly that reason, so the popup is one rectangle rather than two of different sizes pushed together — and switching the calendar to its month or year view does not change that.

## The bounds do more work here

`minDate` and `maxDate` are read at **full precision**, which is the one place this parts company with [`PlDatePicker`](./date-picker). There, a bound is about which days exist and the time of day on it is ignored. Here, a minimum of 09:30 on the 27th leaves the 27th selectable in the calendar and greys out the morning in the clock.

That is the behaviour a "not before now" rule actually needs, and a day-granular check cannot give it: it would either block the whole of today or allow this morning.

<Demo src="date-time-picker/precision" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/date-time-picker/precision.tsx

</Demo>

## Examples

### Choosing in either order

Picking a day changes the day and leaves the clock alone; picking an hour changes the clock and leaves the day alone. A picker that reset the time to midnight every time the date was corrected would make choosing a moment an ordered task, and nobody reads a popup in the order it was written.

With no day chosen yet the clock writes onto today, and picking a day afterwards keeps whatever time was set.

`closeOnSelect` is `false` here for the same reason: a moment is two answers, so the footer carries a **Done**.

### The steps

`hourStep`, `minuteStep` and `secondStep` are [`PlTimePicker`](./time-picker)'s, unchanged.

<Demo src="date-time-picker/steps" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/date-time-picker/steps.tsx

</Demo>

### locale

One tag decides the month and weekday names, the order of the header's two buttons, whether the clock is on a 12-hour dial, what AM and PM are called, and how the trigger writes the whole moment.

<Demo src="date-time-picker/locales" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/date-time-picker/locales.tsx

</Demo>

### readOnly · disabled · error

<Demo src="date-time-picker/states" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/date-time-picker/states.tsx

</Demo>

## Accessibility

- The calendar is [`PlDatePicker`](./date-picker)'s in full — `role="grid"`, one roving tab stop, full dates as accessible names — and the columns are [`PlTimePicker`](./time-picker)'s, including the live region that reads the time back as one sentence.
- The trigger wears the **calendar glyph alone**, not both: a control cannot say two things at once, and the date is the part a reader scans for.
- A day blocked by a full-precision bound and an hour blocked by the same bound both carry `aria-disabled` rather than the attribute, so neither leaves the path a keyboard walks.
- With `name`, a hidden input carries the value as a local `YYYY-MM-DDTHH:MM` — the shape `<input type="datetime-local">` submits. Never `toISOString()`: a picker in Seoul would submit a different day.
