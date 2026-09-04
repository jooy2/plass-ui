import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateFloat } from 'plass-ui';

function root(): HTMLElement {
  return document.querySelector<HTMLElement>('.float-under-test')!;
}

function slot(name: string): string {
  return root().style.getPropertyValue(name);
}

describe('PlAnimateFloat', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateFloat>Illustration</PlAnimateFloat>);

    await expect.element(screen.getByText('Illustration')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateFloat className="float-under-test">Illustration</PlAnimateFloat>);

    expect(root()).toHaveAttribute('data-plass-animation', 'float');
  });

  it('runs its own keyframe rather than one of the entrances', async () => {
    await render(<PlAnimateFloat className="float-under-test">Illustration</PlAnimateFloat>);

    // A drift is not an arrival, so it is not in `PlassAnimation` and does not
    // borrow one of the seven.
    expect(root().classList.contains('plass-anim-float')).toBe(true);
    expect(root().classList.contains('plass-anim')).toBe(true);
  });

  it('never finishes unless it was told to', async () => {
    await render(<PlAnimateFloat className="float-under-test">Illustration</PlAnimateFloat>);

    expect(slot('--p-anim-repeat')).toBe('infinite');
  });

  describe('the drift', () => {
    it('goes up by default, which is what floating is', async () => {
      await render(<PlAnimateFloat className="float-under-test">Illustration</PlAnimateFloat>);

      expect(slot('--p-anim-y')).toBe('-8px');
      expect(slot('--p-anim-x')).toBe('0');
    });

    it('takes a distance in pixels or in any length', async () => {
      await render(
        <PlAnimateFloat className="float-under-test" distance={20}>
          Illustration
        </PlAnimateFloat>
      );

      expect(slot('--p-anim-y')).toBe('-20px');

      await render(
        <PlAnimateFloat className="float-under-test second" distance="0.5rem">
          Illustration
        </PlAnimateFloat>
      );

      expect(
        document.querySelector<HTMLElement>('.second')!.style.getPropertyValue('--p-anim-y')
      ).toBe('-0.5rem');
    });

    it('drifts along the row when it was told to', async () => {
      await render(
        <PlAnimateFloat className="float-under-test" orientation="horizontal">
          Illustration
        </PlAnimateFloat>
      );

      expect(slot('--p-anim-x')).toBe('8px');
      expect(slot('--p-anim-y')).toBe('0');
    });
  });

  describe('the curve', () => {
    it('turns around rather than lurching, unlike every entrance here', async () => {
      await render(<PlAnimateFloat className="float-under-test">Illustration</PlAnimateFloat>);

      // The house curve is an entrance's — fast out of the gate, slow into
      // place — and a drift with it would lurch at each end of the cycle.
      expect(slot('--p-anim-ease')).toBe('ease-in-out');
    });

    it('takes a curve of its own', async () => {
      await render(
        <PlAnimateFloat className="float-under-test" easing="linear">
          Illustration
        </PlAnimateFloat>
      );

      expect(slot('--p-anim-ease')).toBe('linear');
    });
  });

  it('holds still when a caller says so', async () => {
    await render(
      <PlAnimateFloat className="float-under-test" paused>
        Illustration
      </PlAnimateFloat>
    );

    expect(slot('--p-anim-state')).toBe('paused');
  });

  it('renders something other than a div when it is handed one', async () => {
    await render(
      <PlAnimateFloat className="float-under-test" render={<span />}>
        Illustration
      </PlAnimateFloat>
    );

    expect(root().tagName).toBe('SPAN');
  });
});
