import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlOtpField } from 'plass-ui';
import { press } from '../../support/keys';

/**
 * Every slot in the row, in order.
 *
 * `input[class]` because Base UI puts one more `<input>` in the row — the
 * hidden one carrying the whole value for a form — and that one has none of the
 * component's classes on it.
 */
function slots(): HTMLInputElement[] {
  return Array.from(document.querySelectorAll<HTMLInputElement>('.otp-under-test input[class]'));
}

describe('PlOtpField', () => {
  describe('the row', () => {
    it('is six slots unless it is told otherwise', async () => {
      await render(<PlOtpField className="otp-under-test" />);

      expect(slots()).toHaveLength(6);
    });

    it('takes the length it was given', async () => {
      await render(<PlOtpField className="otp-under-test" length={4} />);

      expect(slots()).toHaveLength(4);
    });

    it('refuses to be one box, which is a text field', async () => {
      await render(<PlOtpField className="otp-under-test" length={1} />);

      expect(slots()).toHaveLength(2);
    });

    it('stops at twelve, where the row stops fitting a phone', async () => {
      await render(<PlOtpField className="otp-under-test" length={40} />);

      expect(slots()).toHaveLength(12);
    });
  });

  describe('typing', () => {
    it('reports the code as it is typed', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlOtpField className="otp-under-test" length={3} onValueChange={change} />
      );

      await screen.getByRole('textbox').first().fill('12');

      expect(change).toHaveBeenLastCalledWith('12');
    });

    it('fires once the last slot is filled', async () => {
      const complete = vi.fn();
      const screen = await render(
        <PlOtpField className="otp-under-test" length={3} onComplete={complete} />
      );

      await screen.getByRole('textbox').first().fill('123');

      expect(complete).toHaveBeenCalledWith('123');
    });

    it('drops what the charset rejects and says so', async () => {
      const invalid = vi.fn();
      const change = vi.fn();
      const screen = await render(
        <PlOtpField
          className="otp-under-test"
          length={3}
          onValueInvalid={invalid}
          onValueChange={change}
        />
      );

      await screen.getByRole('textbox').first().fill('abc');

      expect(invalid).toHaveBeenCalled();
      expect(change).not.toHaveBeenCalledWith('abc');
    });

    it('takes letters once it is asked to', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlOtpField className="otp-under-test" length={3} charset="alpha" onValueChange={change} />
      );

      await screen.getByRole('textbox').first().fill('abc');

      expect(change).toHaveBeenLastCalledWith('abc');
    });
  });

  describe('the separator', () => {
    it('draws nothing unless a group size is given', async () => {
      await render(<PlOtpField className="otp-under-test" />);

      expect(document.querySelectorAll('.otp-under-test span[aria-hidden="true"]')).toHaveLength(0);
    });

    it('splits the row every group', async () => {
      await render(<PlOtpField className="otp-under-test" length={6} groupSize={3} />);

      const marks = document.querySelectorAll('.otp-under-test span[aria-hidden="true"]');

      expect(marks).toHaveLength(1);
      expect(marks[0].textContent).toBe('–');
    });

    it('draws whatever it was handed', async () => {
      await render(
        <PlOtpField className="otp-under-test" length={4} groupSize={2} separator="·" />
      );

      expect(document.querySelector('.otp-under-test span[aria-hidden="true"]')?.textContent).toBe(
        '·'
      );
    });

    it('never puts one at either end', async () => {
      await render(<PlOtpField className="otp-under-test" length={4} groupSize={4} />);

      expect(document.querySelectorAll('.otp-under-test span[aria-hidden="true"]')).toHaveLength(0);
    });
  });

  describe('the field', () => {
    it('names the row with its label', async () => {
      const screen = await render(<PlOtpField label="Verification code" />);

      await expect.element(screen.getByText('Verification code')).toBeInTheDocument();
    });

    it('shows a description under it', async () => {
      const screen = await render(<PlOtpField description="We texted it to you." />);

      await expect.element(screen.getByText('We texted it to you.')).toBeInTheDocument();
    });

    it('turns invalid when an error is given', async () => {
      const screen = await render(
        <PlOtpField className="otp-under-test" error="That code has expired." />
      );

      await expect.element(screen.getByText('That code has expired.')).toBeInTheDocument();

      const element = document.querySelector<HTMLElement>('.otp-under-test');

      expect(element?.style.getPropertyValue('--p-ring')).toBe('var(--plass-danger-ring)');
    });

    it('can be invalid without a message', async () => {
      await render(<PlOtpField className="otp-under-test" invalid />);

      const element = document.querySelector<HTMLElement>('.otp-under-test');

      expect(element?.style.getPropertyValue('--p-ring')).toBe('var(--plass-danger-ring)');
    });

    it('lets a form library keep the field valid despite a message', async () => {
      await render(
        <PlOtpField className="otp-under-test" error="Shown but not fatal." invalid={false} />
      );

      const element = document.querySelector<HTMLElement>('.otp-under-test');

      expect(element?.style.getPropertyValue('--p-ring')).toBe('var(--plass-primary-ring)');
    });
  });

  describe('states', () => {
    it('stops every slot answering when it is disabled', async () => {
      await render(<PlOtpField className="otp-under-test" disabled />);

      expect(slots().every((slot) => slot.disabled)).toBe(true);
    });

    it('stays readable but not typeable when it is read-only', async () => {
      await render(<PlOtpField className="otp-under-test" readOnly defaultValue="123456" />);

      expect(slots().every((slot) => slot.readOnly)).toBe(true);
    });

    it('hides the characters when it is masked', async () => {
      await render(<PlOtpField className="otp-under-test" mask defaultValue="1" />);

      expect(slots().every((slot) => slot.type === 'password')).toBe(true);
    });

    it('shows them otherwise', async () => {
      await render(<PlOtpField className="otp-under-test" defaultValue="1" />);

      expect(slots()[0].type).toBe('text');
    });
  });

  describe('the form', () => {
    it('submits under the name it was given', async () => {
      await render(<PlOtpField className="otp-under-test" name="code" defaultValue="12" />);

      expect(document.querySelector('input[name="code"]')).not.toBeNull();
    });
  });
  describe('hotKeys', () => {
    it('answers a chord pressed in a slot', async () => {
      const resend = vi.fn();

      await render(<PlOtpField className="otp-under-test" hotKeys={{ 'Shift+Enter': resend }} />);

      press(slots()[2], 'Enter', { shiftKey: true });

      expect(resend).toHaveBeenCalledTimes(1);
    });
  });
});
