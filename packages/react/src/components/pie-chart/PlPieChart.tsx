'use client';

import * as React from 'react';
import {
  ChartDataTable,
  ChartLegendBar,
  ChartStatus,
  ChartSurface,
  ChartTooltipPanel,
  markTransitionClasses,
  useMeasuredWidth,
  useVisibility,
  type ChartBaseProps,
  type ChartTooltipItem
} from '../../internal/chart-frame.js';
import {
  arcPath,
  categoryAt,
  chartFontSizes,
  compactNumber,
  formatCategory,
  markGap,
  plotHeights,
  seriesColor,
  toValue
} from '../../internal/chart.js';
import { useDefaults } from '../../internal/defaults.js';
import { numberFormatter } from '../../internal/format.js';
import { useLabels } from '../../internal/labels.js';
import { cx, metaTextClasses } from '../../internal/styles.js';
import type {
  PlassChartCategory,
  PlassChartDatum,
  PlassChartLegend,
  PlassChartSeries,
  PlassChartTooltip
} from '../../types.js';

/** How much of the middle is cut out, per shape. */
const holes = { pie: 0, donut: 0.62, semi: 0.62 } as const;

export interface PlPieChartProps extends ChartBaseProps {
  /**
   * The slices. Numbers, or points that carry their own name and colour.
   *
   * One series and not an array of them, because that is what a pie *is*: the
   * slices are the entities here, so each one takes a palette slot of its own
   * and the legend lists them rather than listing series.
   */
  data: readonly PlassChartDatum[];
  /** What each slice is called. Points may carry their own `x` instead. */
  categories?: readonly PlassChartCategory[];
  /**
   * - `pie` — a filled disc. The default.
   * - `donut` — a ring, with room in the middle for the total.
   * - `semi` — half a ring, opened along the bottom. For a gauge, or for a
   *   dashboard tile that is wider than it is tall.
   * @default 'pie'
   */
  shape?: 'pie' | 'donut' | 'semi';
  /**
   * Where the first slice starts, in degrees clockwise from twelve o'clock.
   * Ignored by `semi`, which is defined by where it opens.
   * @default 0
   */
  startAngle?: number;
  /**
   * What goes in the hole. A `donut` or a `semi` with nothing in the middle is
   * a pie with a bite out of it; the total, or the one figure the chart is
   * about, is what the ring was drawn around.
   */
  center?: React.ReactNode;
  /**
   * Writes each slice's share on it, where the slice is wide enough for the
   * text to fit with room either side. A label that does not fit is dropped
   * rather than clipped — the tooltip and the table still have it.
   *
   * The number written is the **share**, not the value: a share is what a pie
   * is a picture of, and the value is one hover away.
   * @default 'none'
   */
  valueLabels?: 'none' | 'all';
}

/**
 * Parts of a whole, at a glance.
 *
 * The narrowest chart in the library and the easiest one to misuse. An angle is
 * a poor thing to compare — two slices within a few percent of each other are
 * indistinguishable, and a reader cannot rank six of them — so the pie is right
 * for exactly one question: *is one of these most of it?* Anything finer than
 * that, and anything past six slices, is a [`PlBarChart`](./bar-chart).
 *
 * A slice's colour follows the slice and not its size, so a chart that is
 * refiltered or resorted keeps every category the colour it had.
 */
export function PlPieChart({
  data,
  categories,
  shape = 'pie',
  startAngle = 0,
  center,
  valueLabels = 'none',
  height,
  format,
  locale: localeProp,
  label,
  legend,
  tooltip,
  empty,
  size: sizeProp,
  variant = 'ghost',
  padded = false,
  className,
  ...box
}: PlPieChartProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const locale = localeProp ?? defaults.locale;

  const hostRef = React.useRef<HTMLDivElement>(null);
  const width = useMeasuredWidth(hostRef);
  const words = useLabels();
  const tableId = React.useId();

  const formatValue = React.useCallback(
    (value: number) =>
      format ? numberFormatter(locale, format).format(value) : compactNumber(value, locale),
    [format, locale]
  );

  const values = React.useMemo(() => data.map(toValue), [data]);

  /* A pie's slices are what the legend, the visibility and the palette are all
     keyed on, so they are turned into one-value series here. That is not a
     workaround: everywhere else in the library the thing that gets a colour and
     a legend row is a series, and a slice is playing exactly that part. */
  const slices = React.useMemo<PlassChartSeries[]>(
    () =>
      values.map((value, index) => ({
        name: formatCategory(categoryAt(index, categories, [values]), locale),
        data: [data[index]],
        color: value.color
      })),
    [values, categories, data, locale]
  );

  const visibility = useVisibility(slices);
  const [active, setActive] = React.useState<number | null>(null);

  const colors = slices.map((slice, index) => seriesColor(slice, index));

  const total = values.reduce(
    (sum, value, index) =>
      visibility.visible[index] && value.value !== null ? sum + Math.abs(value.value) : sum,
    0
  );

  const semi = shape === 'semi';
  const plotHeight = typeof height === 'number' ? height : plotHeights[size];
  const fontSize = chartFontSizes[size];

  const legendOptions: PlassChartLegend =
    legend === false
      ? { interactive: false }
      : legend === true || legend === undefined
        ? {}
        : legend;
  const showLegend = legend !== false && slices.length > 1;
  const legendSide = legendOptions.side ?? 'bottom';

  const tooltipOptions: PlassChartTooltip =
    tooltip === false ? { mode: 'none' } : tooltip === true || tooltip === undefined ? {} : tooltip;
  const tooltipOff = tooltipOptions.mode === 'none';

  // A semicircle gets the *whole* height as its radius rather than half of it —
  // it only draws the top half, so reserving room for the bottom one would leave
  // a blank band under the chart. Its centre then sits below the middle of the
  // box by half a radius, which puts the arc itself in the middle: pinned to the
  // bottom edge instead, a wide card would draw a thin band with an empty half
  // above it.
  const centreX = width / 2;
  const outer = Math.max(0, Math.min(width / 2, semi ? plotHeight : plotHeight / 2) - 2);
  const centreY = semi ? Math.min(plotHeight, plotHeight / 2 + outer / 2) : plotHeight / 2;
  const inner = outer * holes[shape];

  const nothing = total <= 0 || outer <= 0;

  // The 2px between two slices, as the angle that subtends it at the rim. Wider
  // for a small pie than for a large one, which is the point: the gap is a
  // constant on screen, not a constant in the data.
  const pad = outer > 0 ? Math.min(4, (markGap / outer) * (180 / Math.PI)) : 0;
  const sweep = semi ? 180 : 360;
  const from = semi ? -90 : startAngle;

  const arcs: {
    index: number;
    start: number;
    end: number;
    value: number;
    share: number;
  }[] = [];

  let angle = from;

  values.forEach((value, index) => {
    if (!visibility.visible[index] || value.value === null || value.value === 0) {
      return;
    }

    const share = Math.abs(value.value) / total;
    const span = share * sweep;

    arcs.push({ index, start: angle, end: angle + span, value: value.value, share });
    angle += span;
  });

  const items: ChartTooltipItem[] =
    active === null
      ? []
      : [
          {
            seriesIndex: active,
            name: slices[active]?.name,
            color: values[active]?.color ?? colors[active],
            value: values[active]?.value ?? null,
            formatted: `${formatValue(values[active]?.value ?? 0)} · ${
              Math.round(
                ((Math.abs(values[active]?.value ?? 0) / total) * 100 + Number.EPSILON) * 10
              ) / 10
            }%`,
            label: values[active]?.label
          }
        ];

  return (
    <ChartSurface
      {...box}
      size={size}
      variant={variant}
      padded={padded}
      className={className}
      legendSide={legendSide}
      legend={
        showLegend ? (
          <ChartLegendBar
            series={slices}
            colors={colors}
            options={legendOptions}
            visibility={visibility}
            size={size}
            values={
              legendOptions.showValue
                ? values.map((value) =>
                    value.value === null ? undefined : formatValue(value.value)
                  )
                : undefined
            }
          />
        ) : null
      }
      table={
        nothing ? null : (
          <ChartDataTable
            id={tableId}
            caption={label}
            categories={slices.map((slice) => slice.name ?? '')}
            series={[{ name: label, data }]}
            values={[values]}
            format={formatValue}
            locale={locale}
          />
        )
      }
    >
      {/* Two children rather than one: the readout under the picture has to be
          a *sibling* of it and not a child — see `ChartStatus`. */}
      <div
        ref={hostRef}
        role="img"
        tabIndex={nothing ? undefined : 0}
        // Never the bare prop: `label` is optional, and a focusable `role="img"`
        // with nothing to be called by is a tab stop that announces silence.
        aria-label={label ?? words.chart}
        aria-describedby={nothing ? undefined : tableId}
        onPointerLeave={() => setActive(null)}
        onBlur={() => setActive(null)}
        onKeyDown={(event) => {
          if (event.key !== 'ArrowRight' && event.key !== 'ArrowLeft') {
            return;
          }

          const order = arcs.map((arc) => arc.index);

          if (order.length === 0) {
            return;
          }

          const at = active === null ? -1 : order.indexOf(active);
          const next = event.key === 'ArrowRight' ? at + 1 : at - 1;

          setActive(order[(next + order.length) % order.length]);
          event.preventDefault();
        }}
        className={cx(
          'relative w-full rounded-(--plass-radius-xs)',
          'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-2'
        )}
        style={{ height: plotHeight }}
      >
        {nothing ? (
          <div
            className={cx(
              'flex h-full items-center justify-center text-(--plass-muted-fg)',
              metaTextClasses[size]
            )}
          >
            {empty ?? words.empty}
          </div>
        ) : width > 0 ? (
          <svg
            width={width}
            height={plotHeight}
            viewBox={`0 0 ${width} ${plotHeight}`}
            aria-hidden="true"
            className="block"
          >
            {arcs.map((arc) => {
              const dimmed =
                (visibility.hovered !== null && visibility.hovered !== arc.index) ||
                (active !== null && active !== arc.index);

              // The pad is taken off both ends and never off a slice narrower
              // than two of it, or a one-degree sliver inverts and draws the
              // whole circle instead of nothing.
              const room = arc.end - arc.start > pad * 2 ? pad / 2 : 0;

              return (
                <path
                  key={arc.index}
                  d={arcPath(centreX, centreY, outer, inner, arc.start + room, arc.end - room)}
                  fill={values[arc.index].color ?? colors[arc.index]}
                  opacity={dimmed ? 0.32 : 1}
                  onPointerEnter={tooltipOff ? undefined : () => setActive(arc.index)}
                  className={markTransitionClasses}
                />
              );
            })}

            {valueLabels === 'all'
              ? arcs.map((arc) => {
                  const middle = ((arc.start + arc.end) / 2 - 90) * (Math.PI / 180);
                  const radius = inner > 0 ? (inner + outer) / 2 : outer * 0.68;
                  const text = `${Math.round(arc.share * 100)}%`;

                  // Measured before it is placed: a label wider than the slice
                  // is dropped, never clipped and never spilled over the
                  // neighbour it would then be labelling.
                  const room = (arc.end - arc.start) * (Math.PI / 180) * radius;

                  if (room < fontSize * 2 || outer - inner < fontSize * 1.6) {
                    return null;
                  }

                  return (
                    <text
                      key={arc.index}
                      x={centreX + radius * Math.cos(middle)}
                      y={centreY + radius * Math.sin(middle)}
                      textAnchor="middle"
                      dominantBaseline="central"
                      fontSize={fontSize}
                      fontWeight={600}
                      // Inside a filled mark is the one place a label wears
                      // something other than an ink token, and it is the sheet's
                      // own colour rather than white: a pale slice would swallow
                      // white and the label would be gone.
                      fill="var(--plass-surface)"
                      className="tabular-nums"
                    >
                      {text}
                    </text>
                  );
                })
              : null}
          </svg>
        ) : null}

        {center && inner > 0 ? (
          <div
            className="pointer-events-none absolute flex flex-col items-center justify-center text-center"
            // The box is the same either way round: its centre is the plot's
            // own centre, so measuring from the start edge and from the left
            // edge land in exactly the same place.
            style={{
              insetInlineStart: centreX - inner,
              top: centreY - inner,
              width: inner * 2,
              height: semi ? inner : inner * 2
            }}
          >
            {center}
          </div>
        ) : null}

        {active !== null && !tooltipOff ? (
          tooltipOptions.render ? (
            <div className="pointer-events-none absolute top-0 start-1/2 z-10">
              {tooltipOptions.render({
                index: active,
                category: slices[active]?.name ?? active,
                items
              })}
            </div>
          ) : (
            <ChartTooltipPanel
              heading={slices[active]?.name}
              items={items}
              x={centreX}
              y={8}
              flip={false}
              size={size}
            />
          )
        ) : null}
      </div>

      {/* Only where there is a crosshair to report — see `ChartStatus`. */}
      {tooltipOff ? null : (
        <ChartStatus heading={active === null ? undefined : slices[active]?.name} items={items} />
      )}
    </ChartSurface>
  );
}
