/**
 * `prefers-reduced-motion` is the browser's answer rather than the document's,
 * so this drives it through Playwright — the `emulateMedia` command registered
 * in `vitest.config.ts`. Asserting the hook against `window.matchMedia` would
 * only be asserting that two reads of the same thing agree.
 *
 * The preference is put back to `no-preference` afterwards, because the browser
 * is shared with every other file in the run and half of them animate.
 */
import { commands } from 'vitest/browser';
import { afterAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { usePlReducedMotion } from 'plass-ui';

afterAll(async () => {
  await commands.emulateMedia({ reducedMotion: 'no-preference' });
});

function Probe() {
  return <span data-testid="answer">{String(usePlReducedMotion())}</span>;
}

const answer = () => document.querySelector('[data-testid="answer"]')!.textContent;

describe('usePlReducedMotion', () => {
  it('is false when the reader has expressed no preference', async () => {
    await commands.emulateMedia({ reducedMotion: 'no-preference' });

    await render(<Probe />);

    await expect.poll(answer).toBe('false');
  });

  it('is true when the reader has asked for less movement', async () => {
    await commands.emulateMedia({ reducedMotion: 'reduce' });

    await render(<Probe />);

    await expect.poll(answer).toBe('true');
  });

  it('re-renders when the preference changes under it', async () => {
    await commands.emulateMedia({ reducedMotion: 'no-preference' });

    const screen = await render(<Probe />);

    await expect.poll(answer).toBe('false');

    await commands.emulateMedia({ reducedMotion: 'reduce' });

    await expect.poll(answer).toBe('true');

    await commands.emulateMedia({ reducedMotion: 'no-preference' });

    await expect.poll(answer).toBe('false');

    screen.unmount();
  });
});
