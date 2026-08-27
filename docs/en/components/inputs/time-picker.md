---
title: PlTimePicker
order: 14
---

# PlTimePicker

<p class="plass-lede">A time of day, chosen from columns. Columns because they are the shape that answers what a time picker is actually asked.</p>

<Demo src="time-picker/hero" :flutter="false" :min-height="200" />

::: fw react

```tsx
import { PlTimePicker } from 'plass-ui';

<PlTimePicker label="Doors" placeholder="Pick a time" minuteStep={15} />;
```

:::

## Props

<PropsTable name="PlTimePicker" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the picker spells it as a value rather than a DOM attribute, and `children` because the columns are the component.

:::

Everything a [`PlDatePicker`](./date-picker) says about `locale` and the absence of a date library holds here too — `Intl` is what decides whether the clock is on a 12-hour dial and what AM and PM are called.

## Columns, not a dial

"Half past nine" is two glances at two columns. "Any time at all, on the hour" is a column you never touch. A clock face is prettier, needs a `transform` to read, and answers neither question faster — and this library does not put a `transform` on a control.

The chosen row in each column is scrolled into view once, on open. That is not decoration: a column of sixty minutes that opens at `00` while the value is `45` has hidden its own answer.

## The bounds are checked per column

This is the detail that separates a working time picker from a frustrating one. A bound is checked against the **span a row stands for**, not against one instant inside it.

With a `minTime` of 09:30, the hour `9` covers 09:00:00–09:59:59, which overlaps what is allowed — so it stays available, and the minute column is where `00` through `25` grey out. Comparing the whole candidate instead hides the 9 and makes half past nine unreachable.

## The value is a Date

Not a string and not a number of minutes. Everything else in this library that carries a moment is a `Date`, and a bare time has nowhere to record that it crossed a daylight-saving boundary. `referenceDate` is the day a bare time is written onto, and it is held still for as long as the picker is mounted — a popup left open across midnight must not quietly move the value onto a new day.

## Examples

### hour12

Taken from the `locale` unless you say otherwise. A 12-hour dial reads `12, 1, 2 … 11` rather than `0, 1, 2`, and gains an AM/PM column; a 24-hour one runs `00` to `23` and has none.

<Demo src="time-picker/dials" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/time-picker/dials.tsx

</Demo>

### The steps

`hourStep`, `minuteStep` and `secondStep` decide how far apart the rows are. A booking that only takes quarter hours should say so with `minuteStep={15}` rather than by rejecting 09:07 after the fact.

<Demo src="time-picker/steps" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/time-picker/steps.tsx

</Demo>

### minTime · maxTime · shouldDisableTime

`minTime` and `maxTime` read the clock only — the day on them is ignored. `shouldDisableTime` is called once per row per column with the instant that row would produce and the column it is in, so a rule may be as coarse as "no afternoons" or as fine as one minute.

<Demo src="time-picker/bounds" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/time-picker/bounds.tsx

</Demo>

### closeOnSelect

`false` here, and `true` on a [`PlDatePicker`](./date-picker). A day is one answer; a time is two, and closing after the first would make choosing 9:30 a matter of opening the popup twice.

Because the popup stays up while the columns are being read, there has to be something to press that means _that is the one_ — so the footer carries a **Done**. Turning `closeOnSelect` on takes it away, since there is then nothing for it to do.

### readOnly · disabled · error

<Demo src="time-picker/states" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/time-picker/states.tsx

</Demo>

## Accessibility

- Each column is a `role="listbox"` named after the unit it holds, and each row is an `option` carrying `aria-selected`.
- A blocked row carries `aria-disabled` rather than the `disabled` attribute, so it stays reachable and is announced as unavailable.
- Three unlabelled lists of numbers say nothing to a reader who is not looking at them, so a polite live region beside the columns reads the whole time back as one sentence whenever it changes.
- The chosen row in each column is brought into view **inside its own column**, by setting `scrollTop` rather than calling `scrollIntoView` — which walks every scrollable ancestor up to the document and, on the frame the popup opens, would scroll the page to the top to reveal a row that is about to move anyway.
- The trigger is held open at the width of the longest time it could show. Those samples are `aria-hidden` and drawn as generated content.
- With `name`, a hidden input carries the value as a local `HH:MM` — the shape `<input type="time">` submits, so a server that already parses those needs no new code.
