'use client';

import * as React from 'react';
import {
  CartesianChart,
  markTransitionClasses,
  type CartesianChartProps,
  type CartesianContext,
  type CartesianLayout,
  type ChartMark,
  type ChartTooltipItem
} from '../../internal/chart-frame.js';
import {
  barBandRatio,
  barMaxThickness,
  barRadius,
  formatTimeTicks,
  formatTimeValue,
  markGap,
  resolveColor,
  seriesColor,
  timeScale,
  toNumber,
  type TimeScale
} from '../../internal/chart.js';
import { srOnlyClasses } from '../../internal/styles.js';
import type { PlassChartCategory, PlassTimelinePoint, PlassTimelineSeries } from '../../types.js';
import { useDefaults } from '../../internal/defaults.js';

export interface PlTimelineChartProps extends Omit<
  CartesianChartProps,
  'series' | 'categories' | 'legend'
> {
  /**
   * One row per series, and the spans on it. A row's name is what the axis
   * says down the left-hand side.
   */
  series: readonly PlassTimelineSeries[];
  /**
   * Where the time axis starts and ends. Taken from the spans otherwise, and
   * rounded outward to a date a calendar has a name for.
   */
  min?: PlassChartCategory;
  max?: PlassChartCategory;
  /**
   * How thick a bar may get, in pixels. Below the cap the bars fill their share
   * of the row; above it the leftover stays as air.
   * @default the `size` ladder — 24 at `md`
   */
  barSize?: number;
  /**
   * Cuts the corners off a span.
   *
   * Both ends, unlike a [`PlBarChart`](./bar-chart), where the baseline end stays
   * square. A span grows from nothing: neither of its ends is a zero, so
   * neither is the one the reader is measuring from.
   * @default true
   */
  rounded?: boolean;
}

/**
 * Work against time — a row per thing, a bar per stretch of it.
 *
 * The two axes are a set of rows and a calendar, which makes this a
 * [`PlBarChart`](./bar-chart) turned on its side with the baseline taken away:
 * every bar starts where its own data says rather than at zero, so what the
 * chart is about is *when* rather than *how much*.
 *
 * Not to be confused with [`PlTimeline`](../display/timeline), which is a list of
 * steps and draws no axis at all. That one is for a sequence of events; this
 * one is for how long each of them took.
 */
export function PlTimelineChart({
  series,
  min,
  max,
  barSize,
  rounded = true,
  size: sizeProp,
  density: densityProp,
  xAxis,
  yAxis,
  locale: localeProp,
  ...props
}: PlTimelineChartProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const density = densityProp ?? defaults.density ?? 'default';
  const locale = localeProp ?? defaults.locale;

  /* The rows, as instants, in lanes. Done once here rather than in the marks
     builder, because the axis has to be solved before anything can be placed on
     it — and because the lane a span sits in is a fact about the data rather
     than about the pixels. */
  const rows = React.useMemo(() => series.map(packRow), [series]);
  const spans = React.useMemo(() => rows.map((row) => row.spans), [rows]);

  const extent = React.useMemo(() => {
    let low = Infinity;
    let high = -Infinity;
    let seen = false;

    for (const row of spans) {
      for (const one of row) {
        if (!one) {
          continue;
        }

        seen = true;
        low = Math.min(low, one.from);
        high = Math.max(high, one.to);
      }
    }

    return seen ? { min: low, max: high } : null;
  }, [spans]);

  const scale = React.useMemo(
    () =>
      timeScale(extent, {
        min: toNumber(min) ?? undefined,
        max: toNumber(max) ?? undefined,
        tickCount: yAxis?.tickCount
      }),
    [extent, min, max, yAxis?.tickCount]
  );

  const tickTexts = React.useMemo(
    () => formatTimeTicks(scale.ticks, scale.unit, locale),
    [scale, locale]
  );

  const colors = React.useMemo(() => series.map((row, index) => seriesColor(row, index)), [series]);

  /* One synthetic series, with an entry per row.
     The frame counts *categories* along the band axis and stacks series within
     each one; a Gantt has the opposite shape — one row per entity, and several
     marks along each row. So the rows are handed over as the categories, and
     this stands in for the series the frame expects to find them under. A row
     with no spans is a `null`, which is what makes an empty chart empty. */
  const filler = React.useMemo(
    () => [{ data: spans.map((row) => (row.some(Boolean) ? 1 : null)) }],
    [spans]
  );

  const names = React.useMemo(
    () => series.map((row, index) => row.name ?? `${index + 1}`),
    [series]
  );

  const thickness = barSize ?? barMaxThickness[size];

  const marks = React.useCallback(
    (layout: CartesianLayout): ChartMark[] => {
      const list: ChartMark[] = [];

      rows.forEach((row, index) => {
        /* A row's lanes share its band, exactly as grouped bars share a
           category's: each takes an equal cut with the 2px of surface between
           them, and the whole group stays centred on the row's own tick. A row
           with one lane is unchanged, which is the point of packing at all. */
        const height = Math.min(
          thickness,
          Math.max(1, (layout.band.band - markGap * (row.lanes - 1)) / row.lanes)
        );
        const group = height * row.lanes + markGap * (row.lanes - 1);
        const top = layout.plot.top + layout.categoryPx(index) - group / 2 + height / 2;

        row.spans.forEach((one, at) => {
          if (!one) {
            return;
          }

          const from = layout.valuePx(one.from);
          const to = layout.valuePx(one.to);

          list.push({
            series: index,
            index: at,
            x: (from + to) / 2,
            y: top + one.lane * (height + markGap),
            r: height / 2,
            // A box and not a disc: a fortnight is two hundred pixels of bar
            // whose centre the pointer may never go near.
            rx: Math.max(0, (to - from) / 2),
            ry: height / 2
          });
        });
      });

      return list;
    },
    [rows, thickness]
  );

  const markTooltip = React.useCallback(
    (mark: ChartMark) => {
      const one = spans[mark.series]?.[mark.index];

      if (!one) {
        return null;
      }

      const items: ChartTooltipItem[] = [
        {
          seriesIndex: mark.series,
          name: names[mark.series],
          color: one.color ?? colors[mark.series],
          // A duration, which is the one number a span has. It is what a
          // caller's own `tooltip.render` gets handed.
          value: one.to - one.from,
          formatted: `${formatTimeValue(one.from, scale.unit, locale)} – ${formatTimeValue(
            one.to,
            scale.unit,
            locale
          )}`
        }
      ];

      // The span names itself when it can, and the row is then the second line
      // rather than a repeat of the first.
      return { heading: one.span.label ?? names[mark.series], items };
    },
    [spans, names, colors, scale.unit, locale]
  );

  return (
    <CartesianChart
      {...props}
      series={filler}
      categories={names}
      size={size}
      density={density}
      locale={locale}
      // The rows run down the side and time runs along the bottom, which is a
      // bar chart on its side. `xAxis` is still the category axis and `yAxis`
      // still the value one, exactly as on every other chart.
      horizontal
      scale={scale}
      xAxis={xAxis}
      yAxis={{ tickFormat: (_value, index) => tickTexts[index] ?? '', ...yAxis }}
      // A Gantt's rows are its axis; a legend would restate them one per line.
      legend={false}
      bandRatio={barBandRatio[density]}
      marks={marks}
      markTooltip={markTooltip}
      table={(id) => (
        <TimelineTable
          id={id}
          names={names}
          series={series}
          spans={spans}
          unit={scale.unit}
          label={props.label}
          corner={xAxis?.label}
          locale={locale}
        />
      )}
    >
      {(context) => <Spans context={context} spans={spans} colors={colors} rounded={rounded} />}
    </CartesianChart>
  );
}

/** A span, once its two ends are numbers and it knows which lane it is in. */
type Placed = {
  from: number;
  to: number;
  /** Which sub-lane of its row, for a row that does two things at once. */
  lane: number;
  color?: string;
  span: PlassTimelinePoint;
} | null;

/**
 * One row's spans, placed, with the overlapping ones moved onto lanes of their
 * own.
 *
 * A row that is doing two things at once is the ordinary case on a Gantt, and
 * drawing the second bar on top of the first turns two facts into one smudge.
 * The packing is the greedy one every scheduler uses: walk the spans in start
 * order and drop each into the first lane whose last one has finished. It is
 * optimal for intervals, and it leaves a row with no overlaps in a single lane
 * — so the common row is exactly as thick as it was.
 *
 * Lanes are assigned in *start* order and stored against the span's original
 * index, because the order the data was written in is the order the arrow keys
 * walk and that must not be reshuffled by a layout decision.
 */
function packRow(row: PlassTimelineSeries): { spans: Placed[]; lanes: number } {
  const spans: Placed[] = row.data.map((span) => {
    const from = toNumber(span.start);
    const to = toNumber(span.end);

    // Either way round. A span the caller wrote backwards is a typo, and
    // drawing it as a bar of negative width is a blank row.
    return from === null || to === null
      ? null
      : {
          from: Math.min(from, to),
          to: Math.max(from, to),
          lane: 0,
          color: span.color ? resolveColor(span.color) : undefined,
          span
        };
  });

  const ends: number[] = [];

  spans
    .map((one, index) => ({ one, index }))
    .filter((entry): entry is { one: NonNullable<Placed>; index: number } => Boolean(entry.one))
    .sort((a, b) => a.one.from - b.one.from)
    .forEach(({ one }) => {
      const free = ends.findIndex((end) => end <= one.from);
      const lane = free === -1 ? ends.length : free;

      ends[lane] = one.to;
      one.lane = lane;
    });

  return { spans, lanes: Math.max(1, ends.length) };
}

interface SpansProps {
  context: CartesianContext;
  spans: readonly (readonly Placed[])[];
  colors: readonly string[];
  rounded: boolean;
}

/**
 * The bars, and the only part of a PlTimelineChart that is not the shared frame.
 *
 * Drawn as rectangles rather than through `barPath`, which is the one place
 * this differs from a PlBarChart and is not an omission: `barPath` rounds the
 * data end and leaves the baseline end square, because a bar that is soft where
 * it meets the axis has lost the exact moment it starts. A span meets no axis.
 * Both of its ends are data, so both of them round.
 */
function Spans({ context, spans, colors, rounded }: SpansProps) {
  const { marks, activeMark, plot } = context;
  const radius = rounded ? barRadius : 0;

  return (
    <g>
      {marks.map((mark) => {
        const one = spans[mark.series]?.[mark.index];

        if (!one) {
          return null;
        }

        const active = activeMark?.series === mark.series && activeMark?.index === mark.index;
        const half = mark.rx ?? mark.r;
        const height = (mark.ry ?? mark.r) * 2;

        /* Cut to the plot rather than to the data. A caller who pinned `min` to
           this quarter still has work that began last one, and a bar that stops
           at the edge says there is more of it off the side; one drawn past the
           edge says the axis is wrong. A zero-width span keeps a hairline, so
           a milestone is still something on the row. */
        const left = Math.max(plot.left, mark.x - half);
        const right = Math.min(plot.left + plot.width, mark.x + half);

        if (right < plot.left || left > plot.left + plot.width) {
          return null;
        }

        const width = Math.max(1, right - left);

        return (
          <rect
            key={`${mark.series}-${mark.index}`}
            x={left}
            y={mark.y - height / 2}
            width={width}
            height={height}
            rx={Math.min(radius, width / 2, height / 2)}
            fill={one.color ?? colors[mark.series]}
            opacity={active ? 1 : 0.92}
            className={markTransitionClasses}
          />
        );
      })}
    </g>
  );
}

interface TableProps {
  id: string;
  names: readonly string[];
  series: readonly PlassTimelineSeries[];
  spans: readonly (readonly Placed[])[];
  unit: TimeScale['unit'];
  label?: string;
  corner?: React.ReactNode;
  locale?: string;
}

/**
 * The chart, as a table — a row per span rather than the frame's grid.
 *
 * Two rows of a Gantt have no columns in common: the third thing on one row and
 * the third thing on another are unrelated, so filing them side by side would
 * be inventing a relationship. Each span gets a line of its own, under the name
 * of the row it belongs to.
 */
function TimelineTable({ id, names, series, spans, unit, label, corner, locale }: TableProps) {
  const titled = series.some((row) => row.data.some((span) => span.label !== undefined));

  return (
    <table id={id} className={srOnlyClasses}>
      {label ? <caption>{label}</caption> : null}
      <thead>
        <tr>
          <th scope="col">{corner ?? ''}</th>
          {titled ? <th scope="col">label</th> : null}
          <th scope="col">start</th>
          <th scope="col">end</th>
        </tr>
      </thead>
      <tbody>
        {spans.flatMap((row, index) =>
          row.map((one, at) => (
            <tr key={`${index}-${at}`}>
              <th scope="row">{names[index]}</th>
              {titled ? <td>{series[index].data[at]?.label ?? ''}</td> : null}
              <td>{one ? formatTimeValue(one.from, unit, locale) : ''}</td>
              <td>{one ? formatTimeValue(one.to, unit, locale) : ''}</td>
            </tr>
          ))
        )}
      </tbody>
    </table>
  );
}
