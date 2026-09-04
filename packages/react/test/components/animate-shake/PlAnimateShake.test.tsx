import { useState } from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateShake, PlButton } from 'plass-ui';

function root(): HTMLElement {
  return document.querySelector<HTMLElement>('.shake-under-test')!;
}

function state(): string {
  return root().dataset.state ?? '';
}

describe('PlAnimateShake', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateShake>Wrong password</PlAnimateShake>);

    await expect.element(screen.getByText('Wrong password')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateShake className="shake-under-test">Wrong</PlAnimateShake>);

    expect(root()).toHaveAttribute('data-plass-animation', 'shake');
  });

  it('runs its own keyframe rather than one of the entrances', async () => {
    await render(<PlAnimateShake className="shake-under-test">Wrong</PlAnimateShake>);

    // A response to something a reader did is not an arrival.
    expect(root().classList.contains('plass-anim-shake')).toBe(true);
  });

  it('holds still until it is told, unlike every other effect here', async () => {
    await render(<PlAnimateShake className="shake-under-test">Wrong</PlAnimateShake>);

    expect(state()).toBe('paused');
  });

  it('runs once when it does run', async () => {
    await render(<PlAnimateShake className="shake-under-test">Wrong</PlAnimateShake>);

    expect(root().style.getPropertyValue('--p-anim-repeat')).toBe('1');
  });

  describe('the travel', () => {
    it('is six pixels either side by default', async () => {
      await render(<PlAnimateShake className="shake-under-test">Wrong</PlAnimateShake>);

      expect(root().style.getPropertyValue('--p-anim-x')).toBe('6px');
    });

    it('takes a distance of its own', async () => {
      await render(
        <PlAnimateShake className="shake-under-test" distance="0.5rem">
          Wrong
        </PlAnimateShake>
      );

      expect(root().style.getPropertyValue('--p-anim-x')).toBe('0.5rem');
    });
  });

  describe('replay', () => {
    it('does not shake on the first render', async () => {
      await render(
        <PlAnimateShake className="shake-under-test" replay={0}>
          Wrong
        </PlAnimateShake>
      );

      // A shake that played itself on mount would be answering an event that
      // has not happened.
      expect(state()).toBe('paused');
    });

    it('shakes every time the value changes', async () => {
      function Subject() {
        const [attempts, setAttempts] = useState(0);

        return (
          <div>
            <PlButton onClick={() => setAttempts((count) => count + 1)}>Submit</PlButton>
            <PlAnimateShake className="shake-under-test" replay={attempts}>
              Wrong password
            </PlAnimateShake>
          </div>
        );
      }

      const screen = await render(<Subject />);

      expect(state()).toBe('paused');

      await screen.getByRole('button').click();

      await expect.poll(() => state()).toBe('running');

      // And again: a refusal can happen twice, which a boolean cannot say.
      await screen.getByRole('button').click();

      await expect.poll(() => state()).toBe('running');
    });
  });

  it('still answers `play` for a caller who has one', async () => {
    await render(
      <PlAnimateShake className="shake-under-test" play>
        Wrong
      </PlAnimateShake>
    );

    await expect.poll(() => state()).toBe('running');
  });

  it('renders something other than a div when it is handed one', async () => {
    await render(
      <PlAnimateShake className="shake-under-test" render={<span />}>
        Wrong
      </PlAnimateShake>
    );

    expect(root().tagName).toBe('SPAN');
  });
});
