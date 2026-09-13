/**
 * The date arithmetic the calendars and the pickers stand on.
 *
 * `test/internal/date_test.dart` holds the same tables, row for row, because
 * the two builds have to give the same answers. A day is written as
 * `[year, month, day]` with the month counted from 1 in both files, so the rows
 * read the same, and converted to a `Date` month here.
 */
import { describe, expect, it } from 'vitest';
import {
  addDays,
  addMonths,
  addYears,
  calendarWeeks,
  compareDay,
  daysInMonth,
  isMonthOutside,
  isYearOutside,
  makeDate,
  toISODate,
  yearPageStart
} from '../../src/internal/date.js';
import type { PlassWeekday } from '../../src/types.js';

type Day = [year: number, month: number, day: number];

function day([year, month, date]: Day): Date {
  return makeDate(year, month - 1, date);
}

function parts(date: Date): Day {
  return [date.getFullYear(), date.getMonth() + 1, date.getDate()];
}

describe('addMonths', () => {
  const rows: [from: Day, amount: number, to: Day][] = [
    [[2026, 1, 31], 1, [2026, 2, 28]],
    [[2024, 1, 31], 1, [2024, 2, 29]],
    [[2026, 3, 31], -1, [2026, 2, 28]],
    [[2026, 12, 31], 2, [2027, 2, 28]],
    [[2026, 7, 15], -7, [2025, 12, 15]],
    [[2026, 5, 31], 1, [2026, 6, 30]],
    [[2026, 8, 31], -12, [2025, 8, 31]],
    [[0, 1, 31], -1, [-1, 12, 31]]
  ];

  it.each(rows)('moves %j by %i months to %j, clamping the day', (from, amount, to) => {
    expect(parts(addMonths(day(from), amount))).toEqual(to);
  });

  it('keeps the time of day', () => {
    const moved = addMonths(new Date(2026, 0, 31, 9, 30, 15), 1);

    expect([moved.getHours(), moved.getMinutes(), moved.getSeconds()]).toEqual([9, 30, 15]);
  });
});

describe('addYears', () => {
  const rows: [from: Day, amount: number, to: Day][] = [
    [[2024, 2, 29], 1, [2025, 2, 28]],
    [[2024, 2, 29], 4, [2028, 2, 29]],
    [[2024, 2, 29], -100, [1924, 2, 29]]
  ];

  it.each(rows)('moves %j by %i years to %j', (from, amount, to) => {
    expect(parts(addYears(day(from), amount))).toEqual(to);
  });
});

describe('addDays', () => {
  const rows: [from: Day, amount: number, to: Day][] = [
    [[2026, 12, 31], 1, [2027, 1, 1]],
    [[2026, 3, 1], -1, [2026, 2, 28]],
    [[2024, 3, 1], -1, [2024, 2, 29]],
    [[2026, 7, 27], 7, [2026, 8, 3]]
  ];

  it.each(rows)('moves %j by %i days to %j', (from, amount, to) => {
    expect(parts(addDays(day(from), amount))).toEqual(to);
  });
});

describe('daysInMonth', () => {
  const rows: [year: number, month: number, days: number][] = [
    [2024, 2, 29],
    [2026, 2, 28],
    [1900, 2, 28],
    [2000, 2, 29],
    [2026, 4, 30],
    [2026, 12, 31]
  ];

  it.each(rows)('gives %i-%i %i days', (year, month, days) => {
    expect(daysInMonth(year, month - 1)).toBe(days);
  });
});

describe('calendarWeeks', () => {
  // The weekday is counted from Sunday as 0, as `PlassWeekday` is in both builds.
  const rows: [month: Day, weekStartsOn: PlassWeekday, first: Day, last: Day][] = [
    [[2026, 7, 1], 0, [2026, 6, 28], [2026, 8, 8]],
    [[2026, 7, 1], 1, [2026, 6, 29], [2026, 8, 9]],
    [[2026, 7, 1], 6, [2026, 6, 27], [2026, 8, 7]],
    [[2026, 2, 1], 0, [2026, 2, 1], [2026, 3, 14]],
    [[2026, 2, 1], 1, [2026, 1, 26], [2026, 3, 8]]
  ];

  it.each(rows)('starts %j on weekday %i at %j and ends it at %j', (month, start, first, last) => {
    const weeks = calendarWeeks(day(month), start);

    expect(weeks).toHaveLength(6);
    expect(weeks.every((week) => week.length === 7)).toBe(true);
    expect(parts(weeks[0][0])).toEqual(first);
    expect(parts(weeks[5][6])).toEqual(last);
    expect(weeks[0][0].getDay()).toBe(start);
  });
});

describe('yearPageStart', () => {
  const rows: [year: number, start: number][] = [
    [2026, 2016],
    [2016, 2016],
    [2027, 2016],
    [2028, 2028],
    [11, 0],
    [0, 0],
    [-1, -12],
    [-12, -12],
    [-13, -24]
  ];

  it.each(rows)('puts %i on the page that starts at %i', (year, start) => {
    expect(yearPageStart(year)).toBe(start);
  });
});

describe('compareDay', () => {
  it('reads the calendar day and not the clock', () => {
    expect(compareDay(new Date(2026, 6, 27, 23, 59), new Date(2026, 6, 27))).toBe(0);
    expect(compareDay(new Date(2026, 6, 26, 23, 59), new Date(2026, 6, 27))).toBeLessThan(0);
  });
});

describe('isMonthOutside and isYearOutside', () => {
  const min = day([2026, 7, 15]);
  const max = day([2026, 7, 15]);

  it('keeps the month a bound falls in', () => {
    expect(isMonthOutside(day([2026, 7, 1]), min, null)).toBe(false);
    expect(isMonthOutside(day([2026, 7, 31]), null, max)).toBe(false);
    expect(isMonthOutside(day([2026, 6, 30]), min, null)).toBe(true);
    expect(isMonthOutside(day([2026, 8, 1]), null, max)).toBe(true);
  });

  it('keeps the year a bound falls in', () => {
    expect(isYearOutside(day([2026, 1, 1]), min, max)).toBe(false);
    expect(isYearOutside(day([2025, 12, 31]), min, null)).toBe(true);
    expect(isYearOutside(day([2027, 1, 1]), null, max)).toBe(true);
  });
});

describe('toISODate', () => {
  it('writes the local day, whatever the clock says', () => {
    // A moment late in the evening is the next day in UTC anywhere east of
    // Greenwich, and early in the morning the day before anywhere west of it.
    expect(toISODate(new Date(2026, 6, 27, 23, 59))).toBe('2026-07-27');
    expect(toISODate(new Date(2026, 6, 27, 0, 1))).toBe('2026-07-27');
  });

  it('pads a short year to four digits', () => {
    expect(toISODate(makeDate(5, 0, 1))).toBe('0005-01-01');
  });
});
