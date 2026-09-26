/**
 * What a chart does with the legend entry under the pointer when it is
 * rendered again without that entry.
 *
 * Pointing at an entry, or focusing it, fades every other series. The entry
 * says so from its own `pointerenter` and `focus`, and a button that is removed
 * while the pointer or the focus is on it is never left and never blurred. Its
 * series used to stay hovered: a chart that lost its last series faded every
 * one that remained, one that lost a middle series faded all but the one that
 * took its place, and the fading came back with the data wherever the pointer
 * had gone by then.
 *
 * The legends are laid out from the start, so taking an entry out leaves the
 * ones before it where they were and the pointer over no entry at all. A
 * browser tells an entry that moves under a resting pointer that the pointer is
 * on it, and that entry is then rightly the hovered one.
 */
import { commands } from 'vitest/browser';
import { beforeEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlLineChart, PlPieChart } from 'plass-ui';

const MONTHS = ['Jan', 'Feb'];

function series(names: readonly string[]) {
  return names.map((name, index) => ({ name, data: [index + 1, index + 2] }));
}

/** The names of the legend entries drawn faded for another one's hover. */
function fadedEntries(container: HTMLElement): string[] {
  return [...container.querySelectorAll('li > button')]
    .filter((entry) => entry.className.includes('opacity-55'))
    .map((entry) => entry.textContent ?? '');
}

/** The opacity each series or slice on the plot is drawn at. */
function marks(container: HTMLElement, selector: string): (string | null)[] {
  return [...container.querySelectorAll(selector)].map((mark) => mark.getAttribute('opacity'));
}

/** Two frames, for the browser to report what is now under the pointer before the chart is read. */
function frames(): Promise<void> {
  return new Promise((resolve) => {
    requestAnimationFrame(() => requestAnimationFrame(() => resolve()));
  });
}

beforeEach(async () => {
  await commands.parkPointer();
});

describe('a line chart legend', () => {
  const chart = (names: readonly string[]) => (
    <PlLineChart
      label="Sessions"
      categories={MONTHS}
      legend={{ align: 'start' }}
      series={series(names)}
    />
  );

  /** Nothing on the plot or in the legend is faded. */
  function atRest(container: HTMLElement) {
    expect(fadedEntries(container)).toEqual([]);
    expect(marks(container, 'svg g[opacity]').every((one) => one === '1')).toBe(true);
  }

  it('lets go of the last entry when it is rendered without it', async () => {
    const screen = await render(chart(['Web', 'Mobile', 'Desktop']));

    await screen.getByRole('button', { name: 'Desktop' }).hover();
    await expect.poll(() => fadedEntries(screen.container)).toEqual(['Web', 'Mobile']);

    await screen.rerender(chart(['Web', 'Mobile']));
    await frames();
    atRest(screen.container);

    // Let go rather than held, so the data bringing a series back to that
    // place does not bring the fading back with it.
    await commands.parkPointer();
    await screen.rerender(chart(['Web', 'Mobile', 'Desktop']));
    await frames();
    atRest(screen.container);
  });

  it('lets go of a middle entry when it is rendered without it', async () => {
    const screen = await render(chart(['Web', 'Mobile applications', 'TV']));

    await screen.getByRole('button', { name: 'Mobile applications' }).hover();
    await expect.poll(() => fadedEntries(screen.container)).toEqual(['Web', 'TV']);

    // TV takes its place, and is too short to reach the pointer.
    await screen.rerender(chart(['Web', 'TV']));
    await frames();
    atRest(screen.container);
  });

  it('lets go of an entry when the legend goes with all but one series', async () => {
    const screen = await render(chart(['Web', 'Mobile']));

    await screen.getByRole('button', { name: 'Web' }).hover();
    await expect.poll(() => fadedEntries(screen.container)).toEqual(['Mobile']);

    await screen.rerender(chart(['Web']));
    await commands.parkPointer();
    await screen.rerender(chart(['Web', 'Mobile']));
    await frames();
    atRest(screen.container);
  });

  it('lets go of the focused entry when it is rendered without it', async () => {
    const screen = await render(chart(['Web', 'Mobile', 'Desktop']));

    await expect.element(screen.getByRole('button', { name: 'Desktop' })).toBeInTheDocument();
    (screen.getByRole('button', { name: 'Desktop' }).element() as HTMLElement).focus();
    await expect.poll(() => fadedEntries(screen.container)).toEqual(['Web', 'Mobile']);

    await screen.rerender(chart(['Web', 'Mobile']));
    await frames();
    atRest(screen.container);
  });
});

describe('a pie chart legend', () => {
  const chart = (names: readonly string[]) => (
    <PlPieChart
      label="Traffic"
      categories={names}
      data={names.map((_, index) => 40 - index * 10)}
      legend={{ align: 'start' }}
    />
  );

  function atRest(container: HTMLElement) {
    expect(fadedEntries(container)).toEqual([]);
    expect(marks(container, 'svg path[fill]:not([fill="none"])').every((one) => one === '1')).toBe(
      true
    );
  }

  it('lets go of the last entry when it is rendered without it', async () => {
    const screen = await render(chart(['Search', 'Social', 'Email']));

    await screen.getByRole('button', { name: 'Email' }).hover();
    await expect.poll(() => fadedEntries(screen.container)).toEqual(['Search', 'Social']);

    await screen.rerender(chart(['Search', 'Social']));
    await frames();
    atRest(screen.container);

    await commands.parkPointer();
    await screen.rerender(chart(['Search', 'Social', 'Email']));
    await frames();
    atRest(screen.container);
  });
});
