/**
 * Whether a `PlTimePicker`'s columns bring the chosen row into view when the
 * page is scaled, which only the stylesheet can answer: without it a column is
 * as tall as its sixty rows and has nothing to scroll.
 *
 * The popup is portalled to the end of `<body>`, out of any scaled box the
 * picker itself sits in, so the transform that reaches a column is one on
 * `<body>` itself, as on a page scaled as a whole to fit a screen.
 * `src/standalone.css` is loaded the way `carousel.test.tsx` loads it.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTimePicker } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { press } from '../support/keys';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** A quarter to ten in the evening, far enough down both columns to need a scroll. */
const NINE_FORTY_FIVE_PM = new Date(2026, 6, 27, 21, 45);

/** Nine in the evening. */
const NINE_PM = new Date(2026, 6, 27, 21, 0);

/** The rows of the column of that name. */
function rowsOf(name: string): HTMLElement[] {
  const column = document.querySelector(`[role="listbox"][aria-label="${name}"]`)!;

  return [...column.querySelectorAll<HTMLElement>('[role="option"]')];
}

/** Whether the whole of `row` is inside the part of its column on screen. */
function shown(row: HTMLElement): boolean {
  const box = row.getBoundingClientRect();
  const column = row.parentElement!.getBoundingClientRect();

  return box.top >= column.top - 0.5 && box.bottom <= column.bottom + 0.5;
}

describe('a PlTimePicker on a scaled page', () => {
  beforeEach(() => {
    document.body.style.transform = 'scale(0.5)';
    document.body.style.transformOrigin = '0 0';
  });

  afterEach(() => {
    document.body.style.removeProperty('transform');
    document.body.style.removeProperty('transform-origin');
  });

  it('opens with the chosen row of each column in view', async () => {
    await render(
      <PlTimePicker locale="en-GB" defaultValue={NINE_FORTY_FIVE_PM} minuteStep={1} defaultOpen />
    );

    await expect.poll(() => shown(rowsOf('Hour')[21])).toBe(true);
    await expect.poll(() => shown(rowsOf('Minute')[45])).toBe(true);
  });

  it('keeps the row a key moves to in view, down the column and back up it', async () => {
    // On the hour, so the minute column opens at its top with nothing to scroll.
    await render(<PlTimePicker locale="en-GB" defaultValue={NINE_PM} minuteStep={1} defaultOpen />);

    const minutes = rowsOf('Minute');

    await expect.poll(() => shown(minutes[0])).toBe(true);

    press(minutes[0], 'End');

    await expect.poll(() => shown(minutes[59])).toBe(true);

    press(minutes[59], 'Home');

    await expect.poll(() => shown(minutes[0])).toBe(true);
  });
});
