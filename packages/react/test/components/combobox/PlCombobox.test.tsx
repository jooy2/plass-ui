import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCombobox, type PlComboboxOption } from 'plass-ui';
import { press } from '../../support/keys';

const items: PlComboboxOption[] = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' },
  { value: 'quito', label: 'Quito', disabled: true }
];

describe('PlCombobox', () => {
  describe('rendering', () => {
    it('renders a combobox input', async () => {
      const screen = await render(<PlCombobox items={items} label="City" />);

      await expect.element(screen.getByRole('combobox', { name: 'City' })).toBeInTheDocument();
    });

    it('shows the placeholder while nothing is typed', async () => {
      const screen = await render(<PlCombobox items={items} placeholder="Pick a city" />);

      expect(screen.getByRole('combobox').element()).toHaveAttribute('placeholder', 'Pick a city');
    });

    it('shows the chosen option by its label, not its value', async () => {
      const screen = await render(<PlCombobox items={items} defaultValue="seoul" />);

      expect(screen.getByRole('combobox').element()).toHaveValue('Seoul');
    });

    it('renders the label, the description and the error', async () => {
      const screen = await render(
        <PlCombobox
          items={items}
          label="City"
          description="Where the team sits."
          error="Pick one."
        />
      );

      await expect.element(screen.getByText('Where the team sits.')).toBeInTheDocument();
      await expect.element(screen.getByText('Pick one.')).toBeInTheDocument();
    });

    it('marks the field invalid when there is an error', async () => {
      const screen = await render(<PlCombobox items={items} error="Pick one." />);

      expect(screen.getByRole('combobox').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <PlCombobox items={items} value="seoul" onValueChange={() => {}} />
      );

      await screen.rerender(<PlCombobox items={items} value="lisbon" onValueChange={() => {}} />);

      expect(screen.getByRole('combobox').element()).toHaveValue('Lisbon');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlCombobox items={items} className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('choosing', () => {
    it('opens the list and picks an option', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlCombobox items={items} onValueChange={onValueChange} />);

      await screen.getByRole('button', { name: 'Open' }).click();
      await screen.getByRole('option', { name: 'Lisbon' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith('lisbon'));
    });

    it('marks a disabled option as such', async () => {
      const screen = await render(<PlCombobox items={items} />);

      await screen.getByRole('button', { name: 'Open' }).click();

      await expect
        .element(screen.getByRole('option', { name: 'Quito' }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('obeys `value` rather than the click when controlled', async () => {
      const screen = await render(
        <PlCombobox items={items} value="seoul" onValueChange={() => {}} />
      );

      await screen.getByRole('button', { name: 'Open' }).click();
      await screen.getByRole('option', { name: 'Lisbon' }).click();

      // Retried rather than read once: the click and React's re-render off the
      // unchanged `value` are two separate turns, and which of them a browser
      // has finished by the time the click promise settles is not fixed.
      await expect.element(screen.getByRole('combobox')).toHaveValue('Seoul');
    });
  });

  describe('filtering', () => {
    it('narrows the list to what was typed', async () => {
      const screen = await render(<PlCombobox items={items} allowCustom={false} />);

      await screen.getByRole('combobox').fill('lis');

      await vi.waitFor(() => expect(screen.getByRole('option').elements()).toHaveLength(1));
      await expect.element(screen.getByRole('option')).toHaveTextContent('Lisbon');
    });

    it('reports what is typed as it changes', async () => {
      const onInputValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} onInputValueChange={onInputValueChange} />
      );

      await screen.getByRole('combobox').fill('qui');

      await vi.waitFor(() => expect(onInputValueChange).toHaveBeenCalledWith('qui'));
    });

    it('says so when nothing matched and nothing may be added', async () => {
      const screen = await render(<PlCombobox items={items} allowCustom={false} />);

      await screen.getByRole('combobox').fill('nowhere');

      await expect.element(screen.getByText('No matches')).toBeInTheDocument();
    });

    it('says so in the caller’s own words', async () => {
      const screen = await render(
        <PlCombobox items={items} allowCustom={false} emptyMessage="Nothing like that" />
      );

      await screen.getByRole('combobox').fill('nowhere');

      await expect.element(screen.getByText('Nothing like that')).toBeInTheDocument();
    });
  });

  describe('a value the list does not have', () => {
    it('offers what was typed as its own row', async () => {
      const screen = await render(<PlCombobox items={items} />);

      await screen.getByRole('combobox').fill('Osaka');

      await expect.element(screen.getByRole('option', { name: /Osaka/ })).toBeInTheDocument();
    });

    it('commits it when that row is taken', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlCombobox items={items} onValueChange={onValueChange} />);

      await screen.getByRole('combobox').fill('Osaka');
      await screen.getByRole('option', { name: /Osaka/ }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith('Osaka'));
    });

    it('offers nothing extra once the text matches an option', async () => {
      const screen = await render(<PlCombobox items={items} />);

      await screen.getByRole('combobox').fill('Lisbon');

      await vi.waitFor(() => expect(screen.getByRole('option').elements()).toHaveLength(1));
    });

    it('says it in the caller’s own words', async () => {
      const screen = await render(
        <PlCombobox items={items} customLabel={(query) => `Create ${query}`} />
      );

      await screen.getByRole('combobox').fill('Osaka');

      await expect
        .element(screen.getByRole('option', { name: 'Create Osaka' }))
        .toBeInTheDocument();
    });

    it('offers nothing at all when `allowCustom` is off', async () => {
      const screen = await render(<PlCombobox items={items} allowCustom={false} />);

      await screen.getByRole('combobox').fill('Osaka');

      expect(screen.getByRole('option').query()).toBeNull();
    });
  });

  describe('multiple', () => {
    it('holds more than one value, as chips', async () => {
      const screen = await render(
        <PlCombobox items={items} multiple defaultValue={['seoul', 'lisbon']} />
      );

      await expect.element(screen.getByText('Seoul')).toBeInTheDocument();
      await expect.element(screen.getByText('Lisbon')).toBeInTheDocument();
    });

    it('reports an array', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} multiple onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Open' }).click();
      await screen.getByRole('option', { name: 'Seoul' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith(['seoul']));
    });

    it('names each chip’s remove button after the chip', async () => {
      const screen = await render(<PlCombobox items={items} multiple defaultValue={['seoul']} />);

      await expect
        .element(screen.getByRole('button', { name: 'Remove Seoul' }))
        .toBeInTheDocument();
    });

    it('takes a value off when its × is pressed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox
          items={items}
          multiple
          defaultValue={['seoul', 'lisbon']}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Remove Seoul' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith(['lisbon']));
    });
  });

  describe('states', () => {
    it('disables the input', async () => {
      const screen = await render(<PlCombobox items={items} disabled />);

      expect(screen.getByRole('combobox').element()).toBeDisabled();
    });

    it('keeps a read-only combobox readable but unchangeable', async () => {
      const screen = await render(<PlCombobox items={items} readOnly defaultValue="seoul" />);

      expect(screen.getByRole('combobox').element()).toHaveAttribute('readonly');
      expect(screen.getByRole('combobox').element()).toHaveValue('Seoul');
    });

    it('offers a × only when asked', async () => {
      const screen = await render(<PlCombobox items={items} defaultValue="seoul" />);

      expect(screen.getByRole('button', { name: 'Clear' }).query()).toBeNull();

      await screen.rerender(<PlCombobox items={items} defaultValue="seoul" clearable />);

      await expect.element(screen.getByRole('button', { name: 'Clear' })).toBeInTheDocument();
    });
  });

  describe('forms', () => {
    it('submits the chosen value under `name`', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();
      });
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlCombobox items={items} name="city" defaultValue="lisbon" />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      const form = screen.getByRole('button', { name: 'Save' }).element().closest('form');

      expect(new FormData(form as HTMLFormElement).get('city')).toBe('lisbon');
    });
  });
  describe('hotKeys', () => {
    it('answers a chord pressed in the input', async () => {
      const create = vi.fn();
      const screen = await render(
        <PlCombobox label="City" items={items} hotKeys={{ 'Shift+Enter': create }} />
      );

      press(screen.getByRole('combobox').element(), 'Enter', { shiftKey: true });

      expect(create).toHaveBeenCalledTimes(1);
    });
  });
});
