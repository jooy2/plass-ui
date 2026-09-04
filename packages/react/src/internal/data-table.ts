/**
 * The arithmetic a data table does before it draws anything.
 *
 * Sorting, paging and range selection are decisions about values rather than
 * about the DOM, so they are here as plain functions: they can be read without
 * a browser, tested without one, and — the reason that matters — they are the
 * same three answers the Flutter build gives, which is what keeps a table
 * sorted one way on the web from being sorted another way in an app.
 */
import type * as React from 'react';

/** Which way a column runs when it is sorted. */
export type PlassSortDirection = 'asc' | 'desc';

/** A column and the direction it is sorted in. */
export interface PlassSort {
  /** The column's `key`. */
  key: string;
  /** Which way it runs. */
  direction: PlassSortDirection;
}

/**
 * Puts two cell values in order.
 *
 * Numbers and dates compare as themselves, strings compare the way the reader's
 * language orders them, and everything else falls back to its text. Two rules
 * carry the weight:
 *
 * **Nothing sorts last, in both directions.** A column of amounts with three
 * blanks in it is a column whose blanks are not the smallest amounts, and a
 * reader who reversed the sort to find the largest should not be handed the
 * empty ones instead. So the answer for a missing value is decided here, before
 * the direction is applied, and the caller flips only the rest.
 *
 * **Strings compare with `localeCompare`.** `'a' < 'B'` is false by code point,
 * which puts every capitalised word above every lower-case one and sorts `Ösi`
 * after `Zoe`. A list of names a reader cannot scan is a list that was sorted
 * for the machine.
 */
export function compareValues(a: unknown, b: unknown): number {
  const aMissing = a === null || a === undefined || a === '';
  const bMissing = b === null || b === undefined || b === '';

  if (aMissing || bMissing) {
    return aMissing && bMissing ? 0 : aMissing ? 1 : -1;
  }

  if (typeof a === 'number' && typeof b === 'number') {
    return a - b;
  }

  if (typeof a === 'boolean' && typeof b === 'boolean') {
    return Number(a) - Number(b);
  }

  if (a instanceof Date && b instanceof Date) {
    return a.getTime() - b.getTime();
  }

  return String(a).localeCompare(String(b));
}

/**
 * What pressing a column heading does next.
 *
 * Ascending, then descending, then **off** — a third press puts the rows back
 * in the order they arrived in. That order is information: it is usually the
 * order the server chose, and a table that can never be put back has thrown it
 * away. Pressing a different column starts that column ascending rather than
 * inheriting the direction of the one before it.
 */
export function nextSort(current: PlassSort | null, key: string): PlassSort | null {
  if (current === null || current.key !== key) {
    return { key, direction: 'asc' };
  }

  return current.direction === 'asc' ? { key, direction: 'desc' } : null;
}

/**
 * The keys of every row between two of them, inclusive, in the order the rows
 * are currently in.
 *
 * What a shift-click ticks. "Currently in" is the point: a reader dragging a
 * range down a sorted table means the rows they can see, not the rows the
 * unsorted array happens to hold between those two indices.
 *
 * An unknown key selects nothing rather than throwing, because the anchor can
 * legitimately have been filtered away between the two clicks.
 */
export function keysBetween(
  keys: readonly React.Key[],
  from: React.Key,
  to: React.Key
): React.Key[] {
  const start = keys.indexOf(from);
  const end = keys.indexOf(to);

  if (start === -1 || end === -1) {
    return [];
  }

  return start <= end ? keys.slice(start, end + 1) : keys.slice(end, start + 1);
}

/**
 * Which rows a page shows, as a `[start, end)` pair into the sorted set.
 *
 * Clamped rather than trusted: a page number that has gone past the end — the
 * usual way being a filter that shortened the list under a reader sitting on
 * page nine — shows the last page instead of an empty table with a pager that
 * says there is something there.
 */
export function pageBounds(total: number, page: number, pageSize: number): [number, number] {
  const pages = Math.max(1, Math.ceil(total / pageSize));
  const current = Math.min(Math.max(1, Math.trunc(page)), pages);
  const start = (current - 1) * pageSize;

  return [start, Math.min(start + pageSize, total)];
}
