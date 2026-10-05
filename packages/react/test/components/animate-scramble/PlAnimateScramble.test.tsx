import { afterEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { useState } from 'react';
import { PlAnimateScramble } from 'plass-ui';
import { committed, frameClock } from '../../support/timing';
import { emulateMedia, emulateReducedMotion } from '../../support/media';

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
  return root().querySelector<HTMLElement>('[aria-hidden="true"]')!.dataset.text ?? '';
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

  describe('a new `delay`', () => {
    function line(delay: number, play = true) {
      return (
        <PlAnimateScramble
          className="scramble-under-test"
          trigger="manual"
          play={play}
          delay={delay}
          duration={1000}
          tick={10}
          characters="01"
        >
          {LINE}
        </PlAnimateScramble>
      );
    }

    it('leaves a line that is settling going', async () => {
      // Taken before the render, so the first frame the line asks for is one
      // this test draws.
      const frames = frameClock();

      try {
        const screen = await render(line(100));

        // The line's clock starts at its first frame, whatever time that is.
        await frames.draw(1000);
        await frames.draw(1400);

        // Three tenths of the way: five of the seventeen characters.
        expect(settled()).toBe(5);

        await screen.rerender(line(1000));
        await frames.draw(1500);

        // Four tenths. A run sent back to waiting would be noise again.
        expect(settled()).toBe(6);

        await frames.draw(2100);

        expect(drawn()).toBe(LINE);
      } finally {
        frames.restore();
      }
    });

    it('is measured from when the wait began while the line is still waiting', async () => {
      const frames = frameClock();

      try {
        const screen = await render(line(1000));

        await frames.draw(1000);
        await frames.draw(1300);

        expect(settled()).toBe(0);

        await screen.rerender(line(200));
        await frames.draw(1400);

        // 400ms after the wait began, so two tenths of the way: three
        // characters.
        expect(settled()).toBe(3);
      } finally {
        frames.restore();
      }
    });

    it('is waited out from the next run on', async () => {
      const frames = frameClock();

      try {
        const screen = await render(line(0));

        await frames.draw(1000);
        await frames.draw(1500);

        expect(settled()).toBe(8);

        await screen.rerender(line(600));
        await frames.draw(2000);

        expect(drawn()).toBe(LINE);

        await screen.rerender(line(600, false));
        await screen.rerender(line(600, true));
        await frames.draw(3000);
        await frames.draw(3599);

        expect(settled()).toBe(0);

        await frames.draw(4100);

        expect(settled()).toBe(8);
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

    it('waits for its trigger when the line changes before it has been started', async () => {
      const scramble = (line: string) => (
        <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={300}>
          {line}
        </PlAnimateScramble>
      );
      // Taken before the render, so every frame the line asks for is one this
      // test draws.
      const frames = frameClock();

      try {
        const screen = await render(scramble(LINE));

        await screen.rerender(scramble('Ship it on Monday'));
        await frames.draw(1000);
        await frames.draw(2000);

        // A new line is what will settle, not a press of go. It used to start
        // the run, and the new line would have settled by now.
        expect(root().dataset.state).toBe('paused');
        expect(drawn()).not.toBe('Ship it on Monday');
      } finally {
        frames.restore();
      }
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
            document.querySelector<HTMLElement>('.second [aria-hidden="true"]')?.dataset.text ?? ''
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
        attributes: true,
        attributeFilter: ['data-text']
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

    it('is noise while a replay waits out its `delay`', async () => {
      const hover = (over: boolean) =>
        committed(() => {
          root().dispatchEvent(
            new PointerEvent(over ? 'pointerover' : 'pointerout', { bubbles: true })
          );
        });
      // Taken before the render, so every frame the line asks for is one this
      // test draws.
      const frames = frameClock();

      try {
        await render(
          <PlAnimateScramble
            className="scramble-under-test"
            trigger="hover"
            delay={500}
            duration={300}
            characters="01"
          >
            {LINE}
          </PlAnimateScramble>
        );

        await hover(true);
        await frames.draw(1000);
        await frames.draw(1800);

        expect(drawn()).toBe(LINE);

        await hover(false);
        await hover(true);
        await frames.draw(2000);

        // Its first frame, which is noise, from the first frame of the wait.
        expect(settled()).toBe(0);

        await frames.draw(2499);

        expect(settled()).toBe(0);
      } finally {
        frames.restore();
      }
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

  describe('when the reader gives movement back', () => {
    it('keeps the line it settled on under reduced motion', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      const frames = frameClock();

      try {
        await render(
          <PlAnimateScramble
            className="scramble-under-test"
            trigger="mount"
            duration={1000}
            tick={10}
            characters="01"
          >
            {LINE}
          </PlAnimateScramble>
        );

        await frames.draw(1000);

        expect(drawn()).toBe(LINE);

        await emulateReducedMotion('no-preference');
        await frames.draw(2000);
        await frames.draw(2300);

        // A line settled again from the start would be noise past its fifth
        // character.
        expect(drawn()).toBe(LINE);
      } finally {
        frames.restore();
      }
    });

    it('is noise for the rest of a wait it was still in, and settles once it is over', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      const frames = frameClock();

      try {
        await render(
          <PlAnimateScramble
            className="scramble-under-test"
            trigger="mount"
            delay={600}
            duration={100}
            tick={10}
            characters="01"
          >
            {LINE}
          </PlAnimateScramble>
        );

        // The wait's clock starts at its first frame, whatever time that is.
        await frames.draw(1000);
        await frames.draw(1300);

        expect(drawn()).toBe(LINE);

        await emulateReducedMotion('no-preference');
        // However late the page draws again, 300ms of the wait was left.
        await frames.draw(5000);

        expect(settled()).toBe(0);

        await frames.draw(5299);

        expect(settled()).toBe(0);

        await frames.draw(5350);

        // Halfway through the 100ms of settling after it: eight of the line's
        // seventeen characters. A run that waited out the whole `delay` again
        // would still be noise.
        expect(settled()).toBe(8);

        await frames.draw(5400);

        expect(drawn()).toBe(LINE);
      } finally {
        frames.restore();
      }
    });

    it('settles the next run from noise as usual', async () => {
      const line = (play: boolean) => (
        <PlAnimateScramble
          className="scramble-under-test"
          trigger="manual"
          play={play}
          duration={1000}
          tick={10}
          characters="01"
        >
          {LINE}
        </PlAnimateScramble>
      );

      await emulateMedia({ reducedMotion: 'reduce' });

      const frames = frameClock();

      try {
        const screen = await render(line(true));

        expect(drawn()).toBe(LINE);

        await emulateReducedMotion('no-preference');
        await frames.draw(2000);

        expect(drawn()).toBe(LINE);

        await screen.rerender(line(false));

        expect(settled()).toBe(0);

        await screen.rerender(line(true));
        await frames.draw(3000);
        await frames.draw(3500);

        expect(settled()).toBe(8);
      } finally {
        frames.restore();
      }
    });
  });
});
