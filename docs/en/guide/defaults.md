---
title: Setting defaults
order: 2
---

# Setting defaults

<p class="plass-lede">A <code>PlassProvider</code> decides <code>size</code>, <code>color</code>, <code>density</code> and the date vocabulary for everything under it. It is optional, the library is finished without one, and what it removes is transcription.</p>

<Demo src="provider/defaults" :min-height="320" />

::: fw react

```tsx
import { PlassProvider } from 'plass-ui';

<PlassProvider size="sm" density="compact" locale="ko-KR">
  <App />
</PlassProvider>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlassTheme.merge(
  defaults: const PlassDefaults(
    size: PlassSize.sm,
    density: PlassDensity.compact,
    names: PlDateNames(months: <String>['January', '…']),
  ),
  child: const MyApp(),
);
```

**Use `PlassTheme.merge`, not the plain constructor.** The constructor _replaces_ the defaults in scope; `merge` keeps the ones above it. It is the same split as `DefaultTextStyle` and `DefaultTextStyle.merge`, for the same reason: an `InheritedWidget` has no context of its own to read an ancestor with, so merging has to happen where there is one. `merge` keeps the brightness in scope too, so a section of a dark screen can be made compact without going light.

:::

## The settings

|                |                                                                             |
| -------------- | --------------------------------------------------------------------------- |
| `size`         | The rung of the size ladder every component starts from                     |
| `color`        | The semantic family they start from                                         |
| `density`      | How tightly they pack their content                                         |
| `locale`       | The BCP 47 tag the date, time and number components format and read against |
| `weekStartsOn` | Which day their weeks start on, as `Date` counts them. Sunday is `0`        |
| `labels`       | The words the components say that `Intl` has no opinion about               |

::: fw react

It carries one more thing that is not a default: **the reading direction**. See [Right to left](../design/rtl). A `dir="rtl"` document turns the layout over on its own, and this is what carries that to the behaviours that read the direction in JavaScript. There is nothing to set; `direction` is only for a subtree that runs the other way from the page around it.

:::

::: fw flutter

`locale` is `names` and `labels` here. The framework ships no `Intl`, so the words themselves are what a theme carries. `PlDateNames` holds the months and the weekdays; `PlassLabels` holds everything the widgets say about themselves, and [Translating the words](locales) is the page about it.

:::

## Deliberate omissions

**`variant` and `elevation` are deliberately absent**, and this is the part worth reading before filing it as a gap.

`variant` names what a surface is _made of_, and the [design language](../design/design-language) spends its first paragraph on the fact that a thing you press and a thing that holds content are different materials. A `PlButton` defaults to `solid` and a `PlCard` to `glass` because that is the arrangement, not because nobody got round to configuring it. One value for both would flatten the distinction rather than set a default.

`elevation` is per-component semantics for the same reason: a control rests **on** the sheet and defaults to `1`, a field is cut **into** it and defaults to `0`. A single number for the two says the opposite of what the ladder means.

An application that genuinely wants every button `glass` writes it on the buttons. There are far fewer of those than there are call sites where `size="sm"` was being repeated.

## Precedence

Four layers, and the order is the one a reader would guess:

**the component's own prop → whatever set it is in → the nearest provider → the component's own default.**

```tsx
<PlassProvider size="sm">
  <PlButtonGroup size="lg">
    <PlButton>lg, from the group</PlButton>
    <PlButton size="xs">xs, from its own prop</PlButton>
  </PlButtonGroup>

  <PlButton>sm, from the provider</PlButton>
</PlassProvider>
```

Providers **nest and merge**. A section that is compact inside an application that is not says only `density`, and keeps the `locale` and the `size` from the provider above it.

## Examples

### One locale, five pickers

`locale` reaches `PlCalendar`, `PlDatePicker`, `PlDateRangePicker`, `PlTimePicker`, `PlDateTimePicker` and `PlNumberField`. `labels` is merged **under** each component's own, so an application can translate the vocabulary once and one picker can still say something different, a "Check in" where the rest of the app says "Start". The library ships that vocabulary translated: see [Translating the words](locales).

<Demo src="provider/locale" :min-height="200">

::: fw react

<<< @/.vitepress/demos/provider/locale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/provider/locale.dart

:::

</Demo>

### Reading what is in scope

```tsx
import { usePlassDefaults } from 'plass-ui';

const { size, locale } = usePlassDefaults();
```

For a component of your own that has to line up with the ones around it. Every field is optional. Nothing is decided until a provider decides it.

## Notes

::: fw flutter

- **Every widget reads it**, `PlTable` included: there is no server-component boundary here, so the one exception the React build has does not exist.
- A `PlassTheme` given only `defaults` still needs `merge` to keep the brightness above it. See the note under the first example.

:::

::: fw react

- **`PlTable` does not read the provider**, and it is the only component that does not. It is kept out of the React Server Component client graph on purpose (every one of its columns is a `render` callback, and a server component cannot hand a function across that boundary), and reading a context would make it a client component. Set its `size` and `density` on the component.
- The provider renders no element and draws nothing. It costs one context read per component, plus one observer on `<html>` for the whole page. The direction is read off the document rather than configured.
- It is not a theme. The colours, the radii, the blur and the shadows are CSS custom properties, and the place to change those is [Colour](../design/color#overriding-a-family). A second copy of them in JavaScript would be a second source of truth.

:::
