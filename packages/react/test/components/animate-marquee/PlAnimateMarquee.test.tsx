import { afterEach, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateMarquee } from 'plass-ui';
import { emulateMedia } from '../../support/media';

describe('PlAnimateMarquee', () => {
  it('names the effect it is running', async () => {
    await render(
      <PlAnimateMarquee className="marquee-under-test">
        <span>Acme</span>
      </PlAnimateMarquee>
    );

    expect(document.querySelector('.marquee-under-test')).toHaveAttribute(
      'data-plass-animation',
      'marquee'
    );
  });

  describe('copies', () => {
    it('lays the content down twice, which is what closes the seam', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test">
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      const tracks = document.querySelectorAll('.marquee-under-test > .plass-marquee-track');

      expect(tracks).toHaveLength(2);
    });

    it('takes more copies for content short enough to leave a hole', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" copies={4}>
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      expect(document.querySelectorAll('.plass-marquee-track')).toHaveLength(4);
    });

    it('never draws fewer than one', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" copies={0}>
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      expect(document.querySelectorAll('.plass-marquee-track')).toHaveLength(1);
    });

    it('reads out the first copy only', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" copies={3}>
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      const tracks = document.querySelectorAll('.plass-marquee-track');

      expect(tracks[0]).not.toHaveAttribute('aria-hidden');
      expect(tracks[1]).toHaveAttribute('aria-hidden', 'true');
      expect(tracks[2]).toHaveAttribute('aria-hidden', 'true');
    });

    it('reaches the links in the first copy only', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" copies={3}>
          <a href="#acme">Acme</a>
        </PlAnimateMarquee>
      );

      const links = document.querySelectorAll<HTMLAnchorElement>('.marquee-under-test a');

      // `aria-hidden` takes a copy off the accessibility tree and leaves its
      // links on the tab order, where each one would be focused with no name.
      links[0].focus();
      expect(document.activeElement).toBe(links[0]);

      links[1].focus();
      expect(document.activeElement).not.toBe(links[1]);

      links[2].focus();
      expect(document.activeElement).not.toBe(links[2]);
    });
  });

  describe('orientation', () => {
    it('runs across by default', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test">
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      expect(document.querySelector('.marquee-under-test')).not.toHaveClass(
        'plass-marquee-vertical'
      );
    });

    it('runs down when asked', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" orientation="vertical">
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      expect(document.querySelector('.marquee-under-test')).toHaveClass('plass-marquee-vertical');
    });
  });

  it('runs the strip the other way round', async () => {
    await render(
      <PlAnimateMarquee className="marquee-under-test" reverse>
        <span>Acme</span>
      </PlAnimateMarquee>
    );

    const root = document.querySelector('.marquee-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-direction')).toBe('reverse');
  });

  it('reads the gap as a CSS length', async () => {
    await render(
      <PlAnimateMarquee className="marquee-under-test" gap={48}>
        <span>Acme</span>
      </PlAnimateMarquee>
    );

    const root = document.querySelector('.marquee-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-gap')).toBe('48px');
  });

  it('measures once rather than on every render a parent does', async () => {
    const Native = window.ResizeObserver;
    let built = 0;

    class Counted extends Native {
      constructor(callback: ResizeObserverCallback) {
        super(callback);
        built += 1;
      }
    }

    window.ResizeObserver = Counted as unknown as typeof ResizeObserver;

    try {
      const screen = await render(
        <PlAnimateMarquee className="marquee-under-test">
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      const first = built;

      // The same content, as a new element: that is what a parent rendering
      // again hands the strip, and it used to read the layout back and build
      // another observer every time.
      await screen.rerender(
        <PlAnimateMarquee className="marquee-under-test">
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      expect(built).toBe(first);
    } finally {
      window.ResizeObserver = Native;
    }
  });

  describe('duration', () => {
    it('is the measured strip divided by the speed, not a number a caller gave', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" gap={0} speed={100}>
          <span style={{ display: 'block', width: 500 }}>Acme</span>
        </PlAnimateMarquee>
      );

      const root = document.querySelector('.marquee-under-test') as HTMLElement;
      const track = document.querySelector('.plass-marquee-track') as HTMLElement;

      // Nothing loads the stylesheet here, so the strip is whatever the test
      // frame let it be — which is the point: the duration follows the
      // measurement rather than the prop, at 100 pixels a second.
      expect(track.offsetWidth).toBeGreaterThan(0);
      expect(root.style.getPropertyValue('--p-anim-duration')).toBe(
        `${Math.round(track.offsetWidth * 10)}ms`
      );
    });

    it('halving the speed doubles the time one pass takes', async () => {
      const screen = await render(
        <PlAnimateMarquee className="marquee-under-test" gap={0} speed={100}>
          <span style={{ display: 'block', width: 500 }}>Acme</span>
        </PlAnimateMarquee>
      );

      const root = document.querySelector('.marquee-under-test') as HTMLElement;
      const fast = parseFloat(root.style.getPropertyValue('--p-anim-duration'));

      await screen.rerender(
        <PlAnimateMarquee className="marquee-under-test" gap={0} speed={50}>
          <span style={{ display: 'block', width: 500 }}>Acme</span>
        </PlAnimateMarquee>
      );

      expect(parseFloat(root.style.getPropertyValue('--p-anim-duration'))).toBe(fast * 2);
    });

    it('holds the strip still at a speed of zero or less', async () => {
      for (const speed of [0, -60]) {
        await render(
          <PlAnimateMarquee className="marquee-under-test" gap={0} speed={speed}>
            <span style={{ display: 'block', width: 500 }}>Acme</span>
          </PlAnimateMarquee>
        );

        const root = document.querySelector('.marquee-under-test') as HTMLElement;

        // Dividing the travel by nothing wrote `Infinityms`, which no browser
        // reads. A speed of nothing is not moving, so the strip is paused.
        expect(root.dataset.state).toBe('paused');
        expect(root.style.getPropertyValue('--p-anim-duration')).toBe('12000ms');
      }
    });

    it('lets an explicit duration win over the measurement', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" duration={9000}>
          <span style={{ display: 'block', width: 500 }}>Acme</span>
        </PlAnimateMarquee>
      );

      const root = document.querySelector('.marquee-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-duration')).toBe('9000ms');
    });
  });

  describe('as a tab stop', () => {
    afterEach(async () => {
      await emulateMedia({ reducedMotion: 'no-preference' });
    });

    // Nothing loads the stylesheet here, so what the box holds is whatever the
    // test frame lays out: a 500px line in a 200px box overflows it either way.
    it('is one while it scrolls, where a reader asked for less motion', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      await render(
        <PlAnimateMarquee className="marquee-under-test" style={{ width: 200 }}>
          <span style={{ display: 'block', width: 500 }}>Acme</span>
        </PlAnimateMarquee>
      );

      await expect
        .poll(() => document.querySelector('.marquee-under-test')!.getAttribute('tabindex'))
        .toBe('0');
    });

    it('is not one where everything fits', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      await render(
        <PlAnimateMarquee className="marquee-under-test" style={{ width: 500 }}>
          <span style={{ display: 'block', width: 100 }}>Acme</span>
        </PlAnimateMarquee>
      );

      expect(document.querySelector('.marquee-under-test')).not.toHaveAttribute('tabindex');
    });

    it('is not one while the strip moves, since there is nothing to scroll to', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" style={{ width: 200 }}>
          <span style={{ display: 'block', width: 500 }}>Acme</span>
        </PlAnimateMarquee>
      );

      expect(document.querySelector('.marquee-under-test')).not.toHaveAttribute('tabindex');
    });
  });

  describe('pauseOnHover', () => {
    it('stops under the pointer by default, so a link on the strip can be followed', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test">
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      expect(document.querySelector('.marquee-under-test')).toHaveAttribute('data-pause-on-hover');
    });

    it('keeps going when a caller turns it off', async () => {
      await render(
        <PlAnimateMarquee className="marquee-under-test" pauseOnHover={false}>
          <span>Acme</span>
        </PlAnimateMarquee>
      );

      expect(document.querySelector('.marquee-under-test')).not.toHaveAttribute(
        'data-pause-on-hover'
      );
    });
  });
});
