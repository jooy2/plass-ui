import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlNumberField } from 'plass-ui';
import { press } from '../../support/keys';

describe('PlNumberField', () => {
  describe('rendering', () => {
    it('renders a spin button with its label', async () => {
      const screen = await render(<PlNumberField label="Quantity" />);

      await expect.element(screen.getByRole('textbox', { name: 'Quantity' })).toBeInTheDocument();
    });

    it('shows the value it is given', async () => {
      const screen = await render(<PlNumberField label="Quantity" value={7} />);

      await expect.element(screen.getByRole('textbox', { name: 'Quantity' })).toHaveValue('7');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<PlNumberField label="Quantity" value={7} />);

      await screen.rerender(<PlNumberField label="Quantity" value={9} />);

      await expect.element(screen.getByRole('textbox', { name: 'Quantity' })).toHaveValue('9');
    });

    it('renders its description and its error', async () => {
      const screen = await render(
        <PlNumberField label="Quantity" description="How many boxes" error="Too many" />
      );

      await expect.element(screen.getByText('How many boxes')).toBeInTheDocument();
      await expect.element(screen.getByText('Too many')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlNumberField label="Quantity" className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('the steppers', () => {
    it('draws both at the end by default', async () => {
      const screen = await render(<PlNumberField label="Quantity" />);

      await expect.element(screen.getByRole('button', { name: 'Increase' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Decrease' })).toBeInTheDocument();
    });

    it('takes names of its own for them', async () => {
      const screen = await render(
        <PlNumberField label="Quantity" incrementLabel="더하기" decrementLabel="빼기" />
      );

      await expect.element(screen.getByRole('button', { name: '더하기' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: '빼기' })).toBeInTheDocument();
    });

    it('draws none when asked', async () => {
      const screen = await render(<PlNumberField label="Quantity" steppers="none" />);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('draws none while read-only', async () => {
      const screen = await render(<PlNumberField label="Quantity" readOnly value={3} />);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('steps the value up and down', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlNumberField label="Quantity" defaultValue={3} onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Increase' }).click();

      await expect.element(screen.getByRole('textbox', { name: 'Quantity' })).toHaveValue('4');

      await screen.getByRole('button', { name: 'Decrease' }).click();

      await expect.element(screen.getByRole('textbox', { name: 'Quantity' })).toHaveValue('3');
      expect(onValueChange).toHaveBeenCalledTimes(2);
    });

    it('steps by `step`', async () => {
      const screen = await render(<PlNumberField label="Quantity" defaultValue={0} step={5} />);

      await screen.getByRole('button', { name: 'Increase' }).click();

      await expect.element(screen.getByRole('textbox', { name: 'Quantity' })).toHaveValue('5');
    });

    it('stops at the ends of the range', async () => {
      const screen = await render(
        <PlNumberField label="Quantity" defaultValue={1} min={0} max={1} />
      );

      expect(screen.getByRole('button', { name: 'Increase' }).element()).toBeDisabled();
      expect(screen.getByRole('button', { name: 'Decrease' }).element()).not.toBeDisabled();
    });
  });

  describe('typing into it', () => {
    it('reports what was typed as a number', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlNumberField label="Quantity" onValueChange={onValueChange} />);

      const input = screen.getByRole('textbox', { name: 'Quantity' });

      await expect.element(input).toBeInTheDocument();
      await input.fill('42');

      await expect.poll(() => onValueChange).toHaveBeenCalledWith(42);
    });
  });

  describe('formatting', () => {
    it('writes the number the way `format` says', async () => {
      const screen = await render(
        <PlNumberField
          label="Price"
          value={1240}
          locale="en-US"
          format={{ style: 'currency', currency: 'USD' }}
        />
      );

      await expect.element(screen.getByRole('textbox', { name: 'Price' })).toHaveValue('$1,240.00');
    });
  });

  describe('states', () => {
    it('disables the control and its steppers', async () => {
      const screen = await render(<PlNumberField label="Quantity" disabled />);

      expect(screen.getByRole('textbox', { name: 'Quantity' }).element()).toBeDisabled();
      expect(screen.getByRole('button', { name: 'Increase' }).element()).toBeDisabled();
    });

    it('turns invalid when there is an error', async () => {
      const screen = await render(<PlNumberField label="Quantity" error="Too many" />);

      expect(screen.getByRole('textbox', { name: 'Quantity' }).element()).toHaveAttribute(
        'aria-invalid',
        'true'
      );
    });
  });
  describe('hotKeys', () => {
    it('answers a chord pressed in the input', async () => {
      const save = vi.fn();
      const screen = await render(<PlNumberField label="Quantity" hotKeys={{ Enter: save }} />);

      press(screen.getByRole('textbox').element(), 'Enter');

      expect(save).toHaveBeenCalledTimes(1);
    });
  });
});
