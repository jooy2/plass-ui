# Plass UI

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![npm latest package](https://img.shields.io/npm/v/plass-ui/latest.svg)](https://www.npmjs.com/package/plass-ui) [![npm downloads](https://img.shields.io/npm/dm/plass-ui.svg)](https://www.npmjs.com/package/plass-ui) [![pub package](https://img.shields.io/pub/v/plass_ui.svg)](https://pub.dev/packages/plass_ui)

### 📘 [**plass.cdget.com**](https://plass.cdget.com)

Live previews and full props for every component, in both frameworks. This README is the map; each package has a quick start of its own.

---

**Plass UI is a component library with a material rather than a theme.** Every surface answers one question — is this pressed, or does it hold something? — and the answer decides everything else.

A thing that is pressed is **tinted glass**: a gradient that sweeps between two ends of its colour family at 135°, a drop shadow tinted with that family, and a bloom of light that follows the pointer across it. A thing that holds something is **clear glass**: translucent, heavily blurred, a white hairline round it, and never dyed. There is no third answer.

It ships for **React** and for **Flutter**, from one design language: the same vocabulary, the same tokens, the same numbers. The documentation is one site with a framework switch in the sidebar rather than two sites that will disagree by the third release.

- **Two materials, one language** — `solid`, `glass`, `ghost`. Not `filled`, `outlined`, `text`.
- **Light instead of relief** — no bevels and no highlights. The gradient carries the form, and a soft glow follows your pointer across the control.
- **One shared vocabulary** — `size`, `color`, `variant`, `density`, `elevation`. An `md` is 40px on every control; `primary` is the same family everywhere, and the same family in the other framework.
- **Accessible by construction** — real roles, labels, focus management and keyboard support, in both packages.
- **Contrast that was checked** — every gradient stop clears 4.5:1 against its own label, the lightest corner included.
- **Dark mode with no work** — follows the platform, and can be forced either way per subtree.
- **The same 74 components on both sides**, listed at the bottom of this page.

## Packages

| Package | Registry | Requires | Quick start |
| --- | --- | --- | --- |
| [`packages/react`](packages/react) | [npm: `plass-ui`](https://www.npmjs.com/package/plass-ui) | React 18 or 19, Node.js 20.19 or later | [README](packages/react/README.md) |
| [`packages/flutter`](packages/flutter) | [pub.dev: `plass_ui`](https://pub.dev/packages/plass_ui) | Flutter 3.41 or newer (Dart 3.11) | [README](packages/flutter/README.md) |

The two **version independently** and keep separate changelogs — [`CHANGELOG.md`](CHANGELOG.md) is the React package's, [`packages/flutter/CHANGELOG.md`](packages/flutter/CHANGELOG.md) the Flutter one's. A release on one side is not a release on the other, so the numbers will not always agree.

## Install

### React

```bash
npm install plass-ui
```

```css
/* your app's CSS entry point */
@import 'plass-ui/styles.css';
```

```tsx
import { PlButton, PlTextField } from 'plass-ui';

<PlTextField label="Email" type="email" fullWidth />
<PlButton type="submit">Sign in</PlButton>
<PlButton variant="glass" color="secondary">Cancel</PlButton>
```

`react` and `react-dom` are peer dependencies; the one runtime dependency is [Base UI](https://base-ui.com). The stylesheet is finished CSS — [Tailwind CSS](https://tailwindcss.com) v4 builds this package and does not have to be installed in yours, though there is a second entry point for projects that already run it. Every component also has an entry point of its own (`plass-ui/button`), and every component carries `'use client'`, so a Next.js Server Component can import one with nothing configured.

[**The React quick start**](packages/react/README.md) has the rest.

### Flutter

```bash
flutter pub add plass_ui
```

```dart
import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlButton(
  onPressed: save,
  child: const Text('Save'),
)
```

Nothing else to install: no dependencies, no assets, no platform channels, no stylesheet and no provider. It is built on `package:flutter/widgets.dart` alone — no Material and no Cupertino — so it sits inside a Material app, a Cupertino app or a bare `WidgetsApp` without dragging a second design system in behind it, and it is unaffected by those two libraries moving out of the framework into `material_ui` and `cupertino_ui`.

[**The Flutter quick start**](packages/flutter/README.md) has the rest.

## What is the same, and what is not

The design is the same on both sides, down to the number. What differs is only what the platform decides — how a stylesheet gets in, how a theme is read, what a callback is called.

| | React | Flutter |
| --- | --- | --- |
| Component names | `PlButton`, `PlTextField` | `PlButton`, `PlTextField` |
| Shared vocabulary | `size`, `color`, `variant`, `density`, `elevation` | `PlassSize`, `PlassColor`, `PlassVariant`, `PlassDensity`, `PlassElevation` |
| Setup | one CSS import | none |
| Runtime dependencies | [Base UI](https://base-ui.com) | none |
| Tokens | CSS custom properties, `--plass-*` | `PlassTheme.of(context)` |
| Dark mode | `prefers-color-scheme`; forced with `.dark` / `[data-theme]` on any ancestor | `MediaQuery.platformBrightness`; forced with `PlassTheme(brightness: …)` |
| Handlers | `onClick`, `onValueChange` | `onPressed`, `onChanged` |
| Docs | [plass.cdget.com](https://plass.cdget.com), **React** in the sidebar | the same page, **Flutter** in the sidebar |

A component's page says exactly what differs where it differs. Where it says nothing, there is nothing.

### The page under the components

This is the one setup step neither package can do for you, and skipping it is the fastest way to conclude the glass is broken. Plass draws controls and sheets; it does not paint your background — but a sheet of glass over a flat white page has nothing to be in front of, and every translucent surface will read as opaque. Two tokens exist for exactly this, and they are the same two on both sides:

```css
body {
  background: linear-gradient(160deg, var(--plass-bg-from) 0%, var(--plass-bg-to) 100%);
  background-attachment: fixed;
  color: var(--plass-fg);
}
```

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

## Documentation

| Page | What you will find |
| --- | --- |
| [**Getting started**](https://plass.cdget.com/guide/getting-started) | Install and setup, end to end, in either framework. |
| [**Examples**](https://plass.cdget.com/examples/dashboard) | Whole screens built out of the components — a dashboard, a landing page, a sign-up flow. |
| [**All components**](https://plass.cdget.com/components/) | Every component, one page each: live previews and the full props table. |
| [**Design language**](https://plass.cdget.com/design/design-language) | Why a Plass surface looks and behaves the way it does. |
| [**Prop conventions**](https://plass.cdget.com/design/prop-conventions) | The shared vocabulary every component draws from. |
| [**Colour**](https://plass.cdget.com/design/color) | The token families, the measured contrast, and how to theme them. |
| [**Changelog**](https://plass.cdget.com/changelog) | What changed in each release. |

## Components

Every component is exported under a `Pl` prefix — `Button`, `Card` and `Table` are the most-taken identifiers in the ecosystem, and a consumer should not have to alias ours on import.

The list below is both packages'. The props are the same props under Dart's names, and each component's page says exactly what differs.

### Display

`PlAvatar` · `PlBadge` · `PlBlockquote` · `PlBreadcrumb` · `PlChip` · `PlDivider` · `PlHighlight` · `PlHotKeys` · `PlIcon` · `PlList` · `PlTable` · `PlTextLink` · `PlTimeline` · `PlTypography`

### Feedback

`PlAlert` · `PlDrawer` · `PlModal` · `PlOverlay` · `PlPopover` · `PlProgressBox` · `PlProgressCircular` · `PlProgressLinear` · `PlSkeleton` · `PlToast` · `PlTooltip`

### Inputs

`PlButton` · `PlButtonGroup` · `PlCheckbox` · `PlCombobox` · `PlDatePicker` · `PlDateRangePicker` · `PlDateTimePicker` · `PlFilePicker` · `PlIconButton` · `PlNumberField` · `PlOtpField` · `PlPagination` · `PlRadioGroup` · `PlRating` · `PlSegmentedButton` · `PlSelect` · `PlSlider` · `PlSwitch` · `PlTextField` · `PlTimePicker`

### Layout

`PlAspectRatio` · `PlContainer` · `PlGrid` · `PlPanes` · `PlScrollZone`

### Navigation

`PlBottomNavigation` · `PlContextMenu` · `PlFloatingBottomNavigation` · `PlMenu`

### Surfaces

`PlAccordion` · `PlBox` · `PlCard` · `PlCarousel` · `PlChatBubble` · `PlCollapsible` · `PlPill` · `PlSpoiler` · `PlTabs` · `PlToolbar`

### Transitions

`PlAnimateAppear` · `PlAnimateBlink` · `PlAnimateFade` · `PlAnimateGrow` · `PlAnimateHeadline` · `PlAnimateLighting` · `PlAnimateMarquee` · `PlAnimateRotate` · `PlAnimateSlide` · `PlAnimateTyping` · `PlAnimateZoom`

## Development

One design language, three things built out of it. Each is entered and run on its own — there is no install at the repository root and no root `package.json`.

```bash
cd packages/react
npm install
npm test              # Vitest, single run (headless Chromium)
npm run typecheck     # tsc --noEmit over both TS projects
npm run build         # tsc + terser + build-styles → dist/
npm run lint          # ESLint
```

```bash
cd packages/flutter
flutter pub get
flutter test          # Widget tests
flutter analyze
cd example && flutter run   # The gallery, on any device
```

```bash
cd docs
npm install
npm run flutter:demos # Compiles the gallery into public/flutter (needs the Flutter SDK)
npm run dev           # VitePress — the develop-and-eyeball loop
npm run build
```

The site renders the React components from `packages/react/src` through a Vite alias and embeds the Flutter gallery as a frame per preview, so `npm run dev` is the develop-and-eyeball loop for both; there is no separate demo app. Editing a component shows up immediately on the React side; the Flutter side needs `npm run flutter:demos` again.

[CONTRIBUTING.md](CONTRIBUTING.md) is the rest — where things live, and how a change to a component is expected to arrive.

## License

MIT © [CDGet](https://cdget.com)
