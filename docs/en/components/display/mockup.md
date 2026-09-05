---
title: PlMockup
order: 24
---

# PlMockup

<p class="plass-lede">A device with a screen you can put anything on: a phone, a tablet, a monitor or a laptop, with the system's own bars drawn on it.</p>

<Demo src="mockup/hero" :min-height="600" />

::: fw react

```tsx
import { PlMockup } from 'plass-ui';

<PlMockup device="mobile">
  <MyScreen />
</PlMockup>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlMockup(device: PlMockupDevice.mobile, child: MyScreen());
```

:::

**The screen is a real viewport at the device's own resolution** — an `md` phone is 390 by 844 — and the whole device is then scaled once to whatever room it has been given. So the content inside is laid out against a _screen_ rather than against the page: a 390-pixel column wraps where it would wrap on a phone, and the mockup can be 200 pixels wide on the page without the content knowing.

That scale is the one `transform` in the library. The rule it is an exception to is about controls, where a scale resamples the label under the pointer pressing it. Nothing here is pressed, and the scale never changes on an interaction — it is set once from the space available, which is the only way to draw a 1440-pixel desktop in a paragraph's width at all.

## Props

<PropsTable name="PlMockup" />

`device` is the one prop with no default: a mockup that has not said what it is a mockup of has not said anything.

**`size` does not set a height or a type scale here.** It sets the resolution of the screen, which is the only thing about a device there is to scale — the second component after [`PlBox`](../surfaces/box) where the ladder means something other than a control height.

## Examples

### device and hardware

<Demo src="mockup/device" :min-height="420">

::: fw react

<<< @/.vitepress/demos/mockup/device.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/mockup/device.dart

:::

</Demo>

A desktop is held up by a stand or by a keyboard; a tablet and a phone hold themselves up, and ignore `hardware` entirely.

`os` picks the chrome. A desktop runs `macos`, `windows` or `linux`; a tablet runs `ipados` or `android`; a phone runs `ios` or `android`. Anything else falls back to the device's own default, with one nicety: `ios` on a tablet and `ipados` on a phone both mean the Apple one, and get it.

### finish

<Demo src="mockup/finish" :min-height="320">

::: fw react

<<< @/.vitepress/demos/mockup/finish.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/mockup/finish.dart

:::

</Demo>

Fixed colours rather than theme tokens, because hardware is hardware. A graphite phone is the same graphite on a page switched to dark, and a device that changed colour with the theme would read as a drawing of the theme rather than of a device.

### bezel

<Demo src="mockup/bezel" :min-height="300">

::: fw react

<<< @/.vitepress/demos/mockup/bezel.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/mockup/bezel.dart

:::

</Demo>

`none` is not a thinner bezel — it is **no hardware at all**, leaving the screen on its own with its corners cut, which is what a mockup that only wants the viewport asks for. `thick` is an older device: narrow sides, a forehead and a chin.

### systemUi and notch

The system's bars each take their own space rather than covering the content: a caller putting a screenshot in a mockup wants all of the screenshot, and a status bar over the top of it would be a crop nobody asked for. Turning `systemUi` off gives that room back rather than uncovering anything.

The cut-out is the exception, because that one really is a hole in the glass — so it is drawn whether or not the bars are. It defaults to what the device would have: a dynamic island on an iOS phone, a punch hole on an Android one, nothing anywhere else.

### orientation

Landscape turns the screen, the bezel and the cut-out together — the forehead and chin of a thick-bezelled phone become its left and right edges, and the island moves out from under the status bar.

A desktop ignores it. Rotating a monitor is a thing people do, but a mockup of it is a different picture — the stand does not move — and pretending otherwise would draw a landscape stand under a portrait screen.

## Accessibility

- The hardware is decoration and says so: the bezel, the stand, the cut-out and every system bar are hidden from assistive technology. What is announced is whatever the caller put on the screen.
- The chrome's only text is the clock, which is a prop rather than the real time — a mockup's clock is part of the picture, and reading the real one would differ between the server that renders the page and the browser that hydrates it.
- On React the screen is a container (`plass-screen`), so content inside can answer to the **device's** width with a container query rather than to the window's.
