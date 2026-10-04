/**
 * That a page rendered on a server hydrates in a browser whose clock reads a
 * different day.
 *
 * The companion of `server-locale.test.tsx`, for the clock rather than the
 * language. At 23:30 UTC on the 30th of September it is already the 1st of
 * October in Seoul, so a calendar a UTC server renders and a calendar a Seoul
 * browser renders disagree about the month, the day marked as today, and which
 * cell holds the tab stop. The server and the hydration read the clock in UTC,
 * and the browser's own zone takes over once hydration is done.
 *
 * The zone is moved with Chromium's DevTools protocol, the one way to move it
 * while a page is open, so this runs in Chromium alone. Both runtimes are this
 * one page, so whatever a runtime fixes when it starts is fixed here once, in
 * the server's zone: the library is imported only after the zone is UTC, and
 * the formatters it caches read the zone each time they are used.
 */
import type * as React from 'react';
import { act } from 'react';
import { hydrateRoot, type Root } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { commands, server } from 'vitest/browser';
import { afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import type { PlCalendar as Calendar } from 'plass-ui';

const chromium = server.browser === 'chromium';

let PlCalendar: typeof Calendar;

const NativeDateTimeFormat = Intl.DateTimeFormat;

/**
 * An `Intl.DateTimeFormat` that reads the zone when it is used rather than when
 * it is built, unless it was given one.
 *
 * `internal/format.ts` caches its formatters, and a formatter fixes the zone
 * when it is built. One built during the server pass would go on writing UTC
 * during the browser's, which two separate runtimes never do.
 */
function DateTimeFormatInTheCurrentZone(
  locales?: Intl.LocalesArgument,
  options?: Intl.DateTimeFormatOptions
): Intl.DateTimeFormat {
  if (options?.timeZone !== undefined) {
    return new NativeDateTimeFormat(locales, options);
  }

  return new Proxy(new NativeDateTimeFormat(locales, options), {
    get(_, key) {
      const live = new NativeDateTimeFormat(locales, options) as unknown as Record<
        PropertyKey,
        unknown
      >;
      const value = live[key];

      return typeof value === 'function' ? value.bind(live) : value;
    }
  });
}

Object.setPrototypeOf(DateTimeFormatInTheCurrentZone, NativeDateTimeFormat);
DateTimeFormatInTheCurrentZone.prototype = NativeDateTimeFormat.prototype;

const hosts: { host: HTMLElement; root: Root }[] = [];

beforeAll(async () => {
  if (!chromium) {
    return;
  }

  await inZone('UTC');
  ({ PlCalendar } = await import('plass-ui'));
});

beforeEach(() => {
  (Intl as unknown as Record<string, unknown>).DateTimeFormat = DateTimeFormatInTheCurrentZone;
});

afterEach(async () => {
  for (const { host, root } of hosts.splice(0)) {
    await act(async () => root.unmount());
    host.remove();
  }

  (Intl as unknown as Record<string, unknown>).DateTimeFormat = NativeDateTimeFormat;
  vi.useRealTimers();

  if (chromium) {
    await commands.emulateTimeZone('');
  }
});

async function inZone(timeZone: string): Promise<void> {
  await commands.emulateTimeZone(timeZone);
  // The emulation is what the test stands on, so it is checked rather than assumed.
  expect(Intl.DateTimeFormat().resolvedOptions().timeZone).toBe(timeZone);
}

/** Renders `ui` on a UTC server, then hydrates it in a Seoul browser. */
async function hydrateInSeoul(ui: React.ReactElement) {
  await inZone('UTC');

  const host = document.createElement('div');
  const onRecoverableError = vi.fn();

  host.innerHTML = renderToString(ui);
  document.body.append(host);

  const served = host.innerHTML;

  await inZone('Asia/Seoul');

  const root = await act(async () => hydrateRoot(host, ui, { onRecoverableError }));

  hosts.push({ host, root });

  return { host, served, onRecoverableError };
}

/** The accessible name of the day marked as today. */
function markedToday(host: HTMLElement): string | null {
  const marked = host.querySelectorAll('[aria-current="date"]');

  return marked.length === 1 ? marked[0].getAttribute('aria-label') : `${marked.length} marked`;
}

/** The accessible name of the day that holds the tab stop. */
function tabStop(host: HTMLElement): string | null {
  return host.querySelector('[role="gridcell"][tabindex="0"]')?.getAttribute('aria-label') ?? null;
}

const fullDate = (date: Date) =>
  new Intl.DateTimeFormat('en-US', { dateStyle: 'full' }).format(date);

describe.skipIf(!chromium)('a server render hydrated in another zone', () => {
  it('opens on the server’s month and moves to the browser’s once hydrated', async () => {
    vi.setSystemTime(new Date('2026-09-30T23:30:00Z'));

    const { host, served, onRecoverableError } = await hydrateInSeoul(<PlCalendar />);

    expect(served).toContain('September');
    expect(onRecoverableError).not.toHaveBeenCalled();
    expect(host.textContent).toContain('October');
    expect(markedToday(host)).toBe(fullDate(new Date(2026, 9, 1)));
  });

  it('marks the server’s today and moves the mark and the tab stop to the browser’s', async () => {
    vi.setSystemTime(new Date('2026-09-14T23:30:00Z'));

    const { host, onRecoverableError } = await hydrateInSeoul(<PlCalendar />);

    expect(onRecoverableError).not.toHaveBeenCalled();
    expect(markedToday(host)).toBe(fullDate(new Date(2026, 8, 15)));
    expect(tabStop(host)).toBe(fullDate(new Date(2026, 8, 15)));
  });
});

describe.skipIf(!chromium)('a calendar rendered only in the browser', () => {
  it('reads the browser’s clock from the first paint', async () => {
    vi.setSystemTime(new Date('2026-09-30T23:30:00Z'));
    await inZone('Asia/Seoul');

    const screen = await render(<PlCalendar />);
    const host = screen.container;

    expect(host.textContent).toContain('October');
    expect(markedToday(host)).toBe(fullDate(new Date(2026, 9, 1)));
  });
});
