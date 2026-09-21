'use client';

import * as React from 'react';
import { CartesianChart, type CartesianChartProps } from '../../internal/chart-frame.js';
import { LineSeries, type ChartMarkers } from '../../internal/chart-line.js';
import { stackToFull, writeChartValue, zeroNulls } from '../../internal/chart.js';
import { useDefaults } from '../../internal/defaults.js';
import type {
  PlassChartCurve,
  PlassChartLabelColor,
  PlassChartNulls,
  PlassChartSeries,
  PlassChartValueLabels
} from '../../types.js';

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
   * What colour those numbers are written in.
   *
   * `series` — the default — gives each label the colour of the band it is
   * sitting on, so a plot with four labelled series says which number belongs
   * to which without the reader tracing it back. `ink` writes them all in the
   * page's own foreground: the chart palette clears 4:1 against the sheet,
   * which is the floor a *mark* is held to rather than the 4.5:1 body text
   * wants, so reach for it where the labels have to meet the text contrast rule
   * on their own.
   * @default 'series'
   */
  valueLabelColor?: PlassChartLabelColor;
  /**
   * What a gap in a series does to the band.
   *
   * - `gap` — it breaks at the `null`. The default, and the only answer that
   *   claims nothing the data did not: the blank says the reading is missing.
   * - `connect` — the two sides are joined. Only when the gap is an artefact of
   *   how the data was collected; otherwise the segment is a number the chart
   *   made up.
   * - `zero` — the gap is read as a zero, everywhere: on the axis, in the
   *   tooltip and in the table as well as under the band. For a missing row
   *   that genuinely means none.
   * @default 'gap'
   */
  nulls?: PlassChartNulls;
  /**
   * Bridges a gap instead of breaking at it. It matters more on an area than on
   * a line: a fill that closes across a missing month paints the made-up number
   * over a larger part of the chart.
   * @deprecated Use `nulls`. `connectNulls` is `nulls="connect"`, and `nulls`
   * also has the third answer — reading the gap as a zero — which a boolean
   * cannot express. It is still honoured when `nulls` is not given.
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
  valueLabelColor = 'series',
  nulls: nullsProp,
  connectNulls = false,
  series,
  yAxis,
  format,
  locale,
  ...props
}: PlAreaChartProps) {
  const defaults = useDefaults();
  const resolvedLocale = locale ?? defaults.locale;
  const id = React.useId().replace(/:/g, '');
  const full = stacked === 'full';
  // The old boolean is read only when the prop that replaced it says nothing.
  const nulls = nullsProp ?? (connectNulls ? 'connect' : 'gap');

  /* 100% stacking is a change to the *data*, not to the drawing: each category
     is renormalised to add up to a hundred. Doing it here rather than in the
     renderer is what lets the axis, the tooltip and the table all agree that
     the number is a share — they read the series they were given. */
  const shown = React.useMemo<readonly PlassChartSeries[]>(() => {
    /* A zeroed gap first, so a band normalised to 100% counts the nought as a
       nought rather than dropping the category out of its own total. Both are
       changes to the *data* for the same reason: the axis, the tooltip and the
       table all read the series they were given. */
    const data = nulls === 'zero' ? zeroNulls(series) : series;

    return full
      ? stackToFull(data, (value) => writeChartValue(value, format, resolvedLocale))
      : data;
  }, [series, nulls, full, format, resolvedLocale]);

  return (
    <CartesianChart
      {...props}
      series={shown}
      format={format}
      locale={locale}
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
          valueLabelColor={valueLabelColor}
          nulls={nulls}
          gradient={false}
          idPrefix={id}
        />
      )}
    </CartesianChart>
  );
}
