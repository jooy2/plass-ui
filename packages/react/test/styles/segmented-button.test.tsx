/**
 * How faded a `PlSegmentedButton`'s segments are drawn, whether they take the
 * pointer light, and what their labels do under the pointer, which only the
 * stylesheet can answer.
 *
 * A disabled set fades itself, and Base UI marks every segment in it disabled
 * as well, so the assertion is on the opacity a segment is drawn at with every
 * fade above it multiplied in, read with `src/standalone.css` loaded the way
 * `combobox.test.tsx` loads it. No opacity is asserted, only how many fades a
 * segment is drawn through: the one a disabled set is drawn at, and never two.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlFieldset, PlSegment, PlSegmentedButton } from 'plass-ui';
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

beforeEach(async () => {
  await commands.parkPointer();
  await emulateMedia({ reducedMotion: 'reduce' });
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/** The opacity `element` is drawn at, with every fade above it multiplied in. */
function drawnOpacity(element: Element): number {
  let opacity = 1;

  for (let node: Element | null = element; node; node = node.parentElement) {
    opacity *= Number(getComputedStyle(node).opacity);
  }

  return opacity;
}

/** How many of `element` and the elements above it drain its colour. */
function drains(element: Element): number {
  let count = 0;

  for (let node: Element | null = element; node; node = node.parentElement) {
    count += getComputedStyle(node).filter.includes('saturate(') ? 1 : 0;
  }

  return count;
}

/** The segment named `name`. */
function segment(name: string): HTMLElement {
  return [...document.querySelectorAll<HTMLElement>('[data-segment]')].find(
    (one) => one.textContent === name
  ) as HTMLElement;
}

describe('the segmented button stylesheet', () => {
  it('draws the segments of a disabled set at the one fade the set is drawn at', async () => {
    const screen = await render(
      <PlSegmentedButton aria-label="Period" defaultValue="day" disabled>
        <PlSegment value="day">Day</PlSegment>
        <PlSegment value="week">Week</PlSegment>
      </PlSegmentedButton>
    );
    const set = screen.getByRole('radiogroup').element();

    expect(drawnOpacity(set)).toBeLessThan(1);

    for (const name of ['Day', 'Week']) {
      expect(segment(name)).toHaveAttribute('data-disabled');
      expect(drawnOpacity(segment(name))).toBe(drawnOpacity(set));
      expect(drains(segment(name))).toBe(1);
    }
  });

  it('draws the segments of a set in a disabled fieldset at that one fade too', async () => {
    const screen = await render(
      <PlFieldset disabled>
        <PlSegmentedButton aria-label="Period" defaultValue="day">
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week" disabled>
            Week
          </PlSegment>
        </PlSegmentedButton>
      </PlFieldset>
    );
    const set = screen.getByRole('radiogroup').element();

    expect(drawnOpacity(set)).toBeLessThan(1);

    for (const name of ['Day', 'Week']) {
      expect(drawnOpacity(segment(name))).toBe(drawnOpacity(set));
    }
  });

  it('puts the light out on every segment of a disabled set', async () => {
    await render(
      <PlSegmentedButton aria-label="Period" defaultValue="day" disabled>
        <PlSegment value="day">Day</PlSegment>
        <PlSegment value="week">Week</PlSegment>
      </PlSegmentedButton>
    );

    for (const name of ['Day', 'Week']) {
      expect(getComputedStyle(segment(name), '::before').content).toBe('none');
    }
  });

  it('fades a segment disabled on its own in a live set as a disabled set is faded', async () => {
    const screen = await render(
      <>
        <PlSegmentedButton aria-label="Period" defaultValue="day">
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week" disabled>
            Week
          </PlSegment>
        </PlSegmentedButton>
        <PlSegmentedButton aria-label="View" defaultValue="list" disabled>
          <PlSegment value="list">List</PlSegment>
        </PlSegmentedButton>
      </>
    );

    expect(drawnOpacity(screen.getByRole('radiogroup', { name: 'Period' }).element())).toBe(1);
    expect(drawnOpacity(segment('Day'))).toBe(1);
    expect(drawnOpacity(segment('Week'))).toBe(
      drawnOpacity(screen.getByRole('radiogroup', { name: 'View' }).element())
    );
    expect(getComputedStyle(segment('Day'), '::before').content).not.toBe('none');
    expect(getComputedStyle(segment('Week'), '::before').content).toBe('none');
  });

  describe('a label under the pointer', () => {
    /**
     * The named segment's label colour at rest and then with the pointer over
     * it. Reduced motion, asked for before each test, puts the colour on at
     * once. No colour is asserted, only whether the pointer changes it.
     */
    async function labelColours(name: string): Promise<{ rest: string; hovered: string }> {
      const rest = getComputedStyle(segment(name)).color;

      await userEvent.hover(segment(name));

      return { rest, hovered: getComputedStyle(segment(name)).color };
    }

    it('darkens the label of a segment that can be pressed', async () => {
      await render(
        <PlSegmentedButton aria-label="Period" defaultValue="day">
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week">Week</PlSegment>
        </PlSegmentedButton>
      );

      const { rest, hovered } = await labelColours('Week');

      expect(hovered).not.toBe(rest);
    });

    it('keeps the chosen segment’s label in the colour of its tile', async () => {
      await render(
        <PlSegmentedButton aria-label="Period" defaultValue="day" variant="solid">
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week">Week</PlSegment>
        </PlSegmentedButton>
      );

      const { rest, hovered } = await labelColours('Day');

      expect(hovered).toBe(rest);
    });

    it('keeps the label of a segment disabled on its own in its muted ink', async () => {
      await render(
        <PlSegmentedButton aria-label="Period" defaultValue="day">
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week" disabled>
            Week
          </PlSegment>
        </PlSegmentedButton>
      );

      expect(segment('Week')).toHaveAttribute('data-disabled');

      const { rest, hovered } = await labelColours('Week');

      expect(hovered).toBe(rest);
    });

    it('keeps the labels of a disabled set in their muted ink', async () => {
      await render(
        <PlSegmentedButton aria-label="Period" defaultValue="day" disabled>
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week">Week</PlSegment>
        </PlSegmentedButton>
      );

      expect(segment('Week')).toHaveAttribute('data-disabled');

      const { rest, hovered } = await labelColours('Week');

      expect(hovered).toBe(rest);
    });
  });
});
