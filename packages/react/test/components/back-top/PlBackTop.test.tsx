/**
 * The window's own scroll is not usable here — the test runner's page is an
 * iframe with its own layout, and one file scrolling it would leave every file
 * after it somewhere unexpected. So these scroll a **panel**, which is the
 * component's other supported target and exercises exactly the same code.
 */
import * as React from 'react';
import { commands } from 'vitest/browser';
import { afterAll, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBackTop } from 'plass-ui';

afterAll(async () => {
  await commands.emulateMedia({ reducedMotion: 'no-preference' });
});

/** A panel taller than itself, with the button watching it. */
function Panel({
  visibilityHeight,
  onClick
}: {
  visibilityHeight?: number;
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
}) {
  const panel = React.useRef<HTMLDivElement>(null);

  return (
    <>
      <div ref={panel} data-testid="panel" style={{ height: '200px', overflowY: 'auto' }}>
        <div style={{ height: '3000px' }} />
      </div>
      <PlBackTop target={panel} visibilityHeight={visibilityHeight} onClick={onClick} />
    </>
  );
}

const panel = () => document.querySelector<HTMLElement>('[data-testid="panel"]')!;
const button = () => document.querySelector<HTMLButtonElement>('button[aria-label]')!;

/**
 * Scrolls the panel and waits for React to have caught up.
 *
 * `expect.poll` rather than a fixed wait: the listener sets state, and a
 * `setTimeout(0)` is not long enough for the render that follows — which fails
 * as "the button never appeared" rather than as a timing problem.
 */
async function scrollTo(top: number, hidden: boolean): Promise<void> {
  panel().scrollTop = top;
  panel().dispatchEvent(new Event('scroll'));

  await expect.poll(() => button().getAttribute('aria-hidden')).toBe(hidden ? 'true' : null);
}

describe('PlBackTop', () => {
  describe('when it appears', () => {
    it('is out of reach at the top of the page', async () => {
      await render(<Panel />);

      // Not merely faded: a control a reader can tab to and cannot see is
      // worse than one that is not there.
      expect(button()).toHaveAttribute('aria-hidden', 'true');
      expect(button().tabIndex).toBe(-1);
      expect(button().className).toContain('pointer-events-none');
    });

    it('arrives once the reader is far enough down', async () => {
      await render(<Panel visibilityHeight={400} />);

      await scrollTo(500, false);

      expect(button().tabIndex).not.toBe(-1);
    });

    it('fades rather than blinking on and off', async () => {
      await render(<Panel visibilityHeight={400} />);

      expect(button().className).toContain('opacity');
      expect(button().className).toContain('transition-property');
      expect(button().className).toContain(',opacity]');
    });

    it('goes away again on the way back up', async () => {
      await render(<Panel visibilityHeight={400} />);

      await scrollTo(500, false);
      await scrollTo(100, true);
    });

    it('takes its own threshold', async () => {
      await render(<Panel visibilityHeight={50} />);

      await scrollTo(100, false);
    });

    it('reads the position it mounted at', async () => {
      // A page restored halfway down — a back navigation, an anchor in the URL
      // — has already done its scrolling before the listener existed. The panel
      // is therefore scrolled first and the button rendered second, which is
      // that order and not a simulation of it.
      const ref = React.createRef<HTMLDivElement>();

      const Restored = ({ withButton }: { withButton: boolean }) => (
        <>
          <div ref={ref} data-testid="panel" style={{ height: '200px', overflowY: 'auto' }}>
            <div style={{ height: '3000px' }} />
          </div>
          {withButton ? <PlBackTop target={ref} /> : null}
        </>
      );

      const screen = await render(<Restored withButton={false} />);

      panel().scrollTop = 900;

      await screen.rerender(<Restored withButton />);

      await expect.poll(() => button()?.getAttribute('aria-hidden')).toBeNull();
    });
  });

  describe('what it does', () => {
    it('takes the panel back to the top', async () => {
      await render(<Panel visibilityHeight={100} />);

      await scrollTo(900, false);
      button().click();

      await expect.poll(() => panel().scrollTop).toBe(0);
    });

    it('runs a caller’s own click first', async () => {
      const onClick = vi.fn();

      await render(<Panel visibilityHeight={100} onClick={onClick} />);

      await scrollTo(900, false);
      button().click();

      expect(onClick).toHaveBeenCalled();
    });

    it('does not scroll when the caller consumed the click', async () => {
      await render(<Panel visibilityHeight={100} onClick={(event) => event.preventDefault()} />);

      await scrollTo(900, false);
      button().click();

      await new Promise((resolve) => setTimeout(resolve, 30));

      expect(panel().scrollTop).toBe(900);
    });
  });

  describe('the name', () => {
    it('has one, and it says what pressing it does', async () => {
      const screen = await render(<Panel visibilityHeight={100} />);

      // Scrolled first on purpose: while it is out of reach it is
      // `aria-hidden`, so it is not in the accessibility tree to be found by
      // role — which is the whole point of hiding it that way.
      await scrollTo(500, false);

      await expect.element(screen.getByRole('button', { name: 'Back to top' })).toBeInTheDocument();
    });
  });
});
