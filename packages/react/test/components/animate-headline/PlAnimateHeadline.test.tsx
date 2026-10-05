import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import * as React from 'react';
import { PlAnimateHeadline, type PlAnimateHeadlineProps } from 'plass-ui';
import { committed } from '../../support/timing';

describe('PlAnimateHeadline', () => {
  it('names the effect it is running', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test">
        <span>faster</span>
        <span>simpler</span>
      </PlAnimateHeadline>
    );

    expect(document.querySelector('.headline-under-test')).toHaveAttribute(
      'data-plass-animation',
      'headline'
    );
  });

  it('keeps every line in the document, in one cell', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test">
        <span>faster</span>
        <span>simpler</span>
        <span>cheaper</span>
      </PlAnimateHeadline>
    );

    const lines = document.querySelectorAll('.headline-under-test > *');

    expect(lines).toHaveLength(3);
    expect(lines[0]).toHaveClass('plass-headline-item');
  });

  it('wraps a bare string, which has no element to mark', async () => {
    await render(<PlAnimateHeadline className="headline-under-test">faster</PlAnimateHeadline>);

    const line = document.querySelector('.headline-under-test > *');

    expect(line?.tagName).toBe('SPAN');
    expect(line).toHaveClass('plass-headline-item');
  });

  it('shows the first line and no other', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test">
        <span>faster</span>
        <span>simpler</span>
      </PlAnimateHeadline>
    );

    const lines = document.querySelectorAll('.headline-under-test > *');

    expect(lines[0]).toHaveAttribute('data-state', 'active');
    expect(lines[1]).not.toHaveAttribute('data-state');
  });

  it('starts an uncontrolled reel wherever it was told to', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test" defaultIndex={1}>
        <span>faster</span>
        <span>simpler</span>
      </PlAnimateHeadline>
    );

    const lines = document.querySelectorAll('.headline-under-test > *');

    expect(lines[1]).toHaveAttribute('data-state', 'active');
  });

  describe('controlled', () => {
    it('shows whichever line the caller says', async () => {
      const screen = await render(
        <PlAnimateHeadline className="headline-under-test" index={0}>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await screen.rerender(
        <PlAnimateHeadline className="headline-under-test" index={1}>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      const lines = document.querySelectorAll('.headline-under-test > *');

      expect(lines[1]).toHaveAttribute('data-state', 'active');
      await expect.element(screen.getByText('faster')).toHaveAttribute('data-state', 'leaving');
    });

    it('clamps an index past the end onto the last line', async () => {
      await render(
        <PlAnimateHeadline className="headline-under-test" index={9}>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      const lines = document.querySelectorAll('.headline-under-test > *');

      expect(lines[1]).toHaveAttribute('data-state', 'active');
    });

    it('does not run a timer of its own, which would fight the caller', async () => {
      const onIndexChange = vi.fn();

      await render(
        <PlAnimateHeadline
          className="headline-under-test"
          index={0}
          interval={10}
          onIndexChange={onIndexChange}
        >
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await new Promise((resolve) => setTimeout(resolve, 80));

      expect(onIndexChange).not.toHaveBeenCalled();
    });
  });

  describe('uncontrolled', () => {
    it('turns on its own and reports each line as it comes up', async () => {
      const onIndexChange = vi.fn();

      const screen = await render(
        <PlAnimateHeadline
          className="headline-under-test"
          interval={20}
          duration={10}
          onIndexChange={onIndexChange}
        >
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await expect.element(screen.getByText('simpler')).toHaveAttribute('data-state', 'active');
      expect(onIndexChange).toHaveBeenCalledWith(1);
    });

    it('stops on the last line when it is not looping', async () => {
      const onIndexChange = vi.fn();

      const screen = await render(
        <PlAnimateHeadline
          className="headline-under-test"
          interval={20}
          duration={10}
          loop={false}
          onIndexChange={onIndexChange}
        >
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      // Waited for rather than slept through: a loaded CI machine takes an
      // order of magnitude longer than the interval to turn the reel once, and
      // a fixed sleep long enough to cover that is a slow test everywhere else.
      await expect.element(screen.getByText('simpler')).toHaveAttribute('data-state', 'active');

      // Several more intervals. A looping reel would have gone back to the
      // first line by now, and would have said so.
      await new Promise((resolve) => setTimeout(resolve, 120));

      await expect.element(screen.getByText('simpler')).toHaveAttribute('data-state', 'active');
      expect(onIndexChange).toHaveBeenCalledTimes(1);
    });

    it('holds still while it is paused', async () => {
      await render(
        <PlAnimateHeadline className="headline-under-test" interval={20} paused>
          <span>faster</span>
          <span>simpler</span>
        </PlAnimateHeadline>
      );

      await new Promise((resolve) => setTimeout(resolve, 120));

      const lines = document.querySelectorAll('.headline-under-test > *');

      expect(lines[0]).toHaveAttribute('data-state', 'active');
    });

    it('keeps turning inside a parent that renders more often than the interval', async () => {
      function Ticking() {
        const [, setTick] = React.useState(0);
        const [, setShown] = React.useState(0);

        React.useEffect(() => {
          const timer = window.setInterval(() => setTick((tick) => tick + 1), 50);

          return () => window.clearInterval(timer);
        }, []);

        // An inline handler, a new function on every one of those renders.
        return (
          <PlAnimateHeadline interval={200} duration={10} onIndexChange={(next) => setShown(next)}>
            <span>faster</span>
            <span>simpler</span>
          </PlAnimateHeadline>
        );
      }

      const screen = await render(<Ticking />);

      await expect
        .element(screen.getByText('simpler'), { timeout: 2000 })
        .toHaveAttribute('data-state', 'active');
    });
  });

  describe('the wait for the next line', () => {
    // The reel turns on a timeout and measures its wait with
    // `performance.now()`, so both run on a clock the test holds.
    beforeEach(() => {
      vi.useFakeTimers({ toFake: ['setTimeout', 'clearTimeout', 'performance'] });
    });

    afterEach(() => {
      vi.useRealTimers();
    });

    function advance(ms: number): Promise<void> {
      return committed(() => {
        vi.advanceTimersByTime(ms);
      });
    }

    function showing(): string | null | undefined {
      return document.querySelector('.headline-under-test [data-state="active"]')?.textContent;
    }

    const reel = (props: Partial<PlAnimateHeadlineProps> = {}) => (
      <PlAnimateHeadline className="headline-under-test" interval={1000} duration={10} {...props}>
        <span>faster</span>
        <span>simpler</span>
        <span>cheaper</span>
      </PlAnimateHeadline>
    );

    it('is what was left of the `interval` once a pause lets it go', async () => {
      const screen = await render(reel());

      await advance(600);
      await screen.rerender(reel({ paused: true }));
      await advance(5000);
      await screen.rerender(reel({ paused: false }));
      await advance(399);

      // It used to wait a whole `interval` again.
      expect(showing()).toBe('faster');

      await advance(1);

      expect(showing()).toBe('simpler');
    });

    it('is what was left of the `delay` and the `interval` once a pause lets it go', async () => {
      const screen = await render(reel({ delay: 500 }));

      await advance(600);
      await screen.rerender(reel({ delay: 500, paused: true }));
      await advance(5000);
      await screen.rerender(reel({ delay: 500, paused: false }));
      await advance(899);

      expect(showing()).toBe('faster');

      await advance(1);

      expect(showing()).toBe('simpler');

      // The next line waits an `interval` and no `delay`.
      await advance(999);

      expect(showing()).toBe('simpler');

      await advance(1);

      expect(showing()).toBe('cheaper');
    });

    it('is what was left of the `interval` once it is back on screen', async () => {
      await render(
        <div className="panel-under-test" style={{ height: '200px', overflow: 'auto' }}>
          {reel()}
          <div style={{ height: '1200px' }} />
        </div>
      );

      const panel = document.querySelector<HTMLElement>('.panel-under-test')!;
      const root = document.querySelector<HTMLElement>('.headline-under-test')!;

      // Waits for the observer on frames, which the test leaves alone.
      // `expect.poll` would move the clock the test holds between its tries.
      const reports = async (state: string) => {
        while (root.dataset.state !== state) {
          await new Promise((resolve) => requestAnimationFrame(resolve));
        }
      };

      await advance(600);

      // The state is drawn a render before the effect that takes the timer
      // away, so an empty `act` lets that effect run before the clock moves.
      panel.scrollTop = 800;
      await reports('paused');
      await committed(() => {});
      await advance(5000);

      expect(showing()).toBe('faster');

      panel.scrollTop = 0;
      await reports('running');
      await committed(() => {});
      await advance(399);

      expect(showing()).toBe('faster');

      await advance(1);

      expect(showing()).toBe('simpler');
    });

    it.each([
      ['longer', 1600],
      ['shorter', 800]
    ])('measures a new `interval` that is %s from when the wait began', async (_, to) => {
      const screen = await render(reel());

      await advance(600);
      await screen.rerender(reel({ interval: to }));
      await advance(to - 600 - 1);

      expect(showing()).toBe('faster');

      await advance(1);

      expect(showing()).toBe('simpler');
    });

    it('turns at once to a new `interval` the wait has already gone past', async () => {
      const screen = await render(reel());

      await advance(600);
      await screen.rerender(reel({ interval: 300 }));
      await advance(0);

      expect(showing()).toBe('simpler');
    });

    it.each([
      ['longer', 1600],
      ['shorter', 300]
    ])(
      'measures a new `delay` that is %s from when the wait began, before the first turn',
      async (_, to) => {
        const screen = await render(reel({ delay: 1000 }));

        await advance(600);
        await screen.rerender(reel({ delay: to }));
        await advance(to + 1000 - 600 - 1);

        expect(showing()).toBe('faster');

        await advance(1);

        expect(showing()).toBe('simpler');
      }
    );

    it('turns at once to a new `delay` the wait has already gone past', async () => {
      const screen = await render(reel({ delay: 1000, interval: 200 }));

      await advance(600);
      await screen.rerender(reel({ delay: 100, interval: 200 }));
      await advance(0);

      expect(showing()).toBe('simpler');
    });

    it('waits a whole `interval` again once it is started again after it was stopped', async () => {
      const screen = await render(reel({ trigger: 'manual', play: true }));

      await advance(600);
      await screen.rerender(reel({ trigger: 'manual', play: false }));
      await advance(100);
      await screen.rerender(reel({ trigger: 'manual', play: true }));
      await advance(999);

      expect(showing()).toBe('faster');

      await advance(1);

      expect(showing()).toBe('simpler');
    });
  });

  it('writes the travel and the duration into its own slots', async () => {
    await render(
      <PlAnimateHeadline className="headline-under-test" rise={28} duration={700}>
        <span>faster</span>
      </PlAnimateHeadline>
    );

    const root = document.querySelector('.headline-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-rise')).toBe('28px');
    expect(root.style.getPropertyValue('--p-anim-duration')).toBe('700ms');
  });
});
