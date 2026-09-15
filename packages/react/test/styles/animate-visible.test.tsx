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
import { PlAnimateSlide } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

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
function mask(children: ReactNode) {
  return <div style={{ overflow: 'hidden', width: '200px', height: '120px' }}>{children}</div>;
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
