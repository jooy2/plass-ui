/**
 * The marks a PlLineChart and an PlAreaChart draw.
 *
 * They are one picture with one part switched off, which is exactly the case
 * `internal/` exists for: an area is a line with the space under it filled, and
 * a stacked area is that with each band sitting on the one below. Writing the
 * path arithmetic twice would mean a `curve="smooth"` that curves differently
 * depending on which of the two components a caller reached for.
 *
 * PlSparkline deliberately does *not* come through here. It has no axes, no
 * legend and no stacking, and what it needs from `internal/chart.ts` is two function
 * calls — routing it through a component built for a full plot would cost it
 * the thing that makes it a sparkline.
 */

import * as React from 'react';
import {
  areaPath,
  chartFontSizes,
  dimmedByHover,
  labelledPoints,
  linePath,
  lineDash,
  lineWidths,
  markerRadii,
  markGap
} from './chart.js';
import { markTransitionClasses } from './chart-frame.js';
import { usePrefersReducedMotion } from './media.js';
import type { CartesianContext } from './chart-frame.js';
import type {
  PlassChartCurve,
  PlassChartLabelColor,
  PlassChartNulls,
  PlassChartValueLabels
} from '../types.js';

/** Whether a point gets a dot on it. */
export type ChartMarkers = 'none' | 'auto' | 'all';

/** Past this many points a dot per point is a row of dots, not a series. */
const autoMarkerLimit = 14;

export interface LineSeriesProps {
  context: CartesianContext;
  curve: PlassChartCurve;
  /** Fills the space between the line and whatever is under it. */
  filled: boolean;
  /** Each band sits on the total of the ones before it. */
  stacked: boolean;
  markers: ChartMarkers;
  valueLabels: PlassChartValueLabels;
  /** What colour those labels are written in. */
  valueLabelColor: PlassChartLabelColor;
  /**
   * What a gap does to the line.
   *
   * Only `connect` reaches this far. `gap` is what the path builder does when
   * it is handed the `null`s, and `zero` was settled before the frame was ever
   * given the data — see `zeroNulls`, which is why a zeroed gap moves the axis
   * and fills the table row as well as the line.
   */
  nulls: PlassChartNulls;
  /**
   * Fades the line from a paler step of its own hue at the old end to the full
   * colour at the new one. One hue throughout — a stroke that changes hue along
   * its length is a second series pretending to be one.
   */
  gradient: boolean;
  /** Unique per chart instance, so two charts' gradient defs cannot collide. */
  idPrefix: string;
}

/**
 * A point on the plot, or `null` where the series has a gap.
 *
 * The `null` is the whole reason this is built as an array rather than filtered:
 * it is what breaks the path, and a filtered array would silently join the two
 * sides of a missing month into one straight line.
 */
type Vertex = { x: number; y: number } | null;

export function LineSeries({
  context,
  curve,
  filled,
  stacked,
  markers,
  valueLabels,
  valueLabelColor,
  nulls,
  gradient,
  idPrefix
}: LineSeriesProps) {
  const {
    values,
    visible,
    colors,
    dashed,
    hovered,
    activeIndex,
    plot,
    point,
    zeroPx,
    size,
    format
  } = context;

  const stroke = lineWidths[size];
  const radius = markerRadii[size];
  /** The band that sits on the axis, and so the one with nothing to be parted from. */
  const first = visible.indexOf(true);

  /* The running total each band sits on. Only the visible series contribute:
     hiding one from the legend has to close the gap it left, or a stacked chart
     with a series turned off reads as a chart with a hole in it. */
  const baselines: number[][] = [];
  const running: number[] = [];

  values.forEach((one, index) => {
    const under = one.map((_, category) => running[category] ?? 0);

    baselines.push(under);

    if (!stacked || !visible[index]) {
      return;
    }

    one.forEach((value, category) => {
      running[category] = (running[category] ?? 0) + (value.value ?? 0);
    });
  });

  const reducedMotion = usePrefersReducedMotion();
  const dimmed = values.map((_, index) => dimmedByHover(hovered, index, visible));

  /* The series the legend has let go of whose band is still easing back to
     whole. Each stays cut out under its markers, as a faded one is, until its
     band's opacity arrives, or its line would show through them on the way.
     Under reduced motion the opacity arrives at once and nothing is kept. */
  const [returning, setReturning] = React.useState<ReadonlySet<number>>(() => new Set());
  const [wasDimmed, setWasDimmed] = React.useState(dimmed);

  if (dimmed.length !== wasDimmed.length || dimmed.some((one, index) => one !== wasDimmed[index])) {
    setWasDimmed(dimmed);
    setReturning(
      (before) =>
        new Set(
          dimmed.flatMap((one, index) =>
            !one &&
            !reducedMotion &&
            visible[index] &&
            (wasDimmed[index] === true || before.has(index))
              ? [index]
              : []
          )
        )
    );
  }

  /* What each visible series draws, worked out once for the three passes
     below: the bands and lines, then the markers, then the labels. */
  const shapes = values.map((one, index) => {
    if (!visible[index]) {
      return null;
    }

    const tops: Vertex[] = one.map((value, category) => {
      if (value.value === null) {
        return null;
      }

      const total = stacked ? baselines[index][category] + value.value : value.value;

      return point(category, total);
    });

    // Whatever `markers` says, the point under the pointer gets a dot: that is
    // what tells the reader which column the tooltip is about.
    const marks = tops.flatMap((vertex, category) =>
      vertex &&
      (markers === 'all' ||
        (markers === 'auto' && one.length <= autoMarkerLimit) ||
        category === activeIndex)
        ? [{ ...vertex, category, r: category === activeIndex ? radius + 1 : radius }]
        : []
    );

    return {
      color: colors[index],
      dimmed: dimmed[index],
      tops,
      marks,
      /** Whether its markers are cut out of its band and line, below. */
      cut: (dimmed[index] || returning.has(index)) && marks.length > 0
    };
  });

  return (
    <g>
      <defs>
        {gradient
          ? colors.map((color, index) => (
              <linearGradient
                key={`stroke-${index}`}
                id={`${idPrefix}-stroke-${index}`}
                x1="0"
                y1="0"
                x2="1"
                y2="0"
              >
                <stop offset="0%" stopColor={`color-mix(in oklab, ${color} 45%, transparent)`} />
                <stop offset="100%" stopColor={color} />
              </linearGradient>
            ))
          : null}

        {/* A wash and not a block: an area that is a saturated slab hides
            whatever it overlaps and makes the line on top of it redundant.
            Stacked bands skip this and take a flat tint, because there the
            fill *is* the mark and a band that fades out has no bottom edge. */}
        {filled && !stacked
          ? colors.map((color, index) => (
              <linearGradient
                key={`fill-${index}`}
                id={`${idPrefix}-fill-${index}`}
                x1="0"
                y1="0"
                x2="0"
                y2="1"
              >
                <stop offset="0%" stopColor={`color-mix(in oklab, ${color} 28%, transparent)`} />
                <stop offset="100%" stopColor={`color-mix(in oklab, ${color} 2%, transparent)`} />
              </linearGradient>
            ))
          : null}

        {/* A faded series' markers fade in a group of their own, drawn after
            every band, where its own band and line would show through them.
            So while it is faded they are cut out of those, out to the edge of
            the ring. At full strength a marker covers them whole. The region
            is the user space rather than the group's box, which a flat line
            has no height in. */}
        {shapes.map((shape, index) =>
          shape?.cut ? (
            <mask
              key={`cut-${index}`}
              id={`${idPrefix}-cut-${index}`}
              maskUnits="userSpaceOnUse"
              x="-50%"
              y="-50%"
              width="200%"
              height="200%"
            >
              <rect x="-50%" y="-50%" width="200%" height="200%" fill="white" />
              {shape.marks.map((mark) => (
                <circle
                  key={mark.category}
                  cx={mark.x}
                  cy={mark.y}
                  r={mark.r + markGap / 2}
                  fill="black"
                  className={markTransitionClasses}
                />
              ))}
            </mask>
          ) : null
        )}
      </defs>

      {values.map((one, index) => {
        const shape = shapes[index];

        if (!shape) {
          return null;
        }

        const { color, tops } = shape;

        // `connect` drops the gaps rather than bridging them in the path
        // builder: a bridged segment and a real one have to be the same shape,
        // and the only way to guarantee that is for the builder never to know
        // the difference.
        const bridged = nulls === 'connect';
        const line = bridged ? (tops.filter(Boolean) as { x: number; y: number }[]) : tops;

        const under: Vertex[] = one.map((value, category) =>
          value.value === null
            ? null
            : stacked
              ? point(category, baselines[index][category])
              : { x: point(category, value.value).x, y: zeroPx }
        );

        // A stacked band's fill *is* its mark, so it does not also get a line
        // drawn along the top: the band above would then be separated from it by
        // a coloured stroke, and a stroke between two marks is ink that is not
        // data. What separates them is the gap below.
        const banded = filled && stacked;

        return (
          <g
            key={index}
            opacity={shape.dimmed ? 0.28 : 1}
            mask={shape.cut ? `url(#${idPrefix}-cut-${index})` : undefined}
            className={markTransitionClasses}
            onTransitionEnd={
              returning.has(index)
                ? (event) => {
                    if (event.target === event.currentTarget && event.propertyName === 'opacity') {
                      setReturning((before) => new Set([...before].filter((one) => one !== index)));
                    }
                  }
                : undefined
            }
          >
            {filled ? (
              <path
                d={areaPath(
                  line,
                  bridged ? (under.filter(Boolean) as { x: number; y: number }[]) : under,
                  curve
                )}
                fill={
                  stacked
                    ? `color-mix(in oklab, ${color} 70%, transparent)`
                    : `url(#${idPrefix}-fill-${index})`
                }
                stroke="none"
              />
            ) : null}

            {/* The 2px of surface between this band and the one under it. Drawn
                on the *lower* edge so the top of the stack keeps its silhouette,
                and skipped on the first band, whose lower edge is the axis. */}
            {banded && index !== first ? (
              <path
                d={linePath(
                  bridged ? (under.filter(Boolean) as { x: number; y: number }[]) : under,
                  curve
                )}
                fill="none"
                stroke="var(--plass-chart-gap)"
                strokeWidth={markGap}
              />
            ) : null}

            {banded ? null : (
              <path
                d={linePath(line, curve)}
                fill="none"
                stroke={gradient ? `url(#${idPrefix}-stroke-${index})` : color}
                strokeWidth={stroke}
                strokeDasharray={dashed[index] ? lineDash : undefined}
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            )}
          </g>
        );
      })}

      {/* The markers go on after every band and every line, each series' in a
          group that fades with it, so the band above a stacked one neither
          washes over their top half nor runs its gap through them, and no line
          crosses another series' marker. */}
      {shapes.map((shape, index) =>
        shape && shape.marks.length > 0 ? (
          <g key={index} opacity={shape.dimmed ? 0.28 : 1} className={markTransitionClasses}>
            {shape.marks.map((mark) => (
              <circle
                key={mark.category}
                cx={mark.x}
                cy={mark.y}
                r={mark.r}
                fill={values[index][mark.category].color ?? shape.color}
                // The ring is the surface showing through, which is what keeps
                // a marker legible where two lines cross — and it is part of
                // the hit target, not only spacing.
                stroke="var(--plass-chart-gap)"
                strokeWidth={markGap}
                className={markTransitionClasses}
              />
            ))}
          </g>
        ) : null
      )}

      {/* And the numbers after every marker, so no band or marker drawn later
          covers one. */}
      {valueLabels === 'none'
        ? null
        : shapes.map((shape, index) => {
            if (!shape) {
              return null;
            }

            const one = values[index];
            const labelled = labelledPoints(one, valueLabels);

            return (
              <g key={index} opacity={shape.dimmed ? 0.28 : 1} className={markTransitionClasses}>
                {shape.tops.map((vertex, category) => {
                  const value = one[category].value;

                  if (!vertex || value === null || !labelled(category)) {
                    return null;
                  }

                  return (
                    <text
                      key={category}
                      x={vertex.x}
                      y={vertex.y - radius - 5}
                      textAnchor={
                        vertex.x > plot.left + plot.width - 24
                          ? 'end'
                          : vertex.x < plot.left + 24
                            ? 'start'
                            : 'middle'
                      }
                      fontSize={chartFontSizes[size]}
                      fontWeight={600}
                      // In the line's own colour, so a plot with four labelled
                      // series says which number belongs to which line without
                      // the reader tracing it back. A point that carries a
                      // colour of its own is labelled in that, for the same
                      // reason: the label names the mark it is sitting on.
                      fill={
                        valueLabelColor === 'ink'
                          ? 'var(--plass-fg)'
                          : (one[category].color ?? shape.color)
                      }
                      className="tabular-nums"
                    >
                      {one[category].label ?? format(value)}
                    </text>
                  );
                })}
              </g>
            );
          })}
    </g>
  );
}
