import { commands } from 'vitest/browser';
import { afterEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateScramble } from 'plass-ui';

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

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: 'no-preference' });
});

describe('PlAnimateScramble', () => {
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
      await render(
        <PlAnimateScramble className="scramble-under-test" duration={5000}>
          {LINE}
        </PlAnimateScramble>
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
      await commands.emulateMedia({ reducedMotion: 'reduce' });

      await render(
        <PlAnimateScramble className="scramble-under-test" trigger="manual" duration={5000}>
          {LINE}
        </PlAnimateScramble>
      );

      await expect.poll(() => drawn()).toBe(LINE);
    });
  });
});
