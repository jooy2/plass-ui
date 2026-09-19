<img src="https://plass.cdget.com/128x128.png" alt="Plass UI" width="96" height="96" />

# Plass UI for Flutter

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![pub package](https://img.shields.io/pub/v/plass_ui.svg)](https://pub.dev/packages/plass_ui)

### [**plass.cdget.com**](https://plass.cdget.com)

Live previews and full parameters for every component. Pick **Flutter** in the sidebar. This README is just the quick start.

![Plass UI components arranged around the Plass mark: a search field, a settings card, radio buttons and checkboxes, buttons and chips, a segmented button and pagination, a success alert, a slider, a progress bar and a meter, an avatar stack, a badge and a rating](https://plass.cdget.com/showcase.png)

---

> **Plass is one design language, shipped as two libraries.** 127 components made of tinted glass and gradients, in React and in Flutter, under the same names and the same numbers. React adds three more for problems only the DOM has.
>
> Every surface answers one question: is this pressed, or does it hold something? A thing you press is a tinted pane, filled with a gradient that turns through its colour family and lit by a bloom that follows your pointer. A thing that holds something is clear glass: translucent, deeply blurred, never dyed. Nothing is bevelled or embossed, and depth is carried by light, colour and blur.

This is the Flutter half. The [React package](https://www.npmjs.com/package/plass-ui) is the other one, and the two hold the same 127 components under the same names, the same parameter vocabulary and the same numbers. They version independently, so this package's number and the npm one's will not always agree.

- **Finished the moment it is installed.** There is no stylesheet to import, no provider to install and no theme file to fill in. A component follows the platform's brightness until a `PlassTheme` overrides it.
- **Five parameters, not fifty.** `size`, `color`, `variant`, `density` and `elevation` mean the same thing on every component (an `md` control is 40px, `primary` is the same family), so the tenth one costs nothing to learn after the first.
- **Readable because it was measured.** Every gradient stop clears 4.5:1 against its own label, the lightest corner included. A colour choice here is not a contrast bug waiting for an audit.
- **Accessible without the checklist.** Real semantics, focus management and keyboard activation, inside the widgets.
- **Dark mode you do not write.** Follows `MediaQuery.platformBrightness`, and can be forced either way by wrapping a subtree. No second palette, no colours redeclared.
- **Nothing you did not ask for.** No dependencies at all, no assets, no platform channels, no plugins. It is built on `package:flutter/widgets.dart` alone, so it drops into any Flutter app without bringing a second design system in behind it, and it is unaffected by `material.dart` and `cupertino.dart` moving out of the framework into `material_ui` and `cupertino_ui`.

## Install

```bash
flutter pub add plass_ui
```

Requires **Flutter 3.41 or newer** (Dart 3.11).

## Use

```dart
import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlButton(
  onPressed: save,
  child: const Text('Save'),
)
```

```dart
// `Icons` is Material's own set, and the one import above does not bring it in.
// A Cupertino app or a bare `WidgetsApp` uses whatever glyphs it already has.
import 'package:flutter/material.dart' show Icons;

PlButton(
  variant: PlassVariant.glass,
  color: PlassColor.secondary,
  size: PlassSize.lg,
  startIcon: const Icon(Icons.add),
  onPressed: newProject,
  child: const Text('New project'),
)
```

## The page under the components

Plass draws controls and sheets. It does not paint your background, but a sheet of glass over a flat white page has nothing to be in front of, and every translucent surface in the library will read as opaque. Two tokens exist for exactly this:

```dart
final tokens = PlassTheme.of(context);

DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[tokens.bgFrom, tokens.bgTo],
    ),
  ),
  child: ...,
)
```

Any backdrop with structure in it works. What does not work is nothing at all.

## Dark mode

Follows `MediaQuery.platformBrightness` with no configuration. To force it either way, wrap a subtree:

```dart
PlassTheme(brightness: Brightness.dark, child: ...)
```

One thing does **not** change with the theme, and it is deliberate: the colour of a key. What changes is the sheet it rests on.

## Components

Every widget is exported under a `Pl` prefix. `Button`, `Card` and `Table` are the most-taken identifiers in the ecosystem, and a `Pl` name is also one that survives a language with no import aliasing.

127 of them, and the [React package](https://www.npmjs.com/package/plass-ui) holds the same 127 under the same names. It has three more, `PlFlex`, `PlPortal` and `PlVisuallyHidden`, which answer problems only the DOM has; the Dart answer to each is a line of framework code rather than a widget. Every component has a page of its own with live previews and the full parameter table.

### Charts

`PlAreaChart` · `PlBarChart` · `PlGaugeChart` · `PlHeatmapChart` · `PlLineChart` · `PlPieChart` · `PlScatterChart` · `PlSparkline` · `PlTimelineChart`

### Display

`PlAppLogo` · `PlAvatar` · `PlBadge` · `PlBlockquote` · `PlBreadcrumb` · `PlChip` · `PlCodeBlock` · `PlDataList` · `PlDataTable` · `PlDivider` · `PlGallery` · `PlHighlight` · `PlHotKeys` · `PlIcon` · `PlImage` · `PlList` · `PlMockup` · `PlStat` · `PlTable` · `PlTextLink` · `PlTimeline` · `PlTree` · `PlTypography`

### Feedback

`PlAlert` · `PlConfirmProvider` · `PlDrawer` · `PlEmpty` · `PlMeter` · `PlModal` · `PlOverlay` · `PlPopconfirm` · `PlPopover` · `PlProgressBox` · `PlProgressCircular` · `PlProgressLinear` · `PlSkeleton` · `PlToast` · `PlTooltip` · `PlTour`

### Inputs

`PlButton` · `PlButtonGroup` · `PlCalendar` · `PlCheckbox` · `PlColorPicker` · `PlCombobox` · `PlDatePicker` · `PlDateRangePicker` · `PlDateTimePicker` · `PlFieldset` · `PlFilePicker` · `PlFloatingActionButton` · `PlForm` · `PlIconButton` · `PlNumberField` · `PlOtpField` · `PlPagination` · `PlRadioGroup` · `PlRating` · `PlSegmentedButton` · `PlSelect` · `PlSlider` · `PlSwitch` · `PlTextField` · `PlTimePicker` · `PlToggle` · `PlToggleGroup` · `PlTransfer` · `PlTreeSelect`

### Layout

`PlAspectRatio` · `PlContainer` · `PlFooter` · `PlGrid` · `PlHeader` · `PlPageLayout` · `PlPanes` · `PlScrollArea` · `PlScrollZone` · `PlShow` · `PlSidebar` · `PlStack`

### Navigation

`PlAnchor` · `PlBackTop` · `PlBottomNavigation` · `PlCommandPalette` · `PlFloatingBottomNavigation` · `PlMenu` · `PlMenubar` · `PlNavigationMenu` · `PlStepper`

### Surfaces

`PlAccordion` · `PlBox` · `PlCard` · `PlCarousel` · `PlChatBubble` · `PlCollapsible` · `PlHoverCard` · `PlHowToSteps` · `PlPill` · `PlSpoiler` · `PlTabs` · `PlToolbar` · `PlWindowPane`

### Transitions

`PlAnimateAppear` · `PlAnimateBlink` · `PlAnimateCounter` · `PlAnimateFade` · `PlAnimateFloat` · `PlAnimateGrow` · `PlAnimateHeadline` · `PlAnimateLighting` · `PlAnimateMarquee` · `PlAnimateReveal` · `PlAnimateRotate` · `PlAnimateScramble` · `PlAnimateShake` · `PlAnimateSlide` · `PlAnimateSplit` · `PlAnimateTyping` · `PlAnimateZoom`

## Changelog

[CHANGELOG.md](https://github.com/jooy2/plass-ui/blob/main/packages/flutter/CHANGELOG.md) is this package's history, and [plass.cdget.com/changelog](https://plass.cdget.com/changelog) is the same list beside the React package's. The two version independently, so a release on one side is not a release on the other.

## Development

```bash
flutter pub get
flutter test          # Widget tests
flutter analyze
cd example && flutter run   # The gallery, on any device
```

The gallery under `example/` is also what the documentation site embeds behind every Flutter preview, and its files under `example/lib/demos/` are the exact Dart the site quotes, so a snippet in the docs is code the analyser has checked.

## License

MIT © [CDGet](https://cdget.com)
