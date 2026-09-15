/**
 * That the three popups with a wedge draw the same wedge.
 *
 * A test of a *contract* rather than of a component, which is why it is here
 * rather than under `test/components/`: each of the three has its own test for
 * whether the arrow is drawn at all, and all three passed while the tooltip's
 * was a different drawing from the other two. The only way that can be caught
 * is by asking the question once, of all of them.
 *
 * What is asserted is the shape of the drawing and not its colours or its size:
 * one filled triangle, and a hairline stroked along the two slanted sides only,
 * at a width that does not scale with the box. A wedge filled twice sits a rung
 * up the glass ladder from the plate it grew out of, because both of the tokens
 * involved are translucent.
 */
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHoverCard, PlPopover, PlTooltip } from 'plass-ui';

/** The wedge each popup drew, found inside the popup it belongs to. */
const popups: Record<string, () => Promise<SVGSVGElement>> = {
  PlTooltip: async () => {
    const screen = await render(
      <PlTooltip open arrow content="Copy">
        <button type="button">Copy</button>
      </PlTooltip>
    );

    await expect.element(screen.getByRole('tooltip')).toBeInTheDocument();

    return screen.getByRole('tooltip').element().querySelector('svg') as SVGSVGElement;
  },
  PlPopover: async () => {
    const screen = await render(
      <PlPopover defaultOpen arrow data-testid="popover-under-test" title="Rates">
        Body
      </PlPopover>
    );

    await expect.element(screen.getByTestId('popover-under-test')).toBeInTheDocument();

    return screen.getByTestId('popover-under-test').element().querySelector('svg') as SVGSVGElement;
  },
  PlHoverCard: async () => {
    await render(
      <PlHoverCard
        defaultOpen
        arrow
        className="hover-card-under-test"
        trigger={<a href="#ada">Ada Lovelace</a>}
        title="Ada Lovelace"
      >
        Wrote the first algorithm intended for a machine.
      </PlHoverCard>
    );

    await expect.poll(() => document.querySelector('.hover-card-under-test')).not.toBeNull();

    return document.querySelector('.hover-card-under-test')!.querySelector('svg') as SVGSVGElement;
  }
};

describe('the popup arrow', () => {
  for (const [name, open] of Object.entries(popups)) {
    describe(name, () => {
      it('fills the wedge once, so it stays on the plate’s rung of the glass ladder', async () => {
        const paths = Array.from((await open()).querySelectorAll('path'));
        const filled = paths.filter((path) => {
          const fill = path.getAttribute('fill');

          return fill !== null && fill !== 'none';
        });

        expect(filled).toHaveLength(1);
        expect(filled[0].getAttribute('fill')).toBe('var(--plass-glass-press)');
      });

      it('strokes the hairline along the two slanted sides and not across the base', async () => {
        const paths = Array.from((await open()).querySelectorAll('path'));
        const stroked = paths.filter((path) => path.getAttribute('stroke') !== null);

        expect(stroked).toHaveLength(1);
        expect(stroked[0].getAttribute('stroke')).toBe('var(--plass-glass-line)');
        // An open path: down one slanted side and up the other. A `z` would
        // close it across the base, which is where the plate already is.
        expect(stroked[0].getAttribute('d')?.toLowerCase()).not.toContain('z');
        // One device pixel at every step of the size ladder, which is what makes
        // it the same hairline the plate's own border is.
        expect(stroked[0].getAttribute('vector-effect')).toBe('non-scaling-stroke');
      });
    });
  }
});
