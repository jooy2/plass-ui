/**
 * That the names the pickers write follow the runtime's time zone when it
 * changes while the page is open.
 *
 * Every day a picker names is a local midnight, so a formatter built in one
 * zone and used in another writes the wall clock of the wrong one: the 1st of a
 * month built in Seoul and written in Los Angeles is the last day of the month
 * before. The same goes for a date built at load and read after the zone has
 * moved west, which is still the evening before.
 *
 * The zone is moved with Chromium's DevTools protocol, the one way to move it
 * while a page is open, so this runs in Chromium alone. The library is imported
 * only once the zone is Seoul, so whatever it builds at load is built there.
 */
import { commands, server } from 'vitest/browser';
import { afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import type * as Library from 'plass-ui';
import type * as Dates from '../../src/internal/date.js';

const chromium = server.browser === 'chromium';

let PlCalendar: typeof Library.PlCalendar;
let monthLabels: typeof Dates.monthLabels;
let weekdayLabels: typeof Dates.weekdayLabels;

async function inZone(timeZone: string): Promise<void> {
  await commands.emulateTimeZone(timeZone);
  // The emulation is what the test stands on, so it is checked rather than assumed.
  expect(Intl.DateTimeFormat().resolvedOptions().timeZone).toBe(timeZone);
}

beforeAll(async () => {
  if (!chromium) {
    return;
  }

  await inZone('Asia/Seoul');
  ({ PlCalendar } = await import('plass-ui'));
  ({ monthLabels, weekdayLabels } = await import('../../src/internal/date.js'));
});

afterEach(async () => {
  if (chromium) {
    await commands.emulateTimeZone('');
  }
});

const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

/** What the column headers of a calendar's day grid are named, in order. */
function columnNames(host: HTMLElement): (string | null)[] {
  return [...host.querySelectorAll('[role="columnheader"]')].map((header) =>
    header.getAttribute('aria-label')
  );
}

describe.skipIf(!chromium)('a time zone that changes while the page is open', () => {
  it('names the weekdays from a Sunday in the zone they are read in', async () => {
    await inZone('America/Los_Angeles');

    expect(weekdayLabels('en-US', 0, 'long')).toEqual(weekdays);
  });

  it('names the months with formatters built for the new zone', async () => {
    await inZone('America/Los_Angeles');

    expect(monthLabels('en-US', 'long')).toEqual(months);

    await inZone('Asia/Seoul');

    expect(monthLabels('en-US', 'long')).toEqual(months);
  });

  it('heads a calendar with its own month and weekdays in either zone', async () => {
    await inZone('America/Los_Angeles');

    const west = await render(<PlCalendar locale="en-US" defaultMonth={new Date(2026, 8, 1)} />);

    expect(west.container.textContent).toContain('September');
    expect(columnNames(west.container)).toEqual(weekdays);

    await west.unmount();
    await inZone('Asia/Seoul');

    const east = await render(<PlCalendar locale="en-US" defaultMonth={new Date(2026, 8, 1)} />);

    expect(east.container.textContent).toContain('September');
    expect(columnNames(east.container)).toEqual(weekdays);
  });
});
