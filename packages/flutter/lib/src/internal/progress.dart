/// What the progress indicators share.
///
/// The Dart half of the React package's `internal/progress.ts`. A bar, and — as
/// they arrive — a ring and a row of plates: different shapes answering one
/// question, how far along is this and is it moving at all. So everything that
/// is *not* the shape belongs here: the ladders, the arithmetic that turns
/// value/min/max into a fraction, and the sentence the value reads as.
///
/// None of it is exported from `plass_ui.dart`.
library;

import 'package:plass_ui/src/types.dart';

/// How thick the linear groove is.
///
/// Its own ladder rather than a fraction of `controlHeight`: a bar is not a
/// control you can put a label inside, and at `md` it wants to be the weight of
/// a rule between two paragraphs rather than a quarter of a button.
///
/// They are `PlSlider`'s rail thicknesses, and deliberately: a rail and a bar
/// are the same channel, one of which you drag and one of which you watch.
const Map<PlassSize, double> barThickness = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 6,
  PlassSize.lg: 8,
  PlassSize.xl: 10,
};

/// How long a determinate indicator takes to travel to a new value.
///
/// One step slower than a control's, so a fill reads as travel rather than as a
/// state change. `--plass-duration-slow` in the stylesheet.
const Duration fillDuration = Duration(milliseconds: 260);

/// How long the indeterminate segment takes to cross the groove once.
const Duration sweepDuration = Duration(milliseconds: 1150);

/// And how long it takes under a reduced-motion preference, where it stops
/// travelling and breathes in place instead.
const Duration pulseDuration = Duration(milliseconds: 1800);

/// How much of the groove the travelling segment covers.
const double sweepWidth = 0.45;

/// The diameter of the ring, in logical pixels.
///
/// They sit just under the control ladder at every step — a `md` ring is 20
/// inside a 40 control — so a ring dropped into a button, a field or a table row
/// never makes the row taller than it already was.
const Map<PlassSize, double> ringDiameter = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 16,
  PlassSize.md: 20,
  PlassSize.lg: 26,
  PlassSize.xl: 32,
};

/// The ring's stroke, thickening with the ring so the hole stays in proportion.
const Map<PlassSize, double> ringStroke = <PlassSize, double>{
  PlassSize.xs: 1.5,
  PlassSize.sm: 1.75,
  PlassSize.md: 2,
  PlassSize.lg: 2.5,
  PlassSize.xl: 3,
};

/// How much of the circle an indeterminate ring draws while it turns.
const double ringArcSweep = 0.28;

/// How long that ring takes to go round once.
const Duration spinDuration = Duration(milliseconds: 900);

/// And how long under a reduced-motion preference, where it is slowed to where
/// it stops reading as motion rather than being stopped: an indeterminate
/// indicator that holds still says the opposite of what it is for.
const Duration slowSpinDuration = Duration(milliseconds: 2400);

/// `value` as a fraction of the range, or `null` when there is nothing to say.
///
/// The clamp is not defensive programming for its own sake — `value` usually
/// arrives from a division somewhere, and a bar that renders 140% wide because
/// one request finished twice is a worse bug than a bar that sits full.
double? progressFraction(double? value, double min, double max) {
  if (value == null || value.isNaN) {
    return null;
  }

  if (max <= min) {
    return null;
  }

  return ((value - min) / (max - min)).clamp(0.0, 1.0);
}

/// What the value reads as, both on screen and to a screen reader.
///
/// A percentage of `min`…`max` rather than of 100, which is the only formatting
/// that holds for a range nobody described: "3%" for step 3 of 4 is worse than
/// saying nothing. A caller who wants the number to mean something else passes
/// [PlProgressLinear.formatValue] and says so.
String? progressText(double? fraction) {
  return fraction == null ? null : '${(fraction * 100).round()}%';
}

/// The value as a screen reader hears it, or `null` while there is none.
///
/// `null` is not an omission: it is what tells the platform to announce
/// indeterminate progress rather than a number.
String? progressSemanticValue(
  double? fraction,
  String Function(double value)? format,
  double? raw,
) {
  if (fraction == null) {
    return null;
  }

  return format != null && raw != null ? format(raw) : progressText(fraction);
}
