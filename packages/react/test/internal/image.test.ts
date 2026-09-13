import { describe, expect, it } from 'vitest';
import {
  elementFractions,
  isSideways,
  objectPosition,
  positionFractions,
  quartersOf
} from '../../src/internal/image';

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

describe('positionFractions', () => {
  it('reads a side as its own axis and leaves the other in the middle', () => {
    expect(positionFractions('top')).toEqual([0.5, 0]);
    expect(positionFractions('right')).toEqual([1, 0.5]);
  });

  it('reads a corner in either order', () => {
    expect(positionFractions('bottom left')).toEqual([0, 1]);
    expect(positionFractions('left bottom')).toEqual([0, 1]);
  });

  it('reads percentages across, then down', () => {
    expect(positionFractions('30% 20%')).toEqual([0.3, 0.2]);
    expect(positionFractions('left 75%')).toEqual([0, 0.75]);
  });

  it('reads the centre as the middle of both', () => {
    expect(positionFractions('center')).toEqual([0.5, 0.5]);
  });

  it('gives up on anything that is not a keyword or a percentage', () => {
    expect(positionFractions('10px 20px')).toBeNull();
    expect(positionFractions('left 4rem')).toBeNull();
  });
});

describe('elementFractions', () => {
  it('leaves an upright, unmirrored picture as it is', () => {
    expect(elementFractions([0.3, 0.2], 0, false, false)).toEqual([0.3, 0.2]);
  });

  it('undoes a mirror on the axis it mirrors', () => {
    expect(elementFractions([0.25, 0.1], 0, true, false)).toEqual([0.75, 0.1]);
    expect(elementFractions([0.25, 0.1], 0, false, true)).toEqual([0.25, 0.9]);
  });

  it('undoes a turn a quarter at a time', () => {
    // One quarter clockwise lays the element's left edge along the top of the
    // screen, so the top of what is shown is the left of the element.
    expect(elementFractions([0.5, 0], 1, false, false)).toEqual([0, 0.5]);
    expect(elementFractions([0.5, 0], 2, false, false)).toEqual([0.5, 1]);
    expect(elementFractions([0.5, 0], 3, false, false)).toEqual([1, 0.5]);
  });

  it('undoes the mirror before the turn', () => {
    // The shown top-left corner of a picture mirrored across and turned a
    // quarter is the element's own top-left corner.
    expect(elementFractions([0, 0], 1, true, false)).toEqual([0, 0]);
  });
});

describe('objectPosition', () => {
  it('writes two percentages, rounded to two decimals', () => {
    expect(objectPosition('top left', 0, 'none')).toBe('0% 0%');
    expect(objectPosition('33.3333% 20%', 0, 'none')).toBe('33.33% 20%');
  });

  it('passes a value it cannot read through untouched', () => {
    expect(objectPosition('10px 20px', 1, 'both')).toBe('10px 20px');
  });
});
