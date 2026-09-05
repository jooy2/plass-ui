'use client';

import * as React from 'react';
import {
  areaPath,
  barMaxThickness,
  barPath,
  barRadius,
  extentOf,
  linePath,
  lineWidths,
  markerRadii,
  markGap,
  resolveColor,
  sparklineHeights,
  toValue
} from '../../internal/chart.js';
import { useMeasuredWidth } from '../../internal/chart-frame.js';
import { useDefaults } from '../../internal/defaults.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import type { PlassChartCurve, PlassChartDatum, PlassColor, PlassSize } from '../../types.js';

export interface PlSparklineProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'children'
> {
  /** The values. `null` is a gap, exactly as it is on every other chart. */
  data: readonly PlassChartDatum[];
  /**
   * Which mark. A line for a trend, an area for a quantity, bars for a count of
   * discrete things — the same three sentences the full charts say, at a size
   * where nothing else is being said at all.
   * @default 'line'
   */
  shape?: 'line' | 'area' | 'bar';
  /** How the line gets from one point to the next. @default 'linear' */
  curve?: PlassChartCurve;
  /**
   * How tall the strip is. Sized against the line of text it sits beside rather
   * than against the page — a sparkline is a word in a sentence, not a picture.
   * @default 'md'
   */
  size?: PlassSize;
  /**
   * The mark's colour. A `PlassColor` family, or any CSS colour.
   *
   * Unlike the full charts this one takes it directly: a sparkline has exactly
   * one series and no legend, so there is nothing for a palette to hand out.
   * @default the first chart slot
   */
  color?: PlassColor | (string & {});
  /**
   * Puts a dot on the last point. The one direct label a strip this small has
   * room for, and it says where the series ended up.
   * @default false
   */
  endDot?: boolean;
  /**
   * Draws a rule across the strip at this value — a target, a budget, last
   * year's average. The one piece of context a sparkline can carry.
   */
  baseline?: number;
  /**
   * The bottom of the scale. Left out, the strip fills itself with its own
   * range, which is what makes a sparkline legible at twenty pixels tall — and
   * what makes two of them side by side incomparable. Pass the same `min` and
   * `max` to a row of them and they become a small-multiples chart.
   */
  min?: number;
  /** And the top of it. */
  max?: number;
  /** How wide. Fills its container by default. */
  width?: number | string;
  /** A name for the strip, read out in place of it. */
  label?: string;
}

/**
 * A chart with everything taken away except the shape.
 *
 * No axes, no grid, no legend, no tooltip — it is not a small chart, it is a
 * different thing: a word-sized picture that goes inside a sentence, beside a
 * [`PlStat`](../display/stat), or in a table cell, and says which way something
 * has been going. Every number it could label is one the surrounding text
 * already has, which is why it labels none of them.
 *
 * It scales itself to its own range, so the strip is always full. That is what
 * makes it readable this small and it is also the trap: two sparklines side by
 * side are drawn on two different scales unless they are given the same `min`
 * and `max`.
 */
export const PlSparkline = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlSparklineProps>(
  function PlSparkline(
    {
      data,
      shape = 'line',
      curve = 'linear',
      size: sizeProp,
      color,
      endDot = false,
      baseline,
      min,
      max,
      width: widthProp,
      label,
      className,
      style,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';

    const hostRef = React.useRef<HTMLDivElement>(null);
    const measured = useMeasuredWidth(hostRef);
    const id = React.useId().replace(/:/g, '');

    const values = React.useMemo(() => data.map(toValue), [data]);
    const height = sparklineHeights[size];
    const stroke = lineWidths[size];
    const radius = markerRadii[size];

    const extent = extentOf([values], false);
    const low = min ?? (extent ? Math.min(extent.min, baseline ?? extent.min) : 0);
    const high = max ?? (extent ? Math.max(extent.max, baseline ?? extent.max) : 1);
    const span = high - low || 1;

    const width = typeof widthProp === 'number' ? widthProp : measured;
    const fill = resolveColor(color ?? 'var(--plass-chart-1)');

    // The stroke straddles the path, so the drawable band comes in by half of
    // it at both ends — otherwise the highest and lowest points are shaved off
    // by the edge of the box.
    const inset = shape === 'bar' ? 0 : stroke / 2 + (endDot ? radius : 0);
    const usable = Math.max(1, height - inset * 2);

    const y = (value: number) => inset + (1 - (value - low) / span) * usable;
    const step = values.length > 1 ? width / (values.length - 1) : width;

    const points = values.map((value, index) =>
      value.value === null ? null : { x: index * step, y: y(value.value) }
    );

    /** The last point that is actually a point — where the end dot goes. */
    const lastIndex = (() => {
      for (let index = values.length - 1; index >= 0; index--) {
        if (values[index].value !== null) {
          return index;
        }
      }

      return -1;
    })();

    const slot = width / Math.max(1, values.length);
    const barWidth = Math.min(barMaxThickness[size] / 2, Math.max(1, slot - markGap));

    return (
      <div
        ref={ref}
        className={cx('relative block', className ?? undefined)}
        style={{ width: widthProp ?? '100%', height, ...style }}
        {...props}
      >
        <div ref={hostRef} className="absolute inset-0">
          {width > 0 && values.length > 0 ? (
            <svg
              width={width}
              height={height}
              viewBox={`0 0 ${width} ${height}`}
              role={label ? 'img' : 'presentation'}
              aria-label={label}
              aria-hidden={label ? undefined : true}
              className="block overflow-visible"
            >
              {shape === 'area' ? (
                <>
                  <defs>
                    <linearGradient id={`${id}-fill`} x1="0" y1="0" x2="0" y2="1">
                      <stop
                        offset="0%"
                        stopColor={`color-mix(in oklab, ${fill} 32%, transparent)`}
                      />
                      <stop
                        offset="100%"
                        stopColor={`color-mix(in oklab, ${fill} 2%, transparent)`}
                      />
                    </linearGradient>
                  </defs>
                  <path d={areaPath(points, height, curve)} fill={`url(#${id}-fill)`} />
                </>
              ) : null}

              {baseline !== undefined ? (
                <line
                  x1={0}
                  x2={width}
                  y1={y(baseline)}
                  y2={y(baseline)}
                  stroke="var(--plass-chart-baseline)"
                  strokeWidth={1}
                />
              ) : null}

              {shape === 'bar' ? (
                values.map((value, index) =>
                  value.value === null ? null : (
                    <path
                      key={index}
                      d={barPath(
                        index * slot + (slot - barWidth) / 2,
                        Math.min(y(value.value), y(Math.max(low, 0))),
                        barWidth,
                        Math.max(1, Math.abs(y(value.value) - y(Math.max(low, 0)))),
                        barRadius / 2,
                        value.value >= 0 ? 'up' : 'down'
                      )}
                      fill={value.color ?? fill}
                    />
                  )
                )
              ) : (
                <path
                  d={linePath(points, curve)}
                  fill="none"
                  stroke={fill}
                  strokeWidth={stroke}
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              )}

              {endDot && lastIndex >= 0 && shape !== 'bar' ? (
                <circle
                  cx={points[lastIndex]!.x}
                  cy={points[lastIndex]!.y}
                  r={radius}
                  fill={fill}
                  stroke="var(--plass-chart-gap)"
                  strokeWidth={markGap}
                />
              ) : null}
            </svg>
          ) : null}
        </div>

        {/* The numbers, for the readers the strip does not reach. A sparkline is
            a picture of a trend and nothing else, so what it owes is the values
            — not a description of the shape they happen to make. */}
        {label ? (
          <span className={srOnlyClasses}>
            {values.map((value) => (value.value === null ? '—' : value.value)).join(', ')}
          </span>
        ) : null}
      </div>
    );
  }
);
