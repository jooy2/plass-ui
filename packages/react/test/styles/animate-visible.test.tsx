/**
 * What a `trigger="visible"` effect waits for, which the stylesheet decides.
 *
 * The component tests read a class name off an element, and for almost
 * everything that is enough. Not for this one: an effect that has not been
 * scrolled to yet is held on its own *first frame*, and that frame is a
 * keyframe. With no stylesheet in the room a slide waiting to arrive sits
 * exactly where it will land, which is the one arrangement that cannot tell a
 * box measured where it is from a box measured where it is going. So
 * `src/standalone.css` is loaded here the way `marquee.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import type { ReactNode } from 'react';
import { PlAnimateFade, PlAnimateRotate, PlAnimateSlide } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';
import { reported, scrollAndReport } from '../support/visible';

let sheet: HTMLStyleElement;

beforeAll(async () => {
  // A frame is only held while there is an animation to hold it, and a reader
  // who has asked for less movement has none.
  await emulateMedia({ reducedMotion: 'no-preference' });

  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** The box the slide page recommends: a mask cut to the size of what it holds. */
function mask(children: ReactNode, width = 200, height = 120) {
  return (
    <div style={{ overflow: 'hidden', width: `${width}px`, height: `${height}px` }}>{children}</div>
  );
}

/** Two frames, long enough for React to have drawn what a report started or stopped. */
function settled() {
  return new Promise((resolve) => {
    requestAnimationFrame(() => requestAnimationFrame(resolve));
  });
}

function slide() {
  return (
    <PlAnimateSlide
      className="slide-under-test"
      trigger="visible"
      style={{ width: '200px', height: '120px' }}
    >
      Arriving
    </PlAnimateSlide>
  );
}

function root(): HTMLElement {
  return document.querySelector('.slide-under-test') as HTMLElement;
}

describe('a visible trigger inside a box that clips', () => {
  it('starts a slide that is being held behind the mask’s own edge', async () => {
    await render(mask(slide()));

    // `distance` is the element's own height, so all there is to look at while
    // it waits is a box one whole height below the mask, clipped away to
    // nothing. Where the slide will land has been in full view since the page
    // was drawn.
    await expect.poll(() => root().getAttribute('data-state')).toBe('running');
  });

  it('still waits while the mask itself is off the screen', async () => {
    await render(
      <div>
        <div style={{ height: '200vh' }} />
        {mask(slide())}
      </div>
    );

    // Two frames, which is one for each observer's first report.
    await new Promise((resolve) => {
      requestAnimationFrame(() => requestAnimationFrame(resolve));
    });

    expect(root()).toHaveAttribute('data-state', 'paused');
  });
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

function fade(): HTMLElement {
  return document.querySelector('.fade-under-test') as HTMLElement;
}

function scrollPanel(to: number) {
  return scrollAndReport(document.querySelector<HTMLElement>('.panel-under-test')!, to, fade());
}

describe('a visible trigger that is not `once`', () => {
  it('goes on while its share on screen changes, and plays again once it has left and come back', async () => {
    await render(
      panel(
        <PlAnimateFade
          className="fade-under-test"
          trigger="visible"
          once={false}
          duration={60000}
          style={{ height: '100px' }}
        >
          Arriving
        </PlAnimateFade>
      )
    );

    await expect.poll(() => fade().getAttribute('data-state')).toBe('running');

    const first = fade().getAnimations()[0];

    expect(first).toBeDefined();

    // Three tenths of it, and more, stay on screen the whole way, across a
    // dozen of the observer's steps. Each of those used to start it again,
    // rewinding a fade that had never left.
    for (const to of [20, 40, 60, 70]) {
      await scrollPanel(to);
    }

    // Gone, which lets it go. Every report before this one has been answered by
    // the time it is.
    await scrollPanel(400);
    await expect.poll(() => fade().getAttribute('data-state')).toBe('paused');

    expect(fade().getAnimations()[0]).toBe(first);

    // Back, which is a new run, from its first frame.
    await scrollPanel(0);
    await expect.poll(() => fade().getAttribute('data-state')).toBe('running');

    expect(fade().getAnimations()[0]).not.toBe(first);
  });
});

function moving(): HTMLElement {
  return document.querySelector('.moving-under-test') as HTMLElement;
}

function scrollMoving(to: number) {
  return scrollAndReport(document.querySelector<HTMLElement>('.panel-under-test')!, to, moving());
}

/**
 * Sends the effect to `midway`, where most of what is drawn is outside its mask
 * though where it will land is all inside it, and then on to its end.
 */
async function playsThrough(duration: number, midway: number) {
  await expect.poll(() => moving().getAttribute('data-state')).toBe('running');
  await settled();

  const run = moving().getAnimations()[0];

  run.currentTime = midway;
  await reported(moving());
  await settled();

  // Still this run, and still going. Measured where it was drawn, it read as
  // leaving: a slide was held there, and a turn, rewound to a first frame that
  // fits the mask, started again from the beginning.
  expect(moving()).toHaveAttribute('data-state', 'running');
  expect(moving().getAnimations()[0]).toBe(run);

  run.currentTime = duration;

  await expect.poll(() => run.playState).toBe('finished');
  expect(moving()).toHaveAttribute('data-state', 'running');

  return run;
}

describe('a visible trigger that is not `once`, on an effect that moves its own box', () => {
  it('plays a slide in a mask to its end, and again once it has left and come back', async () => {
    await render(
      panel(
        mask(
          <PlAnimateSlide
            className="moving-under-test"
            trigger="visible"
            once={false}
            duration={10000}
            easing="linear"
            style={{ width: '200px', height: '120px' }}
          >
            Arriving
          </PlAnimateSlide>
        )
      )
    );

    // A tenth of the way up, a tenth of the slide is inside the mask.
    const first = await playsThrough(10000, 1000);

    await scrollMoving(400);
    await expect.poll(() => moving().getAttribute('data-state')).toBe('paused');

    await scrollMoving(0);
    await expect.poll(() => moving().getAttribute('data-state')).toBe('running');

    const second = moving().getAnimations()[0];

    expect(second).not.toBe(first);
    expect(Number(second.currentTime)).toBeLessThan(5000);
  });

  it('plays a turn in a mask to its end', async () => {
    await render(
      panel(
        mask(
          <PlAnimateRotate
            className="moving-under-test"
            trigger="visible"
            once={false}
            duration={10000}
            easing="linear"
            style={{ width: '300px', height: '30px' }}
          >
            Turning
          </PlAnimateRotate>,
          300,
          30
        )
      )
    );

    // Halfway, it stands on its end: a tenth of the box its corners sweep is
    // inside a mask cut to where it lands.
    await playsThrough(10000, 5000);
  });

  it('leaves a slide that goes out of its mask gone while the mask is on screen', async () => {
    await render(
      panel(
        <>
          <div style={{ height: '40px' }} />
          {mask(
            <PlAnimateSlide
              className="moving-under-test"
              mode="out"
              trigger="visible"
              once={false}
              duration={10000}
              easing="linear"
              style={{ width: '200px', height: '120px' }}
            >
              Leaving
            </PlAnimateSlide>
          )}
        </>
      )
    );

    const run = await playsThrough(10000, 9000);

    // Each of these changes how much of the mask is in view, and each report
    // used to find the slide gone from it, let it go, rewind it into the mask
    // and send it out again.
    for (const to of [50, 60, 70, 80]) {
      await scrollMoving(to);
      await settled();

      expect(moving().getAnimations()[0]).toBe(run);
    }

    expect(run.playState).toBe('finished');
  });
});
