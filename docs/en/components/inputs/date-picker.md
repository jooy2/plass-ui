---
title: PlDatePicker
order: 12
---

# PlDatePicker

<p class="plass-lede">One day, chosen from a calendar. The trigger is a <code>PlTextField</code>'s shell wearing a calendar glyph, so a date field and the fields beside it are the same object.</p>

<Demo src="date-picker/hero" :flutter="false" :min-height="200" />

::: fw react

```tsx
import { PlDatePicker } from 'plass-ui';

<PlDatePicker label="Departure" placeholder="Pick a day" minDate={new Date()} />;
```

:::

## Props

<PropsTable name="PlDatePicker" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the picker spells it as a value rather than a DOM attribute, and `children` because the calendar is the component.

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## No date library, and no translation files

The pickers add **nothing** to your dependency tree. Everything they do is either `Date` arithmetic, which is a dozen lines, or `Intl`, which the platform already ships and which knows more about month names in more languages than any bundled table ever will. A component library that quietly added `date-fns` — or worse, picked a side in the dayjs / luxon / Temporal argument on its consumer's behalf — would have made a decision that was not its to make.

That is also the whole of the localisation story. There is no per-language module to import and register: `locale` is a BCP 47 tag, and from it `Intl` supplies the month names, the weekday names, AM and PM, which day the week starts on, the order of the header's two buttons, and how the trigger writes the date. **A project that ships in twelve languages pays nothing for eleven of them.**

The only strings left over are the ones on the picker's own buttons — "Today", "Previous month", "Choose a year" — because the platform has no opinion about those. They are one `labels` object with English defaults.

## You cannot type into it

Deliberately. Parsing a date out of free text is locale-dependent in a way that cannot be done honestly without a date library, and a field that understands `27/7/26` in one browser and not the next is worse than one that never claimed to. The trigger is a button, exactly as a [`PlSelect`](./select)'s is, and the calendar is where the answer comes from.

## Examples

### The header is the point

A picker that only steps a month at a time puts a birthday thirty years back a hundred and eighty clicks away. So the month name and the year are each a **button** that opens a grid of its own — twelve months, then twelve years at a time. Any month of the year on screen is two clicks; any year at all is three.

All three views are the same width _and_ the same height, so switching between them never resizes the popup under the pointer that opened it. The day grid is always six weeks for the same reason: a February that needs four rows and a March that needs six would move every cell as you stepped between them.

### locale

The month and weekday names, AM/PM, which day the week starts on, the order of the header's two buttons and the trigger's own format all come from here. `2026년 7월` in Korean, `July 2026` in English — the two buttons swap places rather than being printed in a fixed order, because a header in the wrong order reads as broken to exactly the readers it is wrong for.

<Demo src="date-picker/locales" :flutter="false" :min-height="280">

<<< @/.vitepress/demos/date-picker/locales.tsx

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate` and `maxDate` are **day-granular**: the time of day on them is ignored, because the bound is about which days exist. `shouldDisableDate` is for the days inside the range that still are not available — weekends, holidays, a room that is already booked.

A blocked day stays in the grid rather than vanishing, and it is not a `disabled` button: it keeps its place in the arrow-key path, so a reader arrowing across a month does not fall into a hole at every blocked day.

<Demo src="date-picker/bounds" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/date-picker/bounds.tsx

</Demo>

### format

Passed straight to `Intl.DateTimeFormat`, so `{ dateStyle: 'full' }` and `{ year: 'numeric', month: 'long' }` both work.

Whatever it says, the trigger is held open at the width of the longest date it could ever hold — so choosing the 1st after the 28th does not shrink the field out from under the pointer that chose it.

<Demo src="date-picker/format" :flutter="false" :min-height="240">

<<< @/.vitepress/demos/date-picker/format.tsx

</Demo>

### readOnly · disabled · error

`error` also turns the picker invalid, which re-points the whole colour family at `danger` — the edge, the ring and the message turn over together. `invalid` does the same without a message.

A `readOnly` picker keeps its value and its focus but **will not open**: what it holds is something to read, and a calendar whose every cell was inert would be a menu of nothing.

<Demo src="date-picker/states" :flutter="false" :min-height="280">

<<< @/.vitepress/demos/date-picker/states.tsx

</Demo>

### Controlled

Pass `value` with `onValueChange`. The value is a `Date` at local midnight — or at whatever time of day it already carried: choosing a new day changes the day and leaves the clock alone, so a picker bound to a field that also holds a time does not silently reset it every time the date is corrected.

`null` is a value a controlled picker legitimately holds. It is what an emptied one is.

## Accessibility

- The grid is a `role="grid"` of `gridcell`s with **one roving tab stop**, so <kbd>Tab</kbd> leaves the calendar rather than walking forty-two cells. That is the pattern the ARIA date-picker practice describes.
- <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd> move by a day and a week, <kbd>Home</kbd> and <kbd>End</kbd> go to the ends of the week, and <kbd>PageUp</kbd> / <kbd>PageDown</kbd> move by a month — a year with <kbd>Shift</kbd>. Running off an edge steps the calendar rather than stopping.
- A blocked day carries `aria-disabled` rather than the `disabled` attribute, so it stays in the arrow-key path and is still announced — as unavailable.
- Every cell's accessible name is the **full date**, never the bare number: `Monday 27 July 2026`, from `Intl`, in the picker's own locale.
- Today carries `aria-current="date"` and a dot rather than a ring, because the ring belongs to the focus indicator and two rings in one cell is a cell saying nothing.
- The weekday headers are `columnheader`s labelled with the full name, so a screen reader hears "Monday" where a sighted reader sees "Mon".
- With `name`, a hidden input carries the value as a **local** `YYYY-MM-DD`. Never `toISOString()`: a picker in Seoul would submit the day before the one on screen.
- The trigger is held open at the width of the longest date it could show. Those samples are `aria-hidden` and drawn as generated content, so nothing extra is read out or found by find-in-page.
- The popup is portalled to the end of `<body>` and its positioner carries `.plass-portal`, which is where a host that scopes a CSS reset can hang the same reset.
