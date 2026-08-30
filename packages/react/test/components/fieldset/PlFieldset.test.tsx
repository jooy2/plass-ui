import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCheckbox, PlFieldset, PlTextField } from 'plass-ui';

describe('PlFieldset', () => {
  describe('the element', () => {
    it('is a real fieldset, which is a group', async () => {
      const screen = await render(
        <PlFieldset legend="Billing address">
          <PlTextField label="Street" />
        </PlFieldset>
      );

      await expect.element(screen.getByRole('group', { name: 'Billing address' })).toBeVisible();
    });

    it('draws a description under the legend', async () => {
      const screen = await render(
        <PlFieldset legend="Billing address" description="Where the invoice goes">
          <PlTextField label="Street" />
        </PlFieldset>
      );

      await expect.element(screen.getByText('Where the invoice goes')).toBeVisible();
    });

    it('draws no legend at all when there is nothing to say', async () => {
      const screen = await render(
        <PlFieldset data-testid="group">
          <PlTextField label="Street" />
        </PlFieldset>
      );

      // Only the field, with no heading block ahead of it.
      expect(screen.getByTestId('group').element().children).toHaveLength(1);
    });

    it('undoes the browser s own border, padding and margin', async () => {
      const screen = await render(
        <PlFieldset data-testid="group" legend="Group">
          <PlTextField label="Street" />
        </PlFieldset>
      );

      const group = screen.getByTestId('group').element();

      expect(group).toHaveClass('border-0');
      expect(group).toHaveClass('p-0');
      expect(group).toHaveClass('m-0');
      // A fieldset is `min-width: min-content`, which is what makes one holding
      // something wide refuse to shrink.
      expect(group).toHaveClass('min-w-0');
    });

    it('draws no surface, because a grouping is not a sheet', async () => {
      const screen = await render(
        <PlFieldset data-testid="group" legend="Group">
          <PlTextField label="Street" />
        </PlFieldset>
      );

      const className = screen.getByTestId('group').element().className;

      expect(className).not.toContain('bg-');
      expect(className).not.toContain('shadow');
    });

    it('stands its controls apart on the sheet ladder', async () => {
      const screen = await render(
        <PlFieldset data-testid="group" legend="Group" size="xs">
          <PlTextField label="Street" />
        </PlFieldset>
      );

      expect(screen.getByTestId('group').element()).toHaveClass('gap-1.5');
    });
  });

  describe('disabled', () => {
    it('reaches every control inside at once', async () => {
      const screen = await render(
        <PlFieldset legend="Billing address" disabled>
          <PlTextField label="Street" />
          <PlCheckbox label="Same as shipping" />
        </PlFieldset>
      );

      await expect.element(screen.getByRole('textbox', { name: 'Street' })).toBeDisabled();
      expect(screen.getByRole('checkbox', { name: 'Same as shipping' }).element()).toHaveAttribute(
        'data-disabled'
      );
    });

    it('reaches one it never heard of, three levels down', async () => {
      function Nested() {
        return (
          <div>
            <div>
              <PlTextField label="Street" />
            </div>
          </div>
        );
      }

      const screen = await render(
        <PlFieldset legend="Billing address" disabled>
          <Nested />
        </PlFieldset>
      );

      await expect.element(screen.getByRole('textbox', { name: 'Street' })).toBeDisabled();
    });

    it('leaves them alone when it is off', async () => {
      const screen = await render(
        <PlFieldset legend="Billing address">
          <PlTextField label="Street" />
        </PlFieldset>
      );

      await expect.element(screen.getByRole('textbox', { name: 'Street' })).not.toBeDisabled();
    });
  });
});
