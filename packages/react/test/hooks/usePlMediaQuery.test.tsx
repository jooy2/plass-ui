/**
 * A media query hook is only worth anything if it answers again when the answer
 * changes, so these resize the runner's own viewport rather than asserting
 * against a string. `page.viewport` is what makes that possible; the initial
 * size is captured and put back afterwards, because the browser is shared with
 * every other file in the run.
 */
import { page } from 'vitest/browser';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { usePlMediaQuery } from 'plass-ui';

let initial: [number, number];

beforeAll(() => {
  initial = [window.innerWidth, window.innerHeight];
});

afterAll(async () => {
  await page.viewport(...initial);
});

/** The hook's answer, in the DOM where an assertion can read it. */
function Probe({ query }: { query: string }) {
  return <span data-testid="answer">{String(usePlMediaQuery(query))}</span>;
}

const answer = () => document.querySelector('[data-testid="answer"]')!.textContent;

describe('usePlMediaQuery', () => {
  it('answers a query that always matches', async () => {
    await render(<Probe query="(min-width: 0px)" />);

    expect(answer()).toBe('true');
  });

  it('answers a query that never matches', async () => {
    await render(<Probe query="(min-width: 99999px)" />);

    expect(answer()).toBe('false');
  });

  it('re-renders when the window stops matching', async () => {
    await page.viewport(900, 600);

    const screen = await render(<Probe query="(min-width: 800px)" />);

    await expect.poll(answer).toBe('true');

    await page.viewport(600, 600);

    await expect.poll(answer).toBe('false');

    // And back again, because a hook that only ever fires once looks identical
    // to a correct one in a test that only narrows.
    await page.viewport(900, 600);

    await expect.poll(answer).toBe('true');

    screen.unmount();
  });

  it('answers the new query when the query itself changes', async () => {
    await page.viewport(900, 600);

    const screen = await render(<Probe query="(min-width: 800px)" />);

    await expect.poll(answer).toBe('true');

    await screen.rerender(<Probe query="(min-width: 99999px)" />);

    await expect.poll(answer).toBe('false');
  });

  it('reads the same engine the stylesheet reads', async () => {
    await page.viewport(700, 600);

    await render(<Probe query="(width >= 40rem)" />);

    await expect.poll(answer).toBe(String(window.matchMedia('(width >= 40rem)').matches));
  });
});
