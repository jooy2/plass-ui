---
title: PlSlider
order: 5
---

# PlSlider

<p class="plass-lede">A value chosen along a range. The rail is a groove cut into the sheet and the run that fills it is the same gradient a button is made of.</p>

<Demo src="slider/hero" :min-height="120" />

```tsx
import { PlSlider } from 'plass-ui';

<PlSlider label="Volume" value={volume} onValueChange={setVolume} showValue />;
```

## Props

<PropsTable name="PlSlider" />

Every other prop on Base UI's `Slider.Root` passes straight through — `minStepsBetweenValues`, `largeStep`, `format`, `onValueCommitted`, `name`, `disabled`.

There is no `variant` here. The three materials answer "what is this surface made of", and a slider is two surfaces at once: a groove and a key travelling along it. Neither has a choice to offer.

What the shared axes (`size` `color` `elevation` `orientation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### Range

Pass an array to `value` or `defaultValue` and it becomes a range slider with one thumb per entry. There is no separate `range` prop, because the shape of the value already says which one this is.

<Demo src="slider/range" :min-height="120">

<<< @/.vitepress/demos/slider/range.tsx

</Demo>

### color

The filled run is the family's gradient — the same two-stop sweep at 135° a `solid` button carries — and the thumb sits on it, ringed in the page's own surface colour so it never dissolves into the run behind it.

<Demo src="slider/colors" :min-height="280">

<<< @/.vitepress/demos/slider/colors.tsx

</Demo>

### min · max · step

`step` decides what the thumb can land on. A slider with five stops is still a slider and not a segmented control: it is chosen by dragging, and the values are on a scale.

<Demo src="slider/steps" :min-height="260">

<<< @/.vitepress/demos/slider/steps.tsx

</Demo>

### showValue

`true` prints the raw value; a function is handed both Base UI's already-localised strings and the raw numbers, so a currency, a percentage or a duration is one line.

The value sits at the end of the label's row rather than following the thumb. A number that moves is a number that is hard to read and impossible to compare between two sliders stacked on each other.

### size

Moves the groove, the thumb and the label together. The thumb is deliberately far bigger than the groove at every step — it is the only part of the control you can actually catch, and a thumb sized to match a 6px rail is a thumb nobody hits on a touchscreen.

<Demo src="slider/sizes" :min-height="380">

<<< @/.vitepress/demos/slider/sizes.tsx

</Demo>

### orientation

A vertical slider has no length of its own, so it is given one: `h-40` by default. Override it with a class when a mixer needs taller faders.

<Demo src="slider/orientation" :min-height="220">

<<< @/.vitepress/demos/slider/orientation.tsx

</Demo>

### disabled

The light going out, as everywhere else: the shape and the position stay, the saturation and half the opacity go.

<Demo src="slider/states" :min-height="140">

<<< @/.vitepress/demos/slider/states.tsx

</Demo>

## Accessibility

- Each thumb is a real `<input type="range">`, so the browser's own slider semantics, the tab order and `disabled` all come for free.
- `label` is wired to the control by Base UI. Without one — a fader in a bank of them — give the slider an `aria-label`.
- The keyboard is the primitive's: <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd> step, <kbd>PageUp</kbd> / <kbd>PageDown</kbd> take the large step, <kbd>Home</kbd> and <kbd>End</kbd> jump to the ends.
- The whole strip is a pointer target, not just the rail: the control box is several times the groove's thickness, so a press anywhere along it moves the thumb.
- The thumb grows a halo on hover and while dragging rather than growing itself — nothing under the finger is ever scaled.
- `showValue` is a rendered number, not a substitute for the accessible value. That is `aria-valuenow` on the input, which Base UI keeps in step.
