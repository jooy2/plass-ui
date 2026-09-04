import { describe, expect, it } from 'vitest';
import { compareValues, keysBetween, nextSort, pageBounds } from '../../src/internal/data-table.js';

describe('compareValues', () => {
  it('orders numbers as numbers rather than as text', () => {
    // The bug this catches: `[2, 10]` sorted as strings puts 10 first.
    expect(compareValues(2, 10)).toBeLessThan(0);
  });

  it('orders dates by the moment they name', () => {
    expect(compareValues(new Date(2026, 0, 1), new Date(2026, 5, 1))).toBeLessThan(0);
  });

  it('orders booleans with false first', () => {
    expect(compareValues(false, true)).toBeLessThan(0);
  });

  it('orders strings the way the language does rather than by code point', () => {
    // `'a' < 'B'` is false by code point, which puts every capitalised word
    // above every lower-case one.
    expect(compareValues('apple', 'Banana')).toBeLessThan(0);
  });

  it('puts nothing last, whichever way round it is asked', () => {
    expect(compareValues(null, 5)).toBeGreaterThan(0);
    expect(compareValues(5, null)).toBeLessThan(0);
    expect(compareValues(undefined, 5)).toBeGreaterThan(0);
    expect(compareValues('', 5)).toBeGreaterThan(0);
  });

  it('leaves two missing values equal', () => {
    expect(compareValues(null, undefined)).toBe(0);
  });
});

describe('nextSort', () => {
  it('starts a column ascending', () => {
    expect(nextSort(null, 'name')).toEqual({ key: 'name', direction: 'asc' });
  });

  it('turns an ascending column round', () => {
    expect(nextSort({ key: 'name', direction: 'asc' }, 'name')).toEqual({
      key: 'name',
      direction: 'desc'
    });
  });

  it('puts the rows back on the third press', () => {
    // The order the rows arrived in is information, and a table that can never
    // be put back has thrown it away.
    expect(nextSort({ key: 'name', direction: 'desc' }, 'name')).toBeNull();
  });

  it('starts a different column ascending rather than inheriting the direction', () => {
    expect(nextSort({ key: 'name', direction: 'desc' }, 'total')).toEqual({
      key: 'total',
      direction: 'asc'
    });
  });
});

describe('keysBetween', () => {
  const keys = ['a', 'b', 'c', 'd'];

  it('takes both ends of the range', () => {
    expect(keysBetween(keys, 'b', 'd')).toEqual(['b', 'c', 'd']);
  });

  it('reads the same range dragged upwards', () => {
    expect(keysBetween(keys, 'd', 'b')).toEqual(['b', 'c', 'd']);
  });

  it('is one row when both ends are the same row', () => {
    expect(keysBetween(keys, 'c', 'c')).toEqual(['c']);
  });

  it('selects nothing when an end is no longer there', () => {
    // The anchor can legitimately have been filtered away between two clicks.
    expect(keysBetween(keys, 'z', 'c')).toEqual([]);
  });
});

describe('pageBounds', () => {
  it('slices the page asked for', () => {
    expect(pageBounds(25, 2, 10)).toEqual([10, 20]);
  });

  it('stops the last page at the end of the rows', () => {
    expect(pageBounds(25, 3, 10)).toEqual([20, 25]);
  });

  it('shows the last page when the page asked for has gone past the end', () => {
    // The usual way: a filter shortened the list under a reader on page nine.
    expect(pageBounds(25, 9, 10)).toEqual([20, 25]);
  });

  it('shows the first page when the page asked for is below one', () => {
    expect(pageBounds(25, 0, 10)).toEqual([0, 10]);
  });

  it('has one empty page rather than none when there are no rows', () => {
    expect(pageBounds(0, 1, 10)).toEqual([0, 0]);
  });
});
