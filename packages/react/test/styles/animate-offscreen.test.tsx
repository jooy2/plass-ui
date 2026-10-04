/**
 * What an endless effect does while nobody can see it.
 *
 * It rests: a keyframe is paused on the frame it was on, a timer stops being
 * scheduled, and both go on from where they were when the effect is back on
 * screen. A finite effect is left alone. Whether a keyframe is running is a
 * question about the page's animations, and there are none without the
 * stylesheet, so `src/standalone.css` is loaded here the way
 * `animate-visible.test.tsx` loads it.
 */
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import type { ReactNode } from 'react';
import {
  PlAnimateBlink,
  PlAnimateFade,
  PlAnimateFloat,
  PlAnimateHeadline,
  PlAnimateLighting,
  PlAnimateMarquee,
  PlAnimateSlide,
  PlAnimateTyping
} from 'plass-ui';
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

// A marquee pauses under a resting pointer, and the pointer is wherever the
// last file left it, which may be where the strip is drawn.
beforeEach(async () => {
  await commands.parkPointer();
});

/** A scrolling panel with the effect at its top and a long way to scroll past it. */
function panel(children: ReactNode) {
  return (
    <div className="panel-under-test" style={{ height: '200px', overflow: 'auto' }}>
      {children}
      <div style={{ height: '1200px' }} />
    </div>
  );
}

function scrollPanel(to: number) {
  document.querySelector<HTMLElement>('.panel-under-test')!.scrollTop = to;
}

function subject(): HTMLElement {
  return document.querySelector<HTMLElement>('.effect-under-test')!;
}

/** The play state of every animation on the effect and inside it, pseudo-elements included. */
function playStates(): string[] {
  return subject()
    .getAnimations({ subtree: true })
    .map((animation) => animation.playState);
}

function wait(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Scrolls the effect away and back, checking its animations rest and go on.
 * `away` is the state the effect itself reports while it is off screen.
 */
async function restsOffScreen(away: 'paused' | 'running' = 'paused') {
  await expect.poll(() => playStates().length).toBeGreaterThan(0);
  await expect.poll(() => playStates().every((state) => state === 'running')).toBe(true);

  scrollPanel(800);

  await expect.poll(() => playStates().every((state) => state === 'paused')).toBe(true);
  expect(subject()).toHaveAttribute('data-state', away);

  // Held where it stopped rather than rewound: the clock of a resting
  // animation does not move, and it goes on from there.
  const held = subject()
    .getAnimations({ subtree: true })
    .map((animation) => Number(animation.currentTime));

  scrollPanel(0);

  await expect.poll(() => playStates().every((state) => state === 'running')).toBe(true);
  expect(subject()).toHaveAttribute('data-state', 'running');

  const now = subject()
    .getAnimations({ subtree: true })
    .map((animation) => Number(animation.currentTime));

  now.forEach((time, index) => expect(time).toBeGreaterThanOrEqual(held[index]!));
}

describe('an endless effect off screen', () => {
  it('rests a PlAnimateLighting, whose arc is on a pseudo-element', async () => {
    await render(
      panel(
        <PlAnimateLighting className="effect-under-test">
          <div style={{ height: '80px' }}>Glowing</div>
        </PlAnimateLighting>
      )
    );

    await restsOffScreen();
  });

  it('rests a PlAnimateMarquee', async () => {
    await render(
      panel(
        <PlAnimateMarquee className="effect-under-test">
          <span>One</span>
          <span>Two</span>
          <span>Three</span>
        </PlAnimateMarquee>
      )
    );

    await restsOffScreen();
  });

  it('rests a PlAnimateBlink', async () => {
    await render(panel(<PlAnimateBlink className="effect-under-test">Live</PlAnimateBlink>));

    await restsOffScreen();
  });

  it('rests a PlAnimateFloat, which is read off the parent it moves inside', async () => {
    await render(
      panel(
        <div>
          <PlAnimateFloat className="effect-under-test" distance={40}>
            <div style={{ height: '80px' }}>Floating</div>
          </PlAnimateFloat>
        </div>
      )
    );

    await restsOffScreen();
  });

  it('goes on with an endless slide that starts outside its mask', async () => {
    // A mask with the slide half as wide again outside it for the first third
    // of every pass, clear of its edge. Read off the slide itself, that third
    // is off screen, and the slide would rest there, out of sight, for good.
    await render(
      panel(
        <div style={{ overflow: 'hidden', width: '200px', height: '80px' }}>
          <PlAnimateSlide
            className="effect-under-test"
            from="right"
            distance="150%"
            duration={1500}
            easing="linear"
            repeat="infinite"
            style={{ height: '80px' }}
          >
            Arriving
          </PlAnimateSlide>
        </div>
      )
    );

    await expect.poll(() => playStates()).toEqual(['running']);

    const first = Number(subject().getAnimations()[0]!.currentTime);

    await wait(300);

    expect(playStates()).toEqual(['running']);
    expect(Number(subject().getAnimations()[0]!.currentTime)).toBeGreaterThan(first);
  });

  it('rests the caret of a PlAnimateTyping that has finished', async () => {
    await render(panel(<PlAnimateTyping className="effect-under-test" text="Typed" speed={400} />));

    // The typing is finite, so it goes on reporting itself running; the caret
    // after it blinks for ever, and that is what rests.
    await expect.poll(() => subject().getAttribute('data-state')).toBe('running');

    await restsOffScreen('running');
  });

  it('stops typing an endless PlAnimateTyping and goes on from the same character', async () => {
    await render(
      panel(
        <PlAnimateTyping
          className="effect-under-test"
          text="The quick brown fox jumps over the lazy dog"
          speed={40}
          repeat="infinite"
          caret={false}
        />
      )
    );

    const typed = () => subject().querySelector('[aria-hidden="true"]')!.textContent ?? '';

    await expect.poll(() => typed().length).toBeGreaterThan(2);

    scrollPanel(800);
    await expect.poll(() => subject().getAttribute('data-state')).toBe('paused');

    const held = typed();

    await wait(300);

    expect(typed()).toBe(held);

    scrollPanel(0);

    await expect.poll(() => typed().length).toBeGreaterThan(held.length);
    expect(typed().startsWith(held)).toBe(true);
  });

  it('stops turning a looping PlAnimateHeadline', async () => {
    await render(
      panel(
        <PlAnimateHeadline className="effect-under-test" interval={60} duration={10}>
          <span>One</span>
          <span>Two</span>
          <span>Three</span>
        </PlAnimateHeadline>
      )
    );

    const showing = () => subject().querySelector('[data-state="active"]')!.textContent;
    const seen = new Set<string | null>();

    await expect
      .poll(() => {
        seen.add(showing());

        return seen.size;
      })
      .toBeGreaterThan(1);

    scrollPanel(800);
    await expect.poll(() => subject().getAttribute('data-state')).toBe('paused');

    const held = showing();

    await wait(300);

    expect(showing()).toBe(held);

    scrollPanel(0);

    await expect.poll(() => showing()).not.toBe(held);
  });
});

describe('a finite effect off screen', () => {
  it('goes on running', async () => {
    await render(
      panel(
        <PlAnimateFade className="effect-under-test" duration={20000}>
          Arriving
        </PlAnimateFade>
      )
    );

    await expect.poll(() => playStates()).toEqual(['running']);

    scrollPanel(800);
    await wait(200);

    expect(playStates()).toEqual(['running']);
    expect(subject()).toHaveAttribute('data-state', 'running');
  });
});
