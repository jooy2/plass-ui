import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateRotate } from 'plass-ui';

describe('PlAnimateRotate', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateRotate>Turning</PlAnimateRotate>);

    await expect.element(screen.getByText('Turning')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateRotate className="rotate-under-test">Turning</PlAnimateRotate>);

    expect(document.querySelector('.rotate-under-test')).toHaveAttribute(
      'data-plass-animation',
      'rotate'
    );
  });

  describe('from and to', () => {
    it('swings half a turn into place by default', async () => {
      await render(<PlAnimateRotate className="rotate-under-test">Turning</PlAnimateRotate>);

      const root = document.querySelector('.rotate-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-angle')).toBe('-180deg');
      expect(root.style.getPropertyValue('--p-anim-angle-to')).toBe('0deg');
    });

    it('takes both ends, which is what makes an endless spin the same keyframe', async () => {
      await render(
        <PlAnimateRotate className="rotate-under-test" from={0} to={360} repeat="infinite">
          Turning
        </PlAnimateRotate>
      );

      const root = document.querySelector('.rotate-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-angle')).toBe('0deg');
      expect(root.style.getPropertyValue('--p-anim-angle-to')).toBe('360deg');
      expect(root.style.getPropertyValue('--p-anim-repeat')).toBe('infinite');
    });
  });

  it('turns about whichever point it was given', async () => {
    await render(
      <PlAnimateRotate className="rotate-under-test" origin="top left">
        Turning
      </PlAnimateRotate>
    );

    const root = document.querySelector('.rotate-under-test') as HTMLElement;

    expect(root.style.transformOrigin).toBe('left top');
  });

  it('stays fully drawn for a continuous spin', async () => {
    await render(
      <PlAnimateRotate className="rotate-under-test" fade={false}>
        Turning
      </PlAnimateRotate>
    );

    const root = document.querySelector('.rotate-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('1');
  });

  it('turns out of place on the same keyframe run backwards', async () => {
    await render(
      <PlAnimateRotate className="rotate-under-test" mode="out">
        Leaving
      </PlAnimateRotate>
    );

    const root = document.querySelector('.rotate-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-direction')).toBe('reverse');
  });

  it('renders something else entirely when asked', async () => {
    const screen = await render(<PlAnimateRotate render={<span />}>Turning</PlAnimateRotate>);

    expect(screen.getByText('Turning').element().tagName).toBe('SPAN');
  });
});
