/**
 * What a chart's legend does with two series of the same name, and with a name
 * that is also some other series' place.
 *
 * Each legend entry used to be keyed by its series' name, or else its place, so
 * two series of one name shared a key: switching either off switched off both,
 * pointing at the second faded every series but the first, and React warned of
 * two children with one key in the legend and in the table under the chart. A
 * series called "1" shared its key with an unnamed series at index 1 in the
 * same way. A repeated name is now keyed by how many series before it have that
 * name, and a place never meets a name.
 *
 * A test of the frame and the pie together, because both keep the legend's
 * state in one hook, which is why it is here rather than under
 * `test/components/`.
 */
import { commands } from 'vitest/browser';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlLineChart, PlPieChart } from 'plass-ui';

const MONTHS = ['Jan', 'Feb'];

/** Whether each legend entry is switched on, in order. */
function switchedOn(container: HTMLElement): boolean[] {
  return [...container.querySelectorAll('li > button')].map(
    (entry) => entry.getAttribute('aria-pressed') === 'true'
  );
}

/** Whether each legend entry is drawn faded for another one's hover, in order. */
function fadedEntries(container: HTMLElement): boolean[] {
  return [...container.querySelectorAll('li > button')].map((entry) =>
    entry.className.includes('opacity-55')
  );
}

/** Every `console.error` React wrote about two children with one key. */
function keyWarnings(error: { mock: { calls: unknown[][] } }): string[] {
  return error.mock.calls
    .map((call) => call.map(String).join(' '))
    .filter((said) => said.includes('same key'));
}

beforeEach(async () => {
  await commands.parkPointer();
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe('a line chart legend', () => {
  // The tooltip is off because nothing loads the CSS here, so a card left over
  // the plot joins the flow and can catch the click meant for the legend.
  const chart = (names: readonly (string | undefined)[]) => (
    <PlLineChart
      label="Sessions"
      categories={MONTHS}
      tooltip={false}
      legend={{ align: 'start' }}
      series={names.map((name, index) => ({ name, data: [index + 1, index + 2] }))}
    />
  );

  /** The opacity each series is drawn at on the plot. */
  function marks(container: HTMLElement): (string | null)[] {
    return [...container.querySelectorAll('svg g[opacity]')].map((mark) =>
      mark.getAttribute('opacity')
    );
  }

  it('switches off one of two series of the same name and leaves the other on', async () => {
    const screen = await render(chart(['Revenue', 'Revenue', 'Cost']));
    const second = screen.getByRole('button', { name: 'Revenue' }).nth(1);

    await second.click();
    await expect.element(second).toHaveAttribute('aria-pressed', 'false');

    expect(switchedOn(screen.container)).toEqual([true, false, true]);
    expect(marks(screen.container)).toHaveLength(2);
  });

  it('fades every series but the second of two of the same name when it is pointed at', async () => {
    const screen = await render(chart(['Revenue', 'Revenue', 'Cost']));

    await screen.getByRole('button', { name: 'Revenue' }).nth(1).hover();
    await expect.poll(() => fadedEntries(screen.container)).toEqual([true, false, true]);

    expect(marks(screen.container)).toEqual(['0.28', '1', '0.28']);
  });

  it('switches a series called "1" and an unnamed one at index 1 on their own', async () => {
    // The unnamed series is listed by its place counted from one, as "2".
    const screen = await render(chart(['1', undefined, 'Cost']));
    const unnamed = screen.getByRole('button', { name: '2' });

    await unnamed.click();
    await expect.element(unnamed).toHaveAttribute('aria-pressed', 'false');

    expect(switchedOn(screen.container)).toEqual([true, false, true]);

    await screen.getByRole('button', { name: '1', exact: true }).click();

    expect(switchedOn(screen.container)).toEqual([false, false, true]);
  });

  it('keys the legend and the table under the chart without a warning', async () => {
    const error = vi.spyOn(console, 'error').mockImplementation(() => {});
    const screen = await render(chart(['Revenue', 'Revenue', '1', undefined]));

    await expect.element(screen.getByRole('button', { name: '4' })).toBeInTheDocument();
    expect(screen.container.querySelectorAll('thead th')).toHaveLength(5);

    expect(keyWarnings(error)).toEqual([]);
  });
});

describe('a pie chart legend', () => {
  const chart = (names: readonly string[]) => (
    <PlPieChart
      label="Traffic"
      categories={names}
      data={names.map((_, index) => 40 - index * 10)}
      tooltip={false}
      legend={{ align: 'start' }}
    />
  );

  /** The opacity each slice is drawn at. */
  function slices(container: HTMLElement): (string | null)[] {
    return [...container.querySelectorAll('svg path[fill]:not([fill="none"])')].map((slice) =>
      slice.getAttribute('opacity')
    );
  }

  it('switches off one of two slices of the same name and leaves the other on', async () => {
    const screen = await render(chart(['Search', 'Search', 'Email']));
    const second = screen.getByRole('button', { name: 'Search' }).nth(1);

    await second.click();
    await expect.element(second).toHaveAttribute('aria-pressed', 'false');

    expect(switchedOn(screen.container)).toEqual([true, false, true]);
    expect(slices(screen.container)).toHaveLength(2);
  });

  it('fades every slice but the second of two of the same name when it is pointed at', async () => {
    const screen = await render(chart(['Search', 'Search', 'Email']));

    await screen.getByRole('button', { name: 'Search' }).nth(1).hover();
    await expect.poll(() => fadedEntries(screen.container)).toEqual([true, false, true]);

    expect(slices(screen.container)).toEqual(['0.32', '1', '0.32']);
  });

  it('keys the legend without a warning', async () => {
    const error = vi.spyOn(console, 'error').mockImplementation(() => {});
    const screen = await render(chart(['Search', 'Search', 'Email']));

    await expect.element(screen.getByRole('button', { name: 'Email' })).toBeInTheDocument();

    expect(keyWarnings(error)).toEqual([]);
  });
});
