'use client';

import * as React from 'react';
import { CartesianChart, type CartesianChartProps } from '../../internal/chart-frame.js';
import { LineSeries, type ChartMarkers } from '../../internal/chart-line.js';
import { toValues } from '../../internal/chart.js';
import type { PlassChartCurve, PlassChartSeries, PlassChartValueLabels } from '../../types.js';

export interface PlAreaChartProps extends CartesianChartProps {
  /**
   * How the edge of the band gets from one point to the next. The same three
   * shapes a [PlLineChart](./line-chart) offers, and they mean the same things.
   * @default 'linear'
   */
  curve?: PlassChartCurve;
  /**
   * Stacks the bands, each one riding on the total of those below it.
   *
   * - `true` — absolute totals. The top edge is the sum, which is the thing a
   *   stacked area is usually drawn to show.
   * - `'full'` — every category normalised to 100%, so the chart is about
   *   *share* and stops being about size. The value axis becomes a percentage
   *   and says so.
   * @default false
   */
  stacked?: boolean | 'full';
  /**
   * Dots on the points. `none` by default rather than `auto`: a filled band
   * already has a visible edge, and a row of dots on it is ink that says
   * nothing the fill did not.
   * @default 'none'
   */
  markers?: ChartMarkers;
  /** @default 'none' */
  valueLabels?: PlassChartValueLabels;
  /**
   * Draws the band straight through a `null` instead of breaking at it. Off,
   * and on an area it matters more than on a line: a fill that closes across a
   * missing month paints a made-up number over a larger part of the chart.
   * @default false
   */
  connectNulls?: boolean;
}

/**
 * A line with the space under it filled — which changes what the chart is
 * about.
 *
 * A line says where a value went. An area says how much of something there was,
 * and stacked it says how that amount was made up. That is the whole test for
 * reaching for this instead of a [PlLineChart](./line-chart): if the quantity
 * does not add up to anything — a temperature, a rate, a score — the fill under
 * it is decoration, and a chart with two of them is two washes fighting.
 *
 * Unstacked bands are a wash at about a quarter opacity, fading out downward,
 * so two of them overlapping stay readable. Stacked bands are opaquer, because
 * there the fill *is* the mark rather than a hint at the line above it.
 */
export function PlAreaChart({
  curve = 'linear',
  stacked = false,
  markers = 'none',
  valueLabels = 'none',
  connectNulls = false,
  series,
  yAxis,
  format,
  ...props
}: PlAreaChartProps) {
  const id = React.useId().replace(/:/g, '');
  const full = stacked === 'full';

  /* 100% stacking is a change to the *data*, not to the drawing: each category
     is renormalised to add up to a hundred. Doing it here rather than in the
     renderer is what lets the axis, the tooltip and the table all agree that
     the number is a share — they read the series they were given. */
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
          // The tooltip and the table keep the number the caller passed, which
          // is the one they actually have. A stacked-to-full chart that can
          // only tell you percentages has thrown the data away.
          label: value.label ?? String(value.value)
        };
      })
    }));
  }, [series, full]);

  return (
    <CartesianChart
      {...props}
      series={shown}
      format={format}
      yAxis={full ? { min: 0, max: 100, tickFormat: (value) => `${value}%`, ...yAxis } : yAxis}
      stacked={stacked !== false}
      inset
      // Unlike a line, an area's *fill* is its magnitude, so the baseline has to
      // be zero or the band's thickness stops meaning anything.
      includeZero
      headroom={valueLabels === 'none' ? 0 : 10}
    >
      {(context) => (
        <LineSeries
          context={context}
          curve={curve}
          filled
          stacked={stacked !== false}
          markers={markers}
          valueLabels={valueLabels}
          connectNulls={connectNulls}
          gradient={false}
          idPrefix={id}
        />
      )}
    </CartesianChart>
  );
}
