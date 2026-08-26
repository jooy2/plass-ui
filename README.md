# Plass UI

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![npm latest package](https://img.shields.io/npm/v/plass-ui/latest.svg)](https://www.npmjs.com/package/plass-ui) [![npm downloads](https://img.shields.io/npm/dm/plass-ui.svg)](https://www.npmjs.com/package/plass-ui) [![pub package](https://img.shields.io/pub/v/plass_ui.svg)](https://pub.dev/packages/plass_ui)

### 📘 [**plass.cdget.com**](https://plass.cdget.com)

Live previews and full props for every component. This README is just the quick start.

---

**Plass UI is a component library with a material rather than a theme.** Every surface answers one question — is this pressed, or does it hold something? — and the answer decides everything else.

It ships for **React** and for **Flutter**, from one design language: the same vocabulary, the same tokens, the same numbers. The documentation is one site with a framework switch in the sidebar rather than two sites that will disagree by the third release.

A thing that is pressed is **tinted glass**: a gradient that sweeps between two ends of its colour family at 135°, a drop shadow tinted with that family, and a bloom of light that follows the pointer across it. A thing that holds something is **clear glass**: translucent, heavily blurred, a white hairline round it, and never dyed. There is no third answer.

- **Two materials, one language** — `solid`, `glass`, `ghost`. Not `filled`, `outlined`, `text`.
- **Light instead of relief** — no bevels and no highlights. The gradient carries the form, and a soft glow follows your pointer across the control.
- **One shared vocabulary** — `size`, `color`, `variant`, `density`, `elevation`. An `md` is 40px on every control; `primary` is the same family everywhere.
- **Accessible by construction** — real roles, labels, focus management and keyboard support, not `div`s with click handlers.
- **Contrast that was checked** — every gradient stop clears 4.5:1 against its own label, the lightest corner included.
- **Dark mode with no work** — follows the system, and can be forced either way per subtree.
- **ESM only**, TypeScript declarations included, tree-shakeable.
- **One runtime dependency** on React (18 or 19, Node.js 20.19 or later); **none at all** on Flutter, which is also built without `material.dart` or `cupertino.dart`.

> **0.0.1 is a preview.** Both packages ship the same library — every component listed below exists in each. The shape they are poured into — the prop vocabulary, the tokens, the build — is settled. The API is not frozen yet.

## Packages

| Package | Registry | Requires |
| --- | --- | --- |
| [`packages/react`](packages/react) | [npm: `plass-ui`](https://www.npmjs.com/package/plass-ui) | React 18 or 19 |
| [`packages/flutter`](packages/flutter) | [pub.dev: `plass_ui`](https://pub.dev/packages/plass_ui) | Flutter 3.41 or newer |

## Documentation

| Page | What you will find |
| --- | --- |
| [**Getting started**](https://plass.cdget.com/guide/getting-started) | Install and setup, end to end. |
| [**All components**](https://plass.cdget.com/components/) | Every component, one page each: live previews and the full props table. |
| [**Design language**](https://plass.cdget.com/design/design-language) | Why a Plass surface looks and behaves the way it does. |
| [**Prop conventions**](https://plass.cdget.com/design/prop-conventions) | The shared vocabulary every component draws from. |
| [**Colour**](https://plass.cdget.com/design/color) | The token families, the measured contrast, and how to theme them. |
| [**Changelog**](https://plass.cdget.com/changelog) | What changed in each release. |

## Installation

```bash
npm install plass-ui
```

`react` and `react-dom` are peer dependencies — React 18 or 19.

```bash
flutter pub add plass_ui
```

Nothing else to install: the Flutter package has no dependencies, no assets and no platform channels. There is no stylesheet to wire up either — a component works with no ancestor, following the platform's brightness until a `PlassTheme` says otherwise.

### Setup

Add one line to your app's CSS entry point:

```css
@import 'plass-ui/styles.css';
```

`plass-ui/styles.css` is finished CSS — the design tokens, the compiled rules for every utility class the components use, and a small reset whose every rule is specificity 0 so your own styles always win. [Tailwind CSS](https://tailwindcss.com) v4 builds this package; it does not have to be installed in yours.

If your project already runs Tailwind v4, import the token sheet instead:

```css
@import 'tailwindcss';
@import 'plass-ui/tailwind.css';
```

### One more line, and it matters here

Plass does not paint your `<body>`, but a sheet of glass over a flat white page has nothing to be in front of. Two tokens exist for exactly this:

```css
body {
  background: linear-gradient(160deg, var(--plass-bg-from) 0%, var(--plass-bg-to) 100%);
  background-attachment: fixed;
  color: var(--plass-fg);
}
```

## Usage

```tsx
import { PlButton, PlTextField } from 'plass-ui';

export default function SignIn() {
  return (
    <form onSubmit={submit}>
      <PlTextField label="Email" type="email" fullWidth />
      <PlButton type="submit">Sign in</PlButton>
      <PlButton variant="glass" color="secondary">
        Cancel
      </PlButton>
    </form>
  );
}
```

## Components

Every component is exported under a `Pl` prefix — `Button`, `Card` and `Table` are the most-taken identifiers in the ecosystem, and a consumer should not have to alias ours on import.

The list below is both packages'. The props are the same props under Dart's names, and each component's page says exactly what differs.

### Display

`PlAvatar` · `PlBadge` · `PlBlockquote` · `PlBreadcrumb` · `PlChip` · `PlDivider` · `PlHighlight` · `PlHotKeys` · `PlIcon` · `PlList` · `PlTable` · `PlTextLink` · `PlTimeline` · `PlTypography`

### Feedback

`PlAlert` · `PlModal` · `PlOverlay` · `PlSkeleton` · `PlToast` · `PlTooltip`

### Inputs

`PlButton` · `PlCheckbox` · `PlFilePicker` · `PlIconButton` · `PlNumberField` · `PlOtpField` · `PlPagination` · `PlRadioGroup` · `PlRating` · `PlSegmentedButton` · `PlSelect` · `PlSlider` · `PlSwitch` · `PlTextField`

### Layout

`PlAspectRatio` · `PlContainer` · `PlGrid`

### Surfaces

`PlAccordion` · `PlCard` · `PlChatBubble` · `PlTabs`

## Development

Each package is installed and run from its own folder; there is no root install.

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

## License

MIT © [CDGet](https://cdget.com)
