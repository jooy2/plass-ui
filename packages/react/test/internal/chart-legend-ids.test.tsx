/**
 * What a chart's legend does with a series that has an `id`.
 *
 * A legend entry is known by its series' name and how many series before it
 * have that name, so a series renamed between two renders was a new entry: it
 * came back switched on, and the entry the pointer was resting on was let go.
 * Two series of one name were told apart by their order alone, so when the
 * first left the data, the second took over its state. A series with an `id` is
 * known by it instead, and keeps all of that.
 *
 * A test of the frame's legend rather than of one chart, which is why it is
 * here rather than under `test/components/`.
 */
import { commands } from 'vitest/browser';
import { beforeEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlLineChart } from 'plass-ui';

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

/** The opacity each series is drawn at on the plot. */
function marks(container: HTMLElement): (string | null)[] {
  return [...container.querySelectorAll('svg g[opacity]')].map((mark) =>
    mark.getAttribute('opacity')
  );
}

beforeEach(async () => {
  await commands.parkPointer();
});

describe('a line chart legend', () => {
  type Series = { id: string; name: string };

  // The tooltip is off because nothing loads the CSS here, so a card left over
  // the plot joins the flow and can catch the click meant for the legend. The
  // data follows the id, so a series renamed or moved draws what it drew.
  const chart = (list: readonly Series[]) => (
    <PlLineChart
      label="Sessions"
      categories={MONTHS}
      tooltip={false}
      legend={{ align: 'start' }}
      series={list.map((one) => ({ ...one, data: [one.id.length, one.id.length + 1] }))}
    />
  );

  it('switches off one of two series of the same name, and keeps it off when the first leaves', async () => {
    const screen = await render(
      chart([
        { id: 'a', name: 'Revenue' },
        { id: 'bb', name: 'Revenue' },
        { id: 'ccc', name: 'Cost' }
      ])
    );
    const second = screen.getByRole('button', { name: 'Revenue' }).nth(1);

    await second.click();
    await expect.element(second).toHaveAttribute('aria-pressed', 'false');

    expect(switchedOn(screen.container)).toEqual([true, false, true]);

    // The second Revenue is now the first, and still the one switched off.
    await screen.rerender(
      chart([
        { id: 'bb', name: 'Revenue' },
        { id: 'ccc', name: 'Cost' }
      ])
    );

    expect(switchedOn(screen.container)).toEqual([false, true]);
    expect(marks(screen.container)).toHaveLength(1);
  });

  it('keeps a renamed series switched off', async () => {
    const screen = await render(
      chart([
        { id: 'a', name: 'Web' },
        { id: 'bb', name: 'Mobile' },
        { id: 'ccc', name: 'Desktop' }
      ])
    );
    const entry = screen.getByRole('button', { name: 'Mobile' });

    await entry.click();
    await expect.element(entry).toHaveAttribute('aria-pressed', 'false');

    await screen.rerender(
      chart([
        { id: 'a', name: 'Web' },
        { id: 'bb', name: 'Phone' },
        { id: 'ccc', name: 'Desktop' }
      ])
    );

    await expect
      .element(screen.getByRole('button', { name: 'Phone' }))
      .toHaveAttribute('aria-pressed', 'false');
    expect(switchedOn(screen.container)).toEqual([true, false, true]);
    expect(marks(screen.container)).toHaveLength(2);
  });

  it('keeps the pointer on the entry of a renamed series', async () => {
    const screen = await render(
      chart([
        { id: 'a', name: 'Web' },
        { id: 'bb', name: 'Mobile' },
        { id: 'ccc', name: 'Desktop' }
      ])
    );

    await screen.getByRole('button', { name: 'Web' }).hover();
    await expect.poll(() => fadedEntries(screen.container)).toEqual([false, true, true]);

    await screen.rerender(
      chart([
        { id: 'a', name: 'Www' },
        { id: 'bb', name: 'Mobile' },
        { id: 'ccc', name: 'Desktop' }
      ])
    );

    await expect.element(screen.getByRole('button', { name: 'Www' })).toBeInTheDocument();
    expect(fadedEntries(screen.container)).toEqual([false, true, true]);
    expect(marks(screen.container)).toEqual(['1', '0.28', '0.28']);
  });
});
