<img src="https://plass.cdget.com/128x128.png" alt="Plass UI" width="96" height="96" />

# Plass UI for Flutter

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![pub package](https://img.shields.io/pub/v/plass_ui.svg)](https://pub.dev/packages/plass_ui)

### 📘 [**plass.cdget.com**](https://plass.cdget.com)

Live previews and full parameters for every component — pick **Flutter** in the sidebar. This README is just the quick start.

---

> **Plass is one design language, shipped as two libraries.** Every surface answers a single question — is this pressed, or does it hold something? A thing you press is **tinted glass**: a gradient that _turns_ through its colour family rather than darkening, a shadow thrown in that same colour, and a bloom of light that follows your pointer across it. A thing that holds something is **clear glass**: translucent, deeply blurred, edged with a white hairline, never dyed. Nothing is bevelled, nothing is embossed and nothing moves when you press it — depth is carried by light, colour and blur.

This is the Flutter half. The [React package](https://www.npmjs.com/package/plass-ui) is the other one, and the two hold the same components under the same names, the same parameter vocabulary and the same numbers. They version independently, so this package's number and the npm one's will not always agree.

- **Finished the moment it is installed.** There is no stylesheet to import, no provider to install and no theme file to fill in. A component follows the platform's brightness until a `PlassTheme` overrides it.
- **Five parameters, not fifty.** `size`, `color`, `variant`, `density` and `elevation` mean the same thing on every component — an `md` control is 40px, `primary` is the same family — so the tenth one costs nothing to learn after the first.
- **Readable because it was measured.** Every gradient stop clears 4.5:1 against its own label, the lightest corner included. A colour choice here is not a contrast bug waiting for an audit.
- **Accessible without the checklist.** Real semantics, focus management and keyboard activation, inside the widgets.
- **Dark mode you do not write.** Follows `MediaQuery.platformBrightness`, and can be forced either way by wrapping a subtree. No second palette, no colours redeclared.
- **Nothing you did not ask for.** No dependencies at all — no assets, no platform channels, no plugins. It is built on `package:flutter/widgets.dart` alone, so it drops into any Flutter app without bringing a second design system in behind it, and it is unaffected by `material.dart` and `cupertino.dart` moving out of the framework into `material_ui` and `cupertino_ui`.

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

Plass draws controls and sheets. It does not paint your background — but a sheet of glass over a flat white page has nothing to be in front of, and every translucent surface in the library will read as opaque. Two tokens exist for exactly this:

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

## Development

```bash
flutter pub get
flutter test          # Widget tests
flutter analyze
cd example && flutter run   # The gallery, on any device
```

The gallery under `example/` is also what the documentation site embeds behind every Flutter preview, and its files under `example/lib/demos/` are the exact Dart the site quotes — so a snippet in the docs is code the analyser has checked.

## License

MIT © [CDGet](https://cdget.com)
