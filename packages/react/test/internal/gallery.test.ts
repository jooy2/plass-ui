import { describe, expect, it } from 'vitest';
import { dealColumns, isTurned, ratioOf, shownRatio } from '../../src/internal/gallery';

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
