/**
 * These resize the runner's viewport rather than stubbing `matchMedia`, because
 * the claim the ladder makes is that it changes where Tailwind's `md:` changes
 * — and the only way to check that is to ask the same engine at the same width.
 *
 * The widths are `rem`, so every number here assumes a 16px root: 40rem is
 * 640px, 48rem is 768px, 64rem is 1024px, 80rem is 1280px.
 */
import { page } from 'vitest/browser';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { usePlBreakpoint, usePlBreakpointValue, type PlassResponsive } from 'plass-ui';

let initial: [number, number];

beforeAll(() => {
  initial = [window.innerWidth, window.innerHeight];
});

afterAll(async () => {
  await page.viewport(...initial);
});

function Rung() {
  return <span data-testid="answer">{usePlBreakpoint()}</span>;
}

function Value({ from }: { from: PlassResponsive<string> }) {
  return <span data-testid="answer">{String(usePlBreakpointValue(from))}</span>;
}

const answer = () => document.querySelector('[data-testid="answer"]')!.textContent;

/** Every rung named, so the resolved value *is* the current breakpoint. */
const complete = { xs: 'xs', sm: 'sm', md: 'md', lg: 'lg', xl: 'xl' };

describe('usePlBreakpoint', () => {
  it.each([
    [500, 'xs'],
    [700, 'sm'],
    [900, 'md'],
    [1100, 'lg'],
    [1400, 'xl']
  ])('is %s px wide → %s', async (width, rung) => {
    await page.viewport(width, 600);

    await render(<Rung />);

    await expect.poll(answer).toBe(rung);
  });

  it('answers the floor, not the ceiling, exactly on a boundary', async () => {
    // 768px is 48rem, the floor of `md`. A ladder that answered `sm` here would
    // be a rung out of step with every `md:` utility on the page.
    await page.viewport(768, 600);

    await render(<Rung />);

    await expect.poll(answer).toBe('md');
  });

  it('changes as the window does', async () => {
    await page.viewport(1400, 600);

    await render(<Rung />);

    await expect.poll(answer).toBe('xl');

    await page.viewport(500, 600);

    await expect.poll(answer).toBe('xs');
  });
});

describe('usePlBreakpointValue', () => {
  it('returns a bare value at every width', async () => {
    await page.viewport(500, 600);

    const screen = await render(<Value from="everywhere" />);

    await expect.poll(answer).toBe('everywhere');

    await page.viewport(1400, 600);

    await expect.poll(answer).toBe('everywhere');

    screen.unmount();
  });

  it.each([
    [500, 'xs'],
    [700, 'sm'],
    [900, 'md'],
    [1100, 'lg'],
    [1400, 'xl']
  ])('resolves a complete map to the rung at %s px', async (width, rung) => {
    await page.viewport(width, 600);

    await render(<Value from={complete} />);

    await expect.poll(answer).toBe(rung);
  });

  it('applies an entry from its own breakpoint up', async () => {
    await page.viewport(1100, 600);

    const screen = await render(<Value from={{ xs: 'narrow', md: 'wide' }} />);

    // `lg` names nothing, so `md` cascades up to it.
    await expect.poll(answer).toBe('wide');

    await page.viewport(700, 600);

    await expect.poll(answer).toBe('narrow');

    screen.unmount();
  });

  it('is undefined below every rung the map named', async () => {
    await page.viewport(500, 600);

    await render(<Value from={{ lg: 'only wide' }} />);

    // Not `'only wide'`, and not a guess: the caller wrote nothing for `xs`.
    await expect.poll(answer).toBe('undefined');
  });
});
