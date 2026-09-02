import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateReveal } from 'plass-ui';

/** The root, which every assertion here reads slots off. */
function root() {
  return document.querySelector('.reveal-under-test') as HTMLElement;
}

describe('PlAnimateReveal', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateReveal>Uncovered</PlAnimateReveal>);

    await expect.element(screen.getByText('Uncovered')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateReveal className="reveal-under-test">Uncovered</PlAnimateReveal>);

    expect(root()).toHaveAttribute('data-plass-animation', 'reveal');
    expect(root()).toHaveClass('plass-anim-reveal');
  });

  describe('from', () => {
    it('uncovers from the leading edge by default', async () => {
      await render(<PlAnimateReveal className="reveal-under-test">Uncovered</PlAnimateReveal>);

      expect(root().style.getPropertyValue('--p-anim-clip')).toBe('inset(0 100% 0 0)');
    });

    it('takes each of the four sides', async () => {
      // The four `inset()` sides in the physical order CSS writes them, which is
      // the order they have to be checked in: a reveal whose clip named the
      // wrong side would still animate, and would uncover from the wrong edge.
      const clips = {
        top: 'inset(0 0 100% 0)',
        right: 'inset(0 0 0 100%)',
        bottom: 'inset(100% 0 0 0)',
        left: 'inset(0 100% 0 0)'
      } as const;

      const screen = await render(
        <PlAnimateReveal className="reveal-under-test" from="top">
          Uncovered
        </PlAnimateReveal>
      );

      for (const [side, clip] of Object.entries(clips)) {
        await screen.rerender(
          <PlAnimateReveal className="reveal-under-test" from={side as keyof typeof clips}>
            Uncovered
          </PlAnimateReveal>
        );

        expect(root().style.getPropertyValue('--p-anim-clip')).toBe(clip);
      }
    });
  });

  describe('fade', () => {
    it('changes no colour unless it is asked to', async () => {
      await render(<PlAnimateReveal className="reveal-under-test">Uncovered</PlAnimateReveal>);

      // The whole reason to reach for a reveal is that the ink does not move
      // and does not change, so the opacity slot starts where it will end.
      expect(root().style.getPropertyValue('--p-anim-opacity')).toBe('1');
    });

    it('fades behind the wipe when both are wanted', async () => {
      await render(
        <PlAnimateReveal className="reveal-under-test" fade>
          Uncovered
        </PlAnimateReveal>
      );

      expect(root().style.getPropertyValue('--p-anim-opacity')).toBe('0');
    });
  });

  it('covers again on the same keyframe run backwards', async () => {
    await render(
      <PlAnimateReveal className="reveal-under-test" mode="out">
        Covering
      </PlAnimateReveal>
    );

    expect(root().style.getPropertyValue('--p-anim-direction')).toBe('reverse');
  });

  it('wipes each child in turn when it is given a stagger', async () => {
    await render(
      <PlAnimateReveal className="reveal-under-test" stagger={80}>
        <span>One</span>
        <span>Two</span>
      </PlAnimateReveal>
    );

    expect(root()).not.toHaveClass('plass-anim-reveal');
    expect(
      [...root().children].map((child) =>
        (child as HTMLElement).style.getPropertyValue('--p-anim-delay')
      )
    ).toEqual(['0ms', '80ms']);
  });

  it("takes the reader's scroll position like the others", async () => {
    await render(
      <PlAnimateReveal className="reveal-under-test" timeline="view">
        Uncovered
      </PlAnimateReveal>
    );

    expect(root().style.getPropertyValue('--p-anim-timeline')).toBe('view()');
  });

  it('renders something else entirely when asked', async () => {
    const screen = await render(<PlAnimateReveal render={<h2 />}>Uncovered</PlAnimateReveal>);

    expect(screen.getByText('Uncovered').element().tagName).toBe('H2');
  });
});
