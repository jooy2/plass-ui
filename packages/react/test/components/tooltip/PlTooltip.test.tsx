import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTooltip } from 'plass-ui';

describe('PlTooltip', () => {
  describe('the trigger', () => {
    it('adds no element of its own', async () => {
      const screen = await render(
        <PlTooltip content="Copy">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      const trigger = screen.getByRole('button', { name: 'Copy' }).element();

      expect(trigger.tagName).toBe('BUTTON');
      expect(trigger.parentElement?.tagName).not.toBe('BUTTON');
    });

    it('says nothing about a tooltip that is not on the page', async () => {
      const screen = await render(
        <PlTooltip content="Copy">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      expect(screen.getByRole('button').element()).not.toHaveAttribute('aria-describedby');
    });
  });

  describe('the plate', () => {
    it('is not rendered while it is closed', async () => {
      const screen = await render(
        <PlTooltip content="Copy to clipboard">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      expect(screen.getByRole('tooltip').query()).toBeNull();
    });

    it('renders its content when it is open', async () => {
      const screen = await render(
        <PlTooltip open content="Copy to clipboard">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      await expect
        .element(screen.getByRole('tooltip', { name: 'Copy to clipboard' }))
        .toBeInTheDocument();
    });

    it('starts open when told to, and describes the trigger', async () => {
      const screen = await render(
        <PlTooltip defaultOpen content="Copy to clipboard">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      const tooltip = screen.getByRole('tooltip');

      await expect.element(tooltip).toBeInTheDocument();
      expect(screen.getByRole('button').element()).toHaveAttribute(
        'aria-describedby',
        tooltip.element().id
      );
    });

    it('closes on a controlled change', async () => {
      const screen = await render(
        <PlTooltip open content="Copy to clipboard">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      await screen.rerender(
        <PlTooltip open={false} content="Copy to clipboard">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      // Retried rather than asserted once: the plate fades out, so it is still
      // in the DOM for the length of the transition.
      await expect.element(screen.getByRole('tooltip')).not.toBeInTheDocument();
    });

    it('reflects changed content on re-render', async () => {
      const screen = await render(
        <PlTooltip open content="Copy">
          <button type="button">Act</button>
        </PlTooltip>
      );

      await screen.rerender(
        <PlTooltip open content="Cut">
          <button type="button">Act</button>
        </PlTooltip>
      );

      await expect.element(screen.getByRole('tooltip', { name: 'Cut' })).toBeInTheDocument();
    });
  });

  describe('the arrow', () => {
    it('is drawn by default', async () => {
      const screen = await render(
        <PlTooltip open content="Copy">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      await expect.element(screen.getByRole('tooltip')).toBeInTheDocument();
      expect(screen.getByRole('tooltip').element().querySelector('svg')).not.toBeNull();
    });

    it('comes off when asked', async () => {
      const screen = await render(
        <PlTooltip open arrow={false} content="Copy">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      await expect.element(screen.getByRole('tooltip')).toBeInTheDocument();
      expect(screen.getByRole('tooltip').element().querySelector('svg')).toBeNull();
    });
  });

  describe('rendering', () => {
    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <PlTooltip open content="Copy" className="my-own-class">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      await expect.element(screen.getByRole('tooltip')).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the plate', async () => {
      const screen = await render(
        <PlTooltip open content="Copy" data-testid="note">
          <button type="button">Copy</button>
        </PlTooltip>
      );

      await expect.element(screen.getByTestId('note')).toBeInTheDocument();
    });
  });
});
