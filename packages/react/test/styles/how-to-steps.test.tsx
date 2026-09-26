/**
 * How a `PlHowToSteps` guide eases its lines and its titles as `active` moves,
 * which only the stylesheet can answer.
 *
 * A connector's colour and a title's ink follow the step's status, and a class
 * list cannot say whether they ease or change in one frame, so this file loads
 * `src/standalone.css` the way `card.test.tsx` does and records the transitions
 * that actually run. No duration is asserted, only that they run, and that
 * under reduced motion they do not.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHowToStep, PlHowToSteps } from 'plass-ui';
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

function guide(active: number) {
  return (
    <PlHowToSteps active={active} data-testid="guide">
      <PlHowToStep title="Install" />
      <PlHowToStep title="Sign in" />
      <PlHowToStep title="Deploy" />
    </PlHowToSteps>
  );
}

/**
 * Every transition that starts on `element` itself, by property. Read on
 * `transitionrun`, so nothing has to sample a frame.
 */
function recordRuns(element: Element): string[] {
  const runs: string[] = [];

  element.addEventListener('transitionrun', (raw) => {
    const event = raw as TransitionEvent;

    if (event.target === element && event.pseudoElement === '') {
      runs.push(event.propertyName);
    }
  });

  return runs;
}

/** Two frames, which is where a transition the last change started would run. */
async function frames(): Promise<void> {
  for (let step = 0; step < 2; step += 1) {
    await new Promise((resolve) => requestAnimationFrame(resolve));
  }
}

/**
 * The line under the first step, which `active` moving on to the second takes
 * from current to complete, and the titles of the first two, which it takes
 * from current to complete and from upcoming to current.
 */
async function renderGuide() {
  const screen = await render(guide(0));
  const first = screen.getByTestId('guide').element().querySelector(':scope > li') as HTMLElement;
  // The bullet is the first thing hidden from the name, and the line the second.
  const connector = first.querySelectorAll('span[aria-hidden="true"]')[1] as HTMLElement;
  const titles = ['Install', 'Sign in'].map(
    (title) => screen.getByText(title, { exact: true }).element() as HTMLElement
  );

  // Read before the change, which is also what gives the change a style to ease
  // from.
  expect(getComputedStyle(connector).borderInlineStartStyle).toBe('solid');
  expect(titles.every((title) => getComputedStyle(title).color !== '')).toBe(true);

  return { screen, connector, titles };
}

describe('a how-to guide', () => {
  it('eases a step’s line and the titles as `active` moves past it', async () => {
    const { screen, connector, titles } = await renderGuide();
    const lined = recordRuns(connector);
    const inked = titles.map((title) => recordRuns(title));

    await screen.rerender(guide(1));

    await expect.poll(() => lined.some((one) => /^border-.*color$/.test(one))).toBe(true);

    for (const runs of inked) {
      await expect.poll(() => runs).toContain('color');
    }
  });

  it('moves them at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const { screen, connector, titles } = await renderGuide();
    const lined = recordRuns(connector);
    const inked = titles.map((title) => recordRuns(title));

    await screen.rerender(guide(1));
    await frames();

    expect(lined).toEqual([]);
    expect(inked).toEqual([[], []]);
  });
});
