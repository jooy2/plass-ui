---
title: Translating the words
order: 3
---

# Translating the words

<p class="plass-lede">Two dozen components say something of their own. A close button's name, a pager's landmark, the line a list shows when it is empty. Those words ship as translated packs, and one setting turns all of them over at once.</p>

<Demo src="provider/labels" :min-height="360">

::: fw react

<<< @/.vitepress/demos/provider/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/provider/labels.dart

:::

</Demo>

## Two settings, two jobs

`locale` and `labels` are both needed and neither replaces the other.

::: fw react

`locale` is the BCP 47 tag `Intl` formats against. It decides that a date reads `2026. 9. 4.` rather than `9/4/2026`, what July is called, and where the thousands separator goes. The platform owns all of it, so the library does not ship a month name.

`labels` is the ninety-seven entries `Intl` has no opinion about. "Close" is not a date and not a number; nothing in the platform knows it.

:::

::: fw flutter

`labels` is the ninety-six entries the widgets say about themselves. Three are not in the React set. `sortedAscending` and `sortedDescending` are here because `aria-sort` carries a meaning that has to be said in words on this side, and the page on [`PlDataTable`](../components/display/data-table) has the detail. `howToStep` is here because a real `<ol>` tells a screen reader which step it is on, and Flutter has no ordered list to inherit that from. Four of the React set are not here. `notifications` names the region a browser announces toasts in, and a Flutter screen has no such region. `paginationStatus` is what a pager's live region says, and the Flutter pager has no live region. `slide` is a slide's `aria-roledescription`, which Flutter's semantics have no field for. `otpSlot` names one slot of a code field, and the Flutter field is a single semantics node with no slots in it. The framework ships no `Intl`, so the dates are a second object. `PlDateNames` carries the months and the weekday abbreviations, and it is set the same way. See [Setting defaults](defaults).

:::

## The packs

Seven languages ship, and each one is a whole set.

::: fw react

```tsx
import { PlassProvider } from 'plass-ui';
import { ko } from 'plass-ui/locales';

<PlassProvider locale="ko-KR" labels={ko}>
  <App />
</PlassProvider>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/locales.dart';
import 'package:plass_ui/plass_ui.dart';

PlassTheme.merge(
  defaults: const PlassDefaults(labels: ko),
  child: const MyApp(),
);
```

The packs are a **library of their own**, imported separately from `plass_ui.dart`, so an application that writes its own words never compiles them.

:::

| Export   | Language            | The tag that goes with it |
| -------- | ------------------- | ------------------------- |
| `de`     | German              | `de-DE`                   |
| `en`     | English             | `en-US`                   |
| `es`     | Spanish             | `es-ES`                   |
| `fr`     | French              | `fr-FR`                   |
| `ja`     | Japanese            | `ja-JP`                   |
| `ko`     | Korean              | `ko-KR`                   |
| `zhHans` | Chinese, simplified | `zh-Hans-CN`              |

The list is short on purpose. A pack is worth shipping when somebody who reads the language has read it, so this is the list that has been read rather than the list a machine could produce.

## Importing a pack

::: fw react

A `locales['ko']` table would be the shorter API and the wrong one. For a key to be found in a table the table has to be in the build, so a French application would ship the Korean strings, the Japanese strings and the rest of them. An import ships one.

The cost is that the language cannot be chosen from a string at runtime. An application that genuinely switches languages while it is running imports the packs it offers and picks between them, which is the same code it already writes for its own copy:

```tsx
import { de, en, ko } from 'plass-ui/locales';

const packs = { de, en, ko };

<PlassProvider locale={tag} labels={packs[language]}>
  <App />
</PlassProvider>;
```

Three languages in the build because the application offers three, rather than seven because the library has seven.

:::

::: fw flutter

Dart's tree shaking would drop an unreferenced pack from a table on its own, so the reason here is smaller: `plass_ui.dart` is the import every file of an application already has, and putting seven translations behind it makes every one of those files carry them in its analysis. A second library keeps the vocabulary where the vocabulary is used.

:::

## One word at a time

A pack is a starting point, not a ceiling. Every component that says a word takes that word as a prop, and the prop wins.

::: fw react

```tsx
<PlassProvider labels={ko}>
  <PlTransfer sourceLabel="검토 대기" targetLabel="이번 호" items={items} />
</PlassProvider>
```

A partial set works too, with or without a pack. Anything left out stays English, and `{ ...ko, start: '체크인' }` is a pack with one word changed, which is the way to reach a word no component takes a prop for, such as the hint a `PlDateRangePicker` shows between its two dates.

:::

::: fw flutter

```dart
PlTransfer(items: items, sourceLabel: '검토 대기', targetLabel: '이번 호')
```

For a change that should reach a whole screen, or for a word no widget takes a parameter for, the hint a `PlDateRangePicker` shows between its two dates, `copyWith` gives the pack with that word replaced:

```dart
PlassTheme.merge(
  defaults: PlassDefaults(labels: ko.copyWith(start: '체크인')),
  child: child,
);
```

:::

## Precedence

**the component's own prop → the nearest provider's pack → English.**

::: fw react

The merge is per key, so a provider that sets four words leaves the other ninety-two English, and a provider nested inside another one replaces what it names and inherits the rest.

Reading what is in scope, for a component of your own that has to line up with the ones around it:

```tsx
import { defaultLabels, usePlassDefaults } from 'plass-ui';

const { labels } = usePlassDefaults();
const close = labels?.close ?? defaultLabels.close;
```

:::

::: fw flutter

A `PlassLabels` is a whole set, every field it does not name is English from the constructor, so a theme's labels replace the ones above rather than merging into them. `copyWith` is how a nested theme keeps what the outer one said.

Reading what is in scope:

```dart
final PlassLabels labels = PlassTheme.labelsOf(context);
```

It answers `PlassLabels.english` when no theme has decided.

:::

## Key names

The set is one flat list, and a key is named after what it means rather than after the component that says it. `close` is the × on a modal, a drawer, a popover and a toast, translated once. A key exists per component only where the word genuinely differs: a pager's `paginationNext` moves by a page and a carousel's `carouselNext` moves by a slide, so a language that distinguishes the two has somewhere to put the distinction.

## Sentences with a value in them

Seven entries in both sets hold a number or a name: a page button's `paginationPage`, a star's `ratingValue`, a slide's `carouselSlide`, where a gallery tile sits, `galleryItem`, a remove button's `removeItem`, the row that offers a typed value as a new one, `addCustom`, and what a transfer says once rows have moved, `transferMoved`. React has two more, `paginationStatus` and `otpSlot`, and Flutter has one, `howToStep`. They are functions rather than strings, because the order of a sentence moves between languages. "Page 3 of 12" is `12페이지 중 3페이지` in Korean and `第3页，共12页` in Chinese, and a template the component filled in would have kept the English order. The number in a sentence is written the way the language writes it as well: a half star is `2.5 out of 5` in English and `2,5 von 5` in German. A function you write yourself receives the plain number and formats it itself.

::: fw react

```tsx
<PlassProvider labels={{ ...ko, paginationPage: (page) => `${page}쪽` }}>
  <App />
</PlassProvider>
```

A pack holds functions, so a Server Component cannot pass one: React does not send a function across that boundary. Render the `PlassProvider` that takes a pack from a file with `'use client'` at the top, which is where a provider around a whole application usually is already.

:::

::: fw flutter

```dart
String _page(int page) => '$page쪽';

PlassTheme.merge(
  defaults: PlassDefaults(labels: ko.copyWith(paginationPage: _page)),
  child: child,
);
```

Pass a top-level function rather than a closure and a pack stays `const`. A top-level function's tear-off is a constant, so `const PlassLabels(paginationPage: _page)` compiles.

:::

A component's own prop for the same sentence, such as `pageLabel`, `valueLabel`, `slideLabel` or `removeLabel`, still wins over the pack.

## Adding a language

A pack is one file of the same shape, and the type is what keeps it honest. A missing key is a compile error rather than a word that quietly stays English.

::: fw react

```tsx
// packages/react/src/locales/it.ts
import type { PlassLabels } from '../internal/labels.js';

export const it: PlassLabels = {
  close: 'Chiudi'
  // …and every other key.
};
```

Export it from `src/locales/index.ts` and the package test that compares every pack against English covers it from then on.

:::

::: fw flutter

```dart
// packages/flutter/lib/src/locales/it.dart
const PlassLabels it = PlassLabels(close: 'Chiudi');
```

Export it from `lib/locales.dart`. Leaving a field out compiles here, because the constructor defaults it to English, so translate the whole set, and the package test that counts a pack's words against English will say so if you did not.

:::

An application that does not want to wait can write the set itself and pass it to the provider. The packs are a convenience, not the mechanism.

## Notes

- **Nothing here is a date.** Months, weekdays and number formats come from the platform on the React side and from `PlDateNames` on the Flutter one. A pack has no month in it.
- **The reading direction is separate.** An Arabic or Hebrew interface turns over from the document, not from a pack. See [Right to left](../design/rtl).
- **`PlTable` does not read the provider** on the React side, and it is the only component that does not. See the note in [Setting defaults](defaults).
