---
title: Design language
order: 1
---

# Design language

A Plass surface is **a key of tinted glass resting on a clear sheet**. That one sentence is the reason for every rule below. When a new component leaves you unsure, come back to it — and to the question it makes every surface answer:

> **Is this thing pressed, or does it hold something?**

A thing that is pressed is tinted glass: a gradient that sweeps between two ends of its colour family, a drop shadow in that family, and a bloom of light that follows the pointer across it. A thing that holds something is clear glass: translucent, heavily blurred, a white hairline round it, and never dyed. There is no third answer, and a component that seems to need one is two components.

What that sentence takes, and what it leaves out:

- **Taken**: a light direction, colour that bleeds into the shadow a control casts, and light that arrives with the pointer.
- **Dropped**: relief of every kind — bevels, specular highlights, the dark line under a key, bulk — and any state expressed by making a control move.

> **This is where Plass stopped being a plastic library.** An earlier draft drew a filled control as a moulded key: a three-stop gradient that lightened at one corner and darkened at the other, with a specular highlight laid over the top half to finish it. Everything about it was internally consistent and all of it read as lacquer. What replaced it is below, and it is one idea: **a gradient that turns instead of one that shades.**

---

## 1. The two materials

### Tinted glass

A `solid` surface is three layers, and there are deliberately only three.

| Layer | Token                  | Job                                          |
| ----- | ---------------------- | -------------------------------------------- |
| Fill  | `--plass-{color}-fill` | A two-stop gradient at 135°                  |
| Tint  | `--plass-{color}-tint` | The drop shadow, in the control's own colour |
| Glow  | `.plass-glow`          | A bloom of light that follows the pointer    |

**The fill is a gradient, and the gradient turns rather than shades.** The two stops are the two ends of the colour family at _one lightness_: primary runs indigo to azure, danger vermilion to rose, success green to teal, info blue to cyan. Nothing gets lighter and nothing gets darker.

That is the whole reason there is no highlight layer. A gradient that darkens toward one corner is a moulded object catching a lamp, and an object like that needs a specular highlight to finish the illusion — which is exactly what made a filled control read as lacquer. A gradient that turns is a pane of tinted glass, and a pane needs nothing else.

**No highlight on a filled control, and no bevel under it.** An inset white line along the top edge (`inset 0 1px 0 white`) is the single fastest way to make a coloured surface look moulded; `inset 0 -1px 0 black` under it is the second. The hairline belongs to `glass`, which has a real cut edge for light to catch. A `solid` control has one shadow and no edge at all.

**135° everywhere.** The fill and the elevation both assume light arriving from the top-left. One of them pointing somewhere else makes the object read as two objects.

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

Controls are the opposite case and take the family into the fill itself, because a PlButton's surface _is_ the thing being coloured.

> **One consequence.** On a `glass` PlButton, `color` is the label and the hairline. On a `glass` PlTextField, `color` is the hairline, the ring and the caret and nothing else — which is why an invalid field can turn the whole family over to `danger` without repainting its surface.

### The one inset shadow

`--plass-well` is the exception that proves the pair: the only shadow in the library that points **inward**. It is what a `solid` PlTextField is drawn as — the glass at its most opaque with light falling into it — because a gradient under a caret, a text selection and a placeholder is not legible.

So `solid` means "the tinted pane" on anything pressed and "the deepest clear glass" on anything typed into. Same word, and one rule underneath it: `solid` is the heaviest thing that variant can be while still doing its job.

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

### Three values are hand-picked per family

```
--plass-{color}-solid       one end of the sweep, and the family's identity
--plass-{color}-solid-to    the other end
--plass-{color}-on-solid    the ink on both
--plass-{color}-accent      readable on a surface — per theme
```

Everything else (`-fill`, `-tint`, `-soft`, `-line`, `-ring`) is computed with `color-mix()` in the derived block. **Adding a colour family is two edits** — one entry in the `PlassColor` union and three lines in `styles.css`, plus its `accent` in each theme.

### The key does not change with the theme

This is the rule Plass is most likely to be argued with about, and it is deliberate. **A pane of blue glass is the same pane in a dark room.** What changes in dark mode is the ground it rests on: the clear glass loses its white and becomes a smoked pane, the shadow goes black and deepens, and the tint bleeding into that shadow is turned up because a coloured shadow has almost nothing to sit on over a near-black page.

The one family value that _is_ per-theme is `accent` — the colour that has to be **read** off a surface rather than looked at.

### Both ends sit as close to the contrast floor as the arithmetic allows

Every stop clears 4.5:1 against its own `on-solid`, and every one of them is within 0.15 of exactly 4.5. That is not timidity in the other direction: a family held further above the floor than it has to be is a family that is **darker than it has to be**, and a set of buttons that are all a shade too deep is the most common way a palette goes quietly wrong.

So the constraint is two-sided. The floor decides how bright a family may be; nothing else is allowed to make it darker than that.

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

The ladder is a flat 8px per step and it starts higher than a dense desktop toolkit would. That is the material asking for room: a gradient that has to turn, and a hairline, inside 32px is two effects fighting over eleven pixels of fill. `xs` exists for a table row, and it is the one step where the sweep is short enough that the two ends nearly meet.

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

**A PlButton defaults to `1`, and a PlTextField to `0`.** A key rests _on_ the sheet; a field is cut _into_ it. Hovering adds a level and pressing removes one, so a default button presses down flush against the glass and a raised one comes back to where it was.

The ladder climbs by **blur far more than by offset**. A surface that moves 20px down the page when it is raised has left the sheet, and everything in this library is still sitting on one.

### Shadows are tinted, and this is where Plass parts company with restraint

`--plass-{color}-tint` is the drop shadow a control casts in its own colour, and it is the single loudest thing in the design language. It is the difference between a button that is blue and a button that is _made of_ blue.

It is deliberately **not part of the elevation ladder** and does not scale with it. Elevation says how far off the page a surface is; the tint says what the surface is made of. A `danger` button one level higher is not a redder pane of glass.

Only `solid` gets one. A sheet of clear glass casts a neutral shadow, because it has no colour of its own.

---

## 5. Motion

### Controls do not move

**Do not use `transform` on a control.** Scaling a key resamples its label, and text that shimmers under the cursor undoes the restraint everything else is spending effort on. State changes are expressed in **light and depth** only.

A surface that _holds_ content rather than being pressed — a Card, a row — may lift, and should. The rule is about the thing under the finger.

### Press is light, not paint

The fill is a gradient, and a gradient cannot be transitioned. So hover and press are `filter: brightness()`:

```
hover   brightness(1.05)  + one level up the elevation ladder, and the tint spreads
active  brightness(0.95)  + one level down, and the tint contracts under it
```

Three things move together and they all say the same thing: the control has gone down and there is less room under it for its own shadow.

### One duration, both ways

`--plass-duration` is 150ms and `--plass-ease` is one curve, applied identically in both directions. A key going down and a key coming back up are the same spring; an asymmetric press belongs to a different material.

### Light arrives with the pointer

`.plass-glow` is two stacked layers on every interactive control.

- **`::before` is the bloom** — a soft radial light centred on the pointer, fading in over 240ms when the pointer arrives and following it across the surface.
- **`::after` is the press** — the same shape a shade brighter, at `0ms` in and ~700ms out. The flash lands on the frame of the click and is still visibly draining a beat after the finger lifts.

Both read `--p-mx` / `--p-my`, which the component writes **straight to the element's inline style** on `pointermove`.

**Do not hold this in React state.** The event fires at pointer rate, so a `setState` would re-render the tree on every mouse move. The coordinates come from `offsetX`/`offsetY` rather than `getBoundingClientRect()`, so nothing forces a reflow. Icons carry `pointer-events: none`, so the offsets are always relative to the control.

This replaced a static specular highlight, and the reasoning is worth keeping: **a highlight that is always on is a claim about a lamp somewhere off-screen, and it reads as lacquer. Light that arrives with the pointer is a claim about the pointer, which is true.**

The `::after` layer is also what carries the effect on a touch screen, where there is no hover at all: `:active` holds for as long as the finger is down and `pointermove` keeps writing the coordinates, so the light follows a finger dragged across the control.

The two colour slots switch with the variant, because white light on a near-white sheet is invisible: a filled control gets `--plass-glow-on-fill` (white at 18%), and a `glass` or `ghost` one gets its own family's soft tint.

---

## 6. States

The three states each have to speak on their own axis, and each has to be distinguishable from the default at a glance.

| State | How it is expressed | Why |
| --- | --- | --- |
| `disabled` | `opacity: 0.5` and `saturate(0.35)`; no light, no shadow | On a page made of translucent sheets, a surface the page shows _through_ has stopped being an object |
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

A custom property resolves its `var()`s **on the element that declares it**. `--plass-primary-tint` reads `--plass-tint-strength`, which is per-theme — declared only on `:root` it would freeze to the light theme's value inside a `.dark` subtree. That is why the derived block's selector is `:root, .dark, .light, [data-theme='dark'], [data-theme='light']`.

### Move it to CSS when it stops being readable

`.plass-glow` is a real class in `styles.css` rather than a set of Tailwind utilities because `[&::before]:[background:radial-gradient(…)]` is technically expressible and impossible to maintain. Styling that puts a gradient on a pseudo-element belongs in CSS.

### Never use `outline-none`

Tailwind v4's `outline-*` utilities route the style through `--tw-outline-style`. An `outline-none` anywhere on the element sets that variable to `none` and **the focus ring disappears entirely.** Use the shorthand.

```
focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:0px]
```

### The ring is flush

The offset is `0`, and it is `0` on every control in the library. A ring held 2px off a control that draws an edge of its own — a field, a select, a tick, a switch — is read as three concentric rectangles round one object, and the object looks as though it has come loose from the ring. Flush, the outline sits directly against the outside of the edge, and the edge simply thickens and takes the family's colour.

Nothing is lost on a control with no edge either: an outline is always drawn **outside** the border box, so on a filled key it is a rim against the page rather than a band over the fill.

The one exception is a control that something else clips — a tab on a rail, a segment in a groove, a row inside a rounded sheet, an accordion header in a scored pane. Those take `focus-visible:[outline-offset:-2px]`, because a ring drawn outside them is a ring with its top or its bottom sliced off.

### The ring is an `outline` and not a `ring`

Tailwind's `ring-*` is a `box-shadow`, and every Plass surface already spends its `box-shadow` on the elevation, the tint and the glass hairline. A ring would have to be spliced into that chain in each of the three variants, and the first one that forgot would silently lose its focus ring.
