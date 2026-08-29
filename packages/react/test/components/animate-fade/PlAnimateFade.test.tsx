import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateFade } from 'plass-ui';

describe('PlAnimateFade', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateFade>Arriving</PlAnimateFade>);

    await expect.element(screen.getByText('Arriving')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

    expect(document.querySelector('.fade-under-test')).toHaveAttribute(
      'data-plass-animation',
      'fade'
    );
  });

  it('fills the timing slots from its props', async () => {
    await render(
      <PlAnimateFade className="fade-under-test" duration={500} delay={120} easing="linear">
        Arriving
      </PlAnimateFade>
    );

    const root = document.querySelector('.fade-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-duration')).toBe('500ms');
    expect(root.style.getPropertyValue('--p-anim-delay')).toBe('120ms');
    expect(root.style.getPropertyValue('--p-anim-ease')).toBe('linear');
  });

  it('leaves the easing slot alone when nobody set one', async () => {
    await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

    const root = document.querySelector('.fade-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-ease')).toBe('');
  });

  it('starts from the opacity it was given', async () => {
    await render(
      <PlAnimateFade className="fade-under-test" from={0.3}>
        Arriving
      </PlAnimateFade>
    );

    const root = document.querySelector('.fade-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('0.3');
  });

  describe('mode', () => {
    it('runs forwards coming in', async () => {
      await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-direction')).toBe('normal');
    });

    it('runs the same keyframe backwards going out', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" mode="out">
          Leaving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-direction')).toBe('reverse');
    });

    it('alternates in both directions', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" mode="out" alternate>
          Leaving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-direction')).toBe('alternate-reverse');
    });
  });

  describe('repeat', () => {
    it('writes a count as a number', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" repeat={3}>
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-repeat')).toBe('3');
    });

    it('writes an endless one as the word CSS uses', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" repeat="infinite">
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-repeat')).toBe('infinite');
    });
  });

  describe('trigger', () => {
    it('runs on mount by default', async () => {
      await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

      expect(document.querySelector('.fade-under-test')).toHaveAttribute('data-state', 'running');
    });

    it('waits paused on its first frame until a manual play', async () => {
      const screen = await render(
        <PlAnimateFade className="fade-under-test" trigger="manual">
          Arriving
        </PlAnimateFade>
      );

      expect(document.querySelector('.fade-under-test')).toHaveAttribute('data-state', 'paused');

      await screen.rerender(
        <PlAnimateFade className="fade-under-test" trigger="manual" play>
          Arriving
        </PlAnimateFade>
      );

      await expect.element(screen.getByText('Arriving')).toHaveAttribute('data-state', 'running');
    });

    it('holds where it is when paused', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" paused>
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root).toHaveAttribute('data-state', 'paused');
      expect(root.style.getPropertyValue('--p-anim-state')).toBe('paused');
    });

    it('starts on hover, and on focus for a reader without a mouse', async () => {
      const screen = await render(
        <PlAnimateFade className="fade-under-test" trigger="hover">
          Arriving
        </PlAnimateFade>
      );

      expect(document.querySelector('.fade-under-test')).toHaveAttribute('data-state', 'paused');

      await screen.getByText('Arriving').hover();

      await expect.element(screen.getByText('Arriving')).toHaveAttribute('data-state', 'running');
    });
  });

  it('renders something else entirely when asked', async () => {
    const screen = await render(<PlAnimateFade render={<section />}>Arriving</PlAnimateFade>);

    expect(screen.getByText('Arriving').element().tagName).toBe('SECTION');
  });

  it('keeps a caller class and a caller style beside its own', async () => {
    await render(
      <PlAnimateFade className="fade-under-test" style={{ color: 'red' }}>
        Arriving
      </PlAnimateFade>
    );

    const root = document.querySelector('.fade-under-test') as HTMLElement;

    expect(root).toHaveClass('plass-anim');
    expect(root).toHaveClass('plass-anim-fade');
    expect(root.style.color).toBe('red');
  });
});
