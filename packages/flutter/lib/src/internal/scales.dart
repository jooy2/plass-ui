/// The measurements every Plass component is built out of.
///
/// This is `src/internal/styles.ts` from the React package, in Dart, and it is
/// here for the same reason it is there: a `size` of `md` has to be 40px on a
/// button, a text field, a select and a chip, and a table copied into eleven
/// files is a table that will disagree with itself by the twelfth.
///
/// CSS `rem` values become logical pixels one for one, because the React
/// package's scales are all written against a 16px root and Flutter's logical
/// pixel is the same unit at the same density. `h-10` is `2.5rem` is `40`.
///
/// None of this is exported from `plass_ui.dart` — it is the library talking to
/// itself.
library;

import 'package:plass_ui/src/types.dart';

/// The height of a control, and the one number the whole library lines up on.
///
/// The ladder is 8px per step, and it starts higher than a dense desktop
/// toolkit would: `md` is 40, not 32. A moulded surface needs room to be one —
/// a gradient, a specular highlight and a hairline inside 32px is three effects
/// fighting over eleven pixels of fill. `xs` exists for a table row.
///
/// `lg` at 48 and `xl` at 56 both clear the 44px mobile touch target. Density
/// never touches these.
const Map<PlassSize, double> controlHeight = <PlassSize, double>{
  PlassSize.xs: 24,
  PlassSize.sm: 32,
  PlassSize.md: 40,
  PlassSize.lg: 48,
  PlassSize.xl: 56,
};

/// A control's label. One line, so the leading is 1.0.
const Map<PlassSize, double> controlText = <PlassSize, double>{
  PlassSize.xs: 11,
  PlassSize.sm: 13,
  PlassSize.md: 14,
  PlassSize.lg: 16,
  PlassSize.xl: 18,
};

/// Horizontal padding, and the only thing density is allowed to touch.
///
/// The two tracks are roughly 2:1 so the difference is legible at a glance
/// rather than a two-pixel nudge.
const Map<PlassDensity, Map<PlassSize, double>> paddingX = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 10,
    PlassSize.sm: 12,
    PlassSize.md: 16,
    PlassSize.lg: 24,
    PlassSize.xl: 28,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 6,
    PlassSize.sm: 8,
    PlassSize.md: 10,
    PlassSize.lg: 14,
    PlassSize.xl: 16,
  },
};

/// Between a control's own parts — an icon and its label.
const Map<PlassSize, double> gap = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

/// How large a glyph *inside* a control is drawn, as a multiple of the label.
///
/// A ratio rather than a ladder: an icon in a button belongs to the word next
/// to it, so it tracks the label rather than carrying a size of its own. The
/// React package writes this as `1.2em` and means the same thing.
const double iconScale = 1.2;

/// How far the focus ring sits outside the control, matching CSS's
/// `outline-offset: 2px`.
const double focusRingOffset = 2;

/// How thick that ring is, matching CSS's `outline: 2px solid`.
const double focusRingWidth = 2;

/// The radius of the bloom that follows the pointer, in logical pixels.
///
/// `6rem` in the stylesheet, which is 96.
const double glowRadius = 96;

/// The radius of the brighter flash on press. `5rem`, which is 80.
const double flashRadius = 80;

/// How much saturation a read-only surface keeps.
///
/// Read-only keeps the shape, the colour and the edge but goes flat, loses its
/// lift and drains most of the saturation — a label that happens to be
/// control-shaped. It is not dimmed: the value is still there to be read, which
/// is the whole difference from disabled.
const double readOnlySaturation = 0.55;

/// How much saturation a disabled surface keeps, and how much opacity.
///
/// Disabled is **the light going out.** The key keeps its shape, its colour and
/// its place in the layout, and stops catching any light: no gloss, no tinted
/// lift, no shadow, most of the saturation gone and half the opacity with it.
///
/// Opacity is doing real work here rather than standing in for a decision. On a
/// page made of translucent sheets, a surface that has gone part-transparent is
/// a surface the page is showing *through* — it has stopped being an object.
const double disabledSaturation = 0.35;

/// See [disabledSaturation].
const double disabledOpacity = 0.5;

/// The brightness a filled surface takes under the pointer.
///
/// Hover turns the light up and press turns it down, and both are a brightness
/// change rather than a second set of colours — because the fill is a gradient
/// and a gradient cannot be transitioned, but light falling on one can.
const double hoverBrightness = 1.05;

/// The brightness a filled surface takes while it is held down.
const double pressBrightness = 0.95;
