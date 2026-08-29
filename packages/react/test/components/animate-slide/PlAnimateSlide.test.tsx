import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateSlide } from 'plass-ui';

describe('PlAnimateSlide', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateSlide>Arriving</PlAnimateSlide>);

    await expect.element(screen.getByText('Arriving')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateSlide className="slide-under-test">Arriving</PlAnimateSlide>);

    expect(document.querySelector('.slide-under-test')).toHaveAttribute(
      'data-plass-animation',
      'slide'
    );
  });

  describe('from', () => {
    it('comes up from below by default, its own height away', async () => {
      await render(<PlAnimateSlide className="slide-under-test">Arriving</PlAnimateSlide>);

      const root = document.querySelector('.slide-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-x')).toBe('0px');
      expect(root.style.getPropertyValue('--p-anim-y')).toBe('100%');
    });

    it('travels the other way from the top', async () => {
      await render(
        <PlAnimateSlide className="slide-under-test" from="top">
          Arriving
        </PlAnimateSlide>
      );

      const root = document.querySelector('.slide-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-y')).toBe('calc(-1 * 100%)');
    });

    it('moves along the other axis from the left', async () => {
      await render(
        <PlAnimateSlide className="slide-under-test" from="left" distance={40}>
          Arriving
        </PlAnimateSlide>
      );

      const root = document.querySelector('.slide-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-x')).toBe('-40px');
      expect(root.style.getPropertyValue('--p-anim-y')).toBe('0px');
    });

    it('takes a physical right edge, not a logical end', async () => {
      await render(
        <PlAnimateSlide className="slide-under-test" from="right" distance={40}>
          Arriving
        </PlAnimateSlide>
      );

      const root = document.querySelector('.slide-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-x')).toBe('40px');
    });
  });

  describe('distance', () => {
    it('reads a number as pixels', async () => {
      await render(
        <PlAnimateSlide className="slide-under-test" distance={24}>
          Arriving
        </PlAnimateSlide>
      );

      const root = document.querySelector('.slide-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-y')).toBe('24px');
    });

    it('passes a string through as the CSS length it already is', async () => {
      await render(
        <PlAnimateSlide className="slide-under-test" distance="3rem">
          Arriving
        </PlAnimateSlide>
      );

      const root = document.querySelector('.slide-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-y')).toBe('3rem');
    });
  });

  it('leaves by the edge it would have come from', async () => {
    await render(
      <PlAnimateSlide className="slide-under-test" mode="out" from="left">
        Leaving
      </PlAnimateSlide>
    );

    const root = document.querySelector('.slide-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-direction')).toBe('reverse');
    expect(root.style.getPropertyValue('--p-anim-x')).toBe('calc(-1 * 100%)');
  });

  it('stays fully drawn when the fade is turned off', async () => {
    await render(
      <PlAnimateSlide className="slide-under-test" fade={false}>
        Arriving
      </PlAnimateSlide>
    );

    const root = document.querySelector('.slide-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('1');
  });

  it('renders something else entirely when asked', async () => {
    const screen = await render(<PlAnimateSlide render={<section />}>Arriving</PlAnimateSlide>);

    expect(screen.getByText('Arriving').element().tagName).toBe('SECTION');
  });
});
