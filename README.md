# Plass UI

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/plass-ui/blob/main/LICENSE) [![npm latest package](https://img.shields.io/npm/v/plass-ui/latest.svg)](https://www.npmjs.com/package/plass-ui) [![npm downloads](https://img.shields.io/npm/dm/plass-ui.svg)](https://www.npmjs.com/package/plass-ui)

### 📘 [**plass-ui.cdget.com**](https://plass-ui.cdget.com)

Live previews and full props for every component. This README is just the quick start.

---

**Plass UI is a React component library with a material rather than a theme.** Every surface answers one question — is this pressed, or does it hold something? — and the answer decides everything else.

A thing that is pressed is **tinted glass**: a gradient that sweeps between two ends of its colour family at 135°, a drop shadow tinted with that family, and a bloom of light that follows the pointer across it. A thing that holds something is **clear glass**: translucent, heavily blurred, a white hairline round it, and never dyed. There is no third answer.

- **Two materials, one language** — `solid`, `glass`, `ghost`. Not `filled`, `outlined`, `text`.
- **Light instead of relief** — no bevels and no highlights. The gradient carries the form, and a soft glow follows your pointer across the control.
- **One shared vocabulary** — `size`, `color`, `variant`, `density`, `elevation`. An `md` is 40px on every control; `primary` is the same family everywhere.
- **Accessible by construction** — real roles, labels, focus management and keyboard support, not `div`s with click handlers.
- **Contrast that was checked** — every gradient stop clears 4.5:1 against its own label, the lightest corner included.
- **Dark mode with no work** — follows the system, and can be forced either way per subtree.
- **ESM only**, TypeScript declarations included, tree-shakeable.
- **One runtime dependency.** React 18 or 19, Node.js 20.19 or later.

> **0.0.1 is a preview.** Twenty-eight components are released and the shape they are poured into — the prop vocabulary, the tokens, the build — is settled. The API is not frozen yet.

## Documentation

| Page | What you will find |
| --- | --- |
| [**Getting started**](https://plass-ui.cdget.com/guide/getting-started) | Install and setup, end to end. |
| [**All components**](https://plass-ui.cdget.com/components/) | Every component, one page each: live previews and the full props table. |
| [**Design language**](https://plass-ui.cdget.com/design/design-language) | Why a Plass surface looks and behaves the way it does. |
| [**Prop conventions**](https://plass-ui.cdget.com/design/prop-conventions) | The shared vocabulary every component draws from. |
| [**Colour**](https://plass-ui.cdget.com/design/color) | The token families, the measured contrast, and how to theme them. |
| [**Changelog**](https://plass-ui.cdget.com/changelog) | What changed in each release. |

## Installation

```bash
npm install plass-ui
```

`react` and `react-dom` are peer dependencies — React 18 or 19.

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

### Display

`PlAvatar` · `PlBadge` · `PlBlockquote` · `PlBreadcrumb` · `PlChip` · `PlDivider` · `PlHighlight` · `PlHotKeys` · `PlIcon` · `PlList` · `PlTable` · `PlTextLink` · `PlTypography`

### Feedback

`PlAlert` · `PlModal`

### Inputs

`PlButton` · `PlCheckbox` · `PlFilePicker` · `PlPagination` · `PlRadioGroup` · `PlSegmentedButton` · `PlSelect` · `PlSlider` · `PlSwitch` · `PlTextField`

### Surfaces

`PlAccordion` · `PlCard` · `PlTabs`

## Development

```bash
npm test              # Vitest, single run (headless Chromium)
npm run typecheck     # tsc --noEmit over all three TS projects
npm run docs:dev      # VitePress docs site — the develop-and-eyeball loop
npm run build         # tsc + terser + build-styles → dist/
npm run lint          # ESLint
```

The docs render the real components from `src/` through a Vite alias, so `npm run docs:dev` is the develop-and-eyeball loop; there is no separate demo app.

## License

MIT © [CDGet](https://cdget.com)
