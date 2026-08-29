import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateLighting } from 'plass-ui';

describe('PlAnimateLighting', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateLighting>Processing</PlAnimateLighting>);

    await expect.element(screen.getByText('Processing')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateLighting className="lighting-under-test">Live</PlAnimateLighting>);

    const root = document.querySelector('.lighting-under-test');

    expect(root).toHaveAttribute('data-plass-animation', 'lighting');
    expect(root).toHaveClass('plass-anim-lighting');
  });

  it('carries no effect keyframe of its own, because the light is a pseudo-element', async () => {
    await render(<PlAnimateLighting className="lighting-under-test">Live</PlAnimateLighting>);

    expect(document.querySelector('.lighting-under-test')).not.toHaveClass('plass-anim');
  });

  describe('color', () => {
    it('turns between the family two ends as it travels', async () => {
      await render(
        <PlAnimateLighting className="lighting-under-test" color="success">
          Live
        </PlAnimateLighting>
      );

      const root = document.querySelector('.lighting-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-glow-from')).toBe('var(--plass-success-solid)');
      expect(root.style.getPropertyValue('--p-anim-glow-to')).toBe('var(--plass-success-solid-to)');
    });

    it('takes one flat colour when a family is not what is wanted', async () => {
      await render(
        <PlAnimateLighting className="lighting-under-test" glow="#ff9900">
          Live
        </PlAnimateLighting>
      );

      const root = document.querySelector('.lighting-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-glow-from')).toBe('#ff9900');
      expect(root.style.getPropertyValue('--p-anim-glow-to')).toBe('#ff9900');
    });
  });

  it('follows the radius it was given, so the glow matches what is inside', async () => {
    await render(
      <PlAnimateLighting className="lighting-under-test" size="xl">
        Live
      </PlAnimateLighting>
    );

    expect(document.querySelector('.lighting-under-test')).toHaveClass(
      'rounded-(--plass-radius-xl)'
    );
  });

  it('writes the shape of the light into its own slots', async () => {
    await render(
      <PlAnimateLighting className="lighting-under-test" spread={8} arc={120} blur={0}>
        Live
      </PlAnimateLighting>
    );

    const root = document.querySelector('.lighting-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-glow-width')).toBe('8px');
    expect(root.style.getPropertyValue('--p-anim-glow-arc')).toBe('120deg');
    expect(root.style.getPropertyValue('--p-anim-glow-blur')).toBe('0px');
  });

  it('runs the light the other way round', async () => {
    await render(
      <PlAnimateLighting className="lighting-under-test" reverse>
        Live
      </PlAnimateLighting>
    );

    const root = document.querySelector('.lighting-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-direction')).toBe('reverse');
  });

  it('travels forever unless told otherwise', async () => {
    await render(<PlAnimateLighting className="lighting-under-test">Live</PlAnimateLighting>);

    const root = document.querySelector('.lighting-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-repeat')).toBe('infinite');
  });
});
