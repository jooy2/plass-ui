<img src="https://plass.cdget.com/128x128.png" alt="Plass UI" width="96" height="96" />

# Plass UI for React

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![npm latest package](https://img.shields.io/npm/v/plass-ui/latest.svg)](https://www.npmjs.com/package/plass-ui) [![npm downloads](https://img.shields.io/npm/dm/plass-ui.svg)](https://www.npmjs.com/package/plass-ui)

### [**plass.cdget.com**](https://plass.cdget.com)

Live previews and full props for every component. Pick **React** in the sidebar. This README is just the quick start.

![Plass UI components arranged around the Plass mark: a search field, a settings card, radio buttons and checkboxes, buttons and chips, a segmented button and pagination, a success alert, a slider, a progress bar and a meter, an avatar stack, a badge and a rating](https://plass.cdget.com/showcase.png)

---

> **Plass is one design language, shipped as two libraries.** 127 components made of tinted glass and gradients, in React and in Flutter, under the same names and the same numbers. React adds three more for problems only the DOM has.
>
> Every surface answers one question: is this pressed, or does it hold something? A thing you press is a tinted pane, filled with a gradient that turns through its colour family and lit by a bloom that follows your pointer. A thing that holds something is clear glass: translucent, deeply blurred, never dyed. Nothing is bevelled or embossed, and depth is carried by light, colour and blur.

This is the React half. The [Flutter package](https://pub.dev/packages/plass_ui) is the other one, and the two hold the same 127 components under the same names, the same prop vocabulary and the same numbers. They version independently, so this package's number and the pub.dev one's will not always agree.

- **Finished the moment it is installed.** The gradients, the shadows, the blur, the focus ring and the press response are already decided and already agree with each other. One CSS import and the first screen looks like something.
- **Five props, not fifty.** `size`, `color`, `variant`, `density` and `elevation` mean the same thing on every component (an `md` control is 40px, `primary` is the same family), so the tenth one costs nothing to learn after the first.
- **Readable because it was measured.** Every gradient stop clears 4.5:1 against its own label, the lightest corner included. A colour choice here is not a contrast bug waiting for an audit.
- **Accessible without the checklist.** Real roles, labels, focus management and keyboard support, not `div`s with click handlers.
- **Dark mode you do not write.** Follows `prefers-color-scheme`, and can be forced either way on any subtree. No second palette, no colours redeclared.
- **Types in the box.** TypeScript declarations ship with the package, so your editor knows the prop names and the values they take before you do.
- **Nothing you did not ask for.** ESM only, tree-shakeable, two runtime dependencies (`@base-ui/react` and `highlight.js`), and an entry point per component for a build that cannot shake a barrel.

## Install

```bash
npm install plass-ui
```

`react` and `react-dom` are peer dependencies, React 18 or 19. Node.js 20.19 or later.

### Setup

Add one line to your app's CSS entry point:

```css
@import 'plass-ui/styles.css';
```

`plass-ui/styles.css` is finished CSS, the design tokens, the compiled rules for every utility class the components use, and a small reset whose every rule is specificity 0 so your own styles always win. [Tailwind CSS](https://tailwindcss.com) v4 builds this package; it does not have to be installed in yours.

If your project already runs Tailwind v4, import the token sheet instead:

```css
@import 'tailwindcss';
@import 'plass-ui/tailwind.css';
```

`plass-ui/tailwind.css` registers all 130 components with Tailwind, because Tailwind scans files rather than imports, nothing in a build connects `import { PlButton }` to the classes `PlSelect.js` spells out. A project that uses a handful of components can register the handful instead:

```css
@import 'tailwindcss';
@import 'plass-ui/css/base.css'; /* tokens + what every component shares */
@import 'plass-ui/css/button.css';
@import 'plass-ui/css/text-field.css';
```

Still one Tailwind pass, so the utilities keep Tailwind's own order, and about 5 kB gzipped smaller for a small set of components. There is one manifest per component, named after its folder in `dist/components`.

### The page under the components

Plass draws controls and sheets. It does not paint your `<body>`, but a sheet of glass over a flat white page has nothing to be in front of, and every translucent surface in the library will read as opaque. Two tokens exist for exactly this:

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

Every component also has an entry point of its own, for a build that cannot tree-shake a barrel, or for a server render, where the barrel loads all 130 components and their dependencies before the first one is used:

```tsx
import { PlButton } from 'plass-ui/button';
```

Same component, same types. The barrel is the one to reach for by default; this is the escape hatch when a bundler, a test runner or Node's own loader is the thing paying for it.

### Next.js and server components

Nearly every component carries `'use client'`, so a Server Component can import one directly and there is nothing to configure, no `transpilePackages`, no `next.config` entry, no provider. What the directive cannot do is carry a function across the server boundary: a file that passes `onClick`, `onValueChange` or `render` needs its own `'use client'`, which is React's rule for every client component rather than this library's. Outside a server-component graph the directive is inert.

`PlTable` is the exception and has no directive, because that rule would otherwise have cost it its own API: every column is a `render` callback, and a table belongs on a page that fetches its own rows. A Server Component renders it whole; a client module that imports it gets a client component, as it does for anything else it imports.

### Dark mode

Follows `prefers-color-scheme` with no configuration. To force it either way, put `.dark` / `.light` (or `[data-theme='dark']` / `[data-theme='light']`) on any ancestor, `<html>` included.

One thing does **not** change with the theme, and it is deliberate: the colour of a key. What changes is the sheet it rests on.

## Components

Every component is exported under a `Pl` prefix. `Button`, `Card` and `Table` are the most-taken identifiers in the ecosystem, and a consumer should not have to alias ours on import.

130 of them, one for each folder in `dist/components`. The [Flutter package](https://pub.dev/packages/plass_ui) holds 127 of these under the same names, and the other three, `PlFlex`, `PlPortal` and `PlVisuallyHidden`, answer problems only the DOM has. Every component has a page of its own with live previews and the full props table.

The list also names two exports that are not counted, because each shares a folder and a page with another component: `PlToggleGroup`, beside `PlToggle`, and `PlContextMenu`, a second trigger onto `PlMenu`'s surface. Flutter has `PlToggleGroup` but not `PlContextMenu`, for a reason of its own: no right-click gesture means the same thing on every platform Flutter runs on, so a Flutter app opens a `PlMenu` from `onLongPress` itself.

### Charts

`PlAreaChart` · `PlBarChart` · `PlGaugeChart` · `PlHeatmapChart` · `PlLineChart` · `PlPieChart` · `PlScatterChart` · `PlSparkline` · `PlTimelineChart`

### Display

`PlAppLogo` · `PlAvatar` · `PlBadge` · `PlBlockquote` · `PlBreadcrumb` · `PlChip` · `PlCodeBlock` · `PlDataList` · `PlDataTable` · `PlDivider` · `PlGallery` · `PlHighlight` · `PlHotKeys` · `PlIcon` · `PlImage` · `PlList` · `PlMockup` · `PlStat` · `PlTable` · `PlTextLink` · `PlTimeline` · `PlTree` · `PlTypography` · `PlVisuallyHidden`

### Feedback

`PlAlert` · `PlConfirmProvider` · `PlDrawer` · `PlEmpty` · `PlMeter` · `PlModal` · `PlOverlay` · `PlPopconfirm` · `PlPopover` · `PlProgressBox` · `PlProgressCircular` · `PlProgressLinear` · `PlSkeleton` · `PlToast` · `PlTooltip` · `PlTour`

### Inputs

`PlButton` · `PlButtonGroup` · `PlCalendar` · `PlCheckbox` · `PlColorPicker` · `PlCombobox` · `PlDatePicker` · `PlDateRangePicker` · `PlDateTimePicker` · `PlFieldset` · `PlFilePicker` · `PlFloatingActionButton` · `PlForm` · `PlIconButton` · `PlNumberField` · `PlOtpField` · `PlPagination` · `PlRadioGroup` · `PlRating` · `PlSegmentedButton` · `PlSelect` · `PlSlider` · `PlSwitch` · `PlTextField` · `PlTimePicker` · `PlToggle` · `PlToggleGroup` · `PlTransfer` · `PlTreeSelect`

### Layout

`PlAspectRatio` · `PlContainer` · `PlFlex` · `PlFooter` · `PlGrid` · `PlHeader` · `PlPageLayout` · `PlPanes` · `PlPortal` · `PlScrollArea` · `PlScrollZone` · `PlShow` · `PlSidebar` · `PlStack`

### Navigation

`PlAnchor` · `PlBackTop` · `PlBottomNavigation` · `PlCommandPalette` · `PlContextMenu` · `PlFloatingBottomNavigation` · `PlMenu` · `PlMenubar` · `PlNavigationMenu` · `PlStepper`

### Surfaces

`PlAccordion` · `PlBox` · `PlCard` · `PlCarousel` · `PlChatBubble` · `PlCollapsible` · `PlHoverCard` · `PlHowToSteps` · `PlPill` · `PlSpoiler` · `PlTabs` · `PlToolbar` · `PlWindowPane`

### Transitions

`PlAnimateAppear` · `PlAnimateBlink` · `PlAnimateCounter` · `PlAnimateFade` · `PlAnimateFloat` · `PlAnimateGrow` · `PlAnimateHeadline` · `PlAnimateLighting` · `PlAnimateMarquee` · `PlAnimateReveal` · `PlAnimateRotate` · `PlAnimateScramble` · `PlAnimateShake` · `PlAnimateSlide` · `PlAnimateSplit` · `PlAnimateTyping` · `PlAnimateZoom`

### Hooks

React-only, and the machinery the library already ran on rather than anything new. Import them from the barrel or from `plass-ui/hooks`.

`usePlBreakpoint` · `usePlBreakpointValue` · `usePlColorScheme` · `usePlDisclosure` · `usePlElementSize` · `usePlHotKeys` · `usePlMediaQuery` · `usePlOnScreen` · `usePlReducedMotion`

`usePlassDefaults`, `usePlToast` and `usePlConfirm` live with the part they belong to instead, and come from `plass-ui/provider`, `plass-ui/toast` and `plass-ui/confirm`.

## Changelog

[CHANGELOG.md](https://github.com/jooy2/plass-ui/blob/main/packages/react/CHANGELOG.md) is this package's history, and [plass.cdget.com/changelog](https://plass.cdget.com/changelog) is the same list beside the Flutter package's. The two version independently, so a release on one side is not a release on the other.

## Development

This package is installed and run from its own folder; there is no install at the repository root.

```bash
npm install
npm test              # Vitest, three shards of headless Chromium
npm run typecheck     # tsc --noEmit over both TS projects
npm run build         # tsc + terser + build-styles → dist/
npm run lint          # ESLint
npm run size          # what the package costs, packed and installed
```

The documentation site lives at the repository root, in [`docs/`](https://github.com/jooy2/plass-ui/tree/main/docs), and renders these components from `src/` through a Vite alias, so `cd docs && npm run dev` is the develop-and-eyeball loop and there is no separate demo app. [CONTRIBUTING.md](https://github.com/jooy2/plass-ui/blob/main/CONTRIBUTING.md) has the rest.

## License

MIT © [CDGet](https://cdget.com)
