/**
 * The arithmetic every chart is made of.
 *
 * Here rather than in a component for the reason `internal/progress.ts` is: five
 * components draw five different marks and ask exactly the same four questions
 * first — what is the range, where does a value land in the plot, what are the
 * clean numbers to tick at, and what colour is series four. A chart file that
 * also has to answer those is a file where the drawing cannot be read.
 *
 * There is no React in here and nothing in it knows what an SVG is. What it
 * knows is data and pixels; `internal/chart-frame.tsx` is where those become elements.
 *
 * The scales are deliberately not a `d3-scale`. A linear scale is six lines, a
 * band scale is four, and `nice numbers` is twelve — against a charting stack
 * that would be the largest thing in the package. The same trade `internal/color.ts`
 * makes.
 */

import type * as React from 'react';
import { dateFormatter, numberFormatter } from './format.js';
import type {
  PlassChartCategory,
  PlassChartDatum,
  PlassChartPoint,
  PlassChartSeries,
  PlassColor,
  PlassDensity,
  PlassSize
} from '../types.js';

/* ---------------------------------------------------------------------------
 * Scales
 * ------------------------------------------------------------------------- */

/**
 * How tall a plot is when nobody said, in pixels.
 *
 * A chart is one of the few things in the library with no intrinsic height — it
 * is as tall as it is given — so this ladder is what stops every chart on a
 * dashboard being a different shape. The steps climb faster than the control
 * ladder because the thing being scaled is a *picture*: at `xs` this is a strip
 * beside a number, at `xl` it is what the screen is about.
 *
 * The axis band is drawn *inside* this, not added to it. A card sized to the
 * plot and then handed axis labels is the card that grows a two-line scrollbar.
 */
export const plotHeights: Record<PlassSize, number> = {
  xs: 120,
  sm: 160,
  md: 220,
  lg: 280,
  xl: 360
};

/**
 * A PlSparkline's own ladder, which is a different object: it has no axes, no
 * legend and nothing to read off it but the shape, so it is sized against the
 * line of text it sits next to rather than against the page.
 */
export const sparklineHeights: Record<PlassSize, number> = {
  xs: 16,
  sm: 20,
  md: 28,
  lg: 40,
  xl: 56
};

/**
 * The weight of a line, in pixels. `md` is 2, which is the width a data line
 * wants everywhere — thin enough to stay a line where two of them cross, heavy
 * enough to hold a hue at 3:1.
 */
export const lineWidths: Record<PlassSize, number> = {
  xs: 1.5,
  sm: 1.75,
  md: 2,
  lg: 2.25,
  xl: 2.5
};

/**
 * The radius of a marker. `md` is 4, so the dot is 8px across before its ring —
 * the floor below which a marker stops being something a pointer can find.
 */
export const markerRadii: Record<PlassSize, number> = {
  xs: 3,
  sm: 3.5,
  md: 4,
  lg: 4.5,
  xl: 5
};

/**
 * Tick and label type, in pixels rather than as a class.
 *
 * SVG text does not inherit a Tailwind utility usefully — the `<text>` has to
 * carry a `font-size` the layout arithmetic can also read, because the room the
 * axis reserves is measured from it. These are `metaTextClasses` as numbers;
 * keep the two in step.
 */
export const chartFontSizes: Record<PlassSize, number> = {
  xs: 10,
  sm: 11,
  md: 12,
  lg: 13,
  xl: 14
};

/**
 * How thick a bar is allowed to get, in pixels.
 *
 * A cap and not a width: the band a bar sits in is whatever the plot divided by
 * the category count gives, and a bar that fills its band leaves the chart with
 * no air in it at all. Past this the leftover stays as space.
 */
export const barMaxThickness: Record<PlassSize, number> = {
  xs: 14,
  sm: 18,
  md: 24,
  lg: 30,
  xl: 36
};

/**
 * How much of a band the bars in it take, before the cap above applies.
 * `density` is the only thing that moves it — the same rule as everywhere else,
 * spacing and nothing but spacing.
 */
export const barBandRatio: Record<PlassDensity, number> = {
  default: 0.62,
  compact: 0.82
};

/** The gap the surface shows through between two touching marks, in pixels. */
export const markGap = 2;

/** The corner cut off the data end of a bar. Square at the baseline. */
export const barRadius = 4;

/* ---------------------------------------------------------------------------
 * Colour
 * ------------------------------------------------------------------------- */

/** The eight slots, as the `var()`s that resolve them per theme. */
export const chartPalette: readonly string[] = [
  'var(--plass-chart-1)',
  'var(--plass-chart-2)',
  'var(--plass-chart-3)',
  'var(--plass-chart-4)',
  'var(--plass-chart-5)',
  'var(--plass-chart-6)',
  'var(--plass-chart-7)',
  'var(--plass-chart-8)'
];

const colorFamilies = new Set<string>([
  'primary',
  'secondary',
  'success',
  'warning',
  'danger',
  'info'
]);

/** A `PlassColor` resolves to its readable-on-surface accent; anything else is CSS. */
export function resolveColor(value: string): string {
  return colorFamilies.has(value) ? `var(--plass-${value as PlassColor}-accent)` : value;
}

/**
 * What colour a mark is, in the fixed order the palette is handed out in.
 *
 * `index` is the series' place in the array it was passed in, not its place
 * among the ones currently visible. That is the whole point: filtering a legend
 * must not repaint the survivors, because a reader who learned that Europe is
 * blue has learned something that a re-render is not allowed to take back.
 *
 * Past the eighth slot it wraps, and a chart that gets there should not have —
 * a ninth hue is indistinguishable from one of the first eight under colour
 * vision deficiency no matter which one is chosen. Fold the tail into an
 * "Other" series, or draw a second chart.
 */
export function seriesColor(
  series: Pick<PlassChartSeries, 'color'> | undefined,
  index: number,
  palette: readonly string[] = chartPalette
): string {
  if (series?.color) {
    return resolveColor(series.color);
  }

  return resolveColor(palette[index % palette.length] ?? chartPalette[0]);
}

/* ---------------------------------------------------------------------------
 * Data
 * ------------------------------------------------------------------------- */

/** A datum unpacked into the shape the drawing code reads. */
export interface ChartValue {
  value: number | null;
  x?: PlassChartCategory;
  z?: number;
  color?: string;
  label?: React.ReactNode;
}

const isPoint = (datum: PlassChartDatum): datum is PlassChartPoint =>
  typeof datum === 'object' && datum !== null;

/**
 * One datum, whichever of the three ways it was written.
 *
 * `NaN` is folded into `null` here rather than at every call site: it arrives
 * from a division somewhere upstream, it means the same thing a gap means, and
 * a scale that is handed one produces a path with the letters `NaN` in it —
 * which fails silently as a blank chart rather than loudly as an error.
 */
export function toValue(datum: PlassChartDatum): ChartValue {
  if (datum === null || datum === undefined) {
    return { value: null };
  }

  if (typeof datum === 'number') {
    return { value: Number.isFinite(datum) ? datum : null };
  }

  if (!isPoint(datum)) {
    return { value: null };
  }

  return {
    value: datum.y === null || !Number.isFinite(datum.y) ? null : datum.y,
    x: datum.x,
    z: datum.z,
    color: datum.color ? resolveColor(datum.color) : undefined,
    label: datum.label
  };
}

/** Every series unpacked, in the order it was given. */
export function toValues(series: readonly PlassChartSeries[]): ChartValue[][] {
  return series.map((one) => one.data.map(toValue));
}

/**
 * A category as a number, for a category axis that is really a value axis.
 *
 * A `Date` is its epoch milliseconds, which is what makes a scatter of
 * timestamps work at all. A string is not a position on a number line, so it
 * comes back `null` rather than `NaN` — the same rule `toValue` follows, and
 * for the same reason: a `NaN` reaches the scale and leaves the letters in the
 * path.
 */
export function toNumber(value: PlassChartCategory | undefined): number | null {
  if (value instanceof Date) {
    return Number.isFinite(value.getTime()) ? value.getTime() : null;
  }

  if (typeof value === 'number') {
    return Number.isFinite(value) ? value : null;
  }

  return null;
}

/**
 * Where one point sits along a category axis that runs on numbers.
 *
 * The same three sources `categoryAt` reads, in the same order — but per
 * *point* rather than per column, because on a scatter each series has its own
 * x at every index and there is no column for them to share.
 */
export function pointX(
  value: ChartValue,
  index: number,
  categories: readonly PlassChartCategory[] | undefined
): number | null {
  return toNumber(value.x ?? categories?.[index] ?? index);
}

/**
 * The extent of the category values, for a chart whose x is a number.
 *
 * Only points that have a `y` count. A point with no value is not on the plot,
 * so letting its `x` stretch the axis would leave a margin of empty plot
 * standing in for data that was never drawn.
 */
export function categoryExtent(
  values: readonly ChartValue[][],
  categories: readonly PlassChartCategory[] | undefined
): { min: number; max: number } | null {
  let min = Infinity;
  let max = -Infinity;
  let seen = false;

  values.forEach((one) => {
    one.forEach((value, index) => {
      if (value.value === null) {
        return;
      }

      const x = pointX(value, index, categories);

      if (x === null) {
        return;
      }

      seen = true;
      min = Math.min(min, x);
      max = Math.max(max, x);
    });
  });

  return seen ? { min, max } : null;
}

/**
 * The radius a bubble gets for its `z`, in pixels.
 *
 * `z` is an **area** and not a radius, which is the single most common way a
 * bubble chart lies: encode it as a radius and a value twice as large draws a
 * mark four times the size. The square root is what makes the ink on the page
 * proportional to the number behind it.
 *
 * `min` is a floor rather than a scale — a bubble for a small-but-real value
 * has to stay something a pointer can find, and a zero is the only thing
 * allowed to disappear.
 */
export function bubbleRadius(z: number, maxZ: number, max: number, min: number): number {
  if (!(maxZ > 0) || !Number.isFinite(z) || z <= 0) {
    return z === 0 ? 0 : min;
  }

  return Math.max(min, Math.sqrt(Math.min(z, maxZ) / maxZ) * max);
}

/** How many categories the widest series has. */
export function categoryCount(series: readonly PlassChartSeries[]): number {
  return series.reduce((most, one) => Math.max(most, one.data.length), 0);
}

/**
 * What the category axis says at position `index`.
 *
 * `categories` wins, then whatever the first series that has one calls its own
 * point, then the index. Three sources rather than one because a chart is
 * written both ways in the wild — a column of labels beside a column of
 * numbers, or points that carry their own `x` — and neither is wrong.
 */
export function categoryAt(
  index: number,
  categories: readonly PlassChartCategory[] | undefined,
  values: readonly ChartValue[][]
): PlassChartCategory {
  if (categories && index < categories.length) {
    return categories[index];
  }

  for (const one of values) {
    const found = one[index]?.x;

    if (found !== undefined) {
      return found;
    }
  }

  return index;
}

/**
 * The extent of the values, with the stacking rule applied.
 *
 * Stacked charts measure the *totals* and not the parts, and the two arms are
 * accumulated separately so a series that goes negative does not shorten the
 * bar above it. An all-`null` chart has no extent at all, which is what the
 * `null` return says — the caller draws its empty state rather than an axis
 * from `Infinity` to `-Infinity`.
 */
export function extentOf(
  values: readonly ChartValue[][],
  stacked: boolean
): { min: number; max: number } | null {
  let min = Infinity;
  let max = -Infinity;
  let seen = false;

  if (stacked) {
    const length = values.reduce((most, one) => Math.max(most, one.length), 0);

    for (let i = 0; i < length; i++) {
      let positive = 0;
      let negative = 0;

      for (const one of values) {
        const value = one[i]?.value;

        if (value === null || value === undefined) {
          continue;
        }

        seen = true;

        if (value >= 0) {
          positive += value;
        } else {
          negative += value;
        }
      }

      min = Math.min(min, negative);
      max = Math.max(max, positive);
    }
  } else {
    for (const one of values) {
      for (const { value } of one) {
        if (value === null) {
          continue;
        }

        seen = true;
        min = Math.min(min, value);
        max = Math.max(max, value);
      }
    }
  }

  return seen ? { min, max } : null;
}

/* ---------------------------------------------------------------------------
 * Ticks
 * ------------------------------------------------------------------------- */

/** 1, 2, 5, 10 — the steps a reader can do arithmetic on in their head. */
function niceStep(rough: number): number {
  const magnitude = 10 ** Math.floor(Math.log10(rough));
  const normalised = rough / magnitude;

  if (normalised <= 1) {
    return magnitude;
  }

  if (normalised <= 2) {
    return 2 * magnitude;
  }

  if (normalised <= 5) {
    return 5 * magnitude;
  }

  return 10 * magnitude;
}

/**
 * A step that lands on both ends of a range the caller pinned.
 *
 * When a scale is free to move, rounding the *ends* outward to the step is what
 * gives clean ticks. When `min` and `max` are given they cannot move, so the
 * step has to be the thing that gives — and a step that does not divide the
 * range leaves the top tick missing, which on a `min: 99.5, max: 100` axis
 * means the one number the reader came for is the one not written down.
 *
 * So the 1-2-5 family is widened by a half step (2.5, 25, 250 — the divisor
 * every quarter-scale needs) and searched for the step that divides the range
 * exactly and comes closest to the tick count asked for.
 */
function dividingStep(range: number, tickCount: number): number {
  const magnitude = 10 ** Math.floor(Math.log10(range / Math.max(1, tickCount)));
  let best = niceStep(range / Math.max(1, tickCount));
  let closest = Infinity;

  for (const scale of [0.1, 1, 10]) {
    for (const unit of [1, 2, 2.5, 5]) {
      const step = unit * scale * magnitude;
      const count = range / step;
      const whole = Math.round(count);

      // The tolerance is a floating-point guard: 0.5 / 0.1 is 4.999999999999999.
      if (whole < 1 || Math.abs(count - whole) > 1e-9) {
        continue;
      }

      const distance = Math.abs(whole - tickCount);

      if (distance < closest) {
        closest = distance;
        best = step;
      }
    }
  }

  return best;
}

/** A value scale: where it starts, where it ends, and what it ticks at. */
export interface ValueScale {
  min: number;
  max: number;
  ticks: number[];
  /** A value → a fraction of the plot, `0` at `min` and `1` at `max`. */
  fraction: (value: number) => number;
}

/**
 * The scale a value axis runs on, rounded out to clean numbers.
 *
 * Rounding *outward* is the part that matters: a maximum of 4,830 becomes 5,000
 * and not 4,830, so the top tick is a number and the tallest bar stops short of
 * the ceiling. A scale whose last bar touches the frame reads as clipped even
 * when it is exactly right.
 *
 * Zero is included unless the caller says otherwise, because bar length is only
 * proportional to value when the baseline is zero. A line chart of a quantity
 * that never approaches zero is the case for passing `min` — and it is a case
 * the caller has to make, not one the chart makes for them.
 */
export function valueScale(
  extent: { min: number; max: number } | null,
  options: {
    min?: number;
    max?: number;
    tickCount?: number;
    /** Keeps zero in range. Off for a line chart told an explicit `min`. */
    includeZero?: boolean;
  } = {}
): ValueScale {
  const { tickCount = 5, includeZero = true } = options;

  let low = options.min ?? (extent ? extent.min : 0);
  let high = options.max ?? (extent ? extent.max : 1);

  if (includeZero && options.min === undefined) {
    low = Math.min(low, 0);
  }

  if (includeZero && options.max === undefined) {
    high = Math.max(high, 0);
  }

  // A flat series — every value the same — has no extent to divide by. Open a
  // band around it rather than dividing by zero and drawing a line off the top.
  if (high === low) {
    const pad = Math.abs(high) > 0 ? Math.abs(high) * 0.5 : 1;

    low -= pad;
    high += pad;
  }

  // Both ends pinned means the *step* is what has to give; otherwise it is the
  // ends that round outward to a step chosen from the data.
  const pinned = options.min !== undefined && options.max !== undefined;
  const step = pinned
    ? dividingStep(high - low, tickCount)
    : niceStep((high - low) / Math.max(1, tickCount));

  const start = options.min !== undefined ? low : Math.floor(low / step) * step;
  const end = options.max !== undefined ? high : Math.ceil(high / step) * step;
  const span = end - start || 1;

  const ticks: number[] = [];

  // The epsilon is a floating-point guard, not a fudge: `0.1 * 3` lands at
  // 0.30000000000000004, which without it drops the last tick off every scale
  // whose step is not a power of two.
  for (let tick = start; tick <= end + step * 1e-9; tick += step) {
    // And the rounding is the other half of it — a tick printed as
    // `0.30000000000000004` is worse than a missing one.
    ticks.push(Number(tick.toFixed(12)));
  }

  return {
    min: start,
    max: end,
    ticks,
    fraction: (value) => (value - start) / span
  };
}

/* ---------------------------------------------------------------------------
 * Time
 * ------------------------------------------------------------------------- */

/** The units a time axis is allowed to step in. */
export type TimeUnit = 'second' | 'minute' | 'hour' | 'day' | 'week' | 'month' | 'quarter' | 'year';

const second = 1000;
const minute = 60 * second;
const hour = 60 * minute;
const day = 24 * hour;

/**
 * The steps a clock and a calendar actually have, smallest first.
 *
 * `niceStep`'s 1-2-5 is the right family for a count and the wrong one for an
 * instant: run on a millisecond number it produces a tick every 200,000,000 ms,
 * which lands at 14:53:20 on an arbitrary Tuesday. Nobody reads that. Time is
 * not decimal below the year — sixty, sixty, twenty-four, seven, twelve — so
 * the steps are written down rather than derived.
 *
 * `size` is only how the step is *chosen*: months and years are not a fixed
 * number of milliseconds, so the ticks themselves are walked with a calendar.
 */
const timeSteps: readonly { unit: TimeUnit; count: number; size: number }[] = [
  { unit: 'second', count: 1, size: second },
  { unit: 'second', count: 5, size: 5 * second },
  { unit: 'second', count: 15, size: 15 * second },
  { unit: 'second', count: 30, size: 30 * second },
  { unit: 'minute', count: 1, size: minute },
  { unit: 'minute', count: 5, size: 5 * minute },
  { unit: 'minute', count: 15, size: 15 * minute },
  { unit: 'minute', count: 30, size: 30 * minute },
  { unit: 'hour', count: 1, size: hour },
  { unit: 'hour', count: 3, size: 3 * hour },
  { unit: 'hour', count: 6, size: 6 * hour },
  { unit: 'hour', count: 12, size: 12 * hour },
  { unit: 'day', count: 1, size: day },
  { unit: 'day', count: 2, size: 2 * day },
  { unit: 'week', count: 1, size: 7 * day },
  { unit: 'week', count: 2, size: 14 * day },
  { unit: 'month', count: 1, size: 30 * day },
  { unit: 'quarter', count: 1, size: 91 * day },
  { unit: 'month', count: 6, size: 182 * day },
  { unit: 'year', count: 1, size: 365 * day }
];

/**
 * The start of the `unit` that `time` falls in, in the reader's own timezone.
 *
 * Local and not UTC, which is the whole reason this is calendar arithmetic
 * rather than a modulo: a tick labelled "Mar 3" has to sit at midnight where
 * the reader is, and an axis aligned to UTC puts it nine hours into the 2nd.
 */
function floorTime(time: number, unit: TimeUnit): number {
  const at = new Date(time);

  if (unit === 'year') {
    return new Date(at.getFullYear(), 0, 1).getTime();
  }

  if (unit === 'quarter') {
    return new Date(at.getFullYear(), Math.floor(at.getMonth() / 3) * 3, 1).getTime();
  }

  if (unit === 'month') {
    return new Date(at.getFullYear(), at.getMonth(), 1).getTime();
  }

  if (unit === 'week') {
    const midnight = new Date(at.getFullYear(), at.getMonth(), at.getDate());

    midnight.setDate(midnight.getDate() - midnight.getDay());

    return midnight.getTime();
  }

  if (unit === 'day') {
    return new Date(at.getFullYear(), at.getMonth(), at.getDate()).getTime();
  }

  if (unit === 'hour') {
    return new Date(at.getFullYear(), at.getMonth(), at.getDate(), at.getHours()).getTime();
  }

  if (unit === 'minute') {
    return Math.floor(time / minute) * minute;
  }

  return Math.floor(time / second) * second;
}

/**
 * `count` units on from `time`, again by the calendar.
 *
 * Adding 30 days is not adding a month and adding 365 is not adding a year, so
 * a scale that stepped in milliseconds would drift a day per leap year and
 * three per quarter. `setMonth` and `setDate` roll over correctly, and they are
 * also what keeps a daily axis on midnight across a daylight-saving change.
 */
function addTime(time: number, unit: TimeUnit, count: number): number {
  const at = new Date(time);

  if (unit === 'year') {
    at.setFullYear(at.getFullYear() + count);
  } else if (unit === 'quarter') {
    at.setMonth(at.getMonth() + 3 * count);
  } else if (unit === 'month') {
    at.setMonth(at.getMonth() + count);
  } else if (unit === 'week') {
    at.setDate(at.getDate() + 7 * count);
  } else if (unit === 'day') {
    at.setDate(at.getDate() + count);
  } else if (unit === 'hour') {
    at.setHours(at.getHours() + count);
  } else {
    return time + count * (unit === 'minute' ? minute : second);
  }

  return at.getTime();
}

/**
 * The container a step of this unit should be counted from.
 *
 * A 6-month step floored only to a month starts wherever the data starts, and
 * an axis reading "Apr · Oct · Apr · Oct" has told the reader nothing about
 * where in the year they are. Counted from January it reads "Jan · Jul", which
 * is the same six months landing where a calendar already has a name for them.
 * The same argument makes an hourly axis start at midnight and a minute axis
 * start on the hour.
 */
const timeContainer: Record<TimeUnit, TimeUnit> = {
  second: 'minute',
  minute: 'hour',
  hour: 'day',
  day: 'month',
  week: 'week',
  month: 'year',
  quarter: 'year',
  year: 'year'
};

/** The last step boundary at or before `time` — the axis' rounded-out start. */
function alignTime(time: number, unit: TimeUnit, count: number): number {
  let tick = floorTime(time, timeContainer[unit]);

  if (unit === 'year' && count > 1) {
    // Decades start at 1990 and not at 1993, which is the same rule one step up.
    const year = new Date(tick).getFullYear();

    tick = new Date(year - (((year % count) + count) % count), 0, 1).getTime();
  }

  for (let index = 0; index < 500; index++) {
    const next = addTime(tick, unit, count);

    if (next > time) {
      return tick;
    }

    tick = next;
  }

  return tick;
}

/** A value scale whose numbers are instants, and the unit its ticks step in. */
export interface TimeScale extends ValueScale {
  unit: TimeUnit;
  /** How many of that unit each step covers — 1, 5, 15 minutes and so on. */
  step: number;
}

/**
 * The scale a time axis runs on, ticking where a calendar ticks.
 *
 * The ends round *outward* to the step for the reason `valueScale`'s do: a span
 * that starts exactly on the left edge reads as clipped rather than as
 * starting there. Past a year the 1-2-5 family comes back, because above the
 * year time really is decimal — decades and centuries are the only units left.
 */
export function timeScale(
  extent: { min: number; max: number } | null,
  options: { min?: number; max?: number; tickCount?: number } = {}
): TimeScale {
  const { tickCount = 6 } = options;

  let low = options.min ?? extent?.min ?? Date.parse('2000-01-01T00:00:00');
  let high = options.max ?? extent?.max ?? low + day;

  // A single instant is not a range. Open a day around it rather than dividing
  // by zero and drawing every mark on one pixel.
  if (high <= low) {
    low -= day / 2;
    high += day / 2;
  }

  const span = high - low;

  /* The step whose tick count comes *closest* to the one asked for, rather than
     the largest that fits under it. "Largest that fits" is off by a factor of
     two every time the next step up is the better answer: five months at six
     ticks wants a month, and taking the biggest step under `span / 6` takes a
     fortnight and draws eleven. */
  let chosen = timeSteps[0];
  let closest = Infinity;

  for (const candidate of timeSteps) {
    const distance = Math.abs(span / candidate.size - tickCount);

    if (distance < closest) {
      closest = distance;
      chosen = candidate;
    }
  }

  // Above a year the calendar has no more units to offer, so the step goes back
  // to 1-2-5 — counted in years, never in milliseconds.
  const unit = chosen.unit;
  const count =
    unit === 'year'
      ? Math.max(1, Math.round(niceStep(span / tickCount / (365 * day))))
      : chosen.count;

  const start = options.min ?? alignTime(low, unit, count);
  const ticks: number[] = [];

  /* Walked rather than multiplied, so a month is a month. The loop runs one
     step past the data and keeps that step as the end, which is what rounds the
     axis outward at the top the way `alignTime` rounded it at the bottom — a
     span whose last day is the last pixel reads as clipped rather than as
     finished. The 500 is a guard and not a limit: a step small enough to need
     more of them means the unit table was outrun. */
  let tick = start;

  for (let index = 0; index < 500; index++) {
    ticks.push(tick);

    if (tick > high) {
      break;
    }

    tick = addTime(tick, unit, count);
  }

  const end = options.max ?? ticks[ticks.length - 1];
  const width = end - start || 1;

  return {
    min: start,
    max: end,
    ticks: ticks.filter((one) => one >= start && one <= end),
    unit,
    step: count,
    fraction: (value) => (value - start) / width
  };
}

/**
 * The `Intl` options one instant is written with, at each step size.
 *
 * Everything here comes from `Intl` and none of it from `internal/i18n.ts` —
 * the same rule the date pickers follow, and for the same reason: the platform
 * already knows every month name in every language, and a table of them in this
 * repository would be a worse copy that goes stale.
 */
function timeParts(unit: TimeUnit, withYear: boolean): Intl.DateTimeFormatOptions {
  if (unit === 'second') {
    return { hour: '2-digit', minute: '2-digit', second: '2-digit', hourCycle: 'h23' };
  }

  if (unit === 'minute' || unit === 'hour') {
    return { hour: '2-digit', minute: '2-digit', hourCycle: 'h23' };
  }

  if (unit === 'year') {
    return { year: 'numeric' };
  }

  const parts: Intl.DateTimeFormatOptions =
    unit === 'month' || unit === 'quarter'
      ? { month: 'short' }
      : { month: 'short', day: 'numeric' };

  return withYear ? { ...parts, year: 'numeric' } : parts;
}

/** One instant on a time axis, written unambiguously — for a tooltip or a table. */
export function formatTimeValue(value: number, unit: TimeUnit, locale?: string): string {
  return dateFormatter(locale, timeParts(unit, true)).format(new Date(value));
}

/**
 * A whole axis of ticks, written the way an axis is read.
 *
 * The year is decided for the axis rather than for each tick, and that is the
 * part worth explaining. Writing it only where it *changes* is what a reader
 * wants and is not safe here: the labels are thinned again downstream, by a
 * stride measured against the plot's real width, and the tick the year was
 * riding on is exactly the one that gets dropped — leaving `Oct 2025 · Dec ·
 * Feb` with nothing to say which year February is in.
 *
 * So: an axis inside one year names it once, on the first tick, which is the
 * one tick a stride never removes. An axis that crosses a year names it on
 * every tick, so whichever ones survive are each unambiguous. Wider labels mean
 * a heavier stride, and a heavier stride is the better failure.
 */
export function formatTimeTicks(
  ticks: readonly number[],
  unit: TimeUnit,
  locale?: string
): string[] {
  const years = new Set(ticks.map((tick) => new Date(tick).getFullYear()));
  const always = years.size > 1;

  return ticks.map((tick, index) =>
    dateFormatter(locale, timeParts(unit, always || index === 0)).format(new Date(tick))
  );
}

/**
 * How many ticks a category axis can show before the labels collide, and which
 * ones they are.
 *
 * Every nth label rather than rotating them: a rotated axis is unreadable at a
 * glance and it steals a band of the plot to be unreadable in. `n` is chosen so
 * the labels clear each other at the measured width, and it always keeps the
 * first — a reader who cannot see where the axis starts cannot read any of it.
 */
export function tickStride(count: number, available: number, labelWidth: number): number {
  if (count <= 1 || available <= 0) {
    return 1;
  }

  const fits = Math.max(1, Math.floor(available / Math.max(1, labelWidth)));

  return Math.max(1, Math.ceil(count / fits));
}

/**
 * Whether the label at `index` survives the stride.
 *
 * Every nth, and — when it fits — the last one, which is the part a plain
 * modulo gets wrong: a fourteen-day axis at a stride of two ends at day
 * thirteen, and a percentage axis ends at 80%. The end of a scale is the number
 * a reader looks for first, and dropping it to keep the arithmetic tidy is the
 * wrong trade.
 *
 * `roomForLast` is the other half of it and is measured rather than guessed —
 * see `fitsLast`. Forcing a label that does not fit turns a missing "Jun" into
 * an overlapping "MayJun", which is worse than what it fixed.
 */
export function showsTick(
  index: number,
  count: number,
  stride: number,
  roomForLast: boolean
): boolean {
  return index % stride === 0 || (roomForLast && index === count - 1);
}

/**
 * Whether the last label clears the last one the stride kept.
 *
 * The two are `(count - 1) % stride` steps apart, and they need half of each
 * label plus a little air between them — labels are centred on their tick, so
 * only the inner halves can collide.
 */
export function fitsLast(count: number, stride: number, step: number, labelWidth: number): boolean {
  const over = (count - 1) % stride;

  return over > 0 && over * step >= labelWidth + 8;
}

/**
 * Roughly how wide a string renders at a given font size.
 *
 * An estimate on purpose. The alternative is a canvas measurement per label per
 * render, which is a layout read on a path that runs on every resize — and what
 * this number is used for is deciding how much room to reserve, where being a
 * few pixels generous costs nothing and being exact costs a reflow.
 *
 * 0.6em is the average advance of a digit in the sans-serifs a UI runs in;
 * anything CJK is close to a full em, so the widest character decides.
 */
export function textWidth(text: string, fontSize: number): number {
  let width = 0;

  for (const character of text) {
    width += /[ᄀ-ᇿ⺀-꓏가-퟿豈-﫿︰-﹏]/.test(character) ? 1 : 0.6;
  }

  return width * fontSize;
}

/**
 * A label cut to the room it has, with an ellipsis.
 *
 * The alternative when a category name is wider than its slot is to drop
 * labels until the survivors fit, and on five categories called things like
 * "Onboarding flow" that leaves exactly one of them on the axis — an axis with
 * one label is not a shorter axis, it is an unlabelled one. Cut instead: the
 * first few characters distinguish five words, and the tooltip and the table
 * both still have the whole thing.
 */
export function truncate(text: string, maxWidth: number, fontSize: number): string {
  if (maxWidth <= 0 || textWidth(text, fontSize) <= maxWidth) {
    return text;
  }

  const room = maxWidth - textWidth('…', fontSize);
  let cut = '';
  // The running width, rather than re-measuring `cut + character` each time.
  // Measuring the whole prefix again per character makes this quadratic in the
  // length of the label, and it is called once per label per render.
  let width = 0;

  for (const character of text) {
    const next = width + textWidth(character, fontSize);

    if (next > room) {
      break;
    }

    width = next;
    cut += character;
  }

  return cut.length > 0 ? `${cut.trimEnd()}…` : '…';
}

/* ---------------------------------------------------------------------------
 * Geometry
 * ------------------------------------------------------------------------- */

/** The plot's box inside the chart, once the axes have taken their bands. */
export interface PlotBox {
  left: number;
  top: number;
  width: number;
  height: number;
}

/** A band scale: one slot per category, with the marks centred in it. */
export interface BandScale {
  /** The centre of category `index`, in pixels along the axis. */
  centre: (index: number) => number;
  /** How wide one slot is. */
  step: number;
  /** How wide the marks in a slot are allowed to be, together. */
  band: number;
}

export function bandScale(count: number, length: number, ratio: number): BandScale {
  const step = count > 0 ? length / count : length;

  return {
    step,
    band: step * ratio,
    centre: (index) => step * (index + 0.5)
  };
}

/**
 * A path through the points, in whichever of the three shapes was asked for.
 *
 * `null` breaks the path rather than interpolating across it — the `M` that
 * starts a new subpath is the gap. A line that bridges a missing month is a
 * line that invents a number.
 *
 * `smooth` is a monotone cubic and not a Catmull-Rom, which is not a detail: a
 * plain spline overshoots between two close points, so a series that never goes
 * below zero draws a curve that does. A chart is allowed to be curved and it is
 * not allowed to show a value that is not in the data.
 */
export function linePath(
  points: readonly ({ x: number; y: number } | null)[],
  curve: 'linear' | 'smooth' | 'step'
): string {
  const path: string[] = [];
  let run: { x: number; y: number }[] = [];

  const flush = () => {
    if (run.length === 0) {
      return;
    }

    if (run.length === 1) {
      // A lone point between two gaps has no line to be part of. Draw it as a
      // zero-length stroke, which a round cap renders as the dot it is.
      path.push(`M${run[0].x} ${run[0].y}h0`);
    } else if (curve === 'step') {
      path.push(`M${run[0].x} ${run[0].y}`);

      for (let i = 1; i < run.length; i++) {
        const middle = (run[i - 1].x + run[i].x) / 2;

        path.push(`H${middle}V${run[i].y}H${run[i].x}`);
      }
    } else if (curve === 'smooth') {
      path.push(`M${run[0].x} ${run[0].y}`);
      path.push(monotonePath(run));
    } else {
      path.push(`M${run[0].x} ${run[0].y}`);

      for (let i = 1; i < run.length; i++) {
        path.push(`L${run[i].x} ${run[i].y}`);
      }
    }

    run = [];
  };

  for (const point of points) {
    if (point === null) {
      flush();
    } else {
      run.push(point);
    }
  }

  flush();

  return path.join('');
}

/**
 * The cubic segments of a monotone interpolation.
 *
 * Fritsch–Carlson: the tangent at each point is a harmonic mean of the slopes
 * either side of it, clamped to zero wherever they disagree in sign. That
 * clamp is what makes the curve monotone — it is why a run of increasing values
 * never dips on its way up, and why a minimum in the data is the minimum on
 * screen.
 */
function monotonePath(points: readonly { x: number; y: number }[]): string {
  const n = points.length;
  const slopes: number[] = [];

  for (let i = 0; i < n - 1; i++) {
    const dx = points[i + 1].x - points[i].x;

    slopes.push(dx === 0 ? 0 : (points[i + 1].y - points[i].y) / dx);
  }

  const tangents: number[] = [slopes[0] ?? 0];

  for (let i = 1; i < n - 1; i++) {
    const before = slopes[i - 1];
    const after = slopes[i];

    tangents.push(before * after <= 0 ? 0 : (2 * before * after) / (before + after));
  }

  tangents.push(slopes[n - 2] ?? 0);

  const segments: string[] = [];

  for (let i = 0; i < n - 1; i++) {
    const dx = (points[i + 1].x - points[i].x) / 3;

    segments.push(
      `C${points[i].x + dx} ${points[i].y + tangents[i] * dx}` +
        ` ${points[i + 1].x - dx} ${points[i + 1].y - tangents[i + 1] * dx}` +
        ` ${points[i + 1].x} ${points[i + 1].y}`
    );
  }

  return segments.join('');
}

/**
 * The same path closed down to a baseline, for an area.
 *
 * Built from the runs rather than from the whole line so a gap is a gap in the
 * fill too — an area that closes across a missing month fills in a value that
 * was never measured, which is the same lie the bridged line tells, painted
 * over a larger part of the chart.
 */
export function areaPath(
  points: readonly ({ x: number; y: number } | null)[],
  baseline: readonly ({ x: number; y: number } | null)[] | number,
  curve: 'linear' | 'smooth' | 'step'
): string {
  const path: string[] = [];
  let start = 0;

  const flush = (end: number) => {
    const run = points.slice(start, end).filter(Boolean) as { x: number; y: number }[];

    if (run.length === 0) {
      return;
    }

    const under =
      typeof baseline === 'number'
        ? run.map((point) => ({ x: point.x, y: baseline })).reverse()
        : (baseline.slice(start, end).filter(Boolean) as { x: number; y: number }[]).reverse();

    if (under.length === 0) {
      return;
    }

    const top = linePath(run, curve);
    // The underside runs back the other way, and it has to be drawn with the
    // same curve or a smoothed area and its own baseline disagree about where
    // the band is between two points. Only its opening `M` changes to an `L`:
    // a second `moveto` inside the path would lift the pen and leave the fill
    // with no side.
    const bottom = linePath(under, curve).replace(/^M/, 'L');

    path.push(`${top}${bottom}Z`);
  };

  for (let i = 0; i < points.length; i++) {
    if (points[i] === null) {
      flush(i);
      start = i + 1;
    }
  }

  flush(points.length);

  return path.join('');
}

/**
 * A rectangle with the two corners at its *data end* cut off.
 *
 * Rounded at the end and square at the baseline, which is not a stylistic
 * split: a bar that is rounded where it meets the axis has lost the exact
 * moment it starts, and a row of them turns the baseline into a scalloped edge.
 * The end is where the value is, and that is the end worth softening.
 *
 * The radius shrinks to fit rather than clipping, so a bar two pixels tall is a
 * bar and not a circle. `end` is which way the value grows.
 */
export function barPath(
  x: number,
  y: number,
  width: number,
  height: number,
  radius: number,
  end: 'up' | 'down' | 'left' | 'right'
): string {
  const r = Math.max(0, Math.min(radius, width / 2, height / 2));

  if (r === 0 || width <= 0 || height <= 0) {
    return `M${x} ${y}h${width}v${height}h${-width}Z`;
  }

  // Every path below is drawn clockwise on screen, which is what makes the
  // sweep flag `1` on all four corners. Reversing one and leaving the flag is
  // how a rounded corner comes out as a bite taken from the bar.
  const arc = (dx: number, dy: number) => `a${r} ${r} 0 0 1 ${dx} ${dy}`;

  if (end === 'up') {
    return `M${x} ${y + height}V${y + r}${arc(r, -r)}H${x + width - r}${arc(r, r)}V${y + height}Z`;
  }

  if (end === 'down') {
    return `M${x} ${y}H${x + width}V${y + height - r}${arc(-r, r)}H${x + r}${arc(-r, -r)}Z`;
  }

  if (end === 'right') {
    return `M${x} ${y}H${x + width - r}${arc(r, r)}V${y + height - r}${arc(-r, r)}H${x}Z`;
  }

  return `M${x + width} ${y + height}H${x + r}${arc(-r, -r)}V${y + r}${arc(r, -r)}H${x + width}Z`;
}

/**
 * The shapes a point mark can take.
 *
 * The dependable second identity channel, and the only chart form with one
 * going spare: a line cannot be a triangle and a bar cannot be a cross, but a
 * dot can be anything. Five is enough for every palette a chart is allowed.
 */
export type MarkShape = 'circle' | 'square' | 'triangle' | 'diamond' | 'cross';

/** The order shapes are handed out in, matching the palette: fixed, never cycled. */
export const markShapes: readonly MarkShape[] = [
  'circle',
  'square',
  'triangle',
  'diamond',
  'cross'
];

/**
 * How much bigger than a circle of the same area each shape has to be drawn.
 *
 * Equal *area*, not equal radius, and that is the whole reason this table
 * exists rather than five hand-picked numbers. On a bubble chart the area is
 * already carrying a magnitude, so a square that covers a third more ink than
 * the circle beside it is a square reporting a value it was not given. Solved
 * from `πr²`: a square's half-side is `r√π/2`, a diamond's half-diagonal
 * `r√(π/2)`, an equilateral triangle's circumradius `r√(4π/3√3)`, and a plus
 * whose arm is two thirds of its half-span `r√(9π/20)`.
 */
const shapeScale: Record<MarkShape, number> = {
  circle: 1,
  square: 0.8862,
  triangle: 1.5551,
  diamond: 1.2533,
  cross: 1.189
};

/**
 * One point mark, as a path, centred on `cx`/`cy` and covering the same area a
 * circle of radius `r` would.
 *
 * A circle comes back as a path too rather than as a `<circle>`, so whoever
 * draws the marks writes one element and not a branch — the ring, the fill and
 * the hover treatment are then unarguably the same on all five.
 */
export function markPath(shape: MarkShape, cx: number, cy: number, r: number): string {
  const size = Math.max(0, r) * shapeScale[shape];

  if (size === 0) {
    return '';
  }

  if (shape === 'circle') {
    return (
      `M${cx - size} ${cy}a${size} ${size} 0 1 0 ${size * 2} 0` +
      `a${size} ${size} 0 1 0 ${-size * 2} 0Z`
    );
  }

  if (shape === 'square') {
    return `M${cx - size} ${cy - size}h${size * 2}v${size * 2}h${-size * 2}Z`;
  }

  if (shape === 'diamond') {
    return `M${cx} ${cy - size}L${cx + size} ${cy}L${cx} ${cy + size}L${cx - size} ${cy}Z`;
  }

  if (shape === 'triangle') {
    // Sat on its circumcircle rather than on a bounding box, so it shares a
    // centre with the other four — a triangle centred on its box sits low, and
    // a row of markers would then not line up with the row of dots beside it.
    const points = [0, 120, 240].map((degrees) => {
      const radians = ((degrees - 90) * Math.PI) / 180;

      return `${cx + size * Math.cos(radians)} ${cy + size * Math.sin(radians)}`;
    });

    return `M${points.join('L')}Z`;
  }

  const arm = size / 3;

  return (
    `M${cx - arm} ${cy - size}h${arm * 2}v${size - arm}h${size - arm}v${arm * 2}` +
    `h${-(size - arm)}v${size - arm}h${-arm * 2}v${-(size - arm)}h${-(size - arm)}` +
    `v${-arm * 2}h${size - arm}Z`
  );
}

/**
 * The centre line of that slice, as an *open* path.
 *
 * `arcPath` below draws the slice itself, which is a closed shape — and a shape
 * whose `d` has to be rewritten every time the value moves. `d` is not a
 * property CSS can travel along, so a dial drawn that way jumps to each new
 * reading. Stroked instead, the same ring is one line with a width, and how much
 * of it is drawn is `stroke-dashoffset`, which is a number and does travel.
 *
 * It is what ProgressCircular already does, bent to an arbitrary span — which is
 * the point: a gauge is a Meter bent into an arc, and the four indicators in
 * this library have to agree about what a value changing looks like.
 *
 * Angles are degrees clockwise from twelve o'clock, as below.
 */
export function ringPath(cx: number, cy: number, radius: number, from: number, to: number): string {
  const point = (degrees: number) => {
    const radians = ((degrees - 90) * Math.PI) / 180;

    return `${cx + radius * Math.cos(radians)} ${cy + radius * Math.sin(radians)}`;
  };

  // A full circle cannot be one arc — start and end are the same point, and the
  // renderer draws nothing at all. Two half-arcs are the standard answer.
  if (Math.abs(to - from) >= 360) {
    const half = from + 180;

    return (
      `M${point(from)}A${radius} ${radius} 0 1 1 ${point(half)}` +
      `A${radius} ${radius} 0 1 1 ${point(from)}`
    );
  }

  const large = Math.abs(to - from) > 180 ? 1 : 0;

  return `M${point(from)}A${radius} ${radius} 0 ${large} 1 ${point(to)}`;
}

/**
 * A slice of a ring, as a path.
 *
 * `inner` of 0 is a pie and anything above it is a donut. Angles are degrees
 * clockwise from twelve o'clock, which is where a reader starts reading a
 * circle — SVG's own zero is at three o'clock, and the offset is applied here
 * once rather than at four call sites.
 */
export function arcPath(
  cx: number,
  cy: number,
  outer: number,
  inner: number,
  from: number,
  to: number
): string {
  const point = (radius: number, degrees: number) => {
    const radians = ((degrees - 90) * Math.PI) / 180;

    return `${cx + radius * Math.cos(radians)} ${cy + radius * Math.sin(radians)}`;
  };

  const sweep = Math.abs(to - from) >= 360;

  // A full circle cannot be one arc — start and end are the same point, and the
  // renderer draws nothing at all. Two half-arcs are the standard answer.
  if (sweep) {
    const half = from + 180;

    return inner > 0
      ? `M${point(outer, from)}A${outer} ${outer} 0 1 1 ${point(outer, half)}` +
          `A${outer} ${outer} 0 1 1 ${point(outer, from)}Z` +
          `M${point(inner, from)}A${inner} ${inner} 0 1 0 ${point(inner, half)}` +
          `A${inner} ${inner} 0 1 0 ${point(inner, from)}Z`
      : `M${point(outer, from)}A${outer} ${outer} 0 1 1 ${point(outer, half)}` +
          `A${outer} ${outer} 0 1 1 ${point(outer, from)}Z`;
  }

  const large = Math.abs(to - from) > 180 ? 1 : 0;

  if (inner <= 0) {
    return `M${cx} ${cy}L${point(outer, from)}A${outer} ${outer} 0 ${large} 1 ${point(outer, to)}Z`;
  }

  return (
    `M${point(outer, from)}A${outer} ${outer} 0 ${large} 1 ${point(outer, to)}` +
    `L${point(inner, to)}A${inner} ${inner} 0 ${large} 0 ${point(inner, from)}Z`
  );
}

/* ---------------------------------------------------------------------------
 * Magnitude colour
 * ------------------------------------------------------------------------- */

/** Which way a magnitude is coloured. */
export type ChartScaleKind = 'sequential' | 'diverging';

/** How many steps each ramp has. Five, and the reason is in `styles.css`. */
export const rampSteps = 5;

/**
 * The step a value lands on, and the ink a label on it wears.
 *
 * A magnitude is not an identity, so it does not come off the eight-slot
 * categorical ramp — see the note above `--plass-chart-seq-1`. It comes off a
 * one-hue ladder, and which rung is arithmetic on the value.
 *
 * A diverging scale is read from its *middle* rather than from its bottom, so
 * it is the distance either side of the neutral that is scaled — and by the
 * larger of the two arms, so a set running from −2 to +40 does not paint every
 * negative the deepest blue there is.
 */
export function rampStep(
  value: number,
  min: number,
  max: number,
  kind: ChartScaleKind,
  midpoint = 0
): number {
  if (kind === 'diverging') {
    const reach = Math.max(Math.abs(max - midpoint), Math.abs(midpoint - min));

    if (!(reach > 0)) {
      return 2;
    }

    const share = (value - midpoint) / reach;

    // Two rungs each side of the neutral, which is the middle rung.
    return Math.min(4, Math.max(0, 2 + Math.round(share * 2)));
  }

  const span = max - min;

  if (!(span > 0)) {
    return rampSteps - 1;
  }

  return Math.min(rampSteps - 1, Math.max(0, Math.floor(((value - min) / span) * rampSteps)));
}

/** The `var()` for a step of the ramp, and for the ink that reads on it. */
export function rampFill(step: number, kind: ChartScaleKind): string {
  return `var(--plass-chart-${kind === 'diverging' ? 'div' : 'seq'}-${step + 1})`;
}

export function rampInk(step: number, kind: ChartScaleKind): string {
  return `var(--plass-chart-${kind === 'diverging' ? 'div' : 'seq'}-on-${step + 1})`;
}

/* ---------------------------------------------------------------------------
 * Treemap
 * ------------------------------------------------------------------------- */

/** One tile, in pixels, and which value it came from. */
export interface TreemapTile {
  index: number;
  x: number;
  y: number;
  width: number;
  height: number;
}

/**
 * A squarified treemap: the values as boxes whose areas are proportional, laid
 * out as close to square as they can be got.
 *
 * Squarified rather than sliced, and the difference is the whole reason the
 * forty lines are worth it. A slice-and-dice treemap of twenty values ends in
 * slivers a pixel wide, and a sliver's *area* is unreadable however exact it is
 * — the reader compares its length instead, which is not the encoded quantity.
 * Bruls, Huizing and van Wijk's answer is greedy and simple: fill a row along
 * the box's shorter side, keep adding to it while the worst aspect ratio in it
 * improves, and start a new row the moment it stops.
 *
 * The order is the caller's; the layout sorts descending internally because the
 * algorithm needs it and hands the original index back on every tile, so a
 * tile's colour and its name are still its own.
 */
export function squarify(values: readonly number[], width: number, height: number): TreemapTile[] {
  const total = values.reduce((sum, value) => sum + Math.max(0, value), 0);

  if (!(total > 0) || width <= 0 || height <= 0) {
    return [];
  }

  const scale = (width * height) / total;
  const items = values
    .map((value, index) => ({ index, area: Math.max(0, value) * scale }))
    .filter((one) => one.area > 0)
    .sort((a, b) => b.area - a.area);

  const tiles: TreemapTile[] = [];

  let x = 0;
  let y = 0;
  let boxWidth = width;
  let boxHeight = height;
  let row: typeof items = [];

  /** The worst aspect ratio in a row laid along the current short side. */
  const worst = (candidate: typeof items) => {
    const side = Math.min(boxWidth, boxHeight);
    const sum = candidate.reduce((total, one) => total + one.area, 0);

    if (!(sum > 0) || !(side > 0)) {
      return Infinity;
    }

    // Sorted descending, so the first is the largest and the last the smallest.
    const biggest = candidate[0].area;
    const smallest = candidate[candidate.length - 1].area;

    return Math.max((side * side * biggest) / (sum * sum), (sum * sum) / (side * side * smallest));
  };

  const place = () => {
    const sum = row.reduce((total, one) => total + one.area, 0);
    const side = Math.min(boxWidth, boxHeight);
    const thickness = side > 0 ? sum / side : 0;
    const across = boxWidth >= boxHeight;

    let along = 0;

    for (const one of row) {
      const length = thickness > 0 ? one.area / thickness : 0;

      tiles.push(
        across
          ? { index: one.index, x, y: y + along, width: thickness, height: length }
          : { index: one.index, x: x + along, y, width: length, height: thickness }
      );

      along += length;
    }

    if (across) {
      x += thickness;
      boxWidth -= thickness;
    } else {
      y += thickness;
      boxHeight -= thickness;
    }

    row = [];
  };

  for (const one of items) {
    if (row.length === 0 || worst([...row, one]) <= worst(row)) {
      row.push(one);
    } else {
      place();
      row.push(one);
    }
  }

  if (row.length > 0) {
    place();
  }

  return tiles;
}

/* ---------------------------------------------------------------------------
 * Formatting
 *
 * Every formatter below comes out of `internal/format.ts` rather than out of a
 * `new`. These functions are called once per axis tick, once per category and
 * once per tooltip row, and all of that runs again on every re-render — so the
 * one on a chart being hovered runs on every frame.
 *
 * The option objects are module constants for the same reason: the cache is
 * keyed on what the options *say*, so a literal written inline would be
 * stringified afresh on every call to ask a question it already knew.
 * ------------------------------------------------------------------------- */

const shortDayParts: Intl.DateTimeFormatOptions = { month: 'short', day: 'numeric' };
const compactParts: Intl.NumberFormatOptions = { notation: 'compact', maximumFractionDigits: 1 };
const plainParts: Intl.NumberFormatOptions = { maximumFractionDigits: 2 };

/**
 * How a category is written when nobody said.
 *
 * A `Date` gets the reader's own short form, because the alternative is an ISO
 * string across the bottom of every time series. Everything else is `String`,
 * which is what the caller wrote it as.
 */
export function formatCategory(value: PlassChartCategory, locale?: string): string {
  if (value instanceof Date) {
    return dateFormatter(locale, shortDayParts).format(value);
  }

  return String(value);
}

/**
 * A number, compactly enough that a y-axis of thousands is not four labels of
 * seven characters.
 *
 * Only when the caller passed no `format` of their own — the moment they do,
 * they have said what the number means and the library's opinion about
 * thousands separators stops being welcome.
 */
export function compactNumber(value: number, locale?: string): string {
  const magnitude = Math.abs(value);

  if (magnitude >= 10000) {
    return numberFormatter(locale, compactParts).format(value);
  }

  return numberFormatter(locale, plainParts).format(value);
}
