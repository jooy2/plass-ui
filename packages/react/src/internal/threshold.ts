/**
 * Which band a reading has landed in.
 *
 * One rule, shared by the two components that draw a value against a scale a
 * caller described: `PlMeter`'s bar and `PlGaugeChart`'s arc. Written twice
 * they would drift, and a quota that turns `danger` on a bar but not on the
 * dial beside it is a dashboard that contradicts itself.
 */

import type { PlassColor, PlassThreshold } from '../types.js';

/**
 * The family a value lands in.
 *
 * The highest band at or below the value, or `color` when the value is under
 * all of them. One pass rather than a sort, because the list is small and
 * sorting a caller's array — or a copy of it on every render — buys nothing.
 * Reading it rather than walking it in order is also what makes the prop
 * order-independent, which is what a caller assumes.
 */
export function bandColor(
  value: number,
  color: PlassColor,
  thresholds: readonly PlassThreshold[] | undefined
): PlassColor {
  if (!thresholds?.length) {
    return color;
  }

  let best: PlassThreshold | undefined;

  for (const threshold of thresholds) {
    if (value >= threshold.from && (best === undefined || threshold.from > best.from)) {
      best = threshold;
    }
  }

  return best?.color ?? color;
}
