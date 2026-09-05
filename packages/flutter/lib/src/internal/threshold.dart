/// Which band a reading has landed in.
///
/// One rule, shared by the two widgets that draw a value against a scale a
/// caller described: [PlMeter]'s bar and `PlGaugeChart`'s arc. Written twice
/// they would drift, and a quota that turns `danger` on a bar but not on the
/// dial beside it is a dashboard that contradicts itself.
///
/// It is not exported from `plass_ui.dart`.
library;

import 'package:plass_ui/src/types.dart';

/// The family a value lands in.
///
/// The highest band at or below the value, or [color] when the value is under
/// all of them. A single pass rather than a sort, because the list is small and
/// sorting a caller's list — or a copy of it on every build — buys nothing.
/// Reading it rather than walking it in order is also what makes the prop
/// order-independent, which is what a caller assumes.
PlassColor bandColor(double value, PlassColor color, List<PlassThreshold>? thresholds) {
  if (thresholds == null || thresholds.isEmpty) {
    return color;
  }

  PlassThreshold? best;

  for (final PlassThreshold threshold in thresholds) {
    if (value >= threshold.from && (best == null || threshold.from > best.from)) {
      best = threshold;
    }
  }

  return best?.color ?? color;
}
