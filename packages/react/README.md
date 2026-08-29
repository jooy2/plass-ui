# Plass UI for React

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![npm latest package](https://img.shields.io/npm/v/plass-ui/latest.svg)](https://www.npmjs.com/package/plass-ui) [![npm downloads](https://img.shields.io/npm/dm/plass-ui.svg)](https://www.npmjs.com/package/plass-ui)

### 📘 [**plass.cdget.com**](https://plass.cdget.com)

Live previews and full props for every component — pick **React** in the sidebar. This README is just the quick start.

---

**Plass UI is a component library with a material rather than a theme.** Every surface answers one question — is this pressed, or does it hold something? — and the answer decides everything else.

A thing that is pressed is **tinted glass**: a gradient that sweeps between two ends of its colour family at 135°, a drop shadow tinted with that family, and a bloom of light that follows the pointer across it. A thing that holds something is **clear glass**: translucent, heavily blurred, a white hairline round it, and never dyed. There is no third answer.

This is the React half of that language. The [Flutter package](https://pub.dev/packages/plass_ui) is the other one, and the two are the same numbers.

- **Two materials, one language** — `solid`, `glass`, `ghost`. Not `filled`, `outlined`, `text`.
- **Light instead of relief** — no bevels and no highlights. The gradient carries the form, and a soft glow follows your pointer across the control.
- **One shared vocabulary** — `size`, `color`, `variant`, `density`, `elevation`. An `md` is 40px on every control; `primary` is the same family everywhere, and the same family it is in Flutter.
- **Accessible by construction** — real roles, labels, focus management and keyboard support, not `div`s with click handlers.
- **Contrast that was checked** — every gradient stop clears 4.5:1 against its own label, the lightest corner included.
- **Dark mode with no work** — follows `prefers-color-scheme`, and can be forced either way per subtree.
- **ESM only**, TypeScript declarations included, tree-shakeable, with an entry point per component.
- **One runtime dependency**, [Base UI](https://base-ui.com), which is where the interaction and accessibility behaviour comes from.

> **Both packages ship the same library.** Every component listed below exists in each, under the same prop vocabulary and the same tokens. They version independently, so this package's number and the Flutter one's will not always agree.

## Install

```bash
npm install plass-ui
```

`react` and `react-dom` are peer dependencies — React 18 or 19. Node.js 20.19 or later.

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

`plass-ui/tailwind.css` registers all 74 components with Tailwind, because Tailwind scans files rather than imports — nothing in a build connects `import { PlButton }` to the classes `PlSelect.js` spells out. A project that uses a handful of components can register the handful instead:

```css
@import 'tailwindcss';
@import 'plass-ui/css/base.css'; /* tokens + what every component shares */
@import 'plass-ui/css/button.css';
@import 'plass-ui/css/text-field.css';
```

Still one Tailwind pass, so the utilities keep Tailwind's own order — and about 5 kB gzipped smaller for a small set of components. There is one manifest per component, named after its folder in `dist/components`.

### The page under the components

Plass draws controls and sheets. It does not paint your `<body>` — but a sheet of glass over a flat white page has nothing to be in front of, and every translucent surface in the library will read as opaque. Two tokens exist for exactly this:

```css
body {
  background: linear-gradient(160deg, var(--plass-bg-from) 0%, var(--plass-bg-to) 100%);
  background-attachment: fixed;
  color: var(--plass-fg);
}
```

Any backdrop with structure in it works. What does not work is nothing at all.

## Use

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

### One entry point per component

Every component also has an entry point of its own, for a build that cannot tree-shake a barrel — or for a server render, where the barrel loads all 74 components and their dependencies before the first one is used:

```tsx
import { PlButton } from 'plass-ui/button';
```

Same component, same types. The barrel is the one to reach for by default; this is the escape hatch when a bundler, a test runner or Node's own loader is the thing paying for it.

### Next.js and server components

Every component carries `'use client'`, so a Server Component can import one directly and there is nothing to configure — no `transpilePackages`, no `next.config` entry, no provider. What the directive cannot do is carry a function across the server boundary: a file that passes `onClick`, `onValueChange` or `render` needs its own `'use client'`, which is React's rule for every client component rather than this library's. Outside a server-component graph the directive is inert.

### Dark mode

Follows `prefers-color-scheme` with no configuration. To force it either way, put `.dark` / `.light` — or `[data-theme='dark']` / `[data-theme='light']` — on any ancestor, `<html>` included.

One thing does **not** change with the theme, and it is deliberate: the colour of a key. What changes is the sheet it rests on.

## Components

Every component is exported under a `Pl` prefix — `Button`, `Card` and `Table` are the most-taken identifiers in the ecosystem, and a consumer should not have to alias ours on import.

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

This package is installed and run from its own folder; there is no install at the repository root.

```bash
npm install
npm test              # Vitest, single run (headless Chromium)
npm run typecheck     # tsc --noEmit over both TS projects
npm run build         # tsc + terser + build-styles → dist/
npm run lint          # ESLint
npm run size          # what the package costs, packed and installed
```

The documentation site lives at the repository root, in [`docs/`](https://github.com/jooy2/plass-ui/tree/main/docs), and renders these components from `src/` through a Vite alias — so `cd docs && npm run dev` is the develop-and-eyeball loop and there is no separate demo app. [CONTRIBUTING.md](https://github.com/jooy2/plass-ui/blob/main/CONTRIBUTING.md) has the rest.

## License

MIT © [CDGet](https://cdget.com)
