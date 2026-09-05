'use client';

import * as React from 'react';
import { ChartSurface, useMeasuredWidth, type ChartBaseProps } from '../../internal/chart-frame.js';
import {
  arcPath,
  chartFontSizes,
  compactNumber,
  plotHeights,
  ringPath,
  textWidth,
  truncate
} from '../../internal/chart.js';
import { useDefaults } from '../../internal/defaults.js';
import { numberFormatter } from '../../internal/format.js';
import { useLabels } from '../../internal/labels.js';
import { cx, hasContent, metaTextClasses } from '../../internal/styles.js';
import { bandColor } from '../../internal/threshold.js';
import type { PlassColor, PlassThreshold } from '../../types.js';

export interface PlGaugeChartProps extends Omit<ChartBaseProps, 'legend' | 'tooltip'> {
  /**
   * The reading. `null` draws the dial with nothing on it, which is the honest
   * picture of an instrument that has not been told anything.
   */
  value: number | null;
  /** The bottom of the scale. @default 0 */
  min?: number;
  /** And the top of it. @default 100 */
  max?: number;
  /**
   * How far round the dial goes, in degrees, opened symmetrically about twelve
   * o'clock. `180` is the half-dial a dashboard tile wants; `270` is the
   * instrument shape; `360` is a ring.
   * @default 180
   */
  sweep?: number;
  /** How thick the arc is, as a fraction of its radius. @default 0.22 */
  thickness?: number;
  /**
   * Where the arc changes colour — the same `{ from, color }` bands a
   * [`PlMeter`](../feedback/meter) takes, read the same way: the highest band
   * at or below the value wins, and below all of them `color` stands.
   */
  thresholds?: readonly PlassThreshold[];
  /**
   * How many marks are drawn around the dial, ends included. `false` — the
   * default — draws none: a gauge on a dashboard is read as a proportion, and
   * ticks are for an instrument somebody takes a *number* off.
   * @default false
   */
  ticks?: number | false;
  /** Writes `min` and `max` at the two ends of the arc. @default true */
  showRange?: boolean;
  /**
   * What goes in the middle. Left out, it is the value written through
   * `format` — which is what the dial is for, so replacing it is for adding to
   * it rather than for taking it away.
   */
  center?: React.ReactNode;
  /** A line under the value: the unit, or what is being measured. */
  caption?: React.ReactNode;
  /** The family the arc takes where no threshold applies. @default 'primary' */
  color?: PlassColor;
}

/**
 * The largest type size at which a line `units` ems long still sits inside a
 * circle of radius `r`, given that its middle is `base` above the centre.
 *
 * Two things have to fit — half the line's width sideways, and how far its
 * digits climb above that middle — and both grow with the size being solved
 * for, so this is a quadratic rather than a division:
 *
 *     (units·size / 2·fill)² + (base + cap·size)² = r²
 *
 * Solved rather than iterated, because iterating oscillates: a size that does
 * not fit shrinks, a shorter number climbs less, and the room that frees up
 * allows a size that does not fit.
 */
function fitType(units: number, base: number, r: number, cap: number, fill: number): number {
  const a = (units * units) / (4 * fill * fill) + cap * cap;
  const b = 2 * base * cap;
  const c = base * base - r * r;

  if (a <= 0 || c >= 0) {
    return 0;
  }

  return (Math.sqrt(b * b - 4 * a * c) - b) / (2 * a);
}

/** Degrees clockwise from twelve o'clock to a point on a circle of radius `r`. */
function pointAt(cx: number, cy: number, r: number, degrees: number): [number, number] {
  const radians = ((degrees - 90) * Math.PI) / 180;

  return [cx + r * Math.cos(radians), cy + r * Math.sin(radians)];
}

/**
 * One number on a scale that is known in advance, drawn as a dial.
 *
 * It is a [`PlMeter`](../feedback/meter) bent into an arc, and the two are
 * deliberately the same idea in two shapes: `value`, `min`, `max` and
 * `thresholds` mean exactly what they mean there, so a page can move a reading
 * from a bar to a dial without changing what it says. Reach for the bar in a
 * row of fields and for this one in a tile of its own, where a dial reads at a
 * glance from across a room and a four-pixel bar does not.
 *
 * It is not a [`PlPieChart`](./pie-chart) with `shape="semi"`. A pie is *parts
 * of a whole* and every slice is a category; this is one value against a scale,
 * and the unfilled part of the arc is not a second category — it is the rest of
 * the dial.
 */
export function PlGaugeChart({
  value,
  min = 0,
  max = 100,
  sweep = 180,
  thickness = 0.22,
  thresholds,
  ticks = false,
  showRange = true,
  center,
  caption,
  height,
  format,
  locale: localeProp,
  label,
  empty,
  size: sizeProp,
  variant = 'ghost',
  color: colorProp,
  padded = false,
  className,
  ...box
}: PlGaugeChartProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const locale = localeProp ?? defaults.locale;

  const hostRef = React.useRef<HTMLDivElement>(null);
  const width = useMeasuredWidth(hostRef);
  const words = useLabels();

  const formatValue = React.useCallback(
    (each: number) =>
      format ? numberFormatter(locale, format).format(each) : compactNumber(each, locale),
    [format, locale]
  );

  const span = Math.max(1, Math.min(360, sweep));
  const half = span / 2;
  const from = -half;
  const to = half;

  const range = max - min;
  const fraction =
    value === null || Number.isNaN(value) || range === 0
      ? null
      : Math.min(1, Math.max(0, (value - min) / range));

  const family = value === null ? color : bandColor(value, color, thresholds);

  const plotHeight = typeof height === 'number' ? height : plotHeights[size];
  const fontSize = chartFontSizes[size];

  const band = Math.min(0.9, Math.max(0.05, thickness));

  /*
   * How much room the arc needs, as multiples of its own radius.
   *
   * The top of the dial is always a full radius above the centre; how far it
   * reaches *below* depends on the sweep — a half-dial stops level with its
   * centre, a 270° one drops most of a radius past it. Sizing against the box
   * rather than assuming a circle is what keeps a wide, short card from drawing
   * a thin band with an empty half above it.
   *
   * `endOut` is a third question the other two do not answer: which way the
   * arc's two *ends* point, which is the direction the range labels are set
   * along. On a half-dial that is straight out to the sides and it agrees with
   * `sideFactor`; past that the arc keeps widening while its ends swing down
   * and back in.
   */
  const halfRadians = (half * Math.PI) / 180;
  const belowFactor = span >= 360 ? 1 : Math.max(0, -Math.cos(halfRadians));
  const sideFactor = span >= 180 ? 1 : Math.sin(halfRadians);
  const endOutX = Math.sin(halfRadians);
  const endOutY = -Math.cos(halfRadians);

  /*
   * The range labels, cut to a share of the box before anything is sized
   * against them.
   *
   * A `format` that spells a million out in full writes a label three times the
   * width of the tile, and a dial sized to clear it is a hairline with two
   * numbers beside it. Cut is the same answer an axis gives a category name too
   * long for its slot, for the same reason: the dial is the thing being read.
   *
   * Past 330° there is no range to write. The two ends have come within a
   * label's width of each other by then, and `0` and `100` set on top of each
   * other at six o'clock is not a scale — it is a smudge.
   */
  const rangeText =
    showRange && span < 330
      ? ([min, max] as const).map((each) =>
          truncate(formatValue(each), Math.max(0, width * 0.28), fontSize)
        )
      : [];
  const labelWidth = rangeText.reduce(
    (widest, each) => Math.max(widest, textWidth(each, fontSize)),
    0
  );

  /*
   * What reaches past the arc, and therefore what the box has to keep back.
   *
   * A range label goes with the end it names, in one of two arrangements rather
   * than a blend of them. An end that points sideways — a half-dial's — has the
   * whole empty width of the tile under it and only a label's width beside it,
   * so the label is centred *under* the end. An end that already points
   * downward carries the label on in that direction, clear of the band.
   *
   * Either way it is set from the arc's outer edge. Set from the *mid* radius a
   * label is laid over the band itself the moment half the band's thickness
   * beats the gap — which a 270° dial is at every size.
   */
  const edge = fontSize * 0.35;
  const tickReach = ticks === false ? 0 : fontSize * 0.85;
  const labelUnder = endOutY <= 0.25;
  const labelReach = labelUnder ? 0 : fontSize * 0.5;
  const labelDrop = labelUnder ? fontSize : fontSize * (0.35 + endOutY * 0.55);
  const labelBelow = rangeText.length > 0 ? endOutY * labelReach + labelDrop + fontSize * 0.25 : 0;

  const sidePad = Math.max(edge, tickReach);
  const topPad = Math.max(edge, tickReach);
  const bottomPad = Math.max(edge, tickReach, labelBelow);

  /*
   * The radius, as the smallest of what each side of the box allows. The last
   * term is the labels: how far out the ends point, and how much of a label
   * hangs past its end — half of one centred under it, all of one set outward.
   */
  const limits = [
    (width / 2 - sidePad) / Math.max(0.05, sideFactor),
    (plotHeight - topPad - bottomPad) / (1 + belowFactor)
  ];

  if (labelWidth > 0 && endOutX > 0.05) {
    const outboard = labelUnder ? labelWidth / 2 : labelWidth;

    limits.push(Math.max(0, width / 2 - edge - outboard) / endOutX - labelReach);
  }

  const outer = Math.max(0, Math.min(...limits));
  const inner = outer * (1 - band);

  const centreX = width / 2;
  // Centred in what the box actually has rather than pinned under the top
  // margin. A half-dial on a tile as tall as a line chart is a third of its own
  // box, and the two thirds under it are not the dial's to hold.
  const drawn = topPad + outer * (1 + belowFactor) + bottomPad;
  const centreY = topPad + outer + Math.max(0, (plotHeight - drawn) / 2);

  const nothing = outer <= 0 || range === 0;

  /*
   * The reading sits in the middle of the hole the arc leaves, which is not the
   * middle of the circle: a half-dial's hole stops at the horizontal, so its
   * middle is half an inner radius up. Measured against `inner` rather than
   * against the drawing, because what the reading has to stay clear of is the
   * band and not the box.
   *
   * The *reading*, and not the reading and its caption together. A caption
   * hangs off the number rather than sharing the hole with it, and centring the
   * pair pushes the number up into the narrow top.
   */
  const captionRoom = hasContent(caption) ? fontSize * 1.85 : 0;
  const textY = centreY - (inner * (1 - Math.min(1, belowFactor))) / 2;
  const readingRise = Math.min(inner, Math.abs(centreY - textY));

  // How wide the dial is on the row the block straddles, which on a half-dial
  // is a chord well short of the diameter. It bounds the block, so a `center`
  // of its own — a node this has no way to measure — is wrapped by the dial
  // rather than laid out across the tile beside it.
  const blockRise = Math.min(inner, Math.abs(centreY - textY - captionRoom / 2));
  const room = Math.sqrt(Math.max(0, inner * inner - blockRise * blockRise)) * 2;

  /*
   * The reading, sized to the room it actually has rather than to a fixed
   * multiple of the tick type.
   *
   * Twice the tick type is what a dial wants when the number is short, and it
   * is the cap. What it cannot be is a constant: a reading is a number somebody
   * formatted, and `38` and `10,000%` are the same prop. Below the tick size
   * nothing is being read either, so that is the floor, and a number still too
   * long there is left to run.
   */
  const reading = center ?? (value === null ? '—' : formatValue(value));
  const readingUnits = typeof reading === 'string' ? textWidth(reading, 1) : 0;
  const readingSize =
    readingUnits > 0
      ? Math.max(
          fontSize,
          Math.min(
            fontSize * 2,
            // 0.42 of the size above the middle is where a digit's top lands,
            // and 0.86 of the chord is what it may fill. Both keep a little
            // back, because `textWidth` is a *reservation* estimate and runs
            // under on punctuation — a `%` is nearly a full em, not the 0.6 it
            // is counted as.
            fitType(readingUnits, readingRise, inner, 0.42, 0.86)
          )
        )
      : fontSize * 2;

  const tickCount = ticks === false ? 0 : Math.max(2, Math.floor(ticks));

  return (
    <ChartSurface
      {...box}
      variant={variant}
      color={color}
      size={size}
      padded={padded}
      legendSide="bottom"
      className={className}
      legend={null}
      table={null}
    >
      <div
        ref={hostRef}
        className="relative w-full"
        style={{ height: plotHeight }}
        // Named, the dial is one image saying one thing — which is what it is,
        // and it saves a reader hearing the two end labels as loose numbers.
        // Unnamed there is nothing to call it, so it stays a plain box and the
        // reading in the middle is read as the text it already is.
        role={label === undefined ? undefined : 'img'}
        aria-label={
          label === undefined
            ? undefined
            : value === null
              ? label
              : `${label}: ${formatValue(value)} / ${formatValue(max)}`
        }
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
          <>
            <svg
              width={width}
              height={plotHeight}
              viewBox={`0 0 ${width} ${plotHeight}`}
              aria-hidden="true"
              className="block"
            >
              {/* The rest of the dial. Not a second value — a groove. */}
              <path
                d={arcPath(centreX, centreY, outer, inner, from, to)}
                fill={`var(--plass-${color}-soft)`}
              />

              {fraction !== null ? (
                /*
                 * The reading, drawn as a *stroke* along the groove rather than
                 * as a second wedge filling part of it.
                 *
                 * A wedge is a closed shape, so moving the value rewrites its
                 * `d` — and `d` is not a property CSS can travel along, which
                 * is why a dial built that way jumps to each new reading while
                 * the meter it is a bent copy of sweeps to it. A stroke is one
                 * line whose drawn length is `stroke-dashoffset`, which is a
                 * number. `pathLength="1"` makes that number the fraction.
                 *
                 * An arc's length, never a transform: a dial that scaled would
                 * resample the numbers written across it.
                 */
                <path
                  d={ringPath(centreX, centreY, (outer + inner) / 2, from, to)}
                  fill="none"
                  stroke={`var(--plass-${family}-fill)`}
                  strokeWidth={outer - inner}
                  pathLength="1"
                  strokeDasharray="1"
                  strokeDashoffset={1 - fraction}
                  style={{
                    // The slow duration and not the house one: what is moving
                    // here is a quantity settling, which is the case that ladder
                    // step exists for. The colour underneath it changes at the
                    // house pace, because that is a state change and not a
                    // journey.
                    transition:
                      'stroke-dashoffset var(--plass-duration-slow) var(--plass-ease), stroke var(--plass-duration) var(--plass-ease)'
                  }}
                />
              ) : null}

              {tickCount > 0
                ? Array.from({ length: tickCount }, (_, index) => {
                    const at = from + (span * index) / (tickCount - 1);
                    const [x1, y1] = pointAt(centreX, centreY, outer + fontSize * 0.25, at);
                    const [x2, y2] = pointAt(centreX, centreY, outer + fontSize * 0.6, at);

                    return (
                      <line
                        key={index}
                        x1={x1}
                        y1={y1}
                        x2={x2}
                        y2={y2}
                        stroke="var(--plass-chart-grid)"
                        strokeWidth={1}
                        strokeLinecap="round"
                      />
                    );
                  })
                : null}

              {rangeText.length > 0
                ? (
                    [
                      [rangeText[0], from, 'start'],
                      [rangeText[1], to, 'end']
                    ] as const
                  ).map(([each, at, which]) => {
                    const [x, y] = pointAt(centreX, centreY, outer + labelReach, at);

                    return (
                      <text
                        key={which}
                        x={x}
                        y={y + labelDrop}
                        textAnchor={labelUnder ? 'middle' : which === 'start' ? 'end' : 'start'}
                        fontSize={fontSize}
                        fill="var(--plass-muted-fg)"
                      >
                        {each}
                      </text>
                    );
                  })
                : null}
            </svg>

            {/* Real text rather than an SVG `<text>`: this is the one number the
                chart is about, so it has to be selectable, findable and in the
                accessibility tree. */}
            <div
              className="pointer-events-none absolute inset-x-0 mx-auto flex flex-col items-center gap-0.5 text-center"
              // Held to the chord it sits on, so a `center` of its own — a node
              // this has no way to measure — is wrapped by the dial rather than
              // laid out across the tile beside it. Offset by half the caption,
              // so what lands on `textY` is the reading rather than the middle
              // of the two.
              style={{
                top: textY + captionRoom / 2,
                maxWidth: room,
                transform: 'translateY(-50%)'
              }}
            >
              <span
                className="font-semibold text-(--plass-fg) tabular-nums"
                style={{ fontSize: readingSize }}
              >
                {reading}
              </span>
              {caption ? (
                <span className={cx('text-(--plass-muted-fg)', metaTextClasses[size])}>
                  {caption}
                </span>
              ) : null}
            </div>
          </>
        ) : null}
      </div>
    </ChartSurface>
  );
}
