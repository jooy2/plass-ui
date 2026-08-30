---
title: PlColorPicker
order: 20
---

# PlColorPicker

<p class="plass-lede">A colour, chosen by eye. A saturation square with a hue rail beside it — the arrangement every design tool has settled on, because it puts every colour of a hue within one movement of the pointer.</p>

<Demo src="color-picker/hero" :flutter="false" :min-height="220" />

::: fw react

```tsx
import { PlColorPicker } from 'plass-ui';

<PlColorPicker label="Project colour" value={color} onValueChange={setColor} />;
```

:::

## Props

<PropsTable name="PlColorPicker" />

::: fw react

Every native `<div>` attribute passes straight through to the wrapper. `color` is excluded because it is a Plass prop here — the _family_ the control lights up in, not the colour it is holding — and `defaultValue` / `onChange` because the picker spells them as a value and an `onValueChange`.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## HSV is the model, and it never leaves

The panel's state is a hue, a saturation and a value. The string is derived from it, and never the other way round.

That is not a preference. Through RGB, **every shade of black is the same colour** — `#000000` has no hue to read back — so a picker that re-parsed its own output would snap the hue rail to red the moment the pointer reached the bottom of the square. Keeping the model is what keeps the rail still.

An incoming `value` re-seeds the model only when it means something different, and "different" is compared as a _colour_ rather than as a string: `#FF0000` and `#ff0000` are the same colour written twice, and a string comparison would re-seed the model from a value it had just produced, on every render, forever.

## Examples

### inline

Draws the panel in the page with no trigger, for a sidebar or a settings pane where the colour is the thing being edited rather than one field among ten.

<Demo src="color-picker/inline" :flutter="false" :min-height="360">

<<< @/.vitepress/demos/color-picker/inline.tsx

</Demo>

### format

Which notation the value is written in on the way out: `hex`, `rgb` or `hsl`.

All three drop their alpha when the colour is opaque — a caller who never turned `alpha` on should never see `rgba(…, 1)` come out of a control they only used three channels of.

<Demo src="color-picker/formats" :flutter="false" :min-height="160">

<<< @/.vitepress/demos/color-picker/formats.tsx

</Demo>

### alpha

Adds a third rail and lets the value carry a fourth channel. The rail is drawn over a chequerboard, and the chequer is four linear stops at 45° rather than two conic gradients: a conic chequer has a seam down the middle of every tile at a fractional device pixel ratio.

<Demo src="color-picker/alpha" :flutter="false" :min-height="420">

<<< @/.vitepress/demos/color-picker/alpha.tsx

</Demo>

### swatches

The handful of colours a product actually uses, one click away. Pass an array to replace the built-in set, or `false` to draw none.

The built-in set is a plain spectrum plus the greys, and it is deliberately **not** the library's own six families: those are semantic roles, and a picker is asked for a colour rather than for a meaning.

A chosen swatch is ticked in black or white, decided by relative luminance — a fixed white tick disappears on yellow, and lightness alone puts it the wrong way round on green.

<Demo src="color-picker/swatches" :flutter="false" :min-height="380">

<<< @/.vitepress/demos/color-picker/swatches.tsx

</Demo>

### readOnly · disabled · error

`error` turns the control invalid, which re-points the whole colour family at `danger` — the edge, the ring and the message turn over together. `invalid` does the same without a message.

A `readOnly` picker shows its colour and takes nothing: the rails keep their values and lose their tab stops. A `disabled` one leaves the tab order.

<Demo src="color-picker/states" :flutter="false" :min-height="180">

<<< @/.vitepress/demos/color-picker/states.tsx

</Demo>

### There is no colour library under this

The conversions are `internal/color.ts` — HSV, RGB and HSL, one parser and one formatter, about a hundred lines of arithmetic with no trigonometry in it. That is the whole reason a component that _computes_ colours ships without a dependency that does.

What it reads: hex in all four lengths, and `rgb()`/`rgba()`/`hsl()`/`hsla()` in both the comma and the space syntax. What it deliberately does not: named colours and `color()`. A picker has to be able to write every value it can read, and there is no honest way back from `rebeccapurple` to a point on the panel.

## Accessibility

- The square and each rail are real `slider`s with `aria-valuenow`, moved by the arrow keys — one step, or ten with <kbd>Shift</kbd>, which is the same pair every slider in the library uses.
- The square reports both of its channels: `aria-valuenow` is the saturation and `aria-valuetext` is `"saturation%, brightness%"`, because one number cannot describe a point on a plane.
- The hue rail **wraps** rather than stopping: a step back from red is 358°, not 0°. The wheel is a circle and the rail is a picture of one.
- A key the picker does not answer to is left alone, so <kbd>Tab</kbd> moves on rather than being swallowed by a gradient.
- Every swatch is a real `<button>` named by its own colour, with `aria-pressed` on the chosen one.
- `labels` renames any of the parts that have no text on them. They are all named by default, in English.
- A drag takes pointer capture on the element, so a pointer that leaves the panel mid-drag keeps changing the colour rather than dropping it.
