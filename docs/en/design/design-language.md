---
title: Design language
order: 1
---

# Design language

A Plass surface is **a moulded plastic key resting on a sheet of glass**. That one sentence is the reason for every rule below. When a new component leaves you unsure, come back to it — and to the question it makes every surface answer:

> **Is this thing pressed, or does it hold something?**

A thing that is pressed is plastic: a gradient fill, a specular highlight along its top edge, a drop shadow in its own colour, and a press that puts it down. A thing that holds something is glass: translucent, heavily blurred, a white hairline round it, and never dyed. There is no third answer, and a component that seems to need one is two components.

What that sentence takes, and what it leaves out:

- **Taken**: gloss, a light direction, depth that is felt rather than implied, colour that bleeds into the shadow a control casts.
- **Dropped**: the dark bevel under a key, bulk, skeuomorphic bezels, and any state expressed by making a control move.

---

## 1. The two materials

### Plastic

A `solid` surface is four layers, in this order and at these strengths.

| Layer      | Token                  | Job                                                |
| ---------- | ---------------------- | -------------------------------------------------- |
| Fill       | `--plass-{color}-fill` | A three-stop gradient at 135°                      |
| Gloss line | `--plass-gloss-solid`  | `inset 0 1px 0 white/0.34` — light on the top edge |
| Specular   | `.plass-gloss::before` | A highlight over the top 62% of the face           |
| Glow       | `--plass-{color}-glow` | The drop shadow, tinted with the key's own colour  |

**The fill is a gradient, always.** A flat fill is paint; a gradient is a moulded object with light falling across it. The three stops are a 5% lift toward white at the top-left corner, the family's own colour holding the middle where the label sits, and a 10% fall toward black at the far corner.

The lift is smaller than it looks like it should be, and that is a contrast decision rather than a taste one: at anything more, the top-left corner stops clearing 4.5:1 against the label. See [Colour](./color).

**135° everywhere.** The fill, the gloss line and the specular all assume light arriving from the top-left. One of them pointing somewhere else makes the object read as two objects.

**No dark bevel underneath.** `inset 0 -1px 0 black` is the fastest way to turn a moulded key into a 2004 toolbar button. What puts a key above the sheet is the shadow it casts, not a line drawn under its own chin.

### Glass

Everything that holds content is one sheet at three strengths.

```
--plass-glass         rgb(255 255 255 / 0.62)   at rest
--plass-glass-hover   rgb(255 255 255 / 0.76)
--plass-glass-press   rgb(255 255 255 / 0.88)
```

**The ladder is opacity, not lightness.** As a surface is engaged it holds more light, rather than turning grey.

**The blur is the material.** `blur(22px) saturate(160%)` — deliberately a generous smear. Plass is not trying to let you read what is behind a sheet; it is trying to make the sheet look thick. Below about 14px the glass stops being glass and becomes a white box with an alpha on it.

**Glass is never dyed.** A sheet holds other people's content, and that content arrives with its own colours: body text, links, buttons, fields. Tinting the sheet underneath puts every one of them on a background they were not chosen against. So **the family stops at the hairline, the focus ring and the caret, and the glass stays clear.**

Controls are the opposite case and take the family into the fill itself, because a Button's surface _is_ the thing being coloured.

> **One consequence.** On a `glass` Button, `color` is the label and the hairline. On a `glass` TextField, `color` is the hairline, the ring and the caret and nothing else — which is why an invalid field can turn the whole family over to `danger` without repainting its surface.

### The one inset shadow

`--plass-well` is the exception that proves the pair: the only shadow in the library that points **inward**. It is what a `solid` TextField is drawn as — the glass at its most opaque with light falling into it — because a gradient under a caret, a text selection and a placeholder is not legible.

So `solid` means "plastic" on anything pressed and "the deepest glass" on anything typed into. Same word, and one rule underneath it: `solid` is the heaviest thing that variant can be while still doing its job.

---

## 2. Colour

This section is the _why_. For what the tokens actually resolve to and how to override them, see [Colour](./color).

The base colour is `#3558ef`. Everything else comes off its palette.

| Role        | Where it comes from                                    |
| ----------- | ------------------------------------------------------ |
| `primary`   | The base colour                                        |
| `secondary` | Slate that keeps the base colour's hue                 |
| `success`   | A deep green, dark enough to carry white               |
| `warning`   | The complementary amber — the one family with dark ink |
| `danger`    | A muted vermilion                                      |
| `info`      | The analogous azure                                    |

### Two values are hand-picked per family

```
--plass-{color}-solid       the key's own colour
--plass-{color}-on-solid    the ink on it
--plass-{color}-accent      readable on a surface — per theme
```

Everything else (`-fill`, `-glow`, `-soft`, `-line`, `-ring`) is computed with `color-mix()` in the derived block. **Adding a colour family is two edits** — one entry in the `PlassColor` union and two lines in `styles.css`, plus its `accent` in each theme.

### The key does not change with the theme

This is the rule Plass is most likely to be argued with about, and it is deliberate. **A piece of plastic is the same piece of plastic in a dark room.** What changes in dark mode is the ground it rests on: the glass loses its white and becomes a smoked pane, the shadow goes black and deepens, and the tint bleeding into that shadow is turned up because a coloured glow has almost nothing to sit on over a near-black page.

The one family value that _is_ per-theme is `accent` — the colour that has to be **read** off a surface rather than looked at.

### Lightness is fixed by the lightest stop, not by the fill

Every `solid` was chosen against one number: the top-left corner of the gradient derived from it has to clear 4.5:1 against its own `on-solid`. That corner is a 5% lift toward white, which is what pins the fills where they are — they are not "dark", they are as bright as a white label allows.

### `warning` has dark text

White on amber does not reach 4.5:1 at any lightness worth calling amber. `--plass-warning-on-solid` is the one dark brown in the set. Changing the ink is the right answer; distorting the family to preserve a white label is not.

---

## 3. Size and density

### `size` — height and type scale

|        | xs   | sm   | md       | lg   | xl   |
| ------ | ---- | ---- | -------- | ---- | ---- |
| Height | 24px | 32px | **40px** | 48px | 56px |
| Text   | 11px | 13px | **14px** | 16px | 18px |
| Radius | 8px  | 10px | **12px** | 14px | 16px |

The ladder is a flat 8px per step and it starts higher than a dense desktop toolkit would. That is the material asking for room: a gradient, a specular highlight and a hairline inside 32px is three effects fighting over eleven pixels of fill. `xs` exists for a table row and is the one step where the gloss is deliberately faint.

`lg` at 48px and `xl` at 56px both clear the 44px mobile touch target.

### The radius is a fillet, not a percentage

It grows far more slowly than the height does — 33% of an `xs` control, 29% at `md`, 29% at `xl`. That near-constant radius is what makes two controls of different sizes read as two pieces cast in the same mould. A radius pinned to a percentage of the height gives you a small pill and a large rectangle instead.

### `density` — padding, and only padding

```
default   10 / 12 / 16 / 24 / 28px
compact    6 /  8 / 10 / 14 / 16px
```

**Density touches neither the height nor the type scale.** Two controls of the same `size` are the same height whatever their density, so a row of mixed-density controls keeps its baseline. The two tracks are roughly 2:1, so the difference is legible at a glance.

---

## 4. Elevation

```ts
type PlassElevation = 0 | 1 | 2 | 3;
```

**A Button defaults to `1`, and a TextField to `0`.** A key rests _on_ the sheet; a field is cut _into_ it. Hovering adds a level and pressing removes one, so a default button presses down flush against the glass and a raised one comes back to where it was.

The ladder climbs by **blur far more than by offset**. A surface that moves 20px down the page when it is raised has left the sheet, and everything in this library is still sitting on one.

### Shadows are tinted, and this is where Plass parts company with restraint

`--plass-{color}-glow` is the drop shadow a key casts in its own colour, and it is the single loudest thing in the design language. It is the difference between a button that is blue and a button that is _made of_ blue.

It is deliberately **not part of the elevation ladder** and does not scale with it. Elevation says how far off the page a surface is; the glow says what the surface is made of. A `danger` button one level higher is not a redder piece of plastic.

Only `solid` gets one. A sheet of glass casts a neutral shadow, because a sheet of glass has no colour of its own.

---

## 5. Motion

### Controls do not move

**Do not use `transform` on a control.** Scaling a key resamples its label, and text that shimmers under the cursor undoes the restraint everything else is spending effort on. State changes are expressed in **light and depth** only.

A surface that _holds_ content rather than being pressed — a Card, a row — may lift, and should. The rule is about the thing under the finger.

### Press is light, not paint

The fill is a gradient, and a gradient cannot be transitioned. So hover and press are `filter: brightness()`:

```
hover   brightness(1.05)  + one level up the elevation ladder, and the glow spreads
active  brightness(0.95)  + one level down, and the glow contracts under it
```

Three things move together and they all say the same thing: the key has gone down and there is less room under it for its own shadow.

### One duration, both ways

`--plass-duration` is 150ms and `--plass-ease` is one curve, applied identically in both directions. A key going down and a key coming back up are the same spring; an asymmetric press belongs to a different material.

### The gloss is the material, not an effect

`.plass-gloss::before` is a static specular highlight. It is there when nothing is happening, which is exactly what makes it plastic rather than a flourish. The only thing that moves it is a press, where it drops to 30% — the key has tipped away from the light.

There is no pointer tracking, no ripple element, no timer and no JavaScript. One composited layer that never repaints.

---

## 6. States

The three states each have to speak on their own axis, and each has to be distinguishable from the default at a glance.

| State | How it is expressed | Why |
| --- | --- | --- |
| `disabled` | `opacity: 0.5` and `saturate(0.35)`; no gloss, no shadow | On a page made of translucent sheets, a surface the page shows _through_ has stopped being an object |
| `loading` | Unchanged, with a spinner in the `startIcon` slot | It is in progress, not unavailable |
| `readOnly` | Keeps the colour, goes flat, `saturate(0.55)` | A label that happens to be control-shaped |

Only `disabled` uses the native `disabled` attribute. `loading` and `readOnly` are marked with `aria-disabled`, keep focus, and stop activation in the handler.

> **Opacity is doing real work here.** The usual complaint against `opacity: 0.5` is that it reads as "blurry" whatever the state is — and it does, on an opaque page. On this one it reads as the page coming _through_ the control, which is a specific thing to say and the only state that says it. It is the one axis `disabled` uses and no other state touches.

---

## 7. Implementation rules

### Branch state in JS, not in CSS

Two Tailwind variants of equal specificity are resolved by **their order in the generated stylesheet**. That is not a property a component may depend on.

```ts
// like this
disabled ? disabledClasses[variant] : readOnly ? readOnlyClasses[variant] : restClasses[variant];

// not like this — the precedence of data-disabled: against data-readonly: is undefined
('data-disabled:opacity-50 data-readonly:saturate-50');
```

### Colour slots go in inline styles

Tailwind only ever sees **class names that appear literally in the source**. Hardcoding `[--p-fill:var(--plass-primary-fill)]` per family means dozens of classes for every colour added. Generate the `--p-*` slots as inline styles instead.

```ts
'--p-fill': `var(--plass-${color}-fill)`;
```

This is the only kind of reason to step outside Tailwind: **step outside only when Tailwind cannot express it.**

### Derived tokens are repeated per theme root

A custom property resolves its `var()`s **on the element that declares it**. `--plass-primary-glow` reads `--plass-glow-strength`, which is per-theme — declared only on `:root` it would freeze to the light theme's value inside a `.dark` subtree. That is why the derived block's selector is `:root, .dark, .light, [data-theme='dark'], [data-theme='light']`.

### Move it to CSS when it stops being readable

`.plass-gloss` is a real class in `styles.css` rather than a set of Tailwind utilities because `[&::before]:[background:linear-gradient(…)]` is technically expressible and impossible to maintain. Styling that puts a gradient on a pseudo-element belongs in CSS.

### Never use `outline-none`

Tailwind v4's `outline-*` utilities route the style through `--tw-outline-style`. An `outline-none` anywhere on the element sets that variable to `none` and **the focus ring disappears entirely.** Use the shorthand.

```
focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-2
```

### The ring is an `outline` and not a `ring`

Tailwind's `ring-*` is a `box-shadow`, and every Plass surface already spends its `box-shadow` on the elevation, the tinted glow and the gloss line. A ring would have to be spliced into that chain in each of the three variants, and the first one that forgot would silently lose its focus ring.
