import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateMarquee } from 'plass-ui';

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
