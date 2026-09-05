---
title: PlDatePicker
order: 12
---

# PlDatePicker

<p class="plass-lede">One day, chosen from a calendar. The trigger is a <code>PlTextField</code>'s shell wearing a calendar glyph, so a date field and the fields beside it are the same object.</p>

<Demo src="date-picker/hero" :min-height="200" />

::: fw react

```tsx
import { PlDatePicker } from 'plass-ui';

<PlDatePicker label="Departure" placeholder="Pick a day" minDate={new Date()} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDatePicker(
  label: const Text('Departure'),
  placeholder: const Text('Pick a day'),
  minDate: DateTime.now(),
  value: departure,
  onChanged: (DateTime? next) => setState(() => departure = next),
);
```

The calendar lifts itself out of the tree, so a picker needs an `Overlay` above it, `WidgetsApp` with a navigator and `MaterialApp` both provide one.

:::

## Props

<PropsTable name="PlDatePicker" />

::: fw react

Every native `<div>` attribute passes straight through to the field wrapper. `color` is excluded because it collides with the `color` in the table above, `defaultValue` because the picker spells it as a value rather than a DOM attribute, and `children` because the calendar is the component.

A `className` lands on the stack that holds the label, the control and the two lines under it. `classNames` reaches the four parts inside it: `label`, `control` (the trigger) `description` and `error`.

:::

::: fw flutter

The picker is **controlled**, like every other input in the package: `value` with `onChanged`, and `null` is a picker with nothing chosen.

`names` is the one parameter with no React counterpart, and the next section says why.

### PlDateNames

<PropsTable name="PlDateNames" />

:::

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## No date library, and no translation files

The pickers add **nothing** to your dependency tree. Everything they do is either `Date` arithmetic, which is a dozen lines, or `Intl`, which the platform already ships and which knows more about month names in more languages than any bundled table ever will. A component library that quietly added `date-fns`, or worse, picked a side in the dayjs / luxon / Temporal argument on its consumer's behalf. Would have made a decision that was not its to make.

::: fw react

That is also the whole of the localisation story. There is no per-language module to import and register: `locale` is a BCP 47 tag, and from it `Intl` supplies the month names, the weekday names, AM and PM, which day the week starts on, the order of the header's two buttons, and how the trigger writes the date. **A project that ships in twelve languages pays nothing for eleven of them.**

:::

::: fw flutter

This is also the one place the two packages genuinely part company. The browser hands React an `Intl` that already knows what July is called in every language, so a BCP 47 tag is enough. The Flutter framework ships nothing of the kind, and a package that pulled `package:intl` in to fill the gap would be making a dependency decision on its consumer's behalf, the same trade `PlProgressLinear`'s `formatValue` already refuses.

So the words arrive as a `PlDateNames`: English by default, so a picker works with no setup at all, and three lines of `DateFormat` for an app that already depends on `package:intl`.

```dart
PlDateNames(
  months: List<String>.generate(
    12,
    (int i) => DateFormat.MMMM(locale).format(DateTime(2021, i + 1)),
  ),
  monthsShort: List<String>.generate(
    12,
    (int i) => DateFormat.MMM(locale).format(DateTime(2021, i + 1)),
  ),
  weekdays: List<String>.generate(
    7,
    (int i) => DateFormat.EEEE(locale).format(DateTime(2021, 8, i + 1)),
  ),
  weekdaysShort: List<String>.generate(
    7,
    (int i) => DateFormat.E(locale).format(DateTime(2021, 8, i + 1)),
  ),
)
```

:::

The only strings left over are the ones on the picker's own buttons ("Today", "Previous month", "Choose a year"), because neither platform has an opinion about those. They are one `labels` object with English defaults.

## You cannot type into it

This is deliberate. Parsing a date out of free text is locale-dependent in a way that cannot be done honestly without a date library, and a field that understands `27/7/26` in one browser and not the next is worse than one that never claimed to. The trigger is a button, exactly as a [`PlSelect`](./select)'s is, and the calendar is where the answer comes from.

## Examples

### The header

A picker that only steps a month at a time puts a birthday thirty years back a hundred and eighty clicks away. So the month name and the year are each a **button** that opens a grid of its own, twelve months, then twelve years at a time. Any month of the year on screen is two clicks; any year at all is three.

All three views are the same width _and_ the same height, so switching between them never resizes the popup under the pointer that opened it. The day grid is always six weeks for the same reason: a February that needs four rows and a March that needs six would move every cell as you stepped between them.

### precision

A birthday is a day, a card's expiry is a month and a model year is a year. `precision` says which, and the calendar opens on the grid for that unit. A `month` picker's month grid is the last grid, and there is no day grid under it at all. Asking someone which day of December 2027 their card expires is asking a question that will be answered wrongly.

The value is still a `Date`, normalised to the start of what was chosen: the 1st of the month, or the 1st of January. `minDate` and `maxDate` are then read at the same precision, so a `minDate` of 15 July leaves July pickable on a `month` picker and hands back 1 July, a bound on a control that returns a month is a bound on months. `shouldDisableDate` is day-granular and is not consulted at all.

The trigger's default format follows along, and so does the footer's shortcut: "This month" and "This year" rather than "Today".

<Demo src="date-picker/precision" :min-height="360">

::: fw react

<<< @/.vitepress/demos/date-picker/precision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/precision.dart

:::

</Demo>

### Names and labels

::: fw react

`locale` is a BCP 47 tag, and the month and weekday names, AM/PM, which day the week starts on, the order of the header's two buttons and the trigger's own format all come from it.

:::

::: fw flutter

`names` carries all of that, and `monthBeforeYear` is the part that is easiest to overlook.

:::

`2026년 7월` in Korean, `July 2026` in English. The two buttons swap places rather than being printed in a fixed order, because a header in the wrong order reads as broken to exactly the readers it is wrong for.

<Demo src="date-picker/locales" :min-height="280">

::: fw react

<<< @/.vitepress/demos/date-picker/locales.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/locales.dart

:::

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate` and `maxDate` are **day-granular**: the time of day on them is ignored, because the bound is about which days exist. `shouldDisableDate` is for the days inside the range that still are not available, weekends, holidays, a room that is already booked.

A blocked day stays in the grid rather than vanishing, and it is not a `disabled` button: it keeps its place in the arrow-key path, so a reader arrowing across a month does not fall into a hole at every blocked day.

<Demo src="date-picker/bounds" :min-height="220">

::: fw react

<<< @/.vitepress/demos/date-picker/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/bounds.dart

:::

</Demo>

### How the trigger writes it

::: fw react

`format` is passed straight to `Intl.DateTimeFormat`, so `{ dateStyle: 'full' }` and `{ year: 'numeric', month: 'long' }` both work.

:::

::: fw flutter

`formatValue` is a callback, for the reason above. Without it the day is written out of `names` in its medium form; `PlDateNames.spell` is the long one the cells already use.

:::

Whatever it says, the trigger is held open at the width of the longest date it could ever hold, so choosing the 1st after the 28th does not shrink the field out from under the pointer that chose it.

<Demo src="date-picker/format" :min-height="240">

::: fw react

<<< @/.vitepress/demos/date-picker/format.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/format.dart

:::

</Demo>

### readOnly · disabled · error

`error` also turns the picker invalid, which re-points the whole colour family at `danger`, the edge, the ring and the message turn over together. `invalid` does the same without a message.

A `readOnly` picker keeps its value and its focus but **will not open**: what it holds is something to read, and a calendar whose every cell was inert would be a menu of nothing.

<Demo src="date-picker/states" :min-height="280">

::: fw react

<<< @/.vitepress/demos/date-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/states.dart

:::

</Demo>

### Controlled

Pass `value` with `onValueChange`. The value is a `Date` at local midnight, or at whatever time of day it already carried: choosing a new day changes the day and leaves the clock alone, so a picker bound to a field that also holds a time does not silently reset it every time the date is corrected.

`null` is a value a controlled picker legitimately holds. It is what an emptied one is.

## Accessibility

- The grid has **one roving tab stop**, so <kbd>Tab</kbd> leaves the calendar rather than walking forty-two cells. That is the pattern the ARIA date-picker practice describes.

::: fw react

- The grid is a `role="grid"` of `gridcell`s.
- <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd> move by a day and a week, <kbd>Home</kbd> and <kbd>End</kbd> go to the ends of the week, and <kbd>PageUp</kbd> / <kbd>PageDown</kbd> move by a month, a year with <kbd>Shift</kbd>. Running off an edge steps the calendar rather than stopping.
- A blocked day carries `aria-disabled` rather than the `disabled` attribute, so it stays in the arrow-key path and is still announced, as unavailable.

:::

::: fw flutter

- A blocked day keeps its focus node and is announced as unavailable, for the same reason: a reader arrowing across a month must not fall into a hole at every one of them.
- The trigger is a button that carries the chosen day as its **value** rather than folding it into its label, which is what a `PlSelect` already does: the label names the field and the value says what is in it.
- The width samples are behind `ExcludeSemantics`, so nothing extra is read out.

:::

::: fw react

- Every cell's accessible name is the **full date**, never the bare number: `Monday 27 July 2026`, from `Intl`, in the picker's own locale.
- Today carries `aria-current="date"` and a dot rather than a ring, because the ring belongs to the focus indicator and two rings in one cell is a cell saying nothing.
- The weekday headers are `columnheader`s labelled with the full name, so a screen reader hears "Monday" where a sighted reader sees "Mon".
- With `name`, a hidden input carries the value as a **local** `YYYY-MM-DD`, or as `YYYY-MM` and `YYYY` at the two shorter precisions, which is what a native `<input type="month">` submits. Never `toISOString()`: a picker in Seoul would submit the day before the one on screen.
- The trigger is held open at the width of the longest date it could show. Those samples are `aria-hidden` and drawn as generated content, so nothing extra is read out or found by find-in-page.
- The popup is portalled to the end of `<body>` and its positioner carries `.plass-portal`, which is where a host that scopes a CSS reset can hang the same reset.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `locale`, a BCP 47 tag | `names`, a `PlDateNames` | The framework ships no `Intl`, and pulling `package:intl` in would be a dependency decision made on the consumer's behalf. English is the default, so a picker still works with no setup. |
| `format: Intl.DateTimeFormatOptions` | `formatValue: String Function(DateTime)` | The same trade, for the same reason. |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter's own controls are controlled, and its name for the callback. |
| the hidden input, `name`, `required` | — | There is no native form submission to be part of. |
| the header's controls are the picker's `size` | one step down the ladder | A month name is `July` in one language and `септември` in the next, and the row has seven cells to fit inside. Both buttons truncate rather than overflow. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
