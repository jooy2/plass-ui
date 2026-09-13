import { describe, expect, it } from 'vitest';
import { isSideways, quartersOf } from '../../src/internal/image';

describe('quartersOf', () => {
  it('counts the four quarters', () => {
    expect([0, 90, 180, 270].map(quartersOf)).toEqual([0, 1, 2, 3]);
  });

  it('reads a turn the other way as the clockwise one it means', () => {
    expect(quartersOf(-90)).toBe(3);
    expect(quartersOf(-180)).toBe(2);
  });

  it('takes a whole turn and more back round', () => {
    expect(quartersOf(360)).toBe(0);
    expect(quartersOf(450)).toBe(1);
    expect(quartersOf(-450)).toBe(3);
  });

  it('goes to the nearer quarter, and up from halfway', () => {
    // Up from halfway in both directions, which is `Math.round`'s rule and the
    // one the Dart build writes out by hand so the two agree about `-45`.
    expect(quartersOf(44)).toBe(0);
    expect(quartersOf(45)).toBe(1);
    expect(quartersOf(-45)).toBe(0);
    expect(quartersOf(-46)).toBe(3);
  });

  it('is no turn at all for a number that is not one', () => {
    expect(quartersOf(Number.NaN)).toBe(0);
    expect(quartersOf(Number.POSITIVE_INFINITY)).toBe(0);
  });
});

describe('isSideways', () => {
  it('is true for the odd quarters only', () => {
    expect(([0, 1, 2, 3] as const).map(isSideways)).toEqual([false, true, false, true]);
  });
});
