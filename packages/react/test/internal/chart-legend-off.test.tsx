/**
 * Which series a chart keeps switched off when it is rendered again with
 * different series.
 *
 * A series switched off in the legend used to be held by its place, so a
 * series leaving the data ahead of it switched off whichever series moved into
 * that place instead, and a place past the new end switched a series off again
 * once the data grew back to it. It is held by the key its entry is rendered
 * under, its name or else its place, as the hovered entry is, and a key no
 * series has any more is let go in the same way.
 *
 * A test of the frame and the pie together, because both keep the legend's
 * state in one hook, which is why it is here rather than under
 * `test/components/`.
 */
import { commands } from 'vitest/browser';
import { beforeEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlLineChart, PlPieChart } from 'plass-ui';

const MONTHS = ['Jan', 'Feb'];

/** Which legend entries are switched on, by name. */
function switchedOn(container: HTMLElement): Record<string, boolean> {
  return Object.fromEntries(
    [...container.querySelectorAll('li > button')].map((entry) => [
      entry.textContent ?? '',
      entry.getAttribute('aria-pressed') === 'true'
    ])
  );
}

beforeEach(async () => {
  await commands.parkPointer();
});

describe('a line chart legend', () => {
  type Series = { name: string; hidden?: boolean };

  // The tooltip is off because nothing loads the CSS here, so a card left over
  // the plot joins the flow and can catch the click meant for the legend.
  const chart = (list: readonly Series[]) => (
    <PlLineChart
      label="Sessions"
      categories={MONTHS}
      tooltip={false}
      series={list.map((one, index) => ({ ...one, data: [index + 1, index + 2] }))}
    />
  );

  const named = (...names: string[]) => names.map((name) => ({ name }));

  /** How many series the plot draws, by the group each one's line is drawn in. */
  function drawn(container: HTMLElement): number {
    return container.querySelectorAll('svg g[opacity]:has(> path)').length;
  }

  it('keeps the series it switched off, and not the one that took its place', async () => {
    const screen = await render(chart(named('Web', 'Mobile', 'Desktop')));
    const entry = screen.getByRole('button', { name: 'Mobile' });

    await entry.click();
    await expect.element(entry).toHaveAttribute('aria-pressed', 'false');

    // Desktop moves into the place Mobile was in.
    await screen.rerender(chart(named('Mobile', 'Desktop')));

    expect(switchedOn(screen.container)).toEqual({ Mobile: false, Desktop: true });
    expect(drawn(screen.container)).toBe(1);
  });

  it('lets go of a series that left the data, so it is drawn when it comes back', async () => {
    const screen = await render(chart(named('Web', 'Mobile', 'Desktop')));
    const entry = screen.getByRole('button', { name: 'Desktop' });

    await entry.click();
    await expect.element(entry).toHaveAttribute('aria-pressed', 'false');

    await screen.rerender(chart(named('Web', 'Mobile')));

    expect(switchedOn(screen.container)).toEqual({ Web: true, Mobile: true });

    await screen.rerender(chart(named('Web', 'Mobile', 'Desktop')));

    expect(switchedOn(screen.container)).toEqual({ Web: true, Mobile: true, Desktop: true });
    expect(drawn(screen.container)).toBe(3);
  });

  it('holds a series that starts hidden by its name, and reads `hidden` once', async () => {
    const screen = await render(
      chart([{ name: 'Web' }, { name: 'Mobile', hidden: true }, { name: 'Desktop' }])
    );

    await expect.element(screen.getByRole('button', { name: 'Mobile' })).toBeInTheDocument();
    expect(switchedOn(screen.container)).toEqual({ Web: true, Mobile: false, Desktop: true });

    // Web leaves, and Mobile's `hidden` is let go of by the caller: it stays
    // off, because the prop is where the chart starts, and the legend is what
    // switches it back on.
    await screen.rerender(chart(named('Mobile', 'Desktop')));

    expect(switchedOn(screen.container)).toEqual({ Mobile: false, Desktop: true });
  });
});

describe('a pie chart legend', () => {
  const chart = (names: readonly string[]) => (
    <PlPieChart
      label="Traffic"
      categories={names}
      data={names.map((_, index) => 40 - index * 10)}
      tooltip={false}
    />
  );

  /** How many slices the pie draws. */
  function drawn(container: HTMLElement): number {
    return container.querySelectorAll('svg path[fill]:not([fill="none"])').length;
  }

  it('keeps the slice it switched off, and not the one that took its place', async () => {
    const screen = await render(chart(['Search', 'Social', 'Email']));
    const entry = screen.getByRole('button', { name: 'Social' });

    await entry.click();
    await expect.element(entry).toHaveAttribute('aria-pressed', 'false');

    await screen.rerender(chart(['Social', 'Email']));

    expect(switchedOn(screen.container)).toEqual({ Social: false, Email: true });
    expect(drawn(screen.container)).toBe(1);
  });

  it('lets go of a slice that left the data, so it is drawn when it comes back', async () => {
    const screen = await render(chart(['Search', 'Social', 'Email']));
    const entry = screen.getByRole('button', { name: 'Email' });

    await entry.click();
    await expect.element(entry).toHaveAttribute('aria-pressed', 'false');

    await screen.rerender(chart(['Search', 'Social']));
    await screen.rerender(chart(['Search', 'Social', 'Email']));

    expect(switchedOn(screen.container)).toEqual({ Search: true, Social: true, Email: true });
    expect(drawn(screen.container)).toBe(3);
  });
});
