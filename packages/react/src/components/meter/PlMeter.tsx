'use client';

import * as React from 'react';
import { Meter } from '@base-ui/react/meter';
import { useDefaults } from '../../internal/defaults.js';
import {
  barThicknessClasses,
  fillTransitionClasses,
  progressSlots,
  trackClasses
} from '../../internal/progress.js';
import { cx, metaTextClasses, stackGapClasses } from '../../internal/styles.js';
import type { PlassColor, PlassSize } from '../../types.js';

/** Where a band starts, and what the bar is made of from there up. */
export interface PlMeterThreshold {
  /**
   * The value the band begins at, in the meter's own units — not a percentage,
   * unless the range happens to be one. A band whose `from` is outside
   * `min`…`max` is simply never reached.
   */
  from: number;
  /** The family the bar takes while the value is in this band. */
  color: PlassColor;
}

export interface PlMeterProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'children'
> {
  /**
   * How much there is.
   *
   * **Required, and that is the whole difference from a `PlProgressLinear`.** A
   * meter reports a quantity that is already known — disk used, seats taken,
   * how full a battery is — so there is no indeterminate case for it to have a
   * default for. A bar with nothing to report is not a meter; it is a bar that
   * should not have been drawn yet.
   */
  value: number;
  /** @default 0 */
  min?: number;
  /** @default 100 */
  max?: number;
  /** A name for what is being measured. Read out with the value. */
  label?: React.ReactNode;
  /**
   * Shows the value as text beside the bar. A percentage of the range unless
   * `format` says otherwise.
   * @default false
   */
  showValue?: boolean;
  /**
   * How the value is written when it is shown — `Intl.NumberFormat` options, so
   * bytes, currencies and plain counts all work. Without it the value is a
   * percentage of `min`…`max`, which is the only formatting that holds for a
   * range nobody described.
   */
  format?: Intl.NumberFormatOptions;
  /**
   * Bands that change the bar's family as the value climbs.
   *
   * The band with the highest `from` at or below the value wins, and `color` is
   * what the bar is made of below all of them. Order does not matter; the list
   * is read, not walked.
   *
   * This is the prop a meter exists for: a quota bar that is `primary` at a
   * third full, `warning` at three quarters and `danger` at ninety percent
   * says something a fixed colour cannot. The number is still written out by
   * `showValue`, because a band is a second way of saying it and never the
   * only one.
   */
  thresholds?: readonly PlMeterThreshold[];
  /** Thickness of the groove. Nothing else on a meter has a size. */
  size?: PlassSize;
  /** The family the bar takes where no threshold applies. @default 'primary' */
  color?: PlassColor;
}

/**
 * The family a value lands in.
 *
 * The highest band at or below the value, or `color` when the value is under
 * all of them. One pass rather than a sort, because the list is small and
 * sorting a caller's array — or a copy of it on every render — buys nothing.
 */
function bandColor(
  value: number,
  color: PlassColor,
  thresholds: readonly PlMeterThreshold[] | undefined
): PlassColor {
  if (!thresholds?.length) {
    return color;
  }

  let best: PlMeterThreshold | undefined;

  for (const threshold of thresholds) {
    if (value >= threshold.from && (best === undefined || threshold.from > best.from)) {
      best = threshold;
    }
  }

  return best?.color ?? color;
}

/**
 * A quantity inside a range, drawn as a bar.
 *
 * It looks like a [PlProgressLinear](./progress-linear) and it is not one, and
 * the difference is worth stating because it decides which to reach for.
 * **Progress is something advancing; a meter is something already known.** Disk
 * used, seats taken, a password's strength, how full a battery is — none of
 * them is going anywhere on its own, and none of them has an indeterminate
 * state. So `value` is required here, there is no sweep, and the role a screen
 * reader is given is `meter` rather than `progressbar`.
 *
 * `thresholds` is the prop it exists for. A quota bar that turns amber at three
 * quarters and red at ninety percent says something a fixed colour cannot, and
 * the colour is derived from the value rather than chosen by the caller at the
 * moment they happened to be looking.
 *
 * Base UI owns the semantics — the role, the range attributes, `aria-valuetext`
 * and the formatting — and it computes the fill width too, so what is left here
 * is the material: the groove is `--plass-track` and the fill is the family's
 * gradient, both the same as a progress bar's. One material, two meanings. The
 * fill travels on `width` because a gradient cannot be transitioned and a
 * length can.
 */
export const PlMeter = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlMeterProps>(
  function PlMeter(
    {
      value,
      min = 0,
      max = 100,
      label,
      showValue = false,
      format,
      thresholds,
      size: sizeProp,
      color: colorProp,
      className,
      style,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';

    return (
      <Meter.Root
        ref={ref}
        value={value}
        min={min}
        max={max}
        format={format}
        locale={defaults.locale}
        className={cx('flex w-full flex-col', stackGapClasses[size], className)}
        style={{ ...progressSlots(bandColor(value, color, thresholds)), ...style }}
        {...props}
      >
        {label || showValue ? (
          <div
            className={cx(
              'flex items-baseline gap-2',
              label ? 'justify-between' : 'justify-end',
              metaTextClasses[size]
            )}
          >
            {label ? (
              <Meter.Label className="min-w-0 truncate text-(--plass-fg)">{label}</Meter.Label>
            ) : null}
            {showValue ? (
              <Meter.Value className="shrink-0 tabular-nums text-(--plass-muted-fg)" />
            ) : null}
          </div>
        ) : null}

        <Meter.Track
          className={cx(
            'relative w-full overflow-hidden rounded-full',
            trackClasses,
            barThicknessClasses[size]
          )}
        >
          <Meter.Indicator
            className={cx('rounded-full [background-image:var(--p-fill)]', fillTransitionClasses)}
          />
        </Meter.Track>
      </Meter.Root>
    );
  }
);
