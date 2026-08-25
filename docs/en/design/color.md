---
title: Colour
order: 2
---

# Colour

<p class="plass-lede">Six semantic families, three hand-picked values each, and everything else computed. This page is what the tokens are and how to change them; why they are shaped this way is in the design language.</p>

## The six families

`color` is a **role**, never a value. There is no `color="#3558ef"` and no `color="blue"` — a component takes one of six names, and what those names resolve to is a decision the theme owns.

| Family      | Sweep                 | What it is for                           |
| ----------- | --------------------- | ---------------------------------------- |
| `primary`   | `#3f63f2` → `#1b78cb` | The action a screen is about             |
| `secondary` | `#6b7488` → `#59637a` | The quiet action next to it              |
| `success`   | `#1b8649` → `#12866a` | It worked                                |
| `warning`   | `#f0a63e` → `#d98613` | It might not                             |
| `danger`    | `#d04246` → `#d53c54` | It will not come back                    |
| `info`      | `#2379bd` → `#157aa9` | Neither good nor bad, just worth knowing |

The two values are the ends of a 135° gradient, and they are **a hue sweep at one lightness** rather than a shade — indigo to azure, green to teal, vermilion to rose. `warning` is the exception: amber has nowhere to turn that is still amber, so it is the one family whose ends differ in lightness instead.

## What is hand-picked and what is derived

Four values per family are written down. Three of them are the same in both themes:

```css
--plass-primary-solid: #3f63f2; /* one end of the sweep, and the identity */
--plass-primary-solid-to: #1b78cb; /* the other end */
--plass-primary-on-solid: #ffffff; /* the ink on both */
--plass-primary-accent: #2c49d6; /* readable on a surface — per theme */
```

Everything a component actually reads is computed from those, in the derived block:

| Token | How |
| --- | --- |
| `--plass-{c}-fill` | A 135° gradient from `solid` to `solid-to` |
| `--plass-{c}-tint` | `solid` at `--plass-tint-strength` (35% light, 55% dark) — the drop shadow |
| `--plass-{c}-soft` / `-hover` / `-press` | `accent` at 10% / 18% / 26% |
| `--plass-{c}-line` / `-hover` | `accent` at 30% / 48% |
| `--plass-{c}-ring` | `solid` at 55% |

So **adding a colour family is two edits**: one entry in the `PlassColor` union, and three lines plus a per-theme `accent` in `styles.css`.

## The key does not change with the theme

`--plass-{c}-solid`, `--plass-{c}-solid-to` and `--plass-{c}-on-solid` are declared once, on `:root`, outside every theme block. **A pane of blue glass is the same pane in a dark room.**

What dark mode changes is the ground under it:

| Token                    | Light                        | Dark                              |
| ------------------------ | ---------------------------- | --------------------------------- |
| `--plass-glass`          | `white / 0.62`               | `white / 0.07`                    |
| `--plass-glass-line`     | `white / 0.6`                | `white / 0.12`                    |
| `--plass-shadow-ambient` | `rgb(20 40 90 / 0.10)`       | `rgb(0 0 0 / 0.42)`               |
| `--plass-tint-strength`  | `35%`                        | `55%`                             |
| `--plass-{c}-accent`     | dark enough to read on white | light enough to read on the sheet |

The tint strength is turned up rather than the shadow being made bigger: a tinted shadow has almost nothing to sit on over a near-black page.

## The marks a sheet makes on itself

`--plass-glass-line` is white light caught on a cut edge, and it reads because what is behind it is the page wash. Turn it **inward** and there is no wash behind it any more — there is the sheet — and a white rule across a white pane is nothing at all. Three tokens exist for the jobs that face inward, and every one of them is a neutral ink rather than more light:

| Token             | Light                  | Dark            | What it is                    |
| ----------------- | ---------------------- | --------------- | ----------------------------- |
| `--plass-divider` | `rgb(20 40 90 / 0.10)` | `white / 0.10`  | One row ruled off the next    |
| `--plass-stripe`  | `rgb(20 40 90 / 0.03)` | `white / 0.035` | The wash on every other row   |
| `--plass-track`   | `rgb(20 40 90 / 0.14)` | `white / 0.16`  | The groove a thumb runs along |

`--plass-border` belongs with them: it is the neutral hairline a control draws round _itself_ — a tick, a switch, a field, a tabs rail — for the same reason, because a control is very often set on a white card rather than on the wash, and a control nobody can see is a control nobody can find.

## Contrast

Every stop of every gradient clears **4.5:1 against its own `on-solid`** — and every one of them sits within 0.15 of exactly 4.5.

Both halves of that matter. The floor is what stops a label from being unreadable; the ceiling is what stops a palette from being darker than it has to be, which is the most common way a set of buttons goes quietly wrong.

Measured, against the label on the fill:

| Family      | start | end  |
| ----------- | ----- | ---- |
| `primary`   | 4.91  | 4.57 |
| `secondary` | 4.69  | 6.02 |
| `success`   | 4.61  | 4.52 |
| `warning`   | 7.10  | 5.12 |
| `danger`    | 4.62  | 4.56 |
| `info`      | 4.62  | 4.79 |

`warning` is the outlier because its ink is dark, so it has room to spare in the direction everything else is pinned in; `secondary` is a neutral slate and takes its second end from lightness rather than hue. White on amber does not reach 4.5:1 at any lightness worth calling amber, which is why `--plass-warning-on-solid` is the one dark brown in the set.

Each `accent` clears 4.5:1 on the page it is read against — the light wash in the light theme, the dark sheet in the dark one.

## Overriding a family

Set the values on any element and everything derived from them follows, because the derived block is repeated on every theme root and `color-mix()` resolves per element.

```css
:root {
  --plass-primary-solid: #7c3aed;
  --plass-primary-solid-to: #9333c4;
  --plass-primary-accent: #6d28d9;
}

.dark,
[data-theme='dark'] {
  --plass-primary-accent: #c4b5fd;
}
```

Three things to check when you do:

1. **Both ends against your ink.** Each has to clear 4.5:1 against `--plass-primary-on-solid`. If one is under, darken that end rather than the ink.
2. **The two ends against each other.** They should differ in _hue_, not in lightness. A second end that is merely darker turns the control back into a moulded key, which is the shape this library spent a version getting rid of.
3. **The accent against the page**, in both themes. It is the value that has to be _read_.

## Neutrals

| Token | Job |
| --- | --- |
| `--plass-surface` | An opaque sheet, for anything that cannot be translucent |
| `--plass-fg` | Body text |
| `--plass-muted-fg` | Labels, descriptions, adornments |
| `--plass-border` | A neutral hairline, where the glass hairline is wrong |
| `--plass-bg-from` / `-to` | The page wash the glass was tuned over — see [Getting started](../guide/getting-started#the-page-under-the-components) |

`--plass-bg-from` and `--plass-bg-to` are the only two tokens the library never uses itself. They exist because a sheet of glass over a flat white page has nothing to be in front of, and a component library has no business painting your `<body>` — so it names the colour instead and leaves the painting to you.
