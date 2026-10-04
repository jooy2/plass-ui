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
 * A read-only set keeps its segments enabled, and the light and the label's
 * hover are read off what Base UI marks them with instead.
 *
 * Where the tile is drawn and when it travels are read the same way, from the
 * transitions that actually start: none for the first placement or for a set
 * that changes size under the tile, one for a new choice.
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

  it('puts the light out on every segment of a read-only set, and keeps it on a live one', async () => {
    await render(
      <>
        <PlSegmentedButton aria-label="Period" defaultValue="day" readOnly>
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week">Week</PlSegment>
        </PlSegmentedButton>
        <PlSegmentedButton aria-label="View" defaultValue="list">
          <PlSegment value="list">List</PlSegment>
          <PlSegment value="grid">Grid</PlSegment>
        </PlSegmentedButton>
      </>
    );

    for (const name of ['Day', 'Week']) {
      expect(segment(name)).toHaveAttribute('data-readonly');
      expect(getComputedStyle(segment(name), '::before').content).toBe('none');
    }

    for (const name of ['List', 'Grid']) {
      expect(getComputedStyle(segment(name), '::before').content).not.toBe('none');
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

    it('keeps the labels of a read-only set in their muted ink', async () => {
      await render(
        <PlSegmentedButton aria-label="Period" defaultValue="day" readOnly>
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week">Week</PlSegment>
        </PlSegmentedButton>
      );

      expect(segment('Week')).toHaveAttribute('data-readonly');

      const { rest, hovered } = await labelColours('Week');

      expect(hovered).toBe(rest);
    });
  });

  describe('the tile', () => {
    let recording: AbortController;

    beforeEach(async () => {
      await emulateMedia({ reducedMotion: 'no-preference' });
      recording = new AbortController();
    });

    afterEach(() => {
      recording.abort();
    });

    /** The tile riding in `group`. */
    function tileIn(group: Element): HTMLElement {
      return group.querySelector<HTMLElement>(':scope > span[aria-hidden="true"]') as HTMLElement;
    }

    /**
     * Every box property a transition starts on a tile from here on, as it
     * starts. Recorded from the page, since a tile can be mounted after this.
     */
    function recordTravel(): string[] {
      const travel: string[] = [];

      document.addEventListener(
        'transitionrun',
        (raw) => {
          const event = raw as TransitionEvent;
          const target = event.target as Element;

          if (
            target.matches('[role="radiogroup"] > span[aria-hidden="true"]') &&
            ['left', 'top', 'width', 'height'].includes(event.propertyName)
          ) {
            travel.push(event.propertyName);
          }
        },
        { signal: recording.signal }
      );

      return travel;
    }

    /** Waits until the tile in `group` has its duration back on. */
    async function ready(group: Element): Promise<void> {
      await expect.poll(() => tileIn(group)?.hasAttribute('data-ready')).toBe(true);
    }

    /** Two frames, which is where a transition the last change started would run. */
    async function frames(): Promise<void> {
      for (let step = 0; step < 2; step += 1) {
        await new Promise((resolve) => requestAnimationFrame(resolve));
      }
    }

    /** Waits out whatever the last change set moving. */
    async function settle(element: Element): Promise<void> {
      await Promise.all(element.getAnimations().map((one) => one.finished));
    }

    /** That the tile in `group` covers the segment named `name`, to within a pixel. */
    function expectUnder(group: Element, name: string): void {
      const tile = tileIn(group).getBoundingClientRect();
      const box = segment(name).getBoundingClientRect();

      for (const side of ['left', 'top', 'width', 'height'] as const) {
        expect(Math.abs(tile[side] - box[side]), side).toBeLessThanOrEqual(1);
      }
    }

    function Periods(props: React.ComponentProps<typeof PlSegmentedButton>) {
      return (
        <PlSegmentedButton aria-label="Period" {...props}>
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week">Week</PlSegment>
          <PlSegment value="month">Month</PlSegment>
        </PlSegmentedButton>
      );
    }

    it('starts under the chosen segment without travelling there', async () => {
      const travel = recordTravel();
      const screen = await render(<Periods defaultValue="week" />);
      const group = screen.getByRole('radiogroup').element();

      await ready(group);
      await frames();

      expect(travel).toEqual([]);
      expectUnder(group, 'Week');
    });

    it('appears under the first choice of an empty set rather than flying in', async () => {
      const travel = recordTravel();
      const screen = await render(<Periods />);
      const group = screen.getByRole('radiogroup').element();

      await screen.getByRole('radio', { name: 'Month' }).click();
      await expect.element(screen.getByRole('radio', { name: 'Month' })).toBeChecked();
      await ready(group);
      await frames();

      expect(travel).toEqual([]);
      expectUnder(group, 'Month');
    });

    it('slides to the segment chosen next', async () => {
      const travel = recordTravel();
      const screen = await render(<Periods defaultValue="day" />);
      const group = screen.getByRole('radiogroup').element();

      await ready(group);
      await screen.getByRole('radio', { name: 'Month' }).click();
      await expect.poll(() => travel).toContain('left');
      await settle(tileIn(group));

      expectUnder(group, 'Month');
    });

    it('keeps up with a resize of the set rather than trailing it', async () => {
      const travel = recordTravel();
      const screen = await render(
        <div className="width-under-test" style={{ width: 300 }}>
          <Periods defaultValue="month" fullWidth />
        </div>
      );
      const group = screen.getByRole('radiogroup').element();

      await ready(group);

      const before = tileIn(group).getBoundingClientRect().left;

      document.querySelector<HTMLElement>('.width-under-test')!.style.width = '450px';

      await expect.poll(() => tileIn(group).getBoundingClientRect().left).toBeGreaterThan(before);
      await ready(group);
      await frames();

      expect(travel).toEqual([]);
      expectUnder(group, 'Month');
    });

    it('slides after a label it is sized by when the label changes', async () => {
      const travel = recordTravel();
      const set = (label: string) => (
        <PlSegmentedButton aria-label="Folder" defaultValue="inbox">
          <PlSegment value="inbox">{label}</PlSegment>
          <PlSegment value="sent">Sent</PlSegment>
        </PlSegmentedButton>
      );
      const screen = await render(set('Inbox'));
      const group = screen.getByRole('radiogroup').element();

      await ready(group);
      await screen.rerender(set('Inbox and everything else'));
      await expect.poll(() => travel).toContain('width');
      await settle(tileIn(group));

      expectUnder(group, 'Inbox and everything else');
    });

    it('follows the chosen segment when the segments are put in another order', async () => {
      const set = (order: string[]) => (
        <PlSegmentedButton aria-label="Period" defaultValue="week">
          {order.map((name) => (
            <PlSegment key={name} value={name.toLowerCase()}>
              {name}
            </PlSegment>
          ))}
        </PlSegmentedButton>
      );
      const screen = await render(set(['Day', 'Week', 'Month']));
      const group = screen.getByRole('radiogroup').element();

      await ready(group);
      await screen.rerender(set(['Month', 'Day', 'Week']));
      await frames();
      await settle(tileIn(group));

      expectUnder(group, 'Week');
    });
  });
});
