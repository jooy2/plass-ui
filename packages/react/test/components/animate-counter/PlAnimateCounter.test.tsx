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
  return root().querySelector<HTMLElement>('[aria-hidden="true"]')!.dataset.text ?? '';
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
  it('builds its formatters once for a `format` written inline', async () => {
    const Native = Intl.NumberFormat;
    let built = 0;

    class Counted extends Native {
      constructor(locales?: Intl.LocalesArgument, options?: Intl.NumberFormatOptions) {
        super(locales, options);
        built += 1;
      }
    }

    Object.defineProperty(Intl, 'NumberFormat', {
      value: Counted,
      configurable: true,
      writable: true
    });

    try {
      const counter = () => (
        <PlAnimateCounter value={1000} duration={400} format={{ notation: 'compact' }} />
      );

      const screen = await render(counter());
      // The caller's, and the copy the figures on the way are written with.
      const first = built;

      // An options object written inline is a new reference on every render
      // around the counter, and memoising on the object itself built another
      // `Intl.NumberFormat` for each one.
      for (let pass = 0; pass < 5; pass += 1) {
        await screen.rerender(counter());
      }

      expect(first).toBe(2);
      expect(built).toBe(first);
    } finally {
      Object.defineProperty(Intl, 'NumberFormat', {
        value: Native,
        configurable: true,
        writable: true
      });
    }
  });

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

  describe('the figures on the way', () => {
    /**
     * Every figure a count draws on its way to `value`, recorded as each one
     * reaches the DOM. Held first, so the record starts before the first frame,
     * and run on a clock the test holds, a frame every 15ms, so a runner that
     * paints twice in 150ms still sees the figures on the way.
     */
    async function framesOf(
      value: number,
      format?: Intl.NumberFormatOptions,
      from = 0
    ): Promise<string[]> {
      const counter = (play: boolean) => (
        <PlAnimateCounter
          className="counter-under-test"
          trigger="manual"
          play={play}
          from={from}
          value={value}
          duration={150}
          format={format}
        />
      );
      const clock = frameClock();
      const frames: string[] = [];
      const observer = new MutationObserver(() => frames.push(drawn()));

      try {
        const screen = await render(counter(false));

        observer.observe(root().querySelector('[aria-hidden="true"]')!, {
          attributes: true,
          attributeFilter: ['data-text']
        });

        await screen.rerender(counter(true));

        // The count's clock starts at its first frame, and the last one is
        // past the end of the run.
        for (let now = 1000; now <= 1165; now += 15) {
          await clock.draw(now);
        }

        expect(drawn()).toBe(new Intl.NumberFormat(undefined, format).format(value));
      } finally {
        observer.disconnect();
        clock.restore();
      }

      // More than the first and the last, or nothing was seen on the way.
      expect(frames.length).toBeGreaterThan(2);

      return frames;
    }

    it('are whole numbers on the way to a whole number', async () => {
      // The default format writes up to three decimals, which a count to 4,812
      // used to show on every frame but the last: "1,105.535".
      for (const frame of await framesOf(4812)) {
        expect(frame).toMatch(/^[\d,]+$/);
      }
    });

    it('have as many decimals as the answer at most', async () => {
      for (const frame of await framesOf(12.5)) {
        expect(frame).toMatch(/^\d+(\.\d)?$/);
      }
    });

    it('keep the decimals a currency always writes', async () => {
      for (const frame of await framesOf(48120, { style: 'currency', currency: 'GBP' })) {
        expect(frame).toMatch(/^£[\d,]+\.\d\d$/);
      }
    });

    it('take a caller’s `maximumFractionDigits` as a ceiling, not as a number to fill', async () => {
      for (const frame of await framesOf(4812, { maximumFractionDigits: 2 })) {
        expect(frame).toMatch(/^[\d,]+$/);
      }
    });

    it('keep to the significant digits of the answer, and to its fraction digits', async () => {
      // Taken before the render, so the first frame the count asks for is one
      // this test draws.
      const frames = frameClock();

      try {
        await render(
          <PlAnimateCounter
            className="counter-under-test"
            trigger="mount"
            value={4812}
            duration={1000}
            easing={(t) => t}
            format={{ maximumSignificantDigits: 3 }}
          />
        );

        // The count's clock starts at its first frame, whatever time that is.
        await frames.draw(1000);
        await frames.draw(1000.25);

        // 1.203, which three significant digits alone write as "1.2", with a
        // decimal the answer, "4,810", never has.
        expect(drawn()).toBe('1');

        await frames.draw(1500);

        // 2,406, to three significant digits.
        expect(drawn()).toBe('2,410');
      } finally {
        frames.restore();
      }
    });

    describe('in compact notation', () => {
      /**
       * The figures a linear count to `value` in compact notation draws at
       * each of `at`, in milliseconds into a one-second count.
       */
      async function compactAt(
        value: number,
        at: number[],
        format: Intl.NumberFormatOptions = {}
      ): Promise<string[]> {
        // Taken before the render, so the first frame the count asks for is
        // one this test draws.
        const frames = frameClock();
        const seen: string[] = [];

        try {
          await render(
            <PlAnimateCounter
              className="counter-under-test"
              trigger="mount"
              value={value}
              duration={1000}
              easing={(t) => t}
              format={{ notation: 'compact', ...format }}
            />
          );

          // The count's clock starts at its first frame, whatever time that is.
          await frames.draw(1000);

          for (const ms of at) {
            await frames.draw(1000 + ms);
            seen.push(drawn());
          }
        } finally {
          frames.restore();
        }

        return seen;
      }

      it('are whole numbers, then whole thousands, on the way to an answer with no decimals', async () => {
        // 1.6, 1,700 and 4,000. Compact notation writes the first two with a
        // decimal of their own, "1.6" and "1.7K", which "5K" never has.
        expect(await compactAt(5000, [0.32, 340, 800, 1000])).toEqual(['2', '2K', '4K', '5K']);
      });

      it('have the one decimal of an answer that has one, and no more', async () => {
        // 0.048, 123.36 and 1,152. Compact notation writes the first as
        // "0.048", with more decimals than "4.8K", and the other two as it
        // writes them anyway.
        expect(await compactAt(4800, [0.01, 25.7, 240, 1000])).toEqual([
          '0',
          '123',
          '1.2K',
          '4.8K'
        ]);
      });

      it('leave a `roundingPriority` the caller wrote as they wrote it', async () => {
        // The rounding compact notation has of its own, written out.
        const written: Intl.NumberFormatOptions = {
          maximumFractionDigits: 0,
          maximumSignificantDigits: 2,
          roundingPriority: 'morePrecision'
        };

        expect(await compactAt(5000, [0.32, 1000], written)).toEqual(['1.6', '5K']);
      });
    });

    it('write a figure that rounds to zero from below as 0, and a negative one as it is', async () => {
      // Held on the figure it counts from. `Intl.NumberFormat` keeps the sign of
      // a negative number it rounds to zero, so -0.4 was drawn as "-0".
      const counter = (from: number) => (
        <PlAnimateCounter
          className="counter-under-test"
          trigger="manual"
          play={false}
          from={from}
          value={3}
        />
      );
      const screen = await render(counter(-0.4));

      expect(drawn()).toBe('0');

      await screen.rerender(counter(-2.4));
      await expect.poll(() => drawn()).toBe('-2');
    });

    it('never draw -0 on the way up to zero', async () => {
      // Every frame from -0.5 on rounds to zero, and the eased count spends
      // about the last two fifths of its time there.
      for (const frame of await framesOf(0, undefined, -6)) {
        expect(frame).toMatch(/^(-[1-6]|0)$/);
      }
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

    it('waits for its trigger when its `value` changes before it has been started', async () => {
      const counter = (value: number, play: boolean) => (
        <PlAnimateCounter
          className="counter-under-test"
          trigger="manual"
          play={play}
          value={value}
          duration={300}
          easing={(t) => t}
        />
      );
      // Taken before the render, so every frame the count asks for is one this
      // test draws.
      const frames = frameClock();

      try {
        const screen = await render(counter(100, false));

        await screen.rerender(counter(200, false));
        await frames.draw(1000);
        await frames.draw(2000);

        // A new value is what the count will arrive at, not a press of go. It
        // used to start the count, and this would read 200.
        expect(root().dataset.state).toBe('paused');
        expect(drawn()).toBe('0');

        await screen.rerender(counter(200, true));
        await frames.draw(3000);
        await frames.draw(3150);

        // Halfway from `from` to the new value.
        expect(figure()).toBe(100);

        await frames.draw(3300);

        expect(figure()).toBe(200);
      } finally {
        frames.restore();
      }
    });

    it('waits to be seen when its `value` changes before it has been', async () => {
      // Below the fold, for the reason the test above gives.
      const counter = (value: number) => (
        <>
          <div style={{ height: '200vh' }} />
          <PlAnimateCounter className="counter-under-test" value={value} duration={300} />
        </>
      );
      const frames = frameClock();

      try {
        const screen = await render(counter(100));

        await screen.rerender(counter(200));
        await frames.draw(1000);
        await frames.draw(2000);

        // It used to count to 200 where nobody could see it.
        expect(root().dataset.state).toBe('paused');
        expect(drawn()).toBe('0');
      } finally {
        frames.restore();
      }
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
            document.querySelector<HTMLElement>('.second [aria-hidden="true"]')?.dataset.text ?? ''
        )
        .toBe('20');
    });

    it('counts a new `value` on from the figure it landed on, even when a frame lands before its run starts', async () => {
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
              duration={300}
            />
          </>
        );
      }

      await render(<Host />);
      await expect.poll(() => figure()).toBe(100);

      const seen: number[] = [];
      const observer = new MutationObserver(() => seen.push(figure()));

      observer.observe(root().querySelector('[aria-hidden="true"]')!, {
        attributes: true,
        attributeFilter: ['data-text']
      });

      const restore = frameBeforeTheNextRender();

      try {
        // A native click rather than a rerender, which would finish every render
        // it causes before any frame could run.
        document.querySelector('button')!.click();
        await expect.poll(() => figure()).toBe(200);
      } finally {
        restore();
        observer.disconnect();
      }

      // Counted from `from`, the new count dropped to 0 first. Given the last
      // count's progress, the frame before its run started would draw 200.
      expect(seen.length).toBeGreaterThan(1);
      expect(seen.at(-1)).toBe(200);
      expect(seen.slice(0, -1).every((count) => count >= 100 && count < 200)).toBe(true);
    });

    it('counts a new `value` on from the frame a running count had got to', async () => {
      const linear = (t: number) => t;
      const counter = (value: number) => (
        <PlAnimateCounter
          className="counter-under-test"
          trigger="mount"
          value={value}
          duration={1000}
          easing={linear}
        />
      );

      // Taken before the render, so the first frame the count asks for is one
      // this test draws.
      const frames = frameClock();

      try {
        const screen = await render(counter(1000));

        await frames.draw(1000);
        await frames.draw(1300);

        expect(figure()).toBe(300);

        await screen.rerender(counter(2000));
        await frames.draw(1400);

        // The figure on screen, which the new count starts from. A count that
        // started again from `from` would be back at 0.
        expect(figure()).toBe(300);

        await frames.draw(1900);

        // Halfway, over the whole `duration`, from 300 to 2,000.
        expect(figure()).toBe(1150);

        await frames.draw(2400);

        expect(figure()).toBe(2000);
      } finally {
        frames.restore();
      }
    });

    it('counts a replay from `from` again, after a new `value`', async () => {
      const counter = (value: number) => (
        <PlAnimateCounter
          className="counter-under-test"
          trigger="hover"
          value={value}
          duration={300}
        />
      );
      const hover = () => root().dispatchEvent(new PointerEvent('pointerover', { bubbles: true }));
      const screen = await render(counter(100));

      hover();
      await expect.poll(() => figure()).toBe(100);

      await screen.rerender(counter(200));
      await expect.poll(() => figure()).toBe(200);

      const seen: number[] = [];
      const observer = new MutationObserver(() => seen.push(figure()));

      observer.observe(root().querySelector('[aria-hidden="true"]')!, {
        attributes: true,
        attributeFilter: ['data-text']
      });

      try {
        root().dispatchEvent(new PointerEvent('pointerout', { bubbles: true }));
        hover();
        await expect.poll(() => seen.length > 1 && seen.at(-1) === 200).toBe(true);
      } finally {
        observer.disconnect();
      }

      // A second hover is the first count again, from `from`, rather than the
      // last one, from 100.
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
