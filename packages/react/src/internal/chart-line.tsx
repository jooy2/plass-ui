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
import { areaPath, chartFontSizes, linePath, lineWidths, markerRadii, markGap } from './chart.js';
import { markTransitionClasses } from './chart-frame.js';
import type { CartesianContext } from './chart-frame.js';
import type { PlassChartCurve, PlassChartValueLabels } from '../types.js';

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
  /**
   * Bridges a gap instead of breaking at it. Off by default, and it should
   * stay off unless the caller knows the gap is an artefact of collection
   * rather than a month where nothing happened.
   */
  connectNulls: boolean;
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
  connectNulls,
  gradient,
  idPrefix
}: LineSeriesProps) {
  const { values, visible, colors, hovered, activeIndex, plot, point, zeroPx, size, format } =
    context;

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
      </defs>

      {values.map((one, index) => {
        if (!visible[index]) {
          return null;
        }

        const color = colors[index];
        // A hovered legend entry dims the *others* — but only when the series
        // being hovered is actually on the plot. Pointing at an entry that is
        // switched off would otherwise fade every visible series to make room
        // for one that is not there.
        const dimmed = hovered !== null && hovered !== index && visible[hovered];

        const tops: Vertex[] = one.map((value, category) => {
          if (value.value === null) {
            return null;
          }

          const total = stacked ? baselines[index][category] + value.value : value.value;

          return point(category, total);
        });

        // `connectNulls` drops the gaps rather than bridging them in the path
        // builder: a bridged segment and a real one have to be the same shape,
        // and the only way to guarantee that is for the builder never to know
        // the difference.
        const line = connectNulls ? (tops.filter(Boolean) as { x: number; y: number }[]) : tops;

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

        const labelled = labelledPoints(one, valueLabels);

        return (
          <g key={index} opacity={dimmed ? 0.28 : 1} className={markTransitionClasses}>
            {filled ? (
              <path
                d={areaPath(
                  line,
                  connectNulls ? (under.filter(Boolean) as { x: number; y: number }[]) : under,
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
                  connectNulls ? (under.filter(Boolean) as { x: number; y: number }[]) : under,
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
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            )}

            {tops.map((vertex, category) => {
              if (!vertex) {
                return null;
              }

              const drawn =
                markers === 'all' ||
                (markers === 'auto' && one.length <= autoMarkerLimit) ||
                category === activeIndex;

              if (!drawn) {
                return null;
              }

              return (
                <circle
                  key={category}
                  cx={vertex.x}
                  cy={vertex.y}
                  r={category === activeIndex ? radius + 1 : radius}
                  fill={one[category].color ?? color}
                  // The ring is the surface showing through, which is what keeps
                  // a marker legible where two lines cross — and it is part of
                  // the hit target, not only spacing.
                  stroke="var(--plass-chart-gap)"
                  strokeWidth={markGap}
                  className={markTransitionClasses}
                />
              );
            })}

            {valueLabels === 'none'
              ? null
              : tops.map((vertex, category) => {
                  const value = one[category].value;

                  if (!vertex || value === null || !labelled(category)) {
                    return null;
                  }

                  return (
                    <text
                      key={`label-${category}`}
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
                      fontWeight={500}
                      fill="var(--plass-fg)"
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

/**
 * Which points of a series get a label, decided once for the whole series.
 *
 * Once and not per point, which is the only thing worth saying about it: asking
 * "is this the series' high" inside the loop over the points means walking the
 * series again for each of them, and a five-hundred-point line then does a
 * quarter of a million comparisons to place two labels — on every render, which
 * on a chart being hovered is every frame.
 */
function labelledPoints(
  one: readonly { value: number | null }[],
  valueLabels: PlassChartValueLabels
): (index: number) => boolean {
  if (valueLabels === 'all') {
    return () => true;
  }

  if (valueLabels === 'last') {
    let last = -1;

    for (let index = one.length - 1; index >= 0; index--) {
      if (one[index].value !== null) {
        last = index;
        break;
      }
    }

    return (index) => index === last;
  }

  // `extremes`. A series that is entirely `null` has no high and no low, and
  // the comparison below is false for every point of it either way.
  let min = Infinity;
  let max = -Infinity;

  for (const entry of one) {
    if (entry.value === null) {
      continue;
    }

    min = Math.min(min, entry.value);
    max = Math.max(max, entry.value);
  }

  return (index) => {
    const value = one[index].value;

    return value !== null && (value === min || value === max);
  };
}
