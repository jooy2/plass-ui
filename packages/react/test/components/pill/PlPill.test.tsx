import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlIconButton, PlPill } from 'plass-ui';

describe('PlPill', () => {
  describe('the lozenge', () => {
    it('draws the title and the line under it', async () => {
      const screen = await render(<PlPill title="Recording" description="00:41" />);

      await expect.element(screen.getByText('Recording')).toBeInTheDocument();
      await expect.element(screen.getByText('00:41')).toBeInTheDocument();
    });

    it('is a stadium cut to half its own row, not a rounded-full box', async () => {
      await render(<PlPill className="pill-under-test" title="Recording" />);
      const element = document.querySelector('.pill-under-test');

      // `rounded-full` on a pill that has grown a second line is a corner half
      // its new height, and a corner that big eats the first two words of every
      // line. The radius is pinned to the *row*.
      expect(element).toHaveClass('rounded-[1rem]');
      expect(element).not.toHaveClass('rounded-full');
    });

    it('floats rather than lying flat, which nothing else in the library does', async () => {
      await render(<PlPill className="pill-under-test" title="Recording" />);

      const element = document.querySelector<HTMLElement>('.pill-under-test');

      expect(element?.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-2)');
    });

    it('takes the tint on its own surface, the way a control does', async () => {
      await render(<PlPill className="pill-under-test" color="danger" title="Recording" />);

      const element = document.querySelector<HTMLElement>('.pill-under-test');

      // A pill is the thing being coloured rather than a sheet holding somebody
      // else's content, so the slot set is a control's.
      expect(element?.style.getPropertyValue('--p-fill')).toBe('var(--plass-danger-fill)');
      expect(element).toHaveClass('[background-image:var(--p-fill)]');
    });

    it('draws the leading slot in a round box of its own', async () => {
      const screen = await render(
        <PlPill title="Ada" startIcon={<img src="/ada.png" alt="" data-testid="portrait" />} />
      );

      const media = screen.getByTestId('portrait').element().parentElement;

      expect(media).toHaveClass('rounded-full');
      expect(media).toHaveClass('overflow-hidden');
    });
  });

  describe('pressing it', () => {
    it('is not a control until it is given something to do', async () => {
      const screen = await render(<PlPill title="Recording" />);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('becomes a real button, reachable from a keyboard', async () => {
      const onClick = vi.fn();
      const screen = await render(<PlPill title="Recording" onClick={onClick} />);

      const element = screen.getByRole('button', { name: 'Recording' }).element();

      expect(element.tagName).toBe('BUTTON');

      await screen.getByRole('button', { name: 'Recording' }).click();

      expect(onClick).toHaveBeenCalled();
    });

    it('keeps the trailing slot outside the button', async () => {
      const screen = await render(
        <PlPill
          title="Recording"
          onClick={() => {}}
          endIcon={<PlIconButton size="xs" variant="ghost" label="Stop" icon={<span>■</span>} />}
        />
      );

      const middle = screen.getByRole('button', { name: 'Recording' }).element();
      const stop = screen.getByRole('button', { name: 'Stop' }).element();

      // A `<button>` holding the control somebody put in `endIcon` is markup the
      // browser rewrites on parse.
      expect(middle.contains(stop)).toBe(false);
    });
  });

  describe('details', () => {
    it('is not drawn at all until there is something to reveal', async () => {
      await render(<PlPill className="pill-under-test" title="Recording" />);

      expect(document.querySelectorAll('.pill-under-test > div')).toHaveLength(1);
    });

    it('is collapsed and inert while it is closed', async () => {
      const screen = await render(
        <PlPill title="Recording" details={<span data-testid="details">Take three</span>} />
      );

      const panel = screen.getByTestId('details').element().parentElement?.parentElement;

      expect(panel).toHaveAttribute('inert');
      expect((panel as HTMLElement).style.height).toBe('0px');
    });

    it('opens to a measured height rather than a hardcoded one', async () => {
      const screen = await render(
        <PlPill
          expanded
          title="Recording"
          details={<span data-testid="details">Take three</span>}
        />
      );

      const panel = screen.getByTestId('details').element().parentElement?.parentElement;

      expect(panel).not.toHaveAttribute('inert');
      await expect
        .poll(() => Number.parseFloat((panel as HTMLElement).style.height))
        .toBeGreaterThan(0);
    });
  });

  describe('position', () => {
    it('stays in the flow until it is told to hang', async () => {
      const screen = await render(<PlPill className="pill-under-test" title="Recording" />);

      expect(document.querySelector('.pill-under-test')).not.toHaveClass('fixed');

      await screen.rerender(
        <PlPill className="pill-under-test" position="fixed" side="bottom" title="Recording" />
      );

      const element = document.querySelector('.pill-under-test');

      expect(element).toHaveClass('fixed');
      expect(element).toHaveClass('bottom-3');
      // Centred by `mx-auto` inside a full-width box rather than by translating
      // it half its own width: the house rule against transforming a surface
      // holds here too, and `auto` margins are direction-agnostic.
      expect(element).toHaveClass('mx-auto');
    });
  });
});
