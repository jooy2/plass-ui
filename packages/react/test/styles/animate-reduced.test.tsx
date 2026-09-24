/**
 * What an effect shows a reader who has asked for less movement, which the
 * stylesheet decides.
 *
 * Under reduced motion an effect is run in no time rather than switched off, so
 * what is on screen is its last frame, and that frame is a keyframe: with no
 * stylesheet in the room every element sits in its natural state whatever it
 * was asked to do. So `src/standalone.css` is loaded here the way
 * `marquee.test.tsx` loads it. What is asserted is whether the content is there
 * and the angle a caller asked for, never a shade or a size.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAnimateFade,
  PlAnimateGrow,
  PlAnimateReveal,
  PlAnimateRotate,
  PlAnimateSlide,
  PlAnimateSplit,
  PlAnimateZoom
} from 'plass-ui';
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
  await emulateMedia({ reducedMotion: 'reduce' });
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/** The element carrying the effect, found by the class a test gave it. */
function target(): HTMLElement {
  return document.querySelector('.effect-under-test') as HTMLElement;
}

const opacity = (element: HTMLElement) => getComputedStyle(element).opacity;

/**
 * Whether anything of the element is drawn: it is not faded away and not
 * clipped away. A reveal leaves by its `clip-path` and keeps its ink.
 */
function drawn(element: HTMLElement): boolean {
  const style = getComputedStyle(element);
  const clip = style.clipPath;

  return style.opacity !== '0' && (clip === 'none' || /^inset\(0(px)?\)$/.test(clip));
}

/** Long enough for a frame, which is all a run in no time takes. */
const frame = () => new Promise((resolve) => setTimeout(resolve, 50));

describe('an effect under reduced motion', () => {
  it('turns to the angle it was asked to end at', async () => {
    await render(
      <PlAnimateRotate className="effect-under-test" from={0} to={90} fade={false}>
        Turning
      </PlAnimateRotate>
    );

    await expect.poll(() => getComputedStyle(target()).rotate).toBe('90deg');
  });

  it('stands at that angle while it waits to be let go', async () => {
    await render(
      <PlAnimateRotate className="effect-under-test" from={0} to={90} trigger="manual">
        Turning
      </PlAnimateRotate>
    );

    await frame();

    expect(getComputedStyle(target()).rotate).toBe('90deg');
    expect(opacity(target())).toBe('1');
  });

  it('ends one pass of an endless turn', async () => {
    await render(
      <PlAnimateRotate
        className="effect-under-test"
        from={0}
        to={90}
        fade={false}
        repeat="infinite"
        easing="linear"
      >
        Turning
      </PlAnimateRotate>
    );

    await expect.poll(() => getComputedStyle(target()).rotate).toBe('90deg');
  });

  it('keeps an entrance', async () => {
    await render(<PlAnimateFade className="effect-under-test">Arriving</PlAnimateFade>);

    await frame();

    expect(opacity(target())).toBe('1');
  });

  it('shows an entrance that is waiting for its trigger', async () => {
    await render(
      <PlAnimateFade className="effect-under-test" trigger="manual">
        Arriving
      </PlAnimateFade>
    );

    await frame();

    expect(opacity(target())).toBe('1');
  });

  for (const [name, exit] of [
    ['PlAnimateFade', <PlAnimateFade key="fade" className="effect-under-test" mode="out" />],
    ['PlAnimateGrow', <PlAnimateGrow key="grow" className="effect-under-test" mode="out" />],
    ['PlAnimateZoom', <PlAnimateZoom key="zoom" className="effect-under-test" mode="out" />],
    ['PlAnimateSlide', <PlAnimateSlide key="slide" className="effect-under-test" mode="out" />],
    ['PlAnimateRotate', <PlAnimateRotate key="rotate" className="effect-under-test" mode="out" />],
    ['PlAnimateReveal', <PlAnimateReveal key="reveal" className="effect-under-test" mode="out" />]
  ] as const) {
    it(`hides a ${name} that leaves`, async () => {
      await render(exit);

      await expect.poll(() => drawn(target())).toBe(false);
    });
  }

  it('hides every part of a PlAnimateSplit that leaves', async () => {
    await render(
      <PlAnimateSplit className="effect-under-test" mode="out">
        Two words
      </PlAnimateSplit>
    );

    const parts = () => Array.from(target().querySelectorAll<HTMLElement>('.plass-anim'));

    expect(parts()).toHaveLength(2);
    await expect.poll(() => parts().some(drawn)).toBe(false);
  });

  it('tells a caller waiting on the end that it has ended', async () => {
    const ended = vi.fn();

    await render(
      <PlAnimateFade className="effect-under-test" mode="out" onAnimationEnd={ended}>
        Leaving
      </PlAnimateFade>
    );

    await expect.poll(() => ended.mock.calls.length).toBe(1);
  });

  it('leaves an exit in place until it is let go', async () => {
    const screen = await render(
      <PlAnimateFade className="effect-under-test" mode="out" trigger="manual" play={false}>
        Leaving
      </PlAnimateFade>
    );

    await frame();

    expect(opacity(target())).toBe('1');

    await screen.rerender(
      <PlAnimateFade className="effect-under-test" mode="out" trigger="manual" play>
        Leaving
      </PlAnimateFade>
    );

    await expect.poll(() => opacity(target())).toBe('0');
  });

  it('keeps an exit on screen for its delay', async () => {
    await render(
      <PlAnimateFade className="effect-under-test" mode="out" delay={400}>
        Leaving
      </PlAnimateFade>
    );

    await frame();

    expect(opacity(target())).toBe('1');
    await expect.poll(() => opacity(target())).toBe('0');
  });

  it('ends where an alternating run ends', async () => {
    // Out and back: the second pass runs backwards, so it finishes faded out.
    await render(
      <PlAnimateFade className="effect-under-test" alternate repeat={2}>
        Blinking once
      </PlAnimateFade>
    );

    await expect.poll(() => opacity(target())).toBe('0');
  });
});
