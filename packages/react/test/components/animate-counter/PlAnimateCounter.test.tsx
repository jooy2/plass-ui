import { afterEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { useState } from 'react';
import { PlAnimateCounter } from 'plass-ui';
import { frameClock } from '../../support/timing';
import { emulateMedia } from '../../support/media';

/**
 * Runs the next animation frame the page asks for as soon as the work that
 * asked for it is done, ahead of anything React has scheduled for later, and
 * hands back a function that puts the real frame clock back.
 *
 * A browser is free to paint between the render that takes a new prop and the
 * render that starts the run the prop causes. In a test it rarely does, so this
 * puts that frame there every time.
 */
function frameBeforeTheNextRender(): () => void {
  const frame = window.requestAnimationFrame;
  const restore = () => {
    window.requestAnimationFrame = frame;
  };

  window.requestAnimationFrame = (callback) => {
    restore();
    queueMicrotask(() => callback(performance.now()));

    return 0;
  };

  return restore;
}

function root(): HTMLElement {
  return document.querySelector<HTMLElement>('.counter-under-test')!;
}

/** What a sighted reader sees right now. */
function drawn(): string {
  return root().querySelector<HTMLElement>('[aria-hidden="true"]')!.textContent ?? '';
}

/** What a screen reader is told, which is the answer and not the count. */
function announced(): string {
  return (root().firstElementChild as HTMLElement).textContent ?? '';
}

/** The drawn figure as a number, without the separators the locale put in. */
function figure(): number {
  return Number(drawn().replace(/,/g, ''));
}

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

describe('PlAnimateCounter', () => {
  describe('pausing', () => {
    const linear = (t: number) => t;

    function counter(paused: boolean) {
      return (
        <PlAnimateCounter
          className="counter-under-test"
          trigger="mount"
          value={1000}
          duration={1000}
          easing={linear}
          paused={paused}
        />
      );
    }

    it('holds the count where it is, and goes on from there when it is let go', async () => {
      // Taken before the render, so the first frame the count asks for is one
      // this test draws.
      const frames = frameClock();

      try {
        const screen = await render(counter(false));

        // The count's clock starts at its first frame, whatever time that is.
        await frames.draw(1000);
        await frames.draw(1300);

        expect(figure()).toBe(300);

        await screen.rerender(counter(true));
        // Two frames, since a loop started again by the change would take its
        // start time on the first and count only from there.
        await frames.draw(1600);
        await frames.draw(1900);

        // A count that went on while it was held would be past 300 here.
        expect(figure()).toBe(300);

        await screen.rerender(counter(false));
        // However late the page draws again after it is let go, the clock goes
        // on from the 300ms the count had already run.
        await frames.draw(5000);

        expect(figure()).toBe(300);

        await frames.draw(5200);

        // 500ms in. A loop that took its start time again would have dropped
        // back to `from`, and be 200ms in.
        expect(figure()).toBe(500);

        await frames.draw(5700);

        expect(figure()).toBe(1000);
      } finally {
        frames.restore();
      }
    });

    it('waits out only what was left of `delay` when it is let go', async () => {
      function waiting(paused: boolean) {
        return (
          <PlAnimateCounter
            className="counter-under-test"
            trigger="mount"
            value={1000}
            delay={600}
            duration={100}
            easing={linear}
            paused={paused}
          />
        );
      }

      // Taken before the render, so the first frame the count asks for is one
      // this test draws.
      const frames = frameClock();

      try {
        const screen = await render(waiting(false));

        // The count's clock starts at its first frame, whatever time that is.
        await frames.draw(1000);
        await frames.draw(1300);

        // Half of the wait has gone by, so what is held is the wait itself.
        expect(figure()).toBe(0);

        await screen.rerender(waiting(true));
        await frames.draw(1600);

        expect(figure()).toBe(0);

        await screen.rerender(waiting(false));
        // However late the page draws again after it is let go, the clock goes
        // on from the 300ms the count had already waited.
        await frames.draw(5000);
        await frames.draw(5299);

        // 300ms of the wait was left, and 299 of them have gone by.
        expect(figure()).toBe(0);

        await frames.draw(5350);

        // Halfway through the 100ms of counting after it. A loop that waited
        // out the whole `delay` again would still be sitting on `from`.
        expect(figure()).toBe(500);

        await frames.draw(5400);

        expect(figure()).toBe(1000);
      } finally {
        frames.restore();
      }
    });

    it('keeps counting when a parent renders it with a new `easing` function', async () => {
      // The same props every time, and an `easing` that is a new function, as
      // an inline arrow is on every render of the parent.
      function counting() {
        return (
          <PlAnimateCounter
            className="counter-under-test"
            trigger="mount"
            value={1000}
            duration={1000}
            easing={(t) => t}
          />
        );
      }

      // Taken before the render, so the first frame the count asks for is one
      // this test draws.
      const frames = frameClock();

      try {
        const screen = await render(counting());

        // The count's clock starts at its first frame, whatever time that is.
        await frames.draw(1000);
        await frames.draw(1300);

        expect(figure()).toBe(300);

        await screen.rerender(counting());
        await frames.draw(1600);

        // 600ms in. A loop started again by the new function would take its
        // start time on this frame and still be at 300, and one that counted
        // again from `from` would be back at 0.
        expect(figure()).toBe(600);
      } finally {
        frames.restore();
      }
    });
  });

  it('lands on the number it was given', async () => {
    await render(
      <PlAnimateCounter className="counter-under-test" trigger="mount" value={4812} duration={50} />
    );

    await expect.poll(() => drawn()).toBe('4,812');
  });

  it('starts from zero unless it was told otherwise', async () => {
    await render(
      <PlAnimateCounter
        className="counter-under-test"
        trigger="manual"
        value={4812}
        duration={5000}
      />
    );

    expect(drawn()).toBe('0');
  });

  it('starts from where it was told', async () => {
    await render(
      <PlAnimateCounter
        className="counter-under-test"
        trigger="manual"
        from={4000}
        value={4812}
        duration={5000}
      />
    );

    expect(drawn()).toBe('4,000');
  });

  describe('the formatting', () => {
    it('is what the count is JavaScript for', async () => {
      await render(
        <PlAnimateCounter
          className="counter-under-test"
          trigger="mount"
          value={48120}
          duration={50}
          format={{ style: 'currency', currency: 'GBP', maximumFractionDigits: 0 }}
        />
      );

      // A CSS counter can tick a number and cannot put a currency symbol on it.
      await expect.poll(() => drawn()).toBe('£48,120');
    });

    it('folds a big number when it is asked to', async () => {
      await render(
        <PlAnimateCounter
          className="counter-under-test"
          trigger="mount"
          value={1200000}
          duration={50}
          format={{ notation: 'compact' }}
        />
      );

      await expect.poll(() => drawn()).toBe('1.2M');
    });
  });

  describe('the trigger', () => {
    it('waits to be seen rather than starting on mount', async () => {
      // Pushed below the fold on purpose. Rendered where the reader can already
      // see it, the observer reports it as seen straight away and starting is
      // the right answer — which would leave the assertion racing the browser
      // rather than testing anything.
      await render(
        <>
          <div style={{ height: '200vh' }} />
          <PlAnimateCounter className="counter-under-test" value={4812} duration={5000} />
        </>
      );

      // The one component in the library that does not start on mount: a count
      // that ran off screen delivered a number that was already there.
      expect(root().dataset.state).toBe('paused');
    });

    it('counts when a caller presses go', async () => {
      await render(
        <PlAnimateCounter
          className="counter-under-test"
          trigger="manual"
          play
          value={4812}
          duration={50}
        />
      );

      await expect.poll(() => drawn()).toBe('4,812');
    });

    it('counts again when the target changes', async () => {
      await render(
        <PlAnimateCounter className="counter-under-test" trigger="mount" value={10} duration={30} />
      );

      await expect.poll(() => drawn()).toBe('10');

      await render(
        <PlAnimateCounter
          className="counter-under-test second"
          trigger="mount"
          value={20}
          duration={30}
        />
      );

      await expect
        .poll(
          () =>
            document.querySelector<HTMLElement>('.second [aria-hidden="true"]')?.textContent ?? ''
        )
        .toBe('20');
    });

    it('counts a new `value` from `from`, even when a frame lands before its run starts', async () => {
      function Host() {
        const [value, setValue] = useState(100);

        return (
          <>
            <button type="button" onClick={() => setValue(200)}>
              More
            </button>
            <PlAnimateCounter
              className="counter-under-test"
              trigger="mount"
              value={value}
              duration={50}
            />
          </>
        );
      }

      await render(<Host />);
      await expect.poll(() => figure()).toBe(100);

      const seen: number[] = [];
      const observer = new MutationObserver(() => seen.push(figure()));

      observer.observe(root().querySelector('[aria-hidden="true"]')!, {
        characterData: true,
        childList: true,
        subtree: true
      });

      const restore = frameBeforeTheNextRender();

      try {
        // A native click rather than a rerender, which would finish every render
        // it causes before any frame could run.
        document.querySelector('button')!.click();
        await expect.poll(() => seen.length).toBeGreaterThan(0);
      } finally {
        restore();
        observer.disconnect();
      }

      // The count that finished at 100 lends the new one nothing. Given its
      // progress, that frame would draw 200 before the new run dropped to 0.
      expect(seen[0]).toBeLessThan(100);
    });
  });

  describe('accessibility', () => {
    it('tells a screen reader the answer and hides the count', async () => {
      await render(
        <PlAnimateCounter
          className="counter-under-test"
          trigger="manual"
          value={4812}
          duration={5000}
        />
      );

      // A number changing sixty times a second in the accessibility tree is
      // either silence or sixty announcements, and neither is the figure.
      expect(announced()).toBe('4,812');
      expect(drawn()).toBe('0');
    });

    it('is simply the number where a reader asked for less motion', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      await render(
        <PlAnimateCounter
          className="counter-under-test"
          trigger="manual"
          value={4812}
          duration={5000}
        />
      );

      await expect.poll(() => drawn()).toBe('4,812');
    });
  });

  it('renders something other than a span when it is handed one', async () => {
    await render(
      <PlAnimateCounter
        className="counter-under-test"
        trigger="mount"
        value={1}
        duration={20}
        render={<div />}
      />
    );

    expect(root().tagName).toBe('DIV');
  });
});
