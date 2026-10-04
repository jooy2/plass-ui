/**
 * That a page rendered on a server hydrates in a browser whose locale is not
 * the server's.
 *
 * A test of a *contract* rather than of a component: every component that
 * formats a number or a date, sorts text or changes its case reads a locale, and
 * the way this breaks is one of them reaching the runtime's own default while a
 * server render is being hydrated. The server is `en-US` and the browser is
 * something else, the markup disagrees about one character, and React throws
 * the server's tree away.
 *
 * Both runtimes are this one, so the default is emulated: `Intl.NumberFormat`,
 * `Intl.DateTimeFormat`, `localeCompare` and `toLocaleUpperCase` answer a call
 * that names no locale in whatever `runtime` says at the time.
 */
import type * as React from 'react';
import { act } from 'react';
import { hydrateRoot, type Root } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAnimateCounter,
  PlAvatar,
  PlCalendar,
  PlDataTable,
  PlDatePicker,
  PlassProvider,
  PlProgressLinear
} from 'plass-ui';

/** What a call that names no locale is answered in. */
let runtime = 'en-US';

const NativeNumberFormat = Intl.NumberFormat;
const NativeDateTimeFormat = Intl.DateTimeFormat;
const nativeLocaleCompare = String.prototype.localeCompare;
const nativeToLocaleUpperCase = String.prototype.toLocaleUpperCase;

type Formatter = new (locales?: Intl.LocalesArgument, options?: object) => object;

/**
 * An `Intl` constructor whose default is `runtime`.
 *
 * A formatter built with no locale asks for the default every time it is used
 * rather than once when it is built. `internal/format.ts` and Base UI both
 * cache their formatters, and one built during the server pass would otherwise
 * go on answering in the server's locale during the browser's, which two
 * separate runtimes never do.
 */
function withRuntimeDefault(Native: Formatter): Formatter {
  function Emulated(locales?: Intl.LocalesArgument, options?: object): object {
    if (locales !== undefined) {
      return new Native(locales, options);
    }

    return new Proxy(new Native(runtime, options), {
      get(_, key) {
        const live = new Native(runtime, options) as Record<PropertyKey, unknown>;
        const value = live[key];

        return typeof value === 'function' ? value.bind(live) : value;
      }
    });
  }

  Object.setPrototypeOf(Emulated, Native);
  Emulated.prototype = Native.prototype;

  return Emulated as unknown as Formatter;
}

beforeEach(() => {
  runtime = 'en-US';

  const intl = Intl as unknown as Record<string, unknown>;

  intl.NumberFormat = withRuntimeDefault(NativeNumberFormat);
  intl.DateTimeFormat = withRuntimeDefault(NativeDateTimeFormat);
  String.prototype.localeCompare = function localeCompare(
    this: string,
    that: string,
    locales?: Intl.LocalesArgument,
    options?: Intl.CollatorOptions
  ) {
    return nativeLocaleCompare.call(this, that, locales ?? runtime, options);
  } as typeof String.prototype.localeCompare;
  String.prototype.toLocaleUpperCase = function toLocaleUpperCase(
    this: string,
    locales?: Intl.LocalesArgument
  ) {
    return nativeToLocaleUpperCase.call(this, locales ?? runtime);
  } as typeof String.prototype.toLocaleUpperCase;
});

afterEach(() => {
  const intl = Intl as unknown as Record<string, unknown>;

  intl.NumberFormat = NativeNumberFormat;
  intl.DateTimeFormat = NativeDateTimeFormat;
  String.prototype.localeCompare = nativeLocaleCompare;
  String.prototype.toLocaleUpperCase = nativeToLocaleUpperCase;
});

const hosts: { host: HTMLElement; root: Root }[] = [];

afterEach(async () => {
  for (const { host, root } of hosts.splice(0)) {
    await act(async () => root.unmount());
    host.remove();
  }
});

/**
 * Renders `ui` on an `en-US` server, then hydrates it in a browser whose own
 * locale is `browser`, and hands back the page and what React complained of.
 */
async function hydrateIn(browser: string, ui: React.ReactElement) {
  runtime = 'en-US';

  const host = document.createElement('div');
  const onRecoverableError = vi.fn();

  host.innerHTML = renderToString(ui);
  document.body.append(host);

  const served = host.textContent ?? '';

  runtime = browser;

  const root = await act(async () => hydrateRoot(host, ui, { onRecoverableError }));

  hosts.push({ host, root });

  return { host, served, onRecoverableError };
}

const september4 = new Date(2026, 8, 4);

describe('a server render hydrated in another locale', () => {
  it('hydrates a number in the server’s format and then writes it in the browser’s', async () => {
    const { host, served, onRecoverableError } = await hydrateIn(
      'de-DE',
      <div>
        <PlAnimateCounter value={12345} trigger="manual" />
        <PlProgressLinear value={42} showValue label="Upload" />
      </div>
    );

    expect(served).toContain('12,345');
    expect(served).toContain('42%');
    expect(onRecoverableError).not.toHaveBeenCalled();

    const counter = host.querySelector('[data-plass-animation="counter"]')!;

    expect(counter.querySelector(':scope > span:not([aria-hidden])')?.textContent).toBe('12.345');
    expect(host.textContent).toContain(
      new NativeNumberFormat('de-DE', { style: 'percent' }).format(0.42)
    );
  });

  it('hydrates a date in the server’s format and then writes it in the browser’s', async () => {
    const { host, served, onRecoverableError } = await hydrateIn(
      'de-DE',
      <div>
        <PlDatePicker label="Due" defaultValue={september4} />
        <PlCalendar defaultValue={september4} />
      </div>
    );

    expect(served).toContain('Sep 4, 2026');
    expect(onRecoverableError).not.toHaveBeenCalled();
    expect(host.textContent).toContain('04.09.2026');

    // A German week starts on Monday, which is the other half of the date path:
    // the first column is decided by the locale before any day is written.
    const first = host.querySelector('[role="columnheader"]');

    expect(first?.getAttribute('aria-label')).toBe('Montag');
  });

  it('hydrates sorted rows in the server’s order and then sorts them the browser’s way', async () => {
    const rows = [{ name: 'Zoe' }, { name: 'Ösi' }, { name: 'Anna' }];
    const { host, onRecoverableError } = await hydrateIn(
      'sv-SE',
      <PlDataTable
        label="People"
        rows={rows}
        getRowKey={(row) => row.name}
        columns={[{ key: 'name', header: 'Name' }]}
        defaultSort={{ key: 'name', direction: 'asc' }}
      />
    );

    const names = () =>
      Array.from(host.querySelectorAll('tbody tr'), (row) => row.textContent?.trim());

    expect(onRecoverableError).not.toHaveBeenCalled();
    // Swedish puts `Ö` after `Z`; English sorts it with the `O`s.
    expect(names()).toEqual(['Anna', 'Zoe', 'Ösi']);
  });

  it('hydrates initials in the server’s case and then in the browser’s', async () => {
    const { host, served, onRecoverableError } = await hydrateIn(
      'tr-TR',
      <PlAvatar name="ilker" />
    );

    expect(served).toContain('I');
    expect(onRecoverableError).not.toHaveBeenCalled();
    expect(host.textContent).toContain('İ');
  });

  it('keeps a locale a provider named, on the server and after it', async () => {
    const { host, served, onRecoverableError } = await hydrateIn(
      'de-DE',
      <PlassProvider locale="fr-FR">
        <PlDatePicker label="Due" defaultValue={september4} />
      </PlassProvider>
    );

    const french = new NativeDateTimeFormat('fr-FR', { dateStyle: 'medium' }).format(september4);

    expect(served).toContain(french);
    expect(onRecoverableError).not.toHaveBeenCalled();
    expect(host.textContent).toContain(french);
  });

  it('keeps a locale a component was given, on the server and after it', async () => {
    const { host, served, onRecoverableError } = await hydrateIn(
      'de-DE',
      <PlDatePicker label="Due" defaultValue={september4} locale="ja-JP" />
    );

    const japanese = new NativeDateTimeFormat('ja-JP', { dateStyle: 'medium' }).format(september4);

    expect(served).toContain(japanese);
    expect(onRecoverableError).not.toHaveBeenCalled();
    expect(host.textContent).toContain(japanese);
  });
});

describe('a page rendered only in the browser', () => {
  it('writes in the browser’s locale from the first paint', async () => {
    runtime = 'de-DE';

    const screen = await render(
      <div>
        <PlAnimateCounter value={12345} trigger="manual" />
        <PlDatePicker label="Due" defaultValue={september4} />
      </div>
    );

    // Read straight after the first commit, before any effect could have
    // switched anything: there is no hydration here, so nothing is pinned.
    const text = screen.container.textContent ?? '';

    expect(text).toContain('12.345');
    expect(text).toContain('04.09.2026');
  });
});
