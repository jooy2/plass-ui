import type * as React from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlButton,
  PlCalendar,
  PlCheckbox,
  PlColorPicker,
  PlCombobox,
  PlDatePicker,
  PlDateRangePicker,
  PlDateTimePicker,
  PlFieldset,
  PlFilePicker,
  PlForm,
  PlNumberField,
  PlOtpField,
  PlPagination,
  PlRadio,
  PlRadioGroup,
  PlRating,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlSlider,
  PlSwitch,
  PlTextField,
  PlTimePicker,
  PlToggle,
  PlTransfer,
  PlTreeSelect
} from 'plass-ui';

const options = [
  { value: 'lisbon', label: 'Lisbon' },
  { value: 'seoul', label: 'Seoul' }
];

/**
 * Every control a form is built from, each drawn with or without a `disabled` of
 * its own. Inside a disabled fieldset each has to be drawn exactly as it is with
 * one.
 */
const controls: Record<string, (disabled?: boolean) => React.ReactNode> = {
  PlTextField: (disabled) => <PlTextField label="Street" disabled={disabled} />,
  PlNumberField: (disabled) => <PlNumberField label="Quantity" disabled={disabled} />,
  PlSelect: (disabled) => <PlSelect label="City" items={options} disabled={disabled} />,
  PlCombobox: (disabled) => <PlCombobox label="City" items={options} disabled={disabled} />,
  PlDatePicker: (disabled) => <PlDatePicker label="Departure" disabled={disabled} />,
  PlOtpField: (disabled) => <PlOtpField label="Code" disabled={disabled} />,
  PlFilePicker: (disabled) => <PlFilePicker label="Attachments" disabled={disabled} />,
  PlCheckbox: (disabled) => <PlCheckbox label="Business address" disabled={disabled} />,
  PlSwitch: (disabled) => <PlSwitch label="Invoices by email" disabled={disabled} />,
  PlRadioGroup: (disabled) => (
    <PlRadioGroup label="Plan" disabled={disabled}>
      <PlRadio value="starter" label="Starter" />
      <PlRadio value="team" label="Team" />
    </PlRadioGroup>
  ),
  PlSlider: (disabled) => <PlSlider label="Volume" defaultValue={40} disabled={disabled} />,
  PlRating: (disabled) => <PlRating defaultValue={3} disabled={disabled} />,
  PlTimePicker: (disabled) => <PlTimePicker label="Doors" disabled={disabled} />,
  PlDateRangePicker: (disabled) => <PlDateRangePicker label="Stay" disabled={disabled} />,
  PlDateTimePicker: (disabled) => <PlDateTimePicker label="Starts" disabled={disabled} />,
  PlColorPicker: (disabled) => <PlColorPicker label="Colour" disabled={disabled} />,
  'inline PlColorPicker': (disabled) => <PlColorPicker label="Colour" inline disabled={disabled} />,
  PlTreeSelect: (disabled) => (
    <PlTreeSelect label="Region" items={[{ id: 'europe', label: 'Europe' }]} disabled={disabled} />
  ),
  PlToggle: (disabled) => <PlToggle disabled={disabled}>Bold</PlToggle>,
  PlButton: (disabled) => <PlButton disabled={disabled}>Verify</PlButton>,
  PlCalendar: (disabled) => <PlCalendar defaultValue={new Date(2026, 6, 27)} disabled={disabled} />,
  PlPagination: (disabled) => <PlPagination count={5} disabled={disabled} />,
  PlTransfer: (disabled) => (
    <PlTransfer items={options} defaultValue={['seoul']} disabled={disabled} />
  )
};

/** The class list of `element` and of everything in it, in document order. */
function drawing(element: Element): string[] {
  return [element, ...element.querySelectorAll('*')].map(
    (node) => node.getAttribute('class') ?? ''
  );
}

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

    describe('draws every control inside as disabled', () => {
      for (const [name, control] of Object.entries(controls)) {
        it(`draws a ${name} as one with its own disabled`, async () => {
          const own = await render(<div data-testid="own">{control(true)}</div>);
          const expected = drawing(own.getByTestId('own').element());

          await own.unmount();

          const screen = await render(
            <PlFieldset data-testid="group" disabled>
              {control()}
            </PlFieldset>
          );
          const group = screen.getByTestId('group').element();

          expect(drawing(group).slice(1)).toEqual(expected.slice(1));
          // The light is a claim that the surface answers, and none of these do.
          // An `inert` sheet takes no pointer, so what is on it cannot light.
          const lit = [...group.querySelectorAll('.plass-glow')].filter(
            (element) => !element.closest('[inert]')
          );

          expect(lit).toHaveLength(0);
        });
      }
    });

    it('draws a field that is disabled twice over once', async () => {
      const own = await render(<div data-testid="own">{controls.PlTextField(true)}</div>);
      const expected = drawing(own.getByTestId('own').element());

      await own.unmount();

      const screen = await render(
        <PlFieldset data-testid="group" disabled>
          {controls.PlTextField(true)}
        </PlFieldset>
      );

      expect(drawing(screen.getByTestId('group').element()).slice(1)).toEqual(expected.slice(1));
    });

    it('draws a field as disabled from a fieldset further out', async () => {
      const screen = await render(
        <PlFieldset disabled>
          <PlFieldset>
            <PlTextField label="Street" />
          </PlFieldset>
        </PlFieldset>
      );
      const shell = screen.getByRole('textbox', { name: 'Street' }).element().parentElement;

      expect(shell).toHaveClass('opacity-50');
      expect(shell).not.toHaveClass('plass-glow');
    });

    it('draws the label of a field inside muted, as a disabled field does', async () => {
      const screen = await render(
        <PlFieldset disabled>
          <PlTextField label="Street" />
          <PlSelect label="City" items={options} />
          <PlCheckbox label="Business address" />
        </PlFieldset>
      );

      for (const label of ['Street', 'City', 'Business address']) {
        expect(screen.getByText(label, { exact: true }).element()).toHaveClass(
          'text-(--plass-muted-fg)'
        );
      }
    });

    it('stops a segmented button inside answering, and puts its light out', async () => {
      const screen = await render(
        <PlFieldset disabled>
          <PlSegmentedButton aria-label="Period" defaultValue="day">
            <PlSegment value="day">Day</PlSegment>
            <PlSegment value="week">Week</PlSegment>
          </PlSegmentedButton>
        </PlFieldset>
      );

      for (const segment of screen.getByRole('radio').elements()) {
        expect(segment).toHaveAttribute('data-disabled');
        expect(segment).not.toHaveClass('plass-glow');
      }

      expect(screen.getByRole('radiogroup').element()).toHaveClass('opacity-50');
    });

    it('takes a slider inside away from the pointer as well as the keys', async () => {
      const screen = await render(
        <PlFieldset disabled>
          <PlSlider label="Volume" defaultValue={40} />
        </PlFieldset>
      );

      expect(screen.getByRole('group', { name: 'Volume' }).element()).toHaveAttribute(
        'data-disabled'
      );
    });

    it('refuses a file dropped on a file picker inside', async () => {
      const changes: File[][] = [];
      const screen = await render(
        <PlFieldset disabled>
          <PlFilePicker label="Attachments" onFilesChange={(files) => changes.push(files)} />
        </PlFieldset>
      );
      const dataTransfer = new DataTransfer();

      dataTransfer.items.add(new File(['x'], 'invoice.pdf', { type: 'application/pdf' }));
      // On the browse button: the drop listeners sit between it and the root.
      screen
        .getByRole('button')
        .element()
        .dispatchEvent(new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer }));

      expect(changes).toHaveLength(0);
    });

    it('keeps a value a form cannot collect by itself out of the form, as a disabled field is', async () => {
      let submitted: Record<string, unknown> | null = null;
      const screen = await render(
        <PlForm onSubmit={(values) => (submitted = values)}>
          <PlFieldset disabled>
            <PlCalendar name="day" defaultValue={new Date(2026, 6, 27)} />
            <PlTextField name="street" label="Street" defaultValue="Rua Augusta" />
          </PlFieldset>
          <PlTextField name="email" label="Email" defaultValue="user@example.com" />
          <PlButton type="submit">Send</PlButton>
        </PlForm>
      );

      await screen.getByRole('button', { name: 'Send' }).click();

      expect(submitted).toEqual({ email: 'user@example.com' });
    });

    it('leaves a field outside it alone', async () => {
      const screen = await render(
        <>
          <PlFieldset disabled>
            <PlTextField label="Street" />
          </PlFieldset>
          <PlTextField label="Email" />
        </>
      );
      const shell = screen.getByRole('textbox', { name: 'Email' }).element().parentElement;

      await expect.element(screen.getByRole('textbox', { name: 'Email' })).toBeEnabled();
      expect(shell).toHaveClass('plass-glow');
      expect(shell).not.toHaveClass('opacity-50');
    });

    it('draws a link in place of a button as it is, since a fieldset does not reach one', async () => {
      const screen = await render(
        <PlFieldset disabled>
          <PlButton render={<a href="#billing" />}>Billing</PlButton>
        </PlFieldset>
      );
      const link = screen.getByRole('link', { name: 'Billing' }).element();

      expect(link).toHaveClass('plass-glow');
      expect(link).not.toHaveClass('opacity-50');
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
