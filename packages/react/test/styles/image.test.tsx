/**
 * How long a `PlImage` picture stand-in waits before it goes, which only the
 * stylesheet can answer.
 *
 * The stand-in stays under the picture while the picture fades in over it, and
 * goes in one step once that fade has run. The wait is a transition delay, so
 * the assertion is on the delay the stand-in resolves beside the length of the
 * picture's own fade, read with `src/standalone.css` loaded the way
 * `card.test.tsx` loads it. No length is asserted, only that the two agree,
 * with motion and without it.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlImage } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

const OK =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
const TINY = `data:image/svg+xml,${encodeURIComponent(
  '<svg xmlns="http://www.w3.org/2000/svg" width="3" height="2"></svg>'
)}`;

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

const standIn = () => document.querySelector('img[aria-hidden="true"]') as HTMLImageElement;
const picture = () => document.querySelector('img:not([aria-hidden])') as HTMLImageElement;

/**
 * The seconds `list` gives the element's `opacity` in its transition, where
 * `list` is the resolved duration or delay list. The two lists pair up with the
 * property list by position, and a shorter one repeats, as CSS reads them.
 */
function opacityTiming(element: HTMLElement, list: 'transitionDuration' | 'transitionDelay') {
  const style = getComputedStyle(element);
  const properties = style.transitionProperty.split(',').map((one) => one.trim());
  const lengths = style[list].split(',').map((one) => parseFloat(one));
  const index = properties.indexOf('opacity');

  expect(index).not.toBe(-1);

  return lengths[index % lengths.length];
}

/** Renders a picture with a stand-in and waits for the picture to arrive. */
async function renderLoaded(): Promise<void> {
  await render(<PlImage src={OK} alt="A portrait" ratio="1" placeholder={{ src: TINY }} />);

  await expect.poll(() => picture().className).toContain('opacity-100');
}

describe('the image stylesheet', () => {
  it('holds the stand-in for as long as the picture takes to fade in over it', async () => {
    await renderLoaded();

    expect(opacityTiming(picture(), 'transitionDuration')).toBeGreaterThan(0);
    expect(opacityTiming(standIn(), 'transitionDelay')).toBe(
      opacityTiming(picture(), 'transitionDuration')
    );
  });

  it('takes the stand-in away as the picture arrives under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });
    await renderLoaded();

    expect(opacityTiming(picture(), 'transitionDuration')).toBe(0);
    expect(opacityTiming(standIn(), 'transitionDelay')).toBe(0);
  });
});
