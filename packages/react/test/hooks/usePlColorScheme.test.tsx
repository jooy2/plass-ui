/**
 * The theme is a document attribute rather than React state, so these assert
 * against `<html>` — which is also where the failure would be visible.
 *
 * `prefers-color-scheme` is the browser's answer rather than the document's, so
 * `system` is exercised through Playwright's media emulation (the `emulateMedia`
 * command registered in `vitest.config.ts`). The document and the storage are
 * put back between tests, because both outlive a single render and the browser
 * is shared with every other file in the run.
 */
import { commands } from 'vitest/browser';
import { afterAll, afterEach, beforeEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlColorSchemeScript, usePlColorScheme, type PlColorScheme } from 'plass-ui';

const DEFAULT_KEY = 'plass-color-scheme';

const root = () => document.documentElement;

/**
 * A fresh storage key per test, and the reason is a real property of the hook:
 * the store behind it is created **once per key** and keeps the choice for as
 * long as the page lives, which is exactly what makes two toggles on one page
 * agree. Reusing one key here would leave each test starting from whatever the
 * one before it chose, and half of them would pass without asserting anything.
 */
let keys = 0;
let KEY = DEFAULT_KEY;

beforeEach(async () => {
  keys += 1;
  KEY = `plass-scheme-test-${keys}`;
  localStorage.removeItem(KEY);
  localStorage.removeItem(DEFAULT_KEY);
  root().classList.remove('light', 'dark');
  delete root().dataset.theme;
  await commands.emulateMedia({ colorScheme: 'light' });
});

afterEach(() => {
  localStorage.removeItem(KEY);
  localStorage.removeItem(DEFAULT_KEY);
  root().classList.remove('light', 'dark');
  delete root().dataset.theme;
});

afterAll(async () => {
  await commands.emulateMedia({ colorScheme: 'no-preference' });
});

function Probe({ storageKey }: { storageKey?: string } = {}) {
  const { scheme, resolved, setScheme, toggle } = usePlColorScheme({
    storageKey: storageKey ?? KEY
  });

  return (
    <div>
      <span data-testid="scheme">{scheme}</span>
      <span data-testid="resolved">{resolved}</span>
      <button type="button" onClick={toggle}>
        Toggle
      </button>
      {(['light', 'dark', 'system'] as PlColorScheme[]).map((value) => (
        <button key={value} type="button" onClick={() => setScheme(value)}>
          {value}
        </button>
      ))}
    </div>
  );
}

const read = (id: string) => document.querySelector(`[data-testid="${id}"]`)!.textContent;

describe('usePlColorScheme', () => {
  describe('following the platform', () => {
    it('starts on system with nothing stored', async () => {
      await render(<Probe />);

      expect(read('scheme')).toBe('system');
    });

    it('resolves system against prefers-color-scheme', async () => {
      await commands.emulateMedia({ colorScheme: 'dark' });

      await render(<Probe />);

      await expect.poll(() => read('resolved')).toBe('dark');
    });

    it('follows the platform changing under it', async () => {
      const screen = await render(<Probe />);

      await expect.poll(() => read('resolved')).toBe('light');

      await commands.emulateMedia({ colorScheme: 'dark' });

      await expect.poll(() => read('resolved')).toBe('dark');

      screen.unmount();
    });

    it('writes nothing onto the document while it is following', async () => {
      await render(<Probe />);

      // `system` is the absence of a choice rather than a third theme, so the
      // question stays with `prefers-color-scheme`.
      await expect.poll(() => root().dataset.theme).toBeUndefined();
      expect(root().classList.contains('light')).toBe(false);
      expect(root().classList.contains('dark')).toBe(false);
    });
  });

  describe('choosing one', () => {
    it('writes both the attribute and the class', async () => {
      const screen = await render(<Probe />);

      await screen.getByRole('button', { name: 'dark' }).click();

      await expect.poll(() => root().dataset.theme).toBe('dark');
      expect(root().classList.contains('dark')).toBe(true);
      // The attribute is what this library's tokens read; the class is what a
      // consumer's own Tailwind `dark:` utilities read.
      expect(root().classList.contains('light')).toBe(false);
    });

    it('keeps the choice', async () => {
      const screen = await render(<Probe />);

      await screen.getByRole('button', { name: 'dark' }).click();

      await expect.poll(() => localStorage.getItem(KEY)).toBe('dark');
    });

    it('reads the choice back on the next mount', async () => {
      localStorage.setItem(KEY, 'dark');

      await render(<Probe />);

      await expect.poll(() => read('scheme')).toBe('dark');
      await expect.poll(() => root().dataset.theme).toBe('dark');
    });

    it('hands the question back on system', async () => {
      const screen = await render(<Probe />);

      await screen.getByRole('button', { name: 'dark' }).click();
      await expect.poll(() => root().dataset.theme).toBe('dark');

      await screen.getByRole('button', { name: 'system' }).click();

      await expect.poll(() => root().dataset.theme).toBeUndefined();
      expect(read('scheme')).toBe('system');
    });

    it('ignores a stored value that is not one of the three', async () => {
      localStorage.setItem(KEY, 'sepia');

      await render(<Probe />);

      expect(read('scheme')).toBe('system');
    });

    it('scopes the choice to its own storage key', async () => {
      localStorage.setItem(`${KEY}-other-app`, 'dark');

      await render(<Probe storageKey={`${KEY}-other-app`} />);

      await expect.poll(() => read('scheme')).toBe('dark');

      localStorage.removeItem(`${KEY}-other-app`);
    });
  });

  describe('toggle', () => {
    it('goes to the opposite of what is painted', async () => {
      await commands.emulateMedia({ colorScheme: 'dark' });

      const screen = await render(<Probe />);

      await expect.poll(() => read('resolved')).toBe('dark');

      await screen.getByRole('button', { name: 'Toggle' }).click();

      // The first press on a system-dark page gives light, which is what a
      // reader pressing a toggle means.
      await expect.poll(() => read('scheme')).toBe('light');
    });

    it('goes back again', async () => {
      const screen = await render(<Probe />);

      await screen.getByRole('button', { name: 'Toggle' }).click();
      await expect.poll(() => read('resolved')).toBe('dark');

      await screen.getByRole('button', { name: 'Toggle' }).click();
      await expect.poll(() => read('resolved')).toBe('light');
    });
  });

  describe('two toggles on one page', () => {
    it('agree with each other', async () => {
      const screen = await render(
        <div>
          <Probe />
          <Probe />
        </div>
      );

      await screen.getByRole('button', { name: 'dark' }).first().click();

      await expect
        .poll(() =>
          Array.from(document.querySelectorAll('[data-testid="scheme"]')).map((n) => n.textContent)
        )
        .toEqual(['dark', 'dark']);
    });
  });
});

describe('PlColorSchemeScript', () => {
  it('renders an inline script and nothing else', async () => {
    const screen = await render(<PlColorSchemeScript />);

    const script = screen.container.querySelector('script')!;

    expect(script).toBeTruthy();
    expect(script.textContent).toContain(DEFAULT_KEY);
  });

  it('carries a nonce when it is given one', async () => {
    const screen = await render(<PlColorSchemeScript nonce="abc123" />);

    expect(screen.container.querySelector('script')!.getAttribute('nonce')).toBe('abc123');
  });

  it('paints the stored choice when it runs', async () => {
    localStorage.setItem(DEFAULT_KEY, 'dark');

    const screen = await render(<PlColorSchemeScript />);

    // Running the script's own text is the point of the test: it is a copy of
    // `applyColorScheme` written out as a string, and a copy that has drifted
    // would paint one theme in the first frame and swap to the other.
    window.eval(screen.container.querySelector('script')!.textContent!);

    expect(root().dataset.theme).toBe('dark');
    expect(root().classList.contains('dark')).toBe(true);
  });

  it('agrees with the hook about what nothing stored means', async () => {
    const screen = await render(<PlColorSchemeScript />);

    window.eval(screen.container.querySelector('script')!.textContent!);

    expect(root().dataset.theme).toBeUndefined();

    await screen.unmount();
    await render(<Probe />);

    expect(read('scheme')).toBe('system');
  });

  it('takes its own storage key and default', async () => {
    const screen = await render(
      <PlColorSchemeScript storageKey={`${KEY}-other-app`} defaultScheme="dark" />
    );

    window.eval(screen.container.querySelector('script')!.textContent!);

    expect(root().dataset.theme).toBe('dark');
  });
});
