/**
 * The arithmetic every chart is built out of.
 *
 * `internal/chart.ts` knows nothing about React or SVG — it is scales, paths
 * and estimates — and that is exactly why it is tested here rather than through
 * a rendered chart. A flat series, an empty range, a `null` in the middle of a
 * line and a full-circle arc are all one call each; reaching the same cases
 * through a component means laying a chart out in a browser and reading the
 * answer back off a path string.
 *
 * The three rules asserted hardest are the ones CLAUDE.md calls load-bearing: a
 * `null` is a gap and never a zero, a series' colour follows its index in the
 * array it was passed, and the palette is handed out in order and never cycled
 * within its own length.
 */
import { describe, expect, it } from 'vitest';
import {
  arcPath,
  bandScale,
  bubbleRadius,
  categoryCount,
  chartPalette,
  extentOf,
  linePath,
  ringPath,
  seriesColor,
  tickStride,
  toValue,
  toValues,
  truncate,
  valueScale
} from '../../src/internal/chart.js';

describe('valueScale', () => {
  it('rounds the top outward to a tick, so the tallest mark stops short of the frame', () => {
    const scale = valueScale({ min: 0, max: 4830 });

    expect(scale.max).toBeGreaterThan(4830);
    expect(scale.ticks[scale.ticks.length - 1]).toBe(scale.max);
  });

  it('opens a band around a flat series rather than dividing by zero', () => {
    // Every value the same. Without this the extent is zero and every point
    // lands on one line — or on `NaN`. Keeping zero in range hides the case, so
    // it is turned off here, which is what a PlLineChart told a `min` does.
    const scale = valueScale({ min: 40, max: 40 }, { includeZero: false });

    expect(scale.min).toBeLessThan(40);
    expect(scale.max).toBeGreaterThan(40);
    expect(Number.isFinite(scale.fraction(40))).toBe(true);
  });

  it('opens a band around a flat series at zero', () => {
    const scale = valueScale({ min: 0, max: 0 });

    expect(scale.max).toBeGreaterThan(scale.min);
    expect(Number.isFinite(scale.fraction(0))).toBe(true);
  });

  it('answers a scale with no data at all', () => {
    const scale = valueScale(null);

    expect(scale.max).toBeGreaterThan(scale.min);
    expect(scale.ticks.length).toBeGreaterThan(1);
  });

  it('keeps zero in range unless an end was pinned', () => {
    expect(valueScale({ min: 20, max: 90 }).min).toBe(0);
    expect(valueScale({ min: 20, max: 90 }, { min: 20 }).min).toBe(20);
  });

  it('prints no tick as a floating-point smear', () => {
    // `0.1 * 3` is 0.30000000000000004. A tick printed that way is worse than
    // a missing one, and the guard against it is what keeps the last tick on.
    const scale = valueScale({ min: 0, max: 0.5 });

    for (const tick of scale.ticks) {
      expect(String(tick).length).toBeLessThan(8);
    }
  });

  it('runs the fraction from 0 at the bottom to 1 at the top', () => {
    const scale = valueScale({ min: 0, max: 100 }, { min: 0, max: 100 });

    expect(scale.fraction(0)).toBe(0);
    expect(scale.fraction(100)).toBe(1);
    expect(scale.fraction(50)).toBeCloseTo(0.5, 10);
  });

  it('handles a range entirely below zero', () => {
    const scale = valueScale({ min: -900, max: -100 });

    expect(scale.min).toBeLessThanOrEqual(-900);
    expect(scale.max).toBe(0);
  });
});

describe('extentOf', () => {
  const rows = (...numbers: (number | null)[][]) =>
    numbers.map((one) => one.map((value) => ({ value })));

  it('ignores a gap rather than counting it as zero', () => {
    // The rule the whole file turns on: a chart that renders missing data as
    // zero reports an outage as a collapse.
    expect(extentOf(rows([50, null, 70]), false)).toEqual({ min: 50, max: 70 });
  });

  it('answers null when there is nothing to measure', () => {
    expect(extentOf(rows([null, null]), false)).toBeNull();
    expect(extentOf([], false)).toBeNull();
  });

  it('sums a stack, and sums the two signs apart', () => {
    expect(extentOf(rows([10, -5], [20, -5]), true)).toEqual({ min: -10, max: 30 });
  });

  it('leaves a gap out of a stack without shortening the column', () => {
    expect(extentOf(rows([10, 10], [null, 10]), true)).toEqual({ min: 0, max: 20 });
  });
});

describe('toValue', () => {
  it('reads the three ways a datum can be written', () => {
    expect(toValue(12)).toEqual({ value: 12 });
    expect(toValue(null)).toEqual({ value: null });
    expect(toValue({ y: 3, x: 'Jan' })).toMatchObject({ value: 3, x: 'Jan' });
  });

  it('treats a number that is not one as a gap', () => {
    // `NaN` and `Infinity` reach a chart from arithmetic a caller did — a rate
    // over a zero denominator — and drawing them puts a mark nowhere.
    expect(toValue(Number.NaN)).toEqual({ value: null });
    expect(toValue(Number.POSITIVE_INFINITY)).toEqual({ value: null });
    expect(toValue({ y: Number.NaN })).toMatchObject({ value: null });
  });

  it('keeps a point’s own label and category beside a null value', () => {
    expect(toValue({ y: null, x: 'Feb', label: 'no reading' })).toMatchObject({
      value: null,
      x: 'Feb',
      label: 'no reading'
    });
  });
});

describe('toValues and categoryCount', () => {
  it('counts the widest series rather than the first', () => {
    expect(categoryCount([{ data: [1, 2, 3] }, { data: [1] }])).toBe(3);
    expect(categoryCount([])).toBe(0);
  });

  it('unpacks every series in the order it was given', () => {
    expect(toValues([{ data: [1, null] }, { data: [{ y: 2 }] }])).toEqual([
      [{ value: 1 }, { value: null }],
      [{ value: 2, x: undefined, z: undefined, color: undefined, label: undefined }]
    ]);
  });
});

describe('seriesColor', () => {
  it('follows the index in the array it was passed, not a position among the visible', () => {
    // Which is what stops filtering a legend repainting the survivors.
    expect(seriesColor(undefined, 0)).toBe(seriesColor(undefined, 0));
    expect(seriesColor(undefined, 1)).not.toBe(seriesColor(undefined, 0));
  });

  it('hands the eight slots out in order', () => {
    // The order is what makes the *adjacent* pairs the ones checked for
    // colour-vision separation, so it is not an implementation detail.
    const first = chartPalette.map((_, index) => seriesColor(undefined, index));

    expect(new Set(first).size).toBe(chartPalette.length);
  });

  it('lets a series name its own colour', () => {
    expect(seriesColor({ color: 'rebeccapurple' }, 3)).toBe('rebeccapurple');
  });
});

describe('linePath', () => {
  const points = [
    { x: 0, y: 10 },
    { x: 10, y: 20 },
    { x: 20, y: 30 }
  ];

  it('draws one run through every point', () => {
    expect(linePath(points, 'linear')).toBe('M0 10L10 20L20 30');
  });

  it('breaks at a gap instead of drawing through it', () => {
    const path = linePath([points[0], null, points[2]], 'linear');

    // Two `M`s means two runs, which is what a break is.
    expect(path.match(/M/g)).toHaveLength(2);
  });

  it('draws a lone point between two gaps as a zero-length stroke', () => {
    // A round cap renders that as the dot it is. Nothing at all would lose the
    // reading entirely.
    expect(linePath([null, points[1], null], 'linear')).toBe('M10 20h0');
  });

  it('draws nothing at all when every point is a gap', () => {
    expect(linePath([null, null], 'linear')).toBe('');
    expect(linePath([], 'linear')).toBe('');
  });

  it('steps between points rather than sloping', () => {
    expect(linePath(points.slice(0, 2), 'step')).toBe('M0 10H5V20H10');
  });

  it('smooths without leaving the points it was given', () => {
    const path = linePath(points, 'smooth');

    expect(path.startsWith('M0 10')).toBe(true);
    expect(path).toContain('C');
  });
});

describe('bandScale', () => {
  it('centres a category in its own slot', () => {
    const band = bandScale(4, 400, 1);

    expect(band.step).toBe(100);
    expect(band.centre(0)).toBe(50);
    expect(band.centre(3)).toBe(350);
  });

  it('survives being asked for no categories', () => {
    expect(Number.isFinite(bandScale(0, 400, 1).step)).toBe(true);
  });

  it('narrows the marks against the slot by the ratio', () => {
    expect(bandScale(4, 400, 0.5).band).toBeLessThan(bandScale(4, 400, 1).band);
  });
});

describe('tickStride', () => {
  it('labels every category when they all fit', () => {
    expect(tickStride(4, 400, 40)).toBe(1);
  });

  it('skips enough of them to fit the rest', () => {
    expect(tickStride(40, 400, 40)).toBeGreaterThan(1);
  });

  it('never returns a stride of zero, whatever it is asked', () => {
    // A stride of zero is an infinite loop in whichever caller walks it.
    expect(tickStride(0, 0, 0)).toBe(1);
    expect(tickStride(100, -10, 0)).toBe(1);
  });
});

describe('truncate', () => {
  it('leaves a label that fits alone', () => {
    expect(truncate('Jan', 200, 12)).toBe('Jan');
  });

  it('cuts a label that does not, and marks the cut', () => {
    const cut = truncate('September 2026', 30, 12);

    expect(cut.endsWith('…')).toBe(true);
    expect(cut.length).toBeLessThan('September 2026'.length);
  });

  it('answers with the mark alone rather than nothing when there is no room', () => {
    expect(truncate('September', 1, 12)).toBe('…');
  });

  it('leaves the label alone when there is no width to fit it to', () => {
    expect(truncate('September', 0, 12)).toBe('September');
  });
});

describe('bubbleRadius', () => {
  it('scales by area rather than by radius', () => {
    // Four times the value is twice the radius, which is what makes two bubbles
    // read as the ratio they are.
    expect(bubbleRadius(100, 100, 20, 2)).toBeCloseTo(20, 10);
    expect(bubbleRadius(25, 100, 20, 2)).toBeCloseTo(10, 10);
  });

  it('keeps a small-but-real value findable, and lets a zero disappear', () => {
    expect(bubbleRadius(0.0001, 100, 20, 2)).toBe(2);
    expect(bubbleRadius(0, 100, 20, 2)).toBe(0);
  });

  it('answers a number when there is no largest value to scale against', () => {
    expect(bubbleRadius(5, 0, 20, 2)).toBe(2);
    expect(Number.isNaN(bubbleRadius(5, 0, 20, 2))).toBe(false);
  });
});

describe('arcPath', () => {
  it('draws a full circle as two arcs rather than one', () => {
    // Start and end are the same point on a single arc, and a renderer draws
    // nothing at all for it.
    const path = arcPath(50, 50, 40, 0, 0, 360);

    expect(path.match(/A/g)?.length).toBeGreaterThanOrEqual(2);
    expect(path).not.toContain('NaN');
  });

  it('draws a ring as two rings when there is a hole in it', () => {
    const ring = arcPath(50, 50, 40, 20, 0, 360);

    expect(ring.match(/M/g)).toHaveLength(2);
  });

  it('draws an ordinary slice without a NaN in it', () => {
    expect(arcPath(50, 50, 40, 0, 0, 90)).not.toContain('NaN');
    expect(arcPath(50, 50, 40, 20, 90, 200)).not.toContain('NaN');
  });
});

describe('ringPath', () => {
  /**
   * The open half of the pair, and the reason it exists: a stroked line has a
   * `stroke-dashoffset`, which is a number CSS can travel along, where a closed
   * wedge only has a `d`, which is not.
   */
  it('leaves the path open, so it can be stroked rather than filled', () => {
    const path = ringPath(50, 50, 30, -90, 90);

    expect(path).not.toContain('Z');
    expect(path.match(/M/g)).toHaveLength(1);
    expect(path).not.toContain('NaN');
  });

  it('draws a full circle as two arcs rather than one', () => {
    const path = ringPath(50, 50, 30, 0, 360);

    expect(path.match(/A/g)).toHaveLength(2);
    expect(path).not.toContain('NaN');
  });

  it('flags a span over a half turn as the long way round', () => {
    expect(ringPath(50, 50, 30, -135, 135)).toContain('0 1 1');
    expect(ringPath(50, 50, 30, -45, 45)).toContain('0 0 1');
  });

  it('starts at twelve o\u2019clock, not at three', () => {
    // A zero-degree point sits directly above the centre.
    expect(ringPath(50, 50, 30, 0, 90).startsWith('M50 20')).toBe(true);
  });
});
