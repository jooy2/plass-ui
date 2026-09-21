'use client';

import * as React from 'react';
import { CartesianChart, type CartesianChartProps } from '../../internal/chart-frame.js';
import { zeroNulls } from '../../internal/chart.js';
import { LineSeries, type ChartMarkers } from '../../internal/chart-line.js';
import type {
  PlassChartCurve,
  PlassChartLabelColor,
  PlassChartNulls,
  PlassChartValueLabels
} from '../../types.js';

export interface PlLineChartProps extends CartesianChartProps {
  /**
   * How the line gets from one point to the next.
   *
   * - `linear` — straight segments. The default, and the only one that claims
   *   nothing the data did not say.
   * - `smooth` — a monotone cubic. Curved, but it will not dip below a value
   *   that both of its neighbours are above; a plain spline would.
   * - `step` — held at each value until the next one. What a rate, a tier or a
   *   setting actually did between two readings, rather than a diagonal
   *   pretending it drifted.
   * @default 'linear'
   */
  curve?: PlassChartCurve;
  /**
   * Dots on the points.
   *
   * `auto` — the default — draws them while there are few enough points for a
   * dot to mean something, and stops at fourteen. Whatever this says, the point
   * under the pointer always gets one: that is what tells the reader which
   * column the tooltip is about.
   * @default 'auto'
   */
  markers?: ChartMarkers;
  /**
   * Fades the line from a paler step of its own hue at the start to the full
   * colour at the end, so the recent end of a long series is the loud one.
   * @default false
   */
  gradient?: boolean;
  /**
   * What a gap in a series does to the line.
   *
   * - `gap` — it breaks at the `null`. The default, and the only answer that
   *   claims nothing the data did not: the blank says the reading is missing.
   * - `connect` — the two sides are joined. Only when the gap is an artefact of
   *   how the data was collected; otherwise the segment is a number the chart
   *   made up.
   * - `zero` — the gap is read as a zero, everywhere: on the axis, in the
   *   tooltip and in the table as well as under the line. For a missing row
   *   that genuinely means none.
   * @default 'gap'
   */
  nulls?: PlassChartNulls;
  /**
   * Bridges a gap instead of breaking at it.
   * @deprecated Use `nulls`. `connectNulls` is `nulls="connect"`, and `nulls`
   * also has the third answer — reading the gap as a zero — which a boolean
   * cannot express. It is still honoured when `nulls` is not given.
   */
  connectNulls?: boolean;
  /**
   * Which values are written on the line. `last` is the one to reach for — it
   * names where each series ended up, which is the question a line chart is
   * usually being asked.
   * @default 'none'
   */
  valueLabels?: PlassChartValueLabels;
  /**
   * What colour those numbers are written in.
   *
   * `series` — the default — gives each label the colour of the line it is
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
   * Stacks the series, each line riding on the total of the ones below it.
   *
   * Rare on a line chart and worth thinking twice about: the reader can follow
   * the bottom series and the top total, and nothing in between. An
   * [`PlAreaChart`](./area-chart) is the shape that makes stacking legible.
   * @default false
   */
  stacked?: boolean;
}

/**
 * A value against time, or against anything else with an order to it.
 *
 * The line is the mark that says *change*: it claims the space between two
 * points is a journey rather than two separate facts, which is true of a
 * temperature and false of four product categories. Reach for a
 * [`PlBarChart`](./bar-chart) when the categories could be shuffled without losing
 * anything.
 *
 * Everything around the line — the axes, the grid, the crosshair, the legend,
 * the tooltip and the table a screen reader gets instead of the picture — comes
 * from the shared frame, which is what makes a PlLineChart and a PlBarChart on one
 * dashboard read as one drawing rather than two.
 */
export function PlLineChart({
  curve = 'linear',
  markers = 'auto',
  gradient = false,
  nulls: nullsProp,
  connectNulls = false,
  valueLabels = 'none',
  valueLabelColor = 'series',
  stacked = false,
  series,
  ...props
}: PlLineChartProps) {
  const id = React.useId().replace(/:/g, '');
  // The old boolean is read only when the prop that replaced it says nothing,
  // so a caller who has moved across is not overruled by a `connectNulls` left
  // behind on the same element.
  const nulls = nullsProp ?? (connectNulls ? 'connect' : 'gap');

  /* A zeroed gap is a change to the *data*, not to the drawing, which is what
     lets the axis, the tooltip and the table all agree that the month was a
     nought rather than a blank. */
  const shown = React.useMemo(
    () => (nulls === 'zero' ? zeroNulls(series) : series),
    [nulls, series]
  );

  return (
    <CartesianChart
      {...props}
      series={shown}
      stacked={stacked}
      // A line sits *on* its category tick, not in the middle of a band — the
      // first point belongs against the axis, not a half-step off it.
      inset
      // The value axis is free to leave zero out here, and a bar chart's is not.
      // What a line encodes is a *position*, so cropping the scale moves every
      // point by the same amount and the shape survives; what a bar encodes is
      // a length, which stops meaning anything the moment it starts from 98.
      // A series that lives between 98 and 99 is a flat line on a scale that
      // begins at zero — `yAxis={{ min: 0 }}` is how a caller asks for one.
      includeZero={false}
      headroom={valueLabels === 'none' ? 0 : 10}
    >
      {(context) => (
        <LineSeries
          context={context}
          curve={curve}
          filled={false}
          stacked={stacked}
          markers={markers}
          valueLabels={valueLabels}
          valueLabelColor={valueLabelColor}
          nulls={nulls}
          gradient={gradient}
          idPrefix={id}
        />
      )}
    </CartesianChart>
  );
}
