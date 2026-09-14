import { describe, expect, it } from 'vitest';
import {
  dealColumns,
  isTurned,
  masonryRows,
  ratioOf,
  shownRatio
} from '../../src/internal/gallery';

describe('ratioOf', () => {
  it('takes a number', () => {
    expect(ratioOf(1.5, 1)).toBe(1.5);
  });

  it('takes the way CSS writes one', () => {
    expect(ratioOf('16/9', 1)).toBeCloseTo(16 / 9);
    expect(ratioOf('16 / 9', 1)).toBeCloseTo(16 / 9);
  });

  it('takes a bare number in a string', () => {
    expect(ratioOf('1.5', 1)).toBe(1.5);
  });

  it('falls back rather than throwing on nonsense', () => {
    expect(ratioOf('wide', 2)).toBe(2);
    expect(ratioOf('16/0', 2)).toBe(2);
    expect(ratioOf(-1, 2)).toBe(2);
    expect(ratioOf(undefined, 2)).toBe(2);
  });
});

describe('dealColumns', () => {
  it('deals across before it deals down', () => {
    // Four squares into two lanes: 1 and 3 on the left, 2 and 4 on the right —
    // which is the order they were given in, read across.
    expect(dealColumns([1, 1, 1, 1], 2)).toEqual([
      [0, 2],
      [1, 3]
    ]);
  });

  it('puts each picture in the shortest lane', () => {
    // A tall picture (ratio 0.5 is twice as tall as it is wide) fills its lane,
    // so the next two both go in the other one.
    expect(dealColumns([0.5, 1, 1], 2)).toEqual([[0], [1, 2]]);
  });

  it('gives back one lane per column, empty ones included', () => {
    expect(dealColumns([1], 3)).toEqual([[0], [], []]);
  });

  it('handles an empty set', () => {
    expect(dealColumns([], 2)).toEqual([[], []]);
  });
});

describe('masonryRows', () => {
  it('lines up squares as a grid would', () => {
    // Every edge is shared by both lanes, so the rows are one share each with
    // a gap between them.
    expect(masonryRows([1, 1, 1, 1], 2, false)).toEqual({
      tracks: [1, 'gap', 1],
      tiles: [
        { column: 1, start: 1, end: 2 },
        { column: 2, start: 1, end: 2 },
        { column: 1, start: 3, end: 4 },
        { column: 2, start: 3, end: 4 }
      ]
    });
  });

  it('runs a tall tile past the edges of the lane beside it', () => {
    expect(masonryRows([0.5, 1, 1], 2, false)).toEqual({
      tracks: [1, 'gap', 1],
      tiles: [
        { column: 1, start: 1, end: 4 },
        { column: 2, start: 1, end: 2 },
        { column: 2, start: 3, end: 4 }
      ]
    });
  });

  it('puts the captions that end on an edge before its gap', () => {
    expect(masonryRows([0.5, 1, 1], 2, true)).toEqual({
      tracks: [1, 'caption', 'gap', 1, 'caption'],
      tiles: [
        { column: 1, start: 1, end: 6 },
        { column: 2, start: 1, end: 3 },
        { column: 2, start: 4, end: 6 }
      ]
    });
  });

  it('sizes each share by its distance from the edge before', () => {
    // A wide picture ends half a column width down, beside a square that ends
    // at one.
    const { tracks, tiles } = masonryRows([2, 1], 2, false);

    expect(tracks).toEqual([0.5, 0.5]);
    expect(tiles).toEqual([
      { column: 1, start: 1, end: 2 },
      { column: 2, start: 1, end: 3 }
    ]);
  });

  it('treats edges a rounding error apart as one', () => {
    // Three pictures of 0.7 in one lane and one of 0.7 / 3 in the other are
    // the same height, which the floating point spells 4.285714285714286 and
    // 4.2857142857142865.
    const { tracks, tiles } = masonryRows([0.7 / 3, 0.7, 0.7, 0.7], 2, false);

    expect(tracks.filter((track) => track !== 'gap')).toHaveLength(3);
    expect(tiles[0].end).toBe(tiles[3].end);
  });

  it('has no rows for an empty set', () => {
    expect(masonryRows([], 3, true)).toEqual({ tracks: [], tiles: [] });
  });
});

describe('isTurned', () => {
  it('is true only for a picture on its side', () => {
    expect([undefined, 0, 90, 180, 270, -90].map(isTurned)).toEqual([
      false,
      false,
      true,
      false,
      true,
      true
    ]);
  });
});

describe('shownRatio', () => {
  it('turns the proportion of a picture on its side', () => {
    expect(shownRatio(1.5, 90)).toBeCloseTo(2 / 3);
    expect(shownRatio(1.5, 270)).toBeCloseTo(2 / 3);
  });

  it('leaves every other picture at its own proportion', () => {
    expect(shownRatio(1.5, undefined)).toBe(1.5);
    expect(shownRatio(1.5, 180)).toBe(1.5);
  });
});
