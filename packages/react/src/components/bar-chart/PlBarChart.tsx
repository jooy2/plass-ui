'use client';

import * as React from 'react';
import {
  CartesianChart,
  markTransitionClasses,
  type CartesianChartProps,
  type CartesianContext
} from '../../internal/chart-frame.js';
import {
  barBandRatio,
  barMaxThickness,
  barPath,
  barRadius,
  chartFontSizes,
  markGap,
  toValues,
  type ChartValue
} from '../../internal/chart.js';
import type {
  PlassChartSeries,
  PlassChartValueLabels,
  PlassOrientation,
  PlassSize
} from '../../types.js';
import { useDefaults } from '../../internal/defaults.js';

export interface PlBarChartProps extends CartesianChartProps {
  /**
   * Which way the bars run.
   *
   * `vertical` — the default — grows them up from the bottom, which is what
   * most people mean by a bar chart. `horizontal` grows them out from the left,
   * and it is the right answer whenever the category names are words: a
   * horizontal chart has a whole column for them, and a vertical one has the
   * width of one bar.
   * @default 'vertical'
   */
  orientation?: PlassOrientation;
  /**
   * Puts the series on top of each other instead of beside each other.
   *
   * - `false` — grouped. Comparing series within a category.
   * - `true` — stacked. The bar's whole length is the total, and the segments
   *   are what it is made of.
   * - `'full'` — every bar the same length, so the chart is about share rather
   *   than size. The value axis becomes a percentage.
   * @default false
   */
  stacked?: boolean | 'full';
  /**
   * Cuts the corners off the data end of each bar. The baseline end stays
   * square — that is where the value starts from, and a rounded foot makes the
   * axis look scalloped.
   * @default true
   */
  rounded?: boolean;
  /**
   * How thick a bar may get, in pixels. Below the cap the bars fill their share
   * of the band; above it the leftover stays as air.
   * @default the `size` ladder — 24 at `md`
   */
  barSize?: number;
  /**
   * Which values are written on the bars.
   *
   * `all` is defensible here in a way it is not on a line chart: eight bars
   * with their numbers on them is a chart and a table at once. Past about a
   * dozen it stops being either.
   * @default 'none'
   */
  valueLabels?: PlassChartValueLabels;
}

/**
 * Lengths, compared.
 *
 * A bar says *how much*, and it says it by being longer — which is the whole
 * reason its axis starts at zero and cannot be talked out of it. Crop the scale
 * and a bar twice as long stops meaning twice as much, and the reader has no
 * way to know it happened. Reach for a [PlLineChart](./line-chart) when what
 * matters is the shape of a change rather than the size of each value.
 *
 * Grouped bars answer "which series is bigger here"; stacked bars answer "what
 * is this total made of". They are different questions and the chart should be
 * asked only one of them at a time.
 */
export function PlBarChart({
  orientation = 'vertical',
  stacked = false,
  rounded = true,
  barSize,
  valueLabels = 'none',
  series,
  yAxis,
  size: sizeProp,
  density: densityProp,
  ...props
}: PlBarChartProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const density = densityProp ?? defaults.density ?? 'default';

  const horizontal = orientation === 'horizontal';
  const full = stacked === 'full';

  /* 100% stacking renormalises the data before anything is drawn, so the axis,
     the tooltip and the table all agree about what the number is. The original
     value survives as the point's label — a chart that can only tell you
     percentages has thrown away what it was given. */
  const shown = React.useMemo<readonly PlassChartSeries[]>(() => {
    if (!full) {
      return series;
    }

    const values = toValues(series);
    const totals: number[] = [];

    for (const one of values) {
      one.forEach((value, index) => {
        totals[index] = (totals[index] ?? 0) + Math.abs(value.value ?? 0);
      });
    }

    return series.map((one, index) => ({
      ...one,
      data: values[index].map((value, category) => {
        if (value.value === null) {
          return null;
        }

        const total = totals[category];

        return {
          x: value.x,
          y: total === 0 ? 0 : (value.value / total) * 100,
          color: value.color,
          label: value.label ?? String(value.value)
        };
      })
    }));
  }, [series, full]);

  return (
    <CartesianChart
      {...props}
      series={shown}
      size={size}
      density={density}
      horizontal={horizontal}
      stacked={stacked !== false}
      yAxis={full ? { min: 0, max: 100, tickFormat: (value) => `${value}%`, ...yAxis } : yAxis}
      // A bar's length is its value, so zero is not optional.
      includeZero
      bandRatio={barBandRatio[density]}
      headroom={valueLabels === 'none' ? 0 : 12}
    >
      {(context) => (
        <Bars
          context={context}
          stacked={stacked !== false}
          rounded={rounded}
          barSize={barSize ?? barMaxThickness[size]}
          valueLabels={valueLabels}
          size={size}
        />
      )}
    </CartesianChart>
  );
}

interface BarsProps {
  context: CartesianContext;
  stacked: boolean;
  rounded: boolean;
  barSize: number;
  valueLabels: PlassChartValueLabels;
  size: PlassSize;
}

/**
 * The bars themselves, and the only part of a PlBarChart that is not the shared
 * frame.
 *
 * Two arrangements out of one loop: grouped bars split the band between the
 * visible series, stacked ones take the whole band and are pushed along by
 * whatever came before them. In both, the 2px between two touching marks is the
 * surface showing through and never a stroke — a border drawn around a bar is
 * ink that is not data.
 */
function Bars({ context, stacked, rounded, barSize, valueLabels, size }: BarsProps) {
  const {
    values,
    visible,
    colors,
    hovered,
    activeIndex,
    plot,
    band,
    horizontal,
    valuePx,
    categoryPx,
    zeroPx,
    format
  } = context;

  const drawn = values
    .map((one, index) => ({ one, index }))
    .filter((entry) => visible[entry.index]);
  const lanes = stacked ? 1 : Math.max(1, drawn.length);

  const laneWidth = Math.min(barSize, Math.max(1, (band.band - markGap * (lanes - 1)) / lanes));
  const groupWidth = laneWidth * lanes + markGap * (lanes - 1);

  /* Where each stacked segment starts, kept per category and per sign: a
     negative segment grows down from zero while the positives grow up, or a
     series that dips takes a bite out of the one above it. */
  const positive: number[] = [];
  const negative: number[] = [];

  // The same type as an axis tick. A value written on a mark is the same kind
  // of thing as one written under it, and two sizes of number on one chart
  // reads as two levels of importance that are not there.
  const labelSize = chartFontSizes[size];

  return (
    <g>
      {drawn.map(({ one, index }, lane) => {
        const color = colors[index];
        const dimmed = hovered !== null && hovered !== index;

        return (
          <g key={index} opacity={dimmed ? 0.28 : 1} className={markTransitionClasses}>
            {one.map((value: ChartValue, category: number) => {
              if (value.value === null) {
                return null;
              }

              const centre = categoryPx(category);
              const offset = stacked
                ? 0
                : lane * (laneWidth + markGap) - groupWidth / 2 + laneWidth / 2;

              const base = stacked
                ? value.value >= 0
                  ? (positive[category] ?? 0)
                  : (negative[category] ?? 0)
                : 0;

              const from = valuePx(base);
              const to = valuePx(base + value.value);

              if (stacked) {
                if (value.value >= 0) {
                  positive[category] = base + value.value;
                } else {
                  negative[category] = base + value.value;
                }
              }

              // The gap between two stacked segments is taken off the far end of
              // each, so the stack still totals the right length and the seam is
              // the sheet rather than a line drawn on it.
              const shrink = stacked && base !== 0 ? markGap : 0;
              const length = Math.abs(to - from) - shrink;

              if (length <= 0) {
                return null;
              }

              const grows = to < from;
              const active = category === activeIndex;

              const path = horizontal
                ? barPath(
                    Math.min(from, to) + (grows ? 0 : shrink),
                    plot.top + centre + offset - laneWidth / 2,
                    length,
                    laneWidth,
                    rounded && !stacked ? barRadius : rounded ? barRadius / 2 : 0,
                    value.value >= 0 ? 'right' : 'left'
                  )
                : barPath(
                    plot.left + centre + offset - laneWidth / 2,
                    Math.min(from, to) + (grows ? 0 : shrink),
                    laneWidth,
                    length,
                    rounded && !stacked ? barRadius : rounded ? barRadius / 2 : 0,
                    value.value >= 0 ? 'up' : 'down'
                  );

              return (
                <g key={category}>
                  <path
                    d={path}
                    fill={value.color ?? color}
                    opacity={active ? 1 : 0.92}
                    className={markTransitionClasses}
                  />

                  {valueLabels === 'none' ||
                  (valueLabels === 'extremes' && !isExtreme(one, category)) ? null : valueLabels ===
                      'last' && category !== one.length - 1 ? null : (
                    // Always just past the data end, on the outside — which for
                    // a bar that grows downward means *below* it. Kept at the
                    // end rather than inside the fill so it never has to be
                    // white on one bar and ink on the next.
                    <text
                      x={
                        horizontal ? to + (value.value >= 0 ? 5 : -5) : plot.left + centre + offset
                      }
                      y={
                        horizontal
                          ? plot.top + centre + offset
                          : value.value >= 0
                            ? to - 5
                            : to + labelSize + 2
                      }
                      textAnchor={horizontal ? (value.value >= 0 ? 'start' : 'end') : 'middle'}
                      dominantBaseline={horizontal ? 'central' : undefined}
                      fontSize={labelSize}
                      fontWeight={500}
                      fill="var(--plass-fg)"
                      className="tabular-nums"
                    >
                      {value.label ?? format(value.value)}
                    </text>
                  )}
                </g>
              );
            })}
          </g>
        );
      })}

      {/* The baseline, redrawn over the bars. Every bar starts here and the line
          is what says so; under them it is half-hidden by the first pixel of
          each one. */}
      {horizontal ? (
        <line
          x1={zeroPx}
          x2={zeroPx}
          y1={plot.top}
          y2={plot.top + plot.height}
          stroke="var(--plass-chart-baseline)"
          strokeWidth={1}
        />
      ) : (
        <line
          x1={plot.left}
          x2={plot.left + plot.width}
          y1={zeroPx}
          y2={zeroPx}
          stroke="var(--plass-chart-baseline)"
          strokeWidth={1}
        />
      )}
    </g>
  );
}

/** Whether this is the series' own high or low — the two bars worth naming. */
function isExtreme(one: readonly ChartValue[], index: number): boolean {
  const value = one[index].value;

  if (value === null) {
    return false;
  }

  let min = Infinity;
  let max = -Infinity;

  for (const entry of one) {
    if (entry.value === null) {
      continue;
    }

    min = Math.min(min, entry.value);
    max = Math.max(max, entry.value);
  }

  return value === min || value === max;
}
