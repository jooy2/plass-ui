import { afterEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { useState } from 'react';
import { PlAnimateScramble } from 'plass-ui';
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

const LINE = 'Ship it on Friday';

function root(): HTMLElement {
  return document.querySelector<HTMLElement>('.scramble-under-test')!;
}

/** What a sighted reader sees right now. */
function drawn(): string {
  return root().querySelector<HTMLElement>('[aria-hidden="true"]')!.textContent ?? '';
}

/** What a screen reader is told, which is the line and not the noise. */
function announced(): string {
  return (root().firstElementChild as HTMLElement).textContent ?? '';
}

/**
 * How many characters at the start of the line match the line. Only right with
 * a pool that holds none of the line's own letters, such as `01`.
 */
function settled(): number {
  const now = Array.from(drawn());
  const line = Array.from(LINE);
  let count = 0;

  while (count < line.length && now[count] === line[count]) {
    count += 1;
  }

  return count;
}

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

describe('PlAnimateScramble', () => {
  describe('pausing', () => {
    function line(paused: boolean) {
      return (
        <PlAnimateScramble
          className="scramble-under-test"
          trigger="mount"
          duration={1000}
          tick={10}
          characters="01"
          paused={paused}
        >
          {LINE}
        </PlAnimateScramble>
      );
    }

    it('holds the line where it is, and goes on settling from there when it is let go', async () => {
      // Taken before the render, so the first frame the line asks for is one
      // this test draws.
      const frames = frameClock();

      try {
        const screen = await render(line(false));

        // The line's clock starts at its first frame, whatever time that is.
        await frames.draw(1000);
        await frames.draw(1400);

        // 400ms of the 1000ms have gone by, which is six of the seventeen
        // characters.
        expect(settled()).toBe(6);

        await screen.rerender(line(true));

        const held = drawn();

        // Two frames, since a loop started again by the change would take its
        // start time on the first and settle only from there.
        await frames.draw(1700);
        await frames.draw(2000);

        // A line that went on settling while it was held would have more than
        // six characters settled here.
        expect(drawn()).toBe(held);

        await screen.rerender(line(false));
        // However late the page draws again after it is let go, the clock goes
        // on from the 400ms the line had already settled for.
        await frames.draw(5000);

        expect(settled()).toBe(6);

        await frames.draw(5100);

        // 500ms in, which is eight of the seventeen. A loop that took its start
        // time again would be 100ms in, with one character settled.
        expect(settled()).toBe(8);

        await frames.draw(5600);

        expect(drawn()).toBe(LINE);
      } finally {
        frames.restore();
      }
    });

    it('waits out only what was left of `delay` when it is let go', async () => {
      function waiting(paused: boolean) {
        return (
          <PlAnimateScramble
            className="scramble-under-test"
            trigger="mount"
            delay={600}
            duration={100}
            tick={10}
            characters="01"
            paused={paused}
          >
            {LINE}
          </PlAnimateScramble>
        );
      }

      // Taken before the render, so the first frame the line asks for is one
      // this test draws.
      const frames = frameClock();

      try {
        const screen = await render(waiting(false));

        // The line's clock starts at its first frame, whatever time that is.
        await frames.draw(1000);
        await frames.draw(1300);

        // Half of the wait has gone by, so what is held is the wait itself.
        expect(settled()).toBe(0);

        await screen.rerender(waiting(true));
        await frames.draw(1600);

        expect(settled()).toBe(0);

        await screen.rerender(waiting(false));
        // However late the page draws again after it is let go, the clock goes
        // on from the 300ms the line had already waited.
        await frames.draw(5000);
        await frames.draw(5299);

        // 300ms of the wait was left, and 299 of them have gone by.
        expect(settled()).toBe(0);

        await frames.draw(5350);

        // Halfway through the 100ms of settling after it, which is eight of the
        // seventeen characters. A loop that waited out the whole `delay` again
        // would still be noise here.
        expect(settled()).toBe(8);

        await frames.draw(5400);

        expect(drawn()).toBe(LINE);
      } finally {
        frames.restore();
      }
    });
  });

  it('settles on the line it was given', async () => {
    await render(
      <PlAnimateScramble className="scramble-under-test" trigger="mount" duration={40}>
        {LINE}
      </PlAnimateScramble>
    );

    await expect.poll(() => drawn()).toBe(LINE);
  });

  it('starts as noise rather than as the line', async () => {
    await render(
      <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={5000}>
        {LINE}
      </PlAnimateScramble>
    );

    // Not started is the first frame: a line waiting to be scrolled to is
    // already noise, not already settled.
    expect(drawn()).not.toBe(LINE);
  });

  describe('the noise', () => {
    it('is made of the line’s own characters', async () => {
      await render(
        <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={5000}>
          {LINE}
        </PlAnimateScramble>
      );

      const own = new Set(Array.from(LINE));

      // English noise over a Korean or a Greek headline is a different script
      // flickering rather than a word arriving.
      for (const character of drawn()) {
        expect(own.has(character)).toBe(true);
      }
    });

    it('does the same in a script that has no Latin letters in it', async () => {
      await render(
        <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={5000}>
          금요일에 배포합니다
        </PlAnimateScramble>
      );

      expect(drawn()).not.toMatch(/[A-Za-z]/);
    });

    it('takes a pool of its own for a caller who wants a terminal', async () => {
      await render(
        <PlAnimateScramble
          className="scramble-under-test"
          trigger="manual"
          duration={5000}
          characters="01"
        >
          {LINE}
        </PlAnimateScramble>
      );

      expect(drawn().replace(/\s/g, '')).toMatch(/^[01]+$/);
    });

    it('never scrambles the spaces', async () => {
      await render(
        <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={5000}>
          {LINE}
        </PlAnimateScramble>
      );

      // The gaps between words are what keeps a line of noise looking like a
      // sentence.
      const spaces = (text: string) => Array.from(text).map((one) => one === ' ');

      expect(spaces(drawn())).toEqual(spaces(LINE));
    });

    it('keeps the line exactly as long as it will be', async () => {
      await render(
        <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={5000}>
          {LINE}
        </PlAnimateScramble>
      );

      expect(drawn().length).toBe(LINE.length);
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
          <PlAnimateScramble className="scramble-under-test" duration={5000}>
            {LINE}
          </PlAnimateScramble>
        </>
      );

      expect(root().dataset.state).toBe('paused');
    });

    it('runs again when the line changes', async () => {
      await render(
        <PlAnimateScramble className="scramble-under-test" trigger="mount" duration={40}>
          {LINE}
        </PlAnimateScramble>
      );

      await expect.poll(() => drawn()).toBe(LINE);

      await render(
        <PlAnimateScramble className="scramble-under-test second" trigger="mount" duration={40}>
          Ship it on Monday
        </PlAnimateScramble>
      );

      await expect
        .poll(
          () =>
            document.querySelector<HTMLElement>('.second [aria-hidden="true"]')?.textContent ?? ''
        )
        .toBe('Ship it on Monday');
    });

    it('settles a new line from the start, even when a frame lands before its run starts', async () => {
      function Host() {
        const [line, setLine] = useState(LINE);

        return (
          <>
            <button type="button" onClick={() => setLine('Ship it on Monday')}>
              Next
            </button>
            <PlAnimateScramble
              className="scramble-under-test"
              trigger="mount"
              duration={300}
              tick={10}
              characters="01"
            >
              {line}
            </PlAnimateScramble>
          </>
        );
      }

      await render(<Host />);

      // Noise first and then the line. The line alone could be the one drawn
      // before the first frame, by a run that has not got anywhere yet.
      await expect.poll(() => drawn()).not.toBe(LINE);
      await expect.poll(() => drawn()).toBe(LINE);

      const seen: string[] = [];
      const observer = new MutationObserver(() => seen.push(drawn()));

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

      // The line that had settled lends the new one nothing, so the first frame
      // of the new line has not settled its first character. Given the old
      // progress, that frame would draw the new line settled but for its end.
      expect(Array.from(seen[0])[0]).not.toBe('S');
    });
  });

  describe('accessibility', () => {
    it('tells a screen reader the line and hides the noise', async () => {
      await render(
        <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={5000}>
          {LINE}
        </PlAnimateScramble>
      );

      expect(announced()).toBe(LINE);
      expect(drawn()).not.toBe(LINE);
    });

    it('is simply the line where a reader asked for less motion', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      await render(
        <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={5000}>
          {LINE}
        </PlAnimateScramble>
      );

      await expect.poll(() => drawn()).toBe(LINE);
    });
  });
});
