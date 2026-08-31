<img src="docs/public/128x128.png" alt="Plass UI" width="96" height="96" />

# Plass UI

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![npm latest package](https://img.shields.io/npm/v/plass-ui/latest.svg)](https://www.npmjs.com/package/plass-ui) [![npm downloads](https://img.shields.io/npm/dm/plass-ui.svg)](https://www.npmjs.com/package/plass-ui) [![pub package](https://img.shields.io/pub/v/plass_ui.svg)](https://pub.dev/packages/plass_ui)

### 📘 [**plass.cdget.com**](https://plass.cdget.com)

Live previews and full props for every component, in both frameworks. This README is the map; each package has a quick start of its own.

---

> **Plass is one design language, shipped as two libraries.** Every surface answers a single question — is this pressed, or does it hold something? A thing you press is **tinted glass**: a gradient that _turns_ through its colour family rather than darkening, a shadow thrown in that same colour, and a bloom of light that follows your pointer across it. A thing that holds something is **clear glass**: translucent, deeply blurred, edged with a white hairline, never dyed. Nothing is bevelled, nothing is embossed and nothing moves when you press it — depth is carried by light, colour and blur. That is the whole system, and it is the same ninety-six components under the same names and the same numbers whether you build in **React** or in **Flutter**.

## Why Plass

- **Finished the moment it is installed.** The gradients, the shadows, the blur, the focus ring and the press response are already decided and already agree with each other. There is no theme file to fill in before the first screen looks like something.
- **Learn it once, use it on both.** Eighty-seven components in React and in Flutter under the same names: an `md` control is 40px on either side, `primary` is the same colour family, and one documentation page — with a framework switch in the sidebar — covers the two rather than drifting apart by the third release.
- **Five props, not fifty.** `size`, `color`, `variant`, `density` and `elevation` mean the same thing on every component, so the tenth one costs nothing to learn after the first.
- **Readable because it was measured.** Every gradient stop clears 4.5:1 against its own label, the lightest corner included. A colour choice here is not a contrast bug waiting for an audit.
- **Accessible without the checklist.** Roles, labels, keyboard operation and focus management live inside the components rather than being bolted on afterwards.
- **Dark mode you do not write.** It follows the platform and can be forced either way on any subtree. No second palette, no colours redeclared.
- **Nothing you did not ask for.** The npm package is ESM and tree-shakeable with a single runtime dependency, so only what you import is bundled. The pub package has no dependencies at all — no assets, no plugins, no stylesheet, no provider.

## Packages

| Package                                | Registry                                                  | Requires                               | Quick start                          |
| -------------------------------------- | --------------------------------------------------------- | -------------------------------------- | ------------------------------------ |
| [`packages/react`](packages/react)     | [npm: `plass-ui`](https://www.npmjs.com/package/plass-ui) | React 18 or 19, Node.js 20.19 or later | [README](packages/react/README.md)   |
| [`packages/flutter`](packages/flutter) | [pub.dev: `plass_ui`](https://pub.dev/packages/plass_ui)  | Flutter 3.41 or newer (Dart 3.11)      | [README](packages/flutter/README.md) |

The two **version independently** and keep separate changelogs — [`packages/react/CHANGELOG.md`](packages/react/CHANGELOG.md) is the React package's, [`packages/flutter/CHANGELOG.md`](packages/flutter/CHANGELOG.md) the Flutter one's. A release on one side is not a release on the other, so the numbers will not always agree.

## Install

### React

```bash
npm install plass-ui
```

```css
/* your app's CSS entry point */
@import "plass-ui/styles.css";
```

```tsx
import { PlButton, PlTextField } from 'plass-ui';

<PlTextField label="Email" type="email" fullWidth />
<PlButton type="submit">Sign in</PlButton>
<PlButton variant="glass" color="secondary">Cancel</PlButton>
```

`react` and `react-dom` are peer dependencies — React 18 or 19. The stylesheet is finished CSS: [Tailwind CSS](https://tailwindcss.com) v4 builds this package and does not have to be installed in yours, though there is a second entry point for a project that already runs it. Every component has an entry point of its own (`plass-ui/button`) and nearly all of them carry `'use client'`, so a Next.js Server Component can import one with nothing configured — and `PlTable`, whose columns are `render` callbacks, deliberately does not, so a server-rendered page can use its own API.

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

Nothing else to install: no dependencies, no assets, no platform channels, no stylesheet and no provider. It is built on `package:flutter/widgets.dart` alone, so it drops into any Flutter app without bringing a second design system in behind it — and it is unaffected by `material.dart` and `cupertino.dart` moving out of the framework into `material_ui` and `cupertino_ui`.

[**The Flutter quick start**](packages/flutter/README.md) has the rest.

## The page under the components

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

| Page                                                                    | What you will find                                                                       |
| ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| [**Getting started**](https://plass.cdget.com/guide/getting-started)    | Install and setup, end to end, in either framework.                                      |
| [**Examples**](https://plass.cdget.com/examples/dashboard)              | Whole screens built out of the components — a dashboard, a landing page, a sign-up flow. |
| [**All components**](https://plass.cdget.com/components/)               | Every component, one page each: live previews and the full props table.                  |
| [**Design language**](https://plass.cdget.com/design/design-language)   | Why a Plass surface looks and behaves the way it does.                                   |
| [**Prop conventions**](https://plass.cdget.com/design/prop-conventions) | The shared vocabulary every component draws from.                                        |
| [**Colour**](https://plass.cdget.com/design/color)                      | The token families, the measured contrast, and how to theme them.                        |
| [**Changelog**](https://plass.cdget.com/changelog)                      | What changed in each release.                                                            |

## Components

Every component is exported under a `Pl` prefix — `Button`, `Card` and `Table` are the most-taken identifiers in the ecosystem, and a consumer should not have to alias ours on import.

The list below is both packages'. The props are the same props under Dart's names, and each component's page says exactly what differs.

A **†** marks the few that are React-only. They are not omissions — each one answers a problem only the DOM has, and the Dart answer is a line of framework code rather than a component. Their pages say which.

### Display

`PlAvatar` · `PlAvatarGroup` · `PlBadge` · `PlBlockquote` · `PlBreadcrumb` · `PlChip` · `PlDivider` · `PlHighlight` · `PlHotKeys` · `PlIcon` · `PlImage` · `PlList` · `PlTable` · `PlStat` · `PlTextLink` · `PlTimeline` · `PlTree` · `PlTypography` · `PlVisuallyHidden`†

### Feedback

`PlAlert` · `PlConfirmProvider` · `PlDrawer` · `PlEmpty` · `PlModal` · `PlOverlay` · `PlPopconfirm` · `PlPopover` · `PlProgressBox` · `PlProgressCircular` · `PlProgressLinear` · `PlSkeleton` · `PlToast` · `PlTooltip`

### Inputs

`PlButton` · `PlButtonGroup` · `PlCalendar` · `PlCheckbox` · `PlColorPicker` · `PlCombobox` · `PlDatePicker` · `PlDateRangePicker` · `PlDateTimePicker` · `PlFieldset` · `PlFilePicker` · `PlForm` · `PlIconButton` · `PlNumberField` · `PlOtpField` · `PlPagination` · `PlRadioGroup` · `PlRating` · `PlSegmentedButton` · `PlSelect` · `PlSlider` · `PlSwitch` · `PlTextField` · `PlTimePicker` · `PlToggle` · `PlToggleGroup` · `PlTransfer`

### Layout

`PlAspectRatio` · `PlContainer` · `PlFooter` · `PlGrid` · `PlHeader` · `PlPageLayout` · `PlPanes` · `PlScrollZone` · `PlSidebar`

### Navigation

`PlBackTop` · `PlBottomNavigation` · `PlCommandPalette` · `PlContextMenu` · `PlFloatingBottomNavigation` · `PlMenu` · `PlMenubar` · `PlNavigationMenu` · `PlStepper`

### Surfaces

`PlAccordion` · `PlBox` · `PlCard` · `PlCarousel` · `PlChatBubble` · `PlCollapsible` · `PlPill` · `PlSpoiler` · `PlTabs` · `PlToolbar`

### Transitions

`PlAnimateAppear` · `PlAnimateBlink` · `PlAnimateFade` · `PlAnimateGrow` · `PlAnimateHeadline` · `PlAnimateLighting` · `PlAnimateMarquee` · `PlAnimateRotate` · `PlAnimateSlide` · `PlAnimateTyping` · `PlAnimateZoom`

## Setting defaults

`size`, `color`, `density` and the date vocabulary can be decided once for an application rather than at every call site. Optional — the library is finished without it.

```tsx
import { PlassProvider } from 'plass-ui';

<PlassProvider size="sm" density="compact" locale="ko-KR">
  <App />
</PlassProvider>;
```

It deliberately does **not** set `variant` or `elevation`: those name what a surface is made of and how far off the page it sits, and both are decided per component by the design language — a button is `solid` and rests on the sheet, a field is cut into it. [The guide](https://plass.cdget.com/guide/defaults) has the long version, and the precedence: a component's own prop beats the set it is in, which beats the provider.

The Flutter package does the same through `PlassTheme.merge`, which also carries the date vocabulary — `names` and `labels` are what a `locale` is there, since the framework ships no `Intl`.

## Hooks

React-only, and the machinery the library already ran on rather than anything new. Import them from the barrel or from `plass-ui/hooks`.

| Hook | What it answers |
| --- | --- |
| `usePlMediaQuery` | Whether the window matches a CSS media query, re-rendering when it stops |
| `usePlBreakpoint` | Which rung of the breakpoint ladder the window is on |
| `usePlBreakpointValue` | What a `PlassResponsive` map resolves to at that rung |
| `usePlReducedMotion` | Whether the reader has asked their platform for less movement |
| `usePlHotKeys` | Binds keyboard chords, spelled the way `PlHotKeys` draws them |
| `usePlassDefaults` | What the nearest `PlassProvider` decided |
| `usePlColorScheme` | The dark mode toggle — the choice, where it is kept, and what it writes |
| `usePlToast` | Raises a toast from a click handler, under a `PlToastProvider` |

Flutter answers the same questions with framework calls — `MediaQuery`, `PlassTheme` — rather than with anything this package would add. Each hook's page names the Dart equivalent.

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
