# Plass UI for Flutter

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![pub package](https://img.shields.io/pub/v/plass_ui.svg)](https://pub.dev/packages/plass_ui)

### 📘 [**plass.cdget.com**](https://plass.cdget.com)

Live previews and full parameters for every component — pick **Flutter** in the sidebar. This README is just the quick start.

---

**Plass UI is a component library with a material rather than a theme.** Every surface answers one question — is this pressed, or does it hold something? — and the answer decides everything else.

A thing that is pressed is **tinted glass**: a gradient that sweeps between two ends of its colour family at 135°, a drop shadow tinted with that family, and a bloom of light that follows the pointer across it. A thing that holds something is **clear glass**: translucent, heavily blurred, a white hairline round it, and never dyed. There is no third answer.

This is the Flutter half of that language. The [React package](https://www.npmjs.com/package/plass-ui) is the other one, and the two are the same numbers.

- **No Material, no Cupertino.** Built on `package:flutter/widgets.dart` alone, so it sits inside a Material app, a Cupertino app or a bare `WidgetsApp` without dragging a second design system in behind it — and it is unaffected by those two libraries moving out of the framework into `material_ui` and `cupertino_ui`.
- **No dependencies.** None. No assets, no platform channels, no plugins.
- **No setup.** There is no stylesheet to import and no provider to install. A component follows the platform's brightness until a `PlassTheme` overrides it.
- **One shared vocabulary** — `size`, `color`, `variant`, `density`, `elevation`. An `md` is 40px on every control; `primary` is the same family everywhere, and the same family it is in React.
- **Accessible by construction** — real semantics, focus management and keyboard activation.

> **This is still a preview.** All thirty-five components are here now, alongside the tokens, the scales and the theme they are built on. What a component _says_ — its parameters and its defaults — is settled enough to read; what it will look like after the first round of real use is not.

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
