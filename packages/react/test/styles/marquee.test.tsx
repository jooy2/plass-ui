/**
 * What a marquee does under reduced motion, which the stylesheet decides.
 *
 * The component test checks the one thing the component writes, the tab stop.
 * Which copies are drawn and whether the box clips or scrolls are rules in a
 * `prefers-reduced-motion` block, so they are asserted here, with
 * `src/standalone.css` loaded the way `grid.test.tsx` loads it.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateMarquee } from 'plass-ui';
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

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

const headlines = Array.from({ length: 10 }, (_, index) => `Headline ${index + 1}`);

function box(): HTMLElement {
  return document.querySelector('.marquee-under-test') as HTMLElement;
}

function tracks(): HTMLElement[] {
  return Array.from(box().querySelectorAll<HTMLElement>('.plass-marquee-track'));
}

describe('the marquee stylesheet', () => {
  it('clips a moving strip to its box', async () => {
    await render(
      <PlAnimateMarquee className="marquee-under-test" style={{ width: 400 }}>
        {headlines.map((headline) => (
          <span key={headline} style={{ display: 'block', width: 160 }}>
            {headline}
          </span>
        ))}
      </PlAnimateMarquee>
    );

    expect(getComputedStyle(box()).overflowX).toBe('hidden');
    expect(getComputedStyle(tracks()[1]).display).toBe('flex');
  });

  it('runs a strip across inside a strip that runs down', async () => {
    await render(
      <PlAnimateMarquee
        orientation="vertical"
        className="marquee-under-test"
        style={{ height: 200 }}
      >
        <PlAnimateMarquee className="inner-under-test" style={{ width: 300 }}>
          {headlines.map((headline) => (
            <span key={headline}>{headline}</span>
          ))}
        </PlAnimateMarquee>
      </PlAnimateMarquee>
    );

    const inner = document.querySelector('.inner-under-test > .plass-marquee-track')!;

    expect(getComputedStyle(tracks()[0]).animationName).toBe('plass-anim-marquee-y');
    expect(getComputedStyle(inner).animationName).toBe('plass-anim-marquee-x');
    expect(getComputedStyle(inner).flexDirection).toBe('row');
  });

  describe('under reduced motion', () => {
    it('draws one copy and scrolls the box along it', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      await render(
        <PlAnimateMarquee className="marquee-under-test" style={{ width: 400 }}>
          {headlines.map((headline) => (
            <span key={headline} style={{ display: 'block', width: 160 }}>
              {headline}
            </span>
          ))}
        </PlAnimateMarquee>
      );

      expect(getComputedStyle(tracks()[1]).display).toBe('none');
      expect(getComputedStyle(box()).overflowX).toBe('auto');
      expect(getComputedStyle(box()).overflowY).toBe('hidden');
      // The box scrolls as far as the last headline of the first copy and no
      // further, so there is no second pass to scroll into.
      expect(box().scrollWidth).toBe(tracks()[0].offsetWidth);
    });

    it('scrolls a vertical strip down its own axis', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      await render(
        <PlAnimateMarquee
          className="marquee-under-test"
          orientation="vertical"
          style={{ width: 200, height: 120 }}
        >
          {headlines.map((headline) => (
            <span key={headline} style={{ display: 'block', height: 40 }}>
              {headline}
            </span>
          ))}
        </PlAnimateMarquee>
      );

      expect(getComputedStyle(tracks()[1]).display).toBe('none');
      expect(getComputedStyle(box()).overflowX).toBe('hidden');
      expect(getComputedStyle(box()).overflowY).toBe('auto');
      expect(box().scrollHeight).toBe(tracks()[0].offsetHeight);
    });
  });
});
