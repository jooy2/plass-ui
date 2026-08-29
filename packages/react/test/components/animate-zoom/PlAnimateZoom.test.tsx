import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateZoom } from 'plass-ui';

describe('PlAnimateZoom', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateZoom>Landed</PlAnimateZoom>);

    await expect.element(screen.getByText('Landed')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateZoom className="zoom-under-test">Landed</PlAnimateZoom>);

    expect(document.querySelector('.zoom-under-test')).toHaveAttribute(
      'data-plass-animation',
      'zoom'
    );
  });

  it('shares the scale keyframe with a grow', async () => {
    await render(<PlAnimateZoom className="zoom-under-test">Landed</PlAnimateZoom>);

    expect(document.querySelector('.zoom-under-test')).toHaveClass('plass-anim-scale');
  });

  it('travels more than twice as far as a grow does', async () => {
    await render(<PlAnimateZoom className="zoom-under-test">Landed</PlAnimateZoom>);

    const root = document.querySelector('.zoom-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-scale')).toBe('0.4');
  });

  it('is always about the centre', async () => {
    await render(<PlAnimateZoom className="zoom-under-test">Landed</PlAnimateZoom>);

    const root = document.querySelector('.zoom-under-test') as HTMLElement;

    expect(root.style.transformOrigin).toBe('center center');
  });

  it('takes a scale above one, which arrives oversized and settles back', async () => {
    await render(
      <PlAnimateZoom className="zoom-under-test" from={1.4}>
        Landed
      </PlAnimateZoom>
    );

    const root = document.querySelector('.zoom-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-scale')).toBe('1.4');
  });

  it('stays fully drawn when the fade is turned off', async () => {
    await render(
      <PlAnimateZoom className="zoom-under-test" fade={false}>
        Landed
      </PlAnimateZoom>
    );

    const root = document.querySelector('.zoom-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('1');
  });

  it('falls away on the same keyframe run backwards', async () => {
    await render(
      <PlAnimateZoom className="zoom-under-test" mode="out">
        Leaving
      </PlAnimateZoom>
    );

    const root = document.querySelector('.zoom-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-direction')).toBe('reverse');
  });

  it('renders something else entirely when asked', async () => {
    const screen = await render(<PlAnimateZoom render={<section />}>Landed</PlAnimateZoom>);

    expect(screen.getByText('Landed').element().tagName).toBe('SECTION');
  });
});
