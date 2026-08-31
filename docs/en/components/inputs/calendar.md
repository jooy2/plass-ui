---
title: PlCalendar
order: 21
---

# PlCalendar

<p class="plass-lede">A month, on the page rather than in a popup. The same grid a <code>PlDatePicker</code> opens, with the trigger and the popup taken away.</p>

<Demo src="calendar/hero" :min-height="400" />

::: fw react

```tsx
import { PlCalendar } from 'plass-ui';

<PlCalendar value={day} onValueChange={setDay} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCalendar(
  value: day,
  onChanged: (DateTime? next) => setState(() => day = next),
);
```

:::

## Props

<PropsTable name="PlCalendar" />

::: fw react

Every native `<div>` attribute passes straight through. There is no `label`, `description` or `error`: this is not a field, so it has no text around it — put it in a [`PlFieldset`](./fieldset) if it needs a caption.

:::

::: fw flutter

There is no `label`, `description` or `error`: this is not a field, so it has no text around it — put it in a [`PlFieldset`](./fieldset) if it needs a caption.

Two differences from the React build, both the ones every date component in this package has. `names` and `labels` take the words rather than a `locale` string, because the framework ships no `Intl` — English is the default, and an app that already has `package:intl` builds a `PlDateNames` from it in three lines. And there is **no `name`**: a Dart form is not an HTML one, so there is no hidden input to submit and the value is the caller's to send.

:::

`density` is not offered. Padding on a grid of forty-two squares is what makes them stop being squares; `size` moves the whole ladder together instead. What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## When to use this rather than a PlDatePicker

A [`PlDatePicker`](./date-picker) is a **field** that happens to open a calendar: it belongs in a form, beside other fields, and its answer is one line of text until you open it. This is a calendar that is not standing in for a field — a booking page, an availability view, a date rail in a dashboard. The grid is the interface rather than a way of filling one in.

If the answer sits in a form next to other inputs, use the picker.

## Examples

### precision

A **floor** rather than a starting view. At `month` the month grid is the last grid and pressing a cell in it answers, so there is no day grid under it at all — a card's expiry is a month, and a control that made somebody answer _which day of December 2027_ is one that will be answered wrongly.

The value is normalised to the start of what was chosen: the 1st of the month, the 1st of January, never whichever day the cursor was resting on.

<Demo src="calendar/precision" :min-height="360">

::: fw react

<<< @/.vitepress/demos/calendar/precision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/precision.dart

:::

</Demo>

### minDate, maxDate and shouldDisableDate

The two bounds are read at the calendar's own `precision`, so a `minDate` of 15 July leaves July pickable on a `month` calendar. `shouldDisableDate` is day-granular and is not consulted at all on the other two.

<Demo src="calendar/bounds" :min-height="400">

::: fw react

<<< @/.vitepress/demos/calendar/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/bounds.dart

:::

</Demo>

### variant

`glass` by default, with the sheet and the elevation a `PlCard` has. Reach for `ghost` when the calendar is already inside something that draws a sheet — a second bordered rectangle inside the first is a second rectangle.

<Demo src="calendar/variants" :min-height="400">

::: fw react

<<< @/.vitepress/demos/calendar/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/variants.dart

:::

</Demo>

### Controlling the month

`month` and `onMonthChange` control what is on screen independently of what is chosen, which is what two calendars kept a month apart need.

```tsx
const [month, setMonth] = useState(startOfMonth(new Date()));

<PlCalendar month={month} onMonthChange={setMonth} value={day} onValueChange={setDay} />;
```

Uncontrolled, the month follows the value: choosing a day out of a trailing week moves the grid to that day's month, because a selection in a month that is no longer on screen is one nobody can see.

### In a form

::: fw react

`name` adds a hidden input. The spelling follows `precision` — `YYYY-MM-DD`, then `YYYY-MM` and `YYYY`, which is what the native inputs of the same shape submit.

```tsx
<form action={book}>
  <PlCalendar name="departure" />
</form>
```

:::

::: fw flutter

There is nothing to add. A Dart form is not an HTML one, so there is no hidden input and no name to give it — the value arrives in `onChanged` and sending it is the caller's.

:::

### disabled

Greys the calendar and takes it out of reach with the `inert` attribute — one attribute rather than a `disabled` on forty-two cells.

There is no `readOnly` beside it, and that is not an omission: a read-only field still shows a value a reader can select and copy, and a calendar has nothing to copy. To block some days rather than all of them, use `shouldDisableDate`.

## Accessibility

- A real `role="grid"` with one **roving tab stop**, so <kbd>Tab</kbd> leaves the calendar rather than walking forty-two cells. That is the pattern the ARIA date-picker practice describes, and the reason no cell is a `disabled` button — a blocked day is `aria-disabled` and still reachable, so a keyboard reader can find out that it is blocked.
- The arrow keys move by one cell, <kbd>PageUp</kbd>/<kbd>PageDown</kbd> by a month (a year with <kbd>Shift</kbd>), <kbd>Home</kbd>/<kbd>End</kbd> to the ends of the week. Running off an edge steps the calendar rather than stopping.
- Each cell's accessible name is the full date in the calendar's `locale`, so a screen reader reads "Monday 27 July 2026" rather than "27".
- `autoFocus` is **off** by default, the opposite of the picker's: a popup has just been opened by somebody who wants to be in it, and a calendar in a page has not.
