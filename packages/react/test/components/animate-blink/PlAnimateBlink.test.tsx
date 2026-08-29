import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateBlink } from 'plass-ui';

describe('PlAnimateBlink', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateBlink>Recording</PlAnimateBlink>);

    await expect.element(screen.getByText('Recording')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateBlink className="blink-under-test">Recording</PlAnimateBlink>);

    expect(document.querySelector('.blink-under-test')).toHaveAttribute(
      'data-plass-animation',
      'blink'
    );
  });

  it('repeats forever unless told otherwise, because one blink is a flicker', async () => {
    await render(<PlAnimateBlink className="blink-under-test">Recording</PlAnimateBlink>);

    const root = document.querySelector('.blink-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-repeat')).toBe('infinite');
  });

  it('takes a count when a caller wants one', async () => {
    await render(
      <PlAnimateBlink className="blink-under-test" repeat={3}>
        Recording
      </PlAnimateBlink>
    );

    const root = document.querySelector('.blink-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-repeat')).toBe('3');
  });

  describe('min', () => {
    it('goes all the way out at the bottom of the cycle by default', async () => {
      await render(<PlAnimateBlink className="blink-under-test">Recording</PlAnimateBlink>);

      const root = document.querySelector('.blink-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('0');
    });

    it('stops at a floor for something that has to stay readable', async () => {
      await render(
        <PlAnimateBlink className="blink-under-test" min={0.45}>
          Recording
        </PlAnimateBlink>
      );

      const root = document.querySelector('.blink-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('0.45');
    });
  });

  it('holds where it is when paused', async () => {
    await render(
      <PlAnimateBlink className="blink-under-test" paused>
        Recording
      </PlAnimateBlink>
    );

    const root = document.querySelector('.blink-under-test') as HTMLElement;

    expect(root).toHaveAttribute('data-state', 'paused');
    expect(root.style.getPropertyValue('--p-anim-state')).toBe('paused');
  });

  it('renders something else entirely when asked', async () => {
    const screen = await render(<PlAnimateBlink render={<span />}>Recording</PlAnimateBlink>);

    expect(screen.getByText('Recording').element().tagName).toBe('SPAN');
  });
});
