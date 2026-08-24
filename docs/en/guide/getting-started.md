---
title: Getting started
order: 1
---

# Getting started

Plass is a React component library. Behaviour and accessibility come from [Base UI](https://base-ui.com) primitives; styling comes from [Tailwind CSS](https://tailwindcss.com) v4. Tailwind is used to build this package and does not have to be installed in yours.

> **0.0.1 is a preview.** Two components are released — [Button](../components/inputs/button) and [TextField](../components/inputs/text-field). The prop vocabulary, the tokens and the build are the shape everything after this will be poured into, so they are worth reading; the component list is not yet worth building a product on.

## Install

```bash
npm install plass-ui
```

`react` and `react-dom` are peer dependencies — **React 18 or 19**. If your project already has one of them, that is the copy Plass uses; if it does not, npm 7 and later install them for you. Everything else the package brings with it.

## Wiring up the stylesheet

Add one line to your app's CSS entry point.

```css
@import 'plass-ui/styles.css';
```

If your bundler handles CSS, importing it from your entry module works just as well.

```ts
import 'plass-ui/styles.css';
```

`plass-ui/styles.css` is **finished CSS**: the design tokens (colour, radius, elevation, motion), the `.plass-gloss` layer, the real rules behind every utility class the components use, and a small reset. There is no build-side configuration, no PostCSS plugin and no `@source`.

### About the reset

`plass-ui/styles.css` includes the global reset the components are written against — Tailwind's Preflight cut down to what they actually need: `box-sizing`, font inheritance on form controls, list markers off. It does not touch the typography of your paragraphs, headings or links.

Every rule in it is wrapped in `:where()`, so it has **specificity 0**. A single type selector of your own — `p { margin: 1rem }` — beats it, whatever the import order. The reset is a floor under the components, not a claim on your page.

### If you already use Tailwind

When Tailwind v4 is already in your project, import the token sheet instead of the compiled one. Nothing is generated twice, and a `className` you pass to a component sorts correctly against the component's own classes.

```css
@import 'tailwindcss';
@import 'plass-ui/tailwind.css';
```

| Line | What it does |
| --- | --- |
| `@import 'tailwindcss'` | Tailwind itself |
| `@import 'plass-ui/tailwind.css'` | The design tokens, the `.plass-gloss` layer, and the `@source` that registers the package |

You do not write an `@source` of your own on this path either. The classes Plass's components use are Tailwind utilities, so Tailwind has to read the package's compiled files to find them; `plass-ui/tailwind.css` takes care of that by declaring `@source '.'` inside itself. `@source` resolves relative to the file it is written in, which here is `node_modules/plass-ui/dist/`, right next to those files. An explicitly registered source is scanned even inside `node_modules`, which automatic detection skips.

This path carries no reset, because Preflight already is one.

## The page under the components

Plass draws controls and sheets. It does not paint your `<body>`, and nothing here requires it to — but a sheet of glass over a flat white page has nothing to be in front of, and every translucent surface in the library will read as opaque.

Two tokens exist for exactly this, and using them is one rule:

```css
body {
  background: linear-gradient(160deg, var(--plass-bg-from) 0%, var(--plass-bg-to) 100%);
  background-attachment: fixed;
  color: var(--plass-fg);
}
```

Any backdrop with structure in it works — a photograph, a mesh, your own gradient. What does not work is nothing at all.

## Use

```tsx
import { Button } from 'plass-ui';

export default function App() {
  return <Button onClick={() => console.log('clicked')}>Save</Button>;
}
```

## Dark mode

The default follows `prefers-color-scheme`. To force it either way, put a class or a `data-theme` on any ancestor.

```text
<html data-theme="dark">   <!-- or --> <html class="dark">
```

For light, use `data-theme="light"` or `class="light"`. `.dark` is supported alongside it to match Tailwind's own convention.

One thing does **not** change with the theme, and it is deliberate: the colour of a key. See [Colour](../design/color#the-key-does-not-change-with-the-theme).

## Next

- [All components](../components/) — everything released, on one page
- [Prop conventions](../design/prop-conventions) — what the shared props mean
- [Design language](../design/design-language) — why the surfaces, colours and motion look like this

## Browser support

The tokens use `color-mix()` and `backdrop-filter`. That means Chrome, Safari and Firefox from 2023 onwards. Where `backdrop-filter` is missing only the blur drops out; the fill, the hairline and the gloss still work, and a sheet reads as a flat translucent panel rather than as glass.
