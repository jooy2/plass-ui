import { describe, expect, it } from 'vitest';
import { headingLevelOf } from '../../src/internal/heading';

describe('headingLevelOf', () => {
  it('passes the six levels a heading has', () => {
    expect([1, 2, 3, 4, 5, 6].map(headingLevelOf)).toEqual([1, 2, 3, 4, 5, 6]);
  });

  it('turns away anything else, which a JavaScript caller can still pass', () => {
    for (const value of [
      0,
      7,
      -1,
      2.5,
      Number.NaN,
      Number.POSITIVE_INFINITY,
      '2',
      null,
      undefined
    ]) {
      expect(headingLevelOf(value)).toBeUndefined();
    }
  });
});
