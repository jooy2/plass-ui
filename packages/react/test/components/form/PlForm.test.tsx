import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlButton,
  PlCalendar,
  PlDatePicker,
  PlDateRangePicker,
  PlFilePicker,
  PlForm,
  PlTextField,
  PlTreeSelect
} from 'plass-ui';

const JULY_27 = new Date(2026, 6, 27);

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

  describe('a control that is not an input', () => {
    it('reports a picker s value', async () => {
      const onSubmit = vi.fn();

      const screen = await render(
        <PlForm onSubmit={onSubmit}>
          <PlDatePicker name="departure" label="Departure" defaultValue={JULY_27} />
          <PlButton type="submit">Book</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Book' }).click();

      await expect.poll(() => onSubmit.mock.calls.length).toBe(1);
      expect(onSubmit.mock.calls[0][0]).toMatchObject({ departure: '2026-07-27' });
    });

    it('reports every value a range or a multiple choice holds', async () => {
      const onSubmit = vi.fn();

      const screen = await render(
        <PlForm onSubmit={onSubmit}>
          <PlDateRangePicker
            name="stay"
            label="Stay"
            defaultValue={{ start: new Date(2026, 6, 10), end: new Date(2026, 6, 20) }}
          />
          <PlTreeSelect
            name="region"
            label="Region"
            multiple
            items={[
              { id: 'france', label: 'France' },
              { id: 'spain', label: 'Spain' }
            ]}
            defaultValue={['france', 'spain']}
          />
          <PlButton type="submit">Book</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Book' }).click();

      await expect.poll(() => onSubmit.mock.calls.length).toBe(1);
      expect(onSubmit.mock.calls[0][0]).toMatchObject({
        stay: ['2026-07-10', '2026-07-20'],
        region: ['france', 'spain']
      });
    });

    it('reports an inline calendar and the files a file picker holds', async () => {
      const onSubmit = vi.fn();
      const file = new File(['a'], 'a.txt', { type: 'text/plain' });

      const screen = await render(
        <PlForm onSubmit={onSubmit}>
          <PlCalendar name="day" defaultValue={JULY_27} />
          <PlFilePicker name="attachments" label="Attachments" defaultValue={[file]} />
          <PlButton type="submit">Send</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Send' }).click();

      await expect.poll(() => onSubmit.mock.calls.length).toBe(1);
      expect(onSubmit.mock.calls[0][0]).toMatchObject({ day: '2026-07-27', attachments: [file] });
    });

    it('leaves a disabled picker out', async () => {
      const onSubmit = vi.fn();

      const screen = await render(
        <PlForm onSubmit={onSubmit}>
          <PlDatePicker name="departure" label="Departure" defaultValue={JULY_27} disabled />
          <PlButton type="submit">Book</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Book' }).click();

      await expect.poll(() => onSubmit.mock.calls.length).toBe(1);
      expect(onSubmit.mock.calls[0][0]).not.toHaveProperty('departure');
    });

    it('does not submit while a required picker is empty, and focuses its trigger', async () => {
      const onSubmit = vi.fn();

      const screen = await render(
        <PlForm onSubmit={onSubmit}>
          <PlDatePicker name="departure" label="Departure" required />
          <PlButton type="submit">Book</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Book' }).click();

      const trigger = screen.getByRole('button', { name: /Departure/ });

      await expect.element(trigger).toHaveFocus();
      await expect.element(trigger).toHaveAttribute('aria-invalid', 'true');
      expect(onSubmit).not.toHaveBeenCalled();
    });

    it('does not submit while a required file picker is empty', async () => {
      const onSubmit = vi.fn();

      const screen = await render(
        <PlForm onSubmit={onSubmit}>
          <PlFilePicker name="attachments" title="Attach" required />
          <PlButton type="submit">Send</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Send' }).click();

      await expect.element(screen.getByRole('button', { name: /Attach/ })).toHaveFocus();
      expect(onSubmit).not.toHaveBeenCalled();
    });

    it('checks a picker when the reader leaves it, on blur', async () => {
      // An empty value counts once it has been changed, as in a text field.
      const form = (value: Date | null) => (
        <PlForm validationMode="onBlur">
          <PlDatePicker name="departure" label="Departure" required value={value} />
          <PlTextField name="other" label="Other" />
        </PlForm>
      );
      const screen = await render(form(JULY_27));

      await screen.rerender(form(null));

      const trigger = screen.getByRole('button', { name: /Departure/ });

      trigger.element().focus();
      await screen.getByRole('textbox', { name: 'Other' }).click();

      await expect.element(trigger).toHaveAttribute('aria-invalid', 'true');
    });

    it('puts a server s answer on the picker it belongs to', async () => {
      const screen = await render(
        <PlForm errors={{ departure: 'No seats left that day' }}>
          <PlDatePicker name="departure" label="Departure" defaultValue={JULY_27} />
          <PlFilePicker name="attachments" title="Attach" />
        </PlForm>
      );

      const trigger = screen.getByRole('button', { name: /Departure/ });

      await expect.element(screen.getByText('No seats left that day')).toBeVisible();
      await expect.element(trigger).toHaveAttribute('aria-invalid', 'true');
      await expect
        .element(trigger)
        .toHaveAccessibleDescription(expect.stringContaining('No seats left that day'));
      await expect
        .element(screen.getByRole('button', { name: /Attach/ }))
        .not.toHaveAttribute('aria-invalid');
    });
  });
});

describe('a picker in a plain form', () => {
  it('blocks the submit while it is required and empty', async () => {
    await render(
      <form className="form-under-test">
        <PlDatePicker name="departure" label="Departure" required />
      </form>
    );

    expect(document.querySelector<HTMLFormElement>('.form-under-test')!.checkValidity()).toBe(
      false
    );
  });

  it('submits nothing while it is disabled', async () => {
    await render(
      <form className="form-under-test">
        <PlDatePicker name="departure" label="Departure" defaultValue={JULY_27} disabled />
        <PlDateRangePicker
          name="stay"
          label="Stay"
          defaultValue={{ start: JULY_27, end: JULY_27 }}
          disabled
        />
      </form>
    );

    const data = new FormData(document.querySelector<HTMLFormElement>('.form-under-test')!);

    expect(data.has('departure')).toBe(false);
    expect(data.has('stay')).toBe(false);
  });
});
