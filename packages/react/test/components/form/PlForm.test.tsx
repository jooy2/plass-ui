import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlForm, PlTextField } from 'plass-ui';

describe('PlForm', () => {
  describe('the element', () => {
    it('is a real form', async () => {
      const screen = await render(
        <PlForm data-testid="form">
          <PlTextField name="email" label="Email" />
        </PlForm>
      );

      expect(screen.getByTestId('form').element().tagName).toBe('FORM');
    });

    it('stacks its children on the sheet ladder', async () => {
      const screen = await render(
        <PlForm data-testid="form">
          <PlTextField name="email" label="Email" />
        </PlForm>
      );

      const form = screen.getByTestId('form').element();

      expect(form).toHaveClass('flex-col');
      expect(form).toHaveClass('gap-3');

      await screen.rerender(
        <PlForm data-testid="form" size="xl">
          <PlTextField name="email" label="Email" />
        </PlForm>
      );

      expect(screen.getByTestId('form').element()).toHaveClass('gap-4');
    });

    it('draws no surface of its own', async () => {
      const screen = await render(
        <PlForm data-testid="form">
          <PlTextField name="email" label="Email" />
        </PlForm>
      );

      const className = screen.getByTestId('form').element().className;

      expect(className).not.toContain('bg-');
      expect(className).not.toContain('border');
    });
  });

  describe('submitting', () => {
    it('reports the form s values and navigates nowhere', async () => {
      const onSubmit = vi.fn();

      const screen = await render(
        <PlForm onSubmit={onSubmit}>
          <PlTextField name="email" label="Email" defaultValue="ada@example.com" />
          <PlButton type="submit">Sign in</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Sign in' }).click();

      await expect.poll(() => onSubmit.mock.calls.length).toBe(1);
      expect(onSubmit.mock.calls[0][0]).toMatchObject({ email: 'ada@example.com' });
    });

    it('does not submit while a field is invalid', async () => {
      const onSubmit = vi.fn();

      const screen = await render(
        <PlForm onSubmit={onSubmit}>
          <PlTextField name="email" label="Email" required />
          <PlButton type="submit">Sign in</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Sign in' }).click();

      expect(onSubmit).not.toHaveBeenCalled();
    });

    it('focuses the first field that failed', async () => {
      const screen = await render(
        <PlForm>
          <PlTextField name="name" label="Name" />
          <PlTextField name="email" label="Email" required />
          <PlButton type="submit">Sign in</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Sign in' }).click();

      await expect.element(screen.getByRole('textbox', { name: 'Email' })).toHaveFocus();
    });
  });

  describe('errors from somewhere else', () => {
    it('puts a server s answer back on the field it belongs to', async () => {
      const screen = await render(
        <PlForm errors={{ email: 'That address is already registered' }}>
          <PlTextField name="email" label="Email" />
        </PlForm>
      );

      await expect.element(screen.getByText('That address is already registered')).toBeVisible();
    });

    it('leaves the other fields alone', async () => {
      const screen = await render(
        <PlForm errors={{ email: 'Taken' }}>
          <PlTextField name="name" label="Name" />
          <PlTextField name="email" label="Email" />
        </PlForm>
      );

      await expect
        .element(screen.getByRole('textbox', { name: 'Name' }))
        .not.toHaveAttribute('aria-invalid', 'true');
    });

    it('clears the error as soon as that field changes', async () => {
      const screen = await render(
        <PlForm errors={{ email: 'Taken' }}>
          <PlTextField name="email" label="Email" />
        </PlForm>
      );

      await expect.element(screen.getByText('Taken')).toBeVisible();

      await screen.getByRole('textbox', { name: 'Email' }).fill('new@example.com');

      await expect.poll(() => screen.getByText('Taken').query()).toBeNull();
    });
  });

  describe('validationMode', () => {
    it('waits for a submit by default, rather than while somebody types', async () => {
      const screen = await render(
        <PlForm>
          <PlTextField name="email" label="Email" type="email" />
          <PlButton type="submit">Sign in</PlButton>
        </PlForm>
      );

      const field = screen.getByRole('textbox', { name: 'Email' });

      await field.fill('not-an-email');
      await field.element().dispatchEvent(new FocusEvent('blur', { bubbles: true }));

      expect(screen.getByRole('alert').query()).toBeNull();
    });

    it('can be asked to check on blur instead', async () => {
      const screen = await render(
        <PlForm validationMode="onBlur">
          <PlTextField name="email" label="Email" type="email" />
          <PlTextField name="other" label="Other" />
        </PlForm>
      );

      await screen.getByRole('textbox', { name: 'Email' }).fill('not-an-email');
      await screen.getByRole('textbox', { name: 'Other' }).click();

      await expect
        .poll(() =>
          screen.getByRole('textbox', { name: 'Email' }).element().getAttribute('aria-invalid')
        )
        .toBe('true');
    });
  });
});
