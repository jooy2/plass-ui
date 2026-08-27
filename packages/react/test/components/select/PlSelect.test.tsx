import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlSelect, type PlSelectOption } from 'plass-ui';

const items: PlSelectOption[] = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' },
  { value: 'quito', label: 'Quito', disabled: true }
];

describe('PlSelect', () => {
  describe('rendering', () => {
    it('renders a combobox trigger', async () => {
      const screen = await render(<PlSelect items={items} label="City" />);

      await expect.element(screen.getByRole('combobox', { name: 'City' })).toBeInTheDocument();
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(<PlSelect items={items} placeholder="Pick a city" />);

      await expect.element(screen.getByText('Pick a city')).toBeInTheDocument();
    });

    it('shows the chosen option by its label, not its value', async () => {
      const screen = await render(<PlSelect items={items} defaultValue="seoul" />);

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Seoul');
    });

    it('renders the label, the description and the error', async () => {
      const screen = await render(
        <PlSelect items={items} label="City" description="Where the team sits." error="Pick one." />
      );

      await expect.element(screen.getByText('Where the team sits.')).toBeInTheDocument();
      await expect.element(screen.getByText('Pick one.')).toBeInTheDocument();
    });

    it('marks the trigger invalid when there is an error', async () => {
      const screen = await render(<PlSelect items={items} error="Pick one." />);

      expect(screen.getByRole('combobox').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('marks the trigger invalid from `invalid` alone', async () => {
      const screen = await render(<PlSelect items={items} invalid />);

      expect(screen.getByRole('combobox').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <PlSelect items={items} value="seoul" onValueChange={() => {}} />
      );

      await screen.rerender(<PlSelect items={items} value="lisbon" onValueChange={() => {}} />);

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Lisbon');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlSelect items={items} className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('choosing', () => {
    it('opens the list and picks an option', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlSelect items={items} placeholder="Pick" onValueChange={onValueChange} />
      );

      await screen.getByRole('combobox').click();
      await screen.getByRole('option', { name: 'Lisbon' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith('lisbon'));
      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Lisbon');
    });

    it('lists every option once the popup is open', async () => {
      const screen = await render(<PlSelect items={items} placeholder="Pick" />);

      await screen.getByRole('combobox').click();

      await vi.waitFor(() => expect(screen.getByRole('option').elements()).toHaveLength(3));
    });

    it('marks a disabled option as such', async () => {
      const screen = await render(<PlSelect items={items} placeholder="Pick" />);

      await screen.getByRole('combobox').click();

      await expect
        .element(screen.getByRole('option', { name: 'Quito' }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('obeys `value` rather than the click when controlled', async () => {
      const screen = await render(
        <PlSelect items={items} value="seoul" onValueChange={() => {}} />
      );

      await screen.getByRole('combobox').click();
      await screen.getByRole('option', { name: 'Lisbon' }).click();

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Seoul');
    });
  });

  describe('states', () => {
    it('disables the trigger', async () => {
      const screen = await render(<PlSelect items={items} disabled />);

      expect(screen.getByRole('combobox').element()).toBeDisabled();
    });

    it('keeps a read-only select focusable but unopenable', async () => {
      const screen = await render(<PlSelect items={items} readOnly defaultValue="seoul" />);
      const trigger = screen.getByRole('combobox').element() as HTMLElement;

      expect(trigger).not.toBeDisabled();

      await screen.getByRole('combobox').click();

      expect(screen.getByRole('option').query()).toBeNull();
    });
  });

  describe('forms', () => {
    it('submits the chosen value under `name`', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();
      });
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlSelect items={items} name="city" defaultValue="lisbon" />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      const form = screen.getByRole('button', { name: 'Save' }).element().closest('form');

      expect(new FormData(form as HTMLFormElement).get('city')).toBe('lisbon');
    });
  });
});
