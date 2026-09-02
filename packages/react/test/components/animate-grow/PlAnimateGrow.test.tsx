import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateGrow } from 'plass-ui';
import { transformOrigin } from '../../support/styles';

describe('PlAnimateGrow', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateGrow>Unfolding</PlAnimateGrow>);

    await expect.element(screen.getByText('Unfolding')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateGrow className="grow-under-test">Unfolding</PlAnimateGrow>);

    expect(document.querySelector('.grow-under-test')).toHaveAttribute(
      'data-plass-animation',
      'grow'
    );
  });

  it('shares the scale keyframe with a zoom', async () => {
    await render(<PlAnimateGrow className="grow-under-test">Unfolding</PlAnimateGrow>);

    expect(document.querySelector('.grow-under-test')).toHaveClass('plass-anim-scale');
  });

  describe('from', () => {
    it('starts close to its final size by default', async () => {
      await render(<PlAnimateGrow className="grow-under-test">Unfolding</PlAnimateGrow>);

      const root = document.querySelector('.grow-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-scale')).toBe('0.8');
    });

    it('takes a scale above one, which settles down onto the page', async () => {
      await render(
        <PlAnimateGrow className="grow-under-test" from={1.3}>
          Unfolding
        </PlAnimateGrow>
      );

      const root = document.querySelector('.grow-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-scale')).toBe('1.3');
    });
  });

  describe('origin', () => {
    it('turns about the middle unless told otherwise', async () => {
      await render(<PlAnimateGrow className="grow-under-test">Unfolding</PlAnimateGrow>);

      const root = document.querySelector('.grow-under-test') as HTMLElement;

      expect(transformOrigin(root)).toBe('center center');
    });

    it('anchors to whichever point it was given', async () => {
      await render(
        <PlAnimateGrow className="grow-under-test" origin="bottom left">
          Unfolding
        </PlAnimateGrow>
      );

      const root = document.querySelector('.grow-under-test') as HTMLElement;

      expect(transformOrigin(root)).toBe('left bottom');
    });

    it('travels with the effect when the children are the ones scaling', async () => {
      await render(
        <PlAnimateGrow className="grow-under-test" origin="bottom left" stagger={70}>
          <span>One</span>
          <span>Two</span>
        </PlAnimateGrow>
      );

      const root = document.querySelector('.grow-under-test') as HTMLElement;

      // `transform-origin` is not inherited, so a staggered grow whose origin
      // stayed on the box would unfold every child from its own middle.
      for (const child of [...root.children] as HTMLElement[]) {
        expect(transformOrigin(child)).toBe('left bottom');
      }
    });
  });

  describe('fade', () => {
    it('fades in with the growth by default', async () => {
      await render(<PlAnimateGrow className="grow-under-test">Unfolding</PlAnimateGrow>);

      const root = document.querySelector('.grow-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('0');
    });

    it('stays fully drawn for something only changing size', async () => {
      await render(
        <PlAnimateGrow className="grow-under-test" fade={false}>
          Unfolding
        </PlAnimateGrow>
      );

      const root = document.querySelector('.grow-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('1');
    });
  });

  it('folds away on the same keyframe run backwards', async () => {
    await render(
      <PlAnimateGrow className="grow-under-test" mode="out">
        Folding
      </PlAnimateGrow>
    );

    const root = document.querySelector('.grow-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-direction')).toBe('reverse');
  });

  it('renders something else entirely when asked', async () => {
    const screen = await render(<PlAnimateGrow render={<section />}>Unfolding</PlAnimateGrow>);

    expect(screen.getByText('Unfolding').element().tagName).toBe('SECTION');
  });
});
