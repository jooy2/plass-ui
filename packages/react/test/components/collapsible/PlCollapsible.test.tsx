import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlCollapsible, PlSwitch } from 'plass-ui';

describe('PlCollapsible', () => {
  describe('the header', () => {
    it('renders a real button that reports the state', async () => {
      const screen = await render(<PlCollapsible title="Advanced">Everything else.</PlCollapsible>);

      const element = screen.getByRole('button', { name: 'Advanced' }).element();

      expect(element.tagName).toBe('BUTTON');
      expect(element).toHaveAttribute('aria-expanded', 'false');
    });

    it('points at the panel it opens', async () => {
      const screen = await render(
        <PlCollapsible defaultOpen title="Advanced">
          Everything else.
        </PlCollapsible>
      );

      const trigger = screen.getByRole('button', { name: 'Advanced' }).element();
      const panel = document.getElementById(trigger.getAttribute('aria-controls') ?? '');

      expect(panel).not.toBeNull();
      expect(panel?.textContent).toContain('Everything else.');
    });

    it('draws the subtitle and the leading glyph', async () => {
      const screen = await render(
        <PlCollapsible
          title="Advanced"
          subtitle="Nine settings"
          startIcon={<svg viewBox="0 0 24 24" data-testid="glyph" />}
        >
          Everything else.
        </PlCollapsible>
      );

      await expect.element(screen.getByText('Nine settings')).toBeInTheDocument();
      await expect.element(screen.getByTestId('glyph')).toBeInTheDocument();
    });

    it('keeps an action outside the trigger', async () => {
      const screen = await render(
        <PlCollapsible title="Advanced" action={<PlSwitch label="On" />}>
          Everything else.
        </PlCollapsible>
      );

      const trigger = screen.getByRole('button', { name: 'Advanced' }).element();
      const toggle = screen.getByRole('switch', { name: 'On' }).element();

      // A header that both folds and holds a switch has two things to press,
      // and one of them cannot be nested inside the other — the browser
      // rewrites a control inside a `<button>` on parse.
      expect(trigger.contains(toggle)).toBe(false);
    });

    it('drops the chevron when it is asked to', async () => {
      const screen = await render(
        <PlCollapsible indicator={false} title="Advanced">
          Everything else.
        </PlCollapsible>
      );

      expect(screen.getByRole('button', { name: 'Advanced' }).element().querySelector('svg')).toBe(
        null
      );
    });

    it('takes a trigger of its own', async () => {
      const screen = await render(
        <PlCollapsible trigger={<PlButton>Show more</PlButton>}>Everything else.</PlCollapsible>
      );

      // The element passed in *becomes* the trigger: it is handed the handler,
      // `aria-expanded` and the `aria-controls`, so nothing has to be wired up.
      await expect
        .element(screen.getByRole('button', { name: 'Show more' }))
        .toHaveAttribute('aria-expanded', 'false');

      await screen.getByRole('button', { name: 'Show more' }).click();

      // The pointer is only added once there is a panel to point at: a closed
      // one is not in the document unless it was asked to stay.
      await expect
        .element(screen.getByRole('button', { name: 'Show more' }))
        .toHaveAttribute('aria-controls');
      await expect.element(screen.getByText('Everything else.')).toBeInTheDocument();
    });
  });

  describe('folding', () => {
    it('opens on a press and closes again', async () => {
      const screen = await render(<PlCollapsible title="Advanced">Everything else.</PlCollapsible>);

      await screen.getByRole('button', { name: 'Advanced' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Advanced' }))
        .toHaveAttribute('aria-expanded', 'true');

      await screen.getByRole('button', { name: 'Advanced' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Advanced' }))
        .toHaveAttribute('aria-expanded', 'false');
    });

    it('starts open on defaultOpen', async () => {
      const screen = await render(
        <PlCollapsible defaultOpen title="Advanced">
          Everything else.
        </PlCollapsible>
      );

      await expect.element(screen.getByText('Everything else.')).toBeInTheDocument();
    });

    it('reports the change and stays where a controlled open put it', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlCollapsible open={false} onOpenChange={onOpenChange} title="Advanced">
          Everything else.
        </PlCollapsible>
      );

      await screen.getByRole('button', { name: 'Advanced' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
      // The parent said closed and never said otherwise.
      await expect
        .element(screen.getByRole('button', { name: 'Advanced' }))
        .toHaveAttribute('aria-expanded', 'false');
    });

    it('does not answer while it is unavailable', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlCollapsible disabled onOpenChange={onOpenChange} title="Advanced">
          Everything else.
        </PlCollapsible>
      );

      await expect.element(screen.getByRole('button', { name: 'Advanced' })).toBeDisabled();
      expect(onOpenChange).not.toHaveBeenCalled();
    });

    it('keeps a closed panel in the DOM when it is asked to', async () => {
      const screen = await render(
        <PlCollapsible keepMounted title="Advanced">
          Everything else.
        </PlCollapsible>
      );

      // In the DOM, hidden — for content that is expensive to build, or that
      // holds form state which should survive being folded away.
      expect(document.body.textContent).toContain('Everything else.');
      expect(screen.getByText('Everything else.').element().closest('[hidden]')).not.toBeNull();
    });
  });

  describe('the sheet', () => {
    it('is a window rather than something that spills past its corners', async () => {
      await render(
        <PlCollapsible className="fold-under-test" title="Advanced">
          Everything else.
        </PlCollapsible>
      );

      expect(document.querySelector('.fold-under-test')).toHaveClass('overflow-hidden');
    });

    it('is never dyed, whatever colour it is given', async () => {
      await render(
        <PlCollapsible className="fold-under-test" color="danger" title="Advanced">
          Everything else.
        </PlCollapsible>
      );

      const element = document.querySelector<HTMLElement>('.fold-under-test');

      expect(element?.style.getPropertyValue('--p-fill')).toBe('');
      expect(element?.style.getPropertyValue('--p-line')).toBe('var(--plass-danger-line)');
    });

    it('goes full bleed when the padding is turned off', async () => {
      const screen = await render(
        <PlCollapsible defaultOpen padded={false} title="Advanced">
          <span data-testid="body">Everything else.</span>
        </PlCollapsible>
      );

      const body = screen.getByTestId('body').element().parentElement;

      expect(body).not.toHaveClass('px-5');
    });
  });
});
