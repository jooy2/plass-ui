import { commands } from 'vitest/browser';
import { afterEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateCounter } from 'plass-ui';

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

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: 'no-preference' });
});

describe('PlAnimateCounter', () => {
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
      await render(
        <PlAnimateCounter className="counter-under-test" value={4812} duration={5000} />
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
      await commands.emulateMedia({ reducedMotion: 'reduce' });

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
