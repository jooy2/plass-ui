---
title: Getting started
order: 1
---

# Getting started

Plass ships for two frameworks from one design language. Pick yours in the sidebar — everything on this site follows it, including the previews.

::: fw react

The React package's behaviour and accessibility come from [Base UI](https://base-ui.com) primitives; its styling comes from [Tailwind CSS](https://tailwindcss.com) v4. Tailwind is used to build the package and does not have to be installed in yours.

:::

::: fw flutter

The Flutter package is built on `package:flutter/widgets.dart` alone. It imports neither `material.dart` nor `cupertino.dart`, which means two things: it drops into a Material app, a Cupertino app or a bare `WidgetsApp` without dragging a second design system in behind it, and it is unaffected by those two libraries moving out of the framework into `material_ui` and `cupertino_ui`. It has no runtime dependencies at all.

:::

> **0.0.1 is a preview.** The prop vocabulary, the tokens and the build are the shape everything after this will be poured into, so they are worth reading; the component list is not yet worth building a product on. Both packages now have the same thirty-five components; see [all components](../components/).

## Install

::: fw react

```bash
npm install plass-ui
```

`react` and `react-dom` are peer dependencies — **React 18 or 19**. If your project already has one of them, that is the copy Plass uses; if it does not, npm 7 and later install them for you. Everything else the package brings with it.

:::

::: fw flutter

```bash
flutter pub add plass_ui
```

**Flutter 3.41 or newer** (Dart 3.11). There is nothing else to install: the package has no dependencies, no assets and no platform channels.

:::

::: fw react

## Wiring up the stylesheet

Add one line to your app's CSS entry point.

```css
@import 'plass-ui/styles.css';
```

If your bundler handles CSS, importing it from your entry module works just as well.

```ts
import 'plass-ui/styles.css';
```

`plass-ui/styles.css` is **finished CSS**: the design tokens (colour, radius, elevation, motion), the `.plass-glow` layer, the real rules behind every utility class the components use, and a small reset. There is no build-side configuration, no PostCSS plugin and no `@source`.

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
| `@import 'plass-ui/tailwind.css'` | The design tokens, the `.plass-glow` layer, and the `@source` that registers the package |

You do not write an `@source` of your own on this path either. The classes Plass's components use are Tailwind utilities, so Tailwind has to read the package's compiled files to find them; `plass-ui/tailwind.css` takes care of that by declaring `@source '.'` inside itself. `@source` resolves relative to the file it is written in, which here is `node_modules/plass-ui/dist/`, right next to those files. An explicitly registered source is scanned even inside `node_modules`, which automatic detection skips.

This path carries no reset, because Preflight already is one.

#### Registering only the components you use

`plass-ui/tailwind.css` registers all 58 components at once, and that is the right default — but it is also a floor you pay whether you use one component or all of them. Tailwind scans _files_, not imports: nothing in a build connects `import { PlButton }` to the classes `PlSelect.js` spells out, so the only way to generate less CSS is to hand Tailwind fewer files.

The package ships that scan in pieces. `plass-ui/css/base.css` is the tokens plus the classes every component shares; `plass-ui/css/<component>.css` is one line registering one component, named after its folder in `dist/components`.

```css
@import 'tailwindcss';
@import 'plass-ui/css/base.css';
@import 'plass-ui/css/button.css';
@import 'plass-ui/css/text-field.css';
```

For a project using a handful of components this is about 5 kB gzipped smaller than the blanket import. It is still **one** Tailwind pass, so the utilities come out in Tailwind's own order — which is why this is shipped as a narrower scan rather than as 58 pre-compiled stylesheets. Concatenating pre-compiled files would put every shared utility ahead of every component-specific one, and Tailwind's sort is what decides which of two conflicting utilities wins.

Registering fewer components than you import is the one way to get this wrong, and it fails visibly: the component renders unstyled. When in doubt, `plass-ui/tailwind.css` is always correct.

:::

::: fw flutter

## No setup

There is no stylesheet to wire up and no provider to install. A component resolves its tokens from the nearest `PlassTheme`, and with none in the tree it falls back to the platform's own brightness — so a button dropped into any app is already in the right theme, and follows the system switch.

`PlassTheme` is therefore an **override** rather than a requirement: reach for it when a screen has to be one theme regardless of the platform.

```dart
PlassTheme(
  brightness: Brightness.dark,
  child: const PlButton(child: Text('Save')),
)
```

### One thing that does need something above it

Four components lift themselves out of the tree — `PlModal`, `PlOverlay`, `PlTooltip` and `PlSelect`'s list — and a lifted surface needs an `Overlay` to go into. `MaterialApp` has one, and so does a `WidgetsApp` with a navigator; an app with neither can add its own:

```dart
WidgetsApp(
  // …
  builder: (BuildContext context, Widget? child) => Overlay.wrap(child: child!),
)
```

Lifting is the point rather than an implementation detail: a sheet drawn where it was written would be clipped by the first ancestor that clips, and on a Plass page that is every card.

`PlToast` needs no `Overlay` — its `PlToastProvider` is already above everything the stack has to cover.

:::

## The page under the components

Plass draws controls and sheets. It does not paint your background, and nothing here requires it to — but a sheet of glass over a flat white page has nothing to be in front of, and every translucent surface in the library will read as opaque.

Two tokens exist for exactly this, and using them is one rule:

::: fw react

```css
body {
  background: linear-gradient(160deg, var(--plass-bg-from) 0%, var(--plass-bg-to) 100%);
  background-attachment: fixed;
  color: var(--plass-fg);
}
```

:::

::: fw flutter

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

:::

Any backdrop with structure in it works — a photograph, a mesh, your own gradient. What does not work is nothing at all.

## Use

::: fw react

```tsx
import { PlButton } from 'plass-ui';

export default function App() {
  return <PlButton onClick={() => console.log('clicked')}>Save</PlButton>;
}
```

:::

::: fw flutter

```dart
import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return PlButton(
      onPressed: () => debugPrint('pressed'),
      child: const Text('Save'),
    );
  }
}
```

:::

## Dark mode

::: fw react

The default follows `prefers-color-scheme`. To force it either way, put a class or a `data-theme` on any ancestor.

```text
<html data-theme="dark">   <!-- or --> <html class="dark">
```

For light, use `data-theme="light"` or `class="light"`. `.dark` is supported alongside it to match Tailwind's own convention.

:::

::: fw flutter

The default follows `MediaQuery.platformBrightness`. To force it either way, wrap the subtree in a `PlassTheme`.

```dart
PlassTheme(brightness: Brightness.dark, child: ...)
```

:::

One thing does **not** change with the theme, and it is deliberate: the colour of a key. See [Colour](../design/color#the-key-does-not-change-with-the-theme).

## Next

- [All components](../components/) — everything released, on one page
- [Prop conventions](../design/prop-conventions) — what the shared props mean
- [Design language](../design/design-language) — why the surfaces, colours and motion look like this

::: fw react

## Browser support

The tokens use `color-mix()` and `backdrop-filter`. That means Chrome, Safari and Firefox from 2023 onwards. Where `backdrop-filter` is missing only the blur drops out; the fill, the hairline, the tinted shadow and the pointer glow still work, and a sheet reads as a flat translucent panel rather than as glass.

:::

::: fw flutter

## Platform support

Every platform Flutter targets, with no per-platform code: the components are drawn rather than delegated, so there is nothing that only exists on one of them.

`glass` uses `BackdropFilter`, which is the most expensive thing in the library on any platform. A screen with dozens of glass surfaces on it is worth measuring; a screen with a handful is not.

:::
