/**
 * That the mark beside a sorted `PlDataTable` heading turns rather than jumps,
 * which only the stylesheet can answer.
 *
 * `rotate-180` sets the individual `rotate` property, and a transition that
 * names `transform` never sees it change, so the flip arrived in one frame
 * while the class list read as if it eased. This file loads
 * `src/standalone.css` the way `fill-fade.test.tsx` does and records the
 * transitions that actually run. No duration is asserted.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlDataTable } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/** Every property a transition starts on `element` for, in order. */
function recordRuns(element: Element): string[] {
  const runs: string[] = [];

  element.addEventListener('transitionrun', (raw) => {
    if (raw.target === element) {
      runs.push((raw as TransitionEvent).propertyName);
    }
  });

  return runs;
}

async function table() {
  const screen = await render(
    <PlDataTable
      columns={[{ key: 'name', header: 'Name', sortable: true }]}
      rows={[{ name: 'Grace' }, { name: 'Ada' }]}
    />
  );
  const heading = screen.getByRole('button', { name: /Name/ });
  const mark = heading.element().querySelector('[aria-hidden="true"]')!;

  return { screen, heading, mark };
}

/** Two frames, which is where a transition the last change started would run. */
async function frames(): Promise<void> {
  for (let step = 0; step < 2; step += 1) {
    await new Promise((resolve) => requestAnimationFrame(resolve));
  }
}

describe('the sort mark', () => {
  it('turns over as the column is sorted one way and back as it is sorted the other', async () => {
    const { heading, mark } = await table();
    const runs = recordRuns(mark);

    await heading.click();
    await expect.poll(() => runs.filter((one) => one === 'rotate')).toHaveLength(1);

    await heading.click();
    await expect.poll(() => runs.filter((one) => one === 'rotate')).toHaveLength(2);
  });

  it('turns at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const { screen, heading, mark } = await table();
    const runs = recordRuns(mark);

    await heading.click();
    await expect
      .element(screen.getByRole('columnheader', { name: /Name/ }))
      .toHaveAttribute('aria-sort', 'ascending');
    await frames();

    expect(runs).toEqual([]);
  });
});
