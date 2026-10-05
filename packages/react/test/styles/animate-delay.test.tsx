/**
 * What a new `delay` does to an effect, which depends on where its run is.
 *
 * While the run is still waiting out its delay, the new one is measured from
 * when the wait began, as a keyframe measures a new `animation-delay`. Once the
 * run is under way it keeps the delay it started with, and the new one is
 * waited out from the next run on. Where a run is, is a question about the
 * page's animations, and there are none without the stylesheet, so
 * `src/standalone.css` is loaded here the way `animate-reduced.test.tsx` loads
 * it.
 */
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateFade, PlAnimateLighting } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });

  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** The element carrying the effect, found by the class a test gave it. */
function target(): HTMLElement {
  return document.querySelector('.effect-under-test') as HTMLElement;
}

/** The keyframe running on `element` itself. */
function keyframe(element: HTMLElement): Animation {
  return element.getAnimations()[0];
}

/** The delay the keyframe on `element` is running with. */
function delayOf(element: HTMLElement): number {
  return Number(keyframe(element).effect!.getComputedTiming().delay);
}

/**
 * Long enough that no run started in a test is anywhere near its end, nor any
 * wait that long anywhere near over, however slow the runner is.
 */
const long = 60_000;

function wait(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

describe('a new `delay`', () => {
  it('leaves a run that is under way going', async () => {
    const started = vi.fn();
    const fade = (delay: number) => (
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        delay={delay}
        easing="linear"
        onAnimationStart={started}
      >
        Arriving
      </PlAnimateFade>
    );
    const screen = await render(fade(50));

    await expect.poll(() => started.mock.calls.length).toBe(1);
    await screen.rerender(fade(long));

    expect(delayOf(target())).toBe(50);
    expect(keyframe(target()).playState).toBe('running');
    // Polled, since a run that has only just begun can still read 0 in WebKit;
    // one sent back to waiting would read 0 for the whole of its new delay.
    await expect.poll(() => getComputedStyle(target()).opacity).not.toBe('0');
  });

  it('leaves a run that is under way and paused where it is', async () => {
    const started = vi.fn();
    const fade = (delay: number, paused: boolean) => (
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        delay={delay}
        paused={paused}
        easing="linear"
        onAnimationStart={started}
      >
        Arriving
      </PlAnimateFade>
    );
    const screen = await render(fade(0, false));

    await expect.poll(() => started.mock.calls.length).toBe(1);
    await wait(100);
    await screen.rerender(fade(0, true));
    await screen.rerender(fade(long, true));

    expect(delayOf(target())).toBe(0);
    expect(keyframe(target()).playState).toBe('paused');
    expect(getComputedStyle(target()).opacity).not.toBe('0');
  });

  it('leaves a run that landed under reduced motion where it landed', async () => {
    const ended = vi.fn();
    const fade = (delay: number) => (
      <PlAnimateFade
        className="effect-under-test"
        mode="out"
        duration={long}
        delay={delay}
        onAnimationEnd={ended}
      >
        Leaving
      </PlAnimateFade>
    );

    await emulateMedia({ reducedMotion: 'reduce' });

    try {
      const screen = await render(fade(0));

      await expect.poll(() => ended.mock.calls.length).toBe(1);
      await emulateMedia({ reducedMotion: 'no-preference' });
      await screen.rerender(fade(long));

      expect(keyframe(target()).playState).toBe('finished');
      expect(getComputedStyle(target()).opacity).toBe('0');
    } finally {
      await emulateMedia({ reducedMotion: 'no-preference' });
    }
  });

  it('is waited out from the next run on', async () => {
    const started = vi.fn();
    const fade = (delay: number, play: boolean) => (
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        delay={delay}
        trigger="manual"
        play={play}
        onAnimationStart={started}
      >
        Arriving
      </PlAnimateFade>
    );
    const screen = await render(fade(0, true));

    await expect.poll(() => started.mock.calls.length).toBe(1);
    await screen.rerender(fade(long, true));
    await screen.rerender(fade(long, false));
    await screen.rerender(fade(long, true));

    expect(delayOf(target())).toBe(long);
    expect(getComputedStyle(target()).opacity).toBe('0');
  });

  it('is measured from when the wait began while the run is still waiting', async () => {
    const fade = (delay: number) => (
      <PlAnimateFade className="effect-under-test" duration={long} delay={delay} easing="linear">
        Arriving
      </PlAnimateFade>
    );
    const screen = await render(fade(long));

    await expect.poll(() => keyframe(target()).playState).toBe('running');
    await wait(200);
    await screen.rerender(fade(100));

    // The wait has already gone past the new delay, so the run is as far into
    // itself as it would be by now rather than waiting another 100ms.
    expect(delayOf(target())).toBe(100);
    expect(getComputedStyle(target()).opacity).not.toBe('0');

    await screen.rerender(fade(long));

    expect(delayOf(target())).toBe(long);
    expect(getComputedStyle(target()).opacity).toBe('0');
  });

  it('leaves the parts of a stagger that are under way going, and moves the ones still waiting', async () => {
    const started = vi.fn();
    const fade = (delay: number) => (
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        delay={delay}
        stagger={long}
        onAnimationStart={started}
      >
        <span>Here</span>
        <span>Later</span>
      </PlAnimateFade>
    );
    const screen = await render(fade(0));
    const [first, second] = Array.from(target().children) as HTMLElement[];

    await expect.poll(() => started.mock.calls.length).toBe(1);
    await screen.rerender(fade(1000));

    expect(delayOf(first)).toBe(0);
    expect(getComputedStyle(first).opacity).not.toBe('0');
    expect(delayOf(second)).toBe(long + 1000);
  });

  it('leaves the arc of a PlAnimateLighting that is under way going', async () => {
    const started = vi.fn();
    const lighting = (delay: number) => (
      <PlAnimateLighting className="effect-under-test" delay={delay} onAnimationStart={started}>
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );
    const screen = await render(lighting(0));
    const arc = () => target().getAnimations({ subtree: true })[0];

    await expect.poll(() => started.mock.calls.length).toBe(1);
    await screen.rerender(lighting(long));

    expect(arc().effect!.getComputedTiming().delay).toBe(0);
    expect(arc().playState).toBe('running');
  });
});
