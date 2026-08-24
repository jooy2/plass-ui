---
title: Colour
order: 2
---

# Colour

<p class="plass-lede">Six semantic families, two hand-picked values each, and everything else computed. This page is what the tokens are and how to change them; why they are shaped this way is in the design language.</p>

## The six families

`color` is a **role**, never a value. There is no `color="#3558ef"` and no `color="blue"` — a component takes one of six names, and what those names resolve to is a decision the theme owns.

| Family      | Light     | What it is for                           |
| ----------- | --------- | ---------------------------------------- |
| `primary`   | `#3558ef` | The action a screen is about             |
| `secondary` | `#4f5a70` | The quiet action next to it              |
| `success`   | `#157845` | It worked                                |
| `warning`   | `#e2921c` | It might not                             |
| `danger`    | `#c4383e` | It will not come back                    |
| `info`      | `#186cb3` | Neither good nor bad, just worth knowing |

## What is hand-picked and what is derived

Three values per family are written down. Two of them are the same in both themes:

```css
--plass-primary-solid: #3558ef; /* the key's own colour */
--plass-primary-on-solid: #ffffff; /* the ink on it */
--plass-primary-accent: #2c49d6; /* readable on a surface — per theme */
```

Everything a component actually reads is computed from those, in the derived block:

| Token | How |
| --- | --- |
| `--plass-{c}-fill` | A 135° gradient: `solid` +5% white → `solid` → `solid` +10% black |
| `--plass-{c}-glow` | `solid` at `--plass-glow-strength` (35% light, 55% dark) |
| `--plass-{c}-soft` / `-hover` / `-press` | `accent` at 10% / 18% / 26% |
| `--plass-{c}-line` / `-hover` | `accent` at 30% / 48% |
| `--plass-{c}-ring` | `solid` at 55% |

So **adding a colour family is two edits**: one entry in the `PlassColor` union, and two lines plus a per-theme `accent` in `styles.css`.

## The key does not change with the theme

`--plass-{c}-solid` and `--plass-{c}-on-solid` are declared once, on `:root`, outside every theme block. **A piece of plastic is the same piece of plastic in a dark room.**

What dark mode changes is the ground under it:

| Token                    | Light                        | Dark                              |
| ------------------------ | ---------------------------- | --------------------------------- |
| `--plass-glass`          | `white / 0.62`               | `white / 0.07`                    |
| `--plass-glass-line`     | `white / 0.6`                | `white / 0.12`                    |
| `--plass-shadow-ambient` | `rgb(20 40 90 / 0.16)`       | `rgb(0 0 0 / 0.5)`                |
| `--plass-glow-strength`  | `35%`                        | `55%`                             |
| `--plass-{c}-accent`     | dark enough to read on white | light enough to read on the sheet |

The glow strength is turned up rather than the shadow being made bigger: a tinted shadow has almost nothing to sit on over a near-black page.

## Contrast

Every `solid` was chosen against one number: **the lightest stop of its gradient has to clear 4.5:1 against its own `on-solid`.** That stop is the top-left corner, a 5% lift toward white — so the corner, and not the middle, is what fixes the fill's lightness.

Measured, light theme, against the label on the fill:

| Family      | lightest stop | middle | darkest stop |
| ----------- | ------------- | ------ | ------------ |
| `primary`   | 5.07          | 5.54   | 6.51         |
| `secondary` | 6.13          | 6.93   | 8.21         |
| `success`   | 4.99          | 5.52   | 6.66         |
| `warning`   | 6.05          | 5.80   | 4.72         |
| `danger`    | 4.65          | 5.27   | 6.46         |
| `info`      | 4.68          | 5.48   | 6.64         |

`warning` runs the other way because its ink is dark: there the _darkest_ stop is the tight one. White on amber does not reach 4.5:1 at any lightness worth calling amber, so `--plass-warning-on-solid` is the one dark brown in the set.

Each `accent` clears 4.5:1 on the page it is read against — the light wash in the light theme, the dark sheet in the dark one.

## Overriding a family

Set the two values on any element and everything derived from them follows, because the derived block is repeated on every theme root and `color-mix()` resolves per element.

```css
:root {
  --plass-primary-solid: #7c3aed;
  --plass-primary-accent: #6d28d9;
}

.dark,
[data-theme='dark'] {
  --plass-primary-accent: #c4b5fd;
}
```

Two things to check when you do:

1. **The lightest gradient stop against your ink.** Mix your colour 95% with white and measure it against `--plass-primary-on-solid`. If it is under 4.5:1, darken the solid rather than the ink.
2. **The accent against the page**, in both themes. It is the value that has to be _read_.

## Neutrals

| Token | Job |
| --- | --- |
| `--plass-surface` | An opaque sheet, for anything that cannot be translucent |
| `--plass-fg` | Body text |
| `--plass-muted-fg` | Labels, descriptions, adornments |
| `--plass-border` | A neutral hairline, where the glass hairline is wrong |
| `--plass-bg-from` / `-to` | The page wash the glass was tuned over — see [Getting started](../guide/getting-started#the-page-under-the-components) |

`--plass-bg-from` and `--plass-bg-to` are the only two tokens the library never uses itself. They exist because a sheet of glass over a flat white page has nothing to be in front of, and a component library has no business painting your `<body>` — so it names the colour instead and leaves the painting to you.
