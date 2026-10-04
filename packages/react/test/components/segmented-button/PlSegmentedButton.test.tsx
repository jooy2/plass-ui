import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlSegment, PlSegmentedButton } from 'plass-ui';

/** Waits out `count` frames. */
async function frames(count: number): Promise<void> {
  for (let step = 0; step < count; step += 1) {
    await new Promise((resolve) => requestAnimationFrame(resolve));
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

describe('PlSegmentedButton', () => {
  describe('rendering', () => {
    it('is a radiogroup holding one radio per segment', async () => {
      const screen = await render(<Periods />);

      await expect.element(screen.getByRole('radiogroup', { name: 'Period' })).toBeInTheDocument();
      expect(screen.getByRole('radio').elements()).toHaveLength(3);
    });

    it('names each segment from its children', async () => {
      const screen = await render(<Periods />);

      await expect.element(screen.getByRole('radio', { name: 'Week' })).toBeInTheDocument();
    });

    it('starts with nothing chosen', async () => {
      const screen = await render(<Periods />);

      for (const segment of screen.getByRole('radio').elements()) {
        expect(segment).toHaveAttribute('aria-checked', 'false');
      }
    });

    it('honours `defaultValue`', async () => {
      const screen = await render(<Periods defaultValue="week" />);

      expect(screen.getByRole('radio', { name: 'Week' }).element()).toHaveAttribute(
        'aria-checked',
        'true'
      );
    });

    it('renders the start and end slots', async () => {
      const screen = await render(
        <PlSegmentedButton aria-label="Scope">
          <PlSegment value="mine" startIcon={<span>◆</span>} endIcon={<span>4</span>}>
            Mine
          </PlSegment>
        </PlSegmentedButton>
      );

      await expect.element(screen.getByText('◆')).toBeInTheDocument();
      await expect.element(screen.getByText('4')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Periods className="my-own-class" />);

      expect(screen.getByRole('radiogroup').element()).toHaveClass('my-own-class');
    });
  });

  describe('the tile', () => {
    it('draws no tile until something is chosen', async () => {
      await render(<Periods className="set-under-test" />);

      expect(document.querySelector('.set-under-test > span[aria-hidden="true"]')).toBeNull();
    });

    it('draws one tile once something is', async () => {
      await render(<Periods className="set-under-test" defaultValue="day" />);

      expect(document.querySelectorAll('.set-under-test > span[aria-hidden="true"]')).toHaveLength(
        1
      );
    });

    it('measures the chosen segment onto the tile', async () => {
      await render(<Periods className="set-under-test" defaultValue="week" />);
      const tile = document.querySelector(
        '.set-under-test > span[aria-hidden="true"]'
      ) as HTMLElement;

      // Nothing loads Tailwind here, so the numbers are all zero — what matters
      // is that all four slots were written, which is what makes the tile
      // resolve to a box at all.
      for (const slot of ['--p-seg-x', '--p-seg-y', '--p-seg-w', '--p-seg-h']) {
        expect(tile.style.getPropertyValue(slot)).not.toBe('');
      }
    });

    it('does not measure again when a parent renders it again with nothing changed', async () => {
      const screen = await render(<Periods className="set-under-test" defaultValue="week" />);

      // The observer's first report measures once more, a frame after the set
      // is mounted.
      await frames(3);

      const reads = vi.spyOn(HTMLElement.prototype, 'offsetLeft', 'get');

      try {
        // The same segments, as new elements: that is what a parent rendering
        // again hands the set, and each one used to read the layout back.
        await screen.rerender(<Periods className="set-under-test" defaultValue="week" />);
        await frames(2);

        expect(
          reads.mock.contexts.filter((element) =>
            (element as HTMLElement).hasAttribute('data-segment')
          )
        ).toEqual([]);
      } finally {
        reads.mockRestore();
      }
    });

    it('measures again when the chosen segment moves among the others', async () => {
      const set = (order: string[]) => (
        <PlSegmentedButton aria-label="Period" className="set-under-test" defaultValue="week">
          {order.map((name) => (
            <PlSegment key={name} value={name.toLowerCase()}>
              {name}
            </PlSegment>
          ))}
        </PlSegmentedButton>
      );
      const screen = await render(set(['Day', 'Week', 'Month']));
      const tile = document.querySelector(
        '.set-under-test > span[aria-hidden="true"]'
      ) as HTMLElement;

      const second = tile.style.getPropertyValue('--p-seg-x');

      // Week goes first: nothing is resized, and the chosen segment stands
      // somewhere else.
      await screen.rerender(set(['Week', 'Day', 'Month']));

      const week = screen.getByRole('radio', { name: 'Week' }).element() as HTMLElement;

      expect(`${week.offsetLeft}px`).not.toBe(second);
      expect(tile.style.getPropertyValue('--p-seg-x')).toBe(`${week.offsetLeft}px`);
    });
    it('measures again when a style moves the chosen segment without resizing the set', async () => {
      const set = (width: number) => (
        <PlSegmentedButton
          aria-label="Period"
          className="set-under-test"
          defaultValue="week"
          style={{ width: 400 }}
        >
          <PlSegment value="day" style={{ display: 'inline-block', width }}>
            Day
          </PlSegment>
          <PlSegment value="week" style={{ display: 'inline-block' }}>
            Week
          </PlSegment>
        </PlSegmentedButton>
      );
      const screen = await render(set(100));
      const tile = document.querySelector(
        '.set-under-test > span[aria-hidden="true"]'
      ) as HTMLElement;

      const before = tile.style.getPropertyValue('--p-seg-x');

      // Day grows, inside a set held at one width: the observer on the set has
      // nothing to report, and Week stands somewhere else.
      await screen.rerender(set(150));

      const week = screen.getByRole('radio', { name: 'Week' }).element() as HTMLElement;

      expect(`${week.offsetLeft}px`).not.toBe(before);
      expect(tile.style.getPropertyValue('--p-seg-x')).toBe(`${week.offsetLeft}px`);
    });

    it('does not measure again when a parent hands it the same styles again', async () => {
      const set = () => (
        <PlSegmentedButton
          aria-label="Period"
          className="set-under-test"
          defaultValue="week"
          style={{ width: 400 }}
        >
          <PlSegment value="day" style={{ display: 'inline-block', width: 100 }}>
            Day
          </PlSegment>
          <PlSegment value="week" style={{ display: 'inline-block' }}>
            Week
          </PlSegment>
        </PlSegmentedButton>
      );
      const screen = await render(set());

      await frames(3);

      const reads = vi.spyOn(HTMLElement.prototype, 'offsetLeft', 'get');

      try {
        // New style objects with the same declarations, which React writes
        // nothing for.
        await screen.rerender(set());
        await frames(2);

        expect(
          reads.mock.contexts.filter((element) =>
            (element as HTMLElement).hasAttribute('data-segment')
          )
        ).toEqual([]);
      } finally {
        reads.mockRestore();
      }
    });
  });

  describe('choosing', () => {
    it('takes the segment that was clicked', async () => {
      const screen = await render(<Periods />);

      await screen.getByRole('radio', { name: 'Month' }).click();

      expect(screen.getByRole('radio', { name: 'Month' }).element()).toHaveAttribute(
        'aria-checked',
        'true'
      );
    });

    it('clears the one that was chosen before', async () => {
      const screen = await render(<Periods defaultValue="day" />);

      await screen.getByRole('radio', { name: 'Month' }).click();

      expect(screen.getByRole('radio', { name: 'Day' }).element()).toHaveAttribute(
        'aria-checked',
        'false'
      );
    });

    it('reports the new value to `onValueChange`', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Periods onValueChange={onValueChange} />);

      await screen.getByRole('radio', { name: 'Week' }).click();

      expect(onValueChange).toHaveBeenCalledWith('week');
    });

    it('obeys `value` rather than the click when controlled', async () => {
      const screen = await render(<Periods value="day" onValueChange={() => {}} />);

      await screen.getByRole('radio', { name: 'Month' }).click();

      expect(screen.getByRole('radio', { name: 'Day' }).element()).toHaveAttribute(
        'aria-checked',
        'true'
      );
    });
  });

  describe('states', () => {
    it('disables every segment at once', async () => {
      const screen = await render(<Periods disabled />);

      for (const segment of screen.getByRole('radio').elements()) {
        expect(segment).toBeDisabled();
      }
    });

    it('disables one segment without touching the rest', async () => {
      const screen = await render(
        <PlSegmentedButton aria-label="Period">
          <PlSegment value="day">Day</PlSegment>
          <PlSegment value="week" disabled>
            Week
          </PlSegment>
        </PlSegmentedButton>
      );

      expect(screen.getByRole('radio', { name: 'Day' }).element()).toBeEnabled();
      expect(screen.getByRole('radio', { name: 'Week' }).element()).toBeDisabled();
    });

    it('does not change when read-only', async () => {
      const screen = await render(<Periods defaultValue="day" readOnly />);

      await screen.getByRole('radio', { name: 'Month' }).click();

      expect(screen.getByRole('radio', { name: 'Day' }).element()).toHaveAttribute(
        'aria-checked',
        'true'
      );
    });
  });

  describe('the set decides the look', () => {
    it('gives every segment the size the set was given', async () => {
      const screen = await render(<Periods size="lg" />);

      for (const segment of screen.getByRole('radio').elements()) {
        expect(segment).toHaveClass('h-12');
      }
    });

    it('shares the row evenly when `fullWidth` is set', async () => {
      const screen = await render(<Periods fullWidth />);

      for (const segment of screen.getByRole('radio').elements()) {
        expect(segment).toHaveClass('flex-1');
      }
    });
  });
});
