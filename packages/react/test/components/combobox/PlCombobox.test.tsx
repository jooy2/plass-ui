import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlCombobox, PlForm, type PlComboboxOption, type PlComboboxValue } from 'plass-ui';
import { press } from '../../support/keys';

const items: PlComboboxOption[] = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' },
  { value: 'quito', label: 'Quito', disabled: true }
];

/**
 * Types at the end of what the field already holds.
 *
 * Focused directly rather than through a click, so the caret is not wherever
 * the pointer happened to land in the text, and Firefox is not asked to take a
 * focus the runner's frame does not hand it.
 */
async function typeAtEnd(input: HTMLInputElement, text: string) {
  input.focus();
  input.setSelectionRange(input.value.length, input.value.length);
  await userEvent.keyboard(text);
}

/**
 * Waits out the frame Base UI answers on, for a check that something stayed
 * as it was. A check that retries would pass on the old state before it went.
 */
function settle() {
  return new Promise((resolve) => requestAnimationFrame(() => setTimeout(resolve, 50)));
}

const heldCities: PlComboboxValue[] = ['seoul'];

/**
 * A parent that renders again on every keystroke, with its options written
 * inline, so each render hands the combobox a new `items` array holding the
 * same options.
 */
function Rerendering({
  initial,
  controlled
}: {
  initial: PlComboboxValue | null;
  controlled: boolean;
}) {
  const [, setQuery] = React.useState('');
  const [value, setValue] = React.useState(initial);

  return (
    <PlCombobox
      items={[
        { value: 'seoul', label: 'Seoul' },
        { value: 'lisbon', label: 'Lisbon' }
      ]}
      {...(controlled ? { value, onValueChange: setValue } : { defaultValue: initial })}
      onInputValueChange={setQuery}
    />
  );
}

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

    it('names the chevron and the × of a labelled field by what they do', async () => {
      const screen = await render(
        <PlCombobox items={items} label="City" defaultValue="seoul" clearable />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Open', exact: true }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Clear', exact: true }))
        .toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'City' }).query()).toBeNull();
    });

    it('names the chevron of a labelled field in the caller’s own words', async () => {
      const screen = await render(
        <PlCombobox items={items} label="City" openLabel="Show cities" />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Show cities', exact: true }))
        .toBeInTheDocument();
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

    it('fades the popup in and never slides it', async () => {
      const screen = await render(<PlCombobox items={items} />);

      await screen.getByRole('combobox').click();

      // The popup is the sheet around the list rather than the list itself,
      // which is the element carrying `role="listbox"`.
      const popup = await vi.waitFor(() =>
        screen.getByRole('listbox').element().closest('.plass-portal > *')!
      );

      expect(popup.className).toContain('data-[starting-style]:opacity-0');
      expect(popup.className).not.toContain('translate');
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

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
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

  describe('rendering again', () => {
    it('keeps what is typed into a field holding a value while inline `items` change', async () => {
      const screen = await render(<Rerendering initial="seoul" controlled />);
      const input = screen.getByRole('combobox').element() as HTMLInputElement;

      await typeAtEnd(input, 'xy');
      await settle();

      expect(input).toHaveValue('Seoulxy');
    });

    it('keeps what is typed into an uncontrolled field while inline `items` change', async () => {
      const screen = await render(<Rerendering initial="seoul" controlled={false} />);
      const input = screen.getByRole('combobox').element() as HTMLInputElement;

      await typeAtEnd(input, 'xy');
      await settle();

      expect(input).toHaveValue('Seoulxy');
    });

    it('keeps what is typed into a field holding a value the list does not have', async () => {
      const screen = await render(<PlCombobox items={items} defaultValue="Osaka" />);
      const input = screen.getByRole('combobox').element() as HTMLInputElement;

      await typeAtEnd(input, 'xy');
      await settle();

      expect(input).toHaveValue('Osakaxy');
    });

    it('writes the new label of a renamed option into the field', async () => {
      const renamed = [{ value: 'seoul', label: 'Seoul City' }, ...items.slice(1)];
      const screen = await render(<PlCombobox items={items} defaultValue="seoul" />);

      await screen.rerender(<PlCombobox items={renamed} defaultValue="seoul" />);

      await expect.element(screen.getByRole('combobox')).toHaveValue('Seoul City');
    });

    it('leaves a query typed into the open list when its option is renamed', async () => {
      const renamed = [{ value: 'seoul', label: 'Seoul City' }, ...items.slice(1)];
      const screen = await render(<PlCombobox items={items} defaultValue="seoul" />);
      const input = screen.getByRole('combobox').element() as HTMLInputElement;

      await typeAtEnd(input, 'x');
      await expect.element(screen.getByRole('listbox')).toBeInTheDocument();

      await screen.rerender(<PlCombobox items={renamed} defaultValue="seoul" />);
      await settle();

      expect(input).toHaveValue('Seoulx');
    });

    it('names a chip after the new label of a renamed option', async () => {
      const renamed = [{ value: 'seoul', label: 'Seoul City' }, ...items.slice(1)];
      const screen = await render(<PlCombobox items={items} multiple defaultValue={['seoul']} />);

      await screen.rerender(<PlCombobox items={renamed} multiple defaultValue={['seoul']} />);

      await expect
        .element(screen.getByRole('button', { name: 'Remove Seoul City' }))
        .toBeInTheDocument();
    });

    it.each([
      [
        'a value the list does not have',
        () => <PlCombobox items={items} name="city" defaultValue="Osaka" />
      ],
      [
        'an uncontrolled `multiple` value',
        () => <PlCombobox items={items} name="city" multiple defaultValue={['seoul']} />
      ],
      [
        'a controlled `multiple` value',
        () => (
          <PlCombobox
            items={items}
            name="city"
            multiple
            value={heldCities}
            onValueChange={() => {}}
          />
        )
      ]
    ])('keeps a form’s error on %s when the parent renders again', async (_, field) => {
      const errors = { city: 'That city is full.' };
      const screen = await render(<PlForm errors={errors}>{field()}</PlForm>);

      await expect.element(screen.getByText('That city is full.')).toBeInTheDocument();

      await screen.rerender(<PlForm errors={errors}>{field()}</PlForm>);
      await settle();

      expect(screen.getByText('That city is full.').query()).not.toBeNull();
    });
  });

  describe('emptying', () => {
    it('says nothing on Escape when a combobox holds nothing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlCombobox items={items} onValueChange={onValueChange} />);

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('says nothing on Escape when a controlled combobox holds nothing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} value={null} onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('says nothing on Escape when a `multiple` combobox holds nothing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} multiple onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('says nothing on Escape when a controlled `multiple` combobox holds nothing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} multiple value={[]} onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('empties a held value on Escape and says so once', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} defaultValue="seoul" onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange).toHaveBeenCalledWith(null);
      await expect.element(screen.getByRole('combobox')).toHaveValue('');
    });

    it('asks a controlled parent to empty its value on Escape, once', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} value="seoul" onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange).toHaveBeenCalledWith(null);
    });

    it('empties a held set of chips on Escape and says so once', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox
          items={items}
          multiple
          defaultValue={['seoul', 'lisbon']}
          onValueChange={onValueChange}
        />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange).toHaveBeenCalledWith([]);
      await expect.element(screen.getByText('Seoul')).not.toBeInTheDocument();
    });

    it('says nothing when the text of a combobox that holds nothing is emptied', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} allowCustom={false} onValueChange={onValueChange} />
      );

      await screen.getByRole('combobox').fill('lis');
      await screen.getByRole('combobox').fill('');

      await expect.element(screen.getByRole('combobox')).toHaveValue('');
      expect(onValueChange).not.toHaveBeenCalled();
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

    it('opens a read-only list from the input, to be looked through', async () => {
      const screen = await render(<PlCombobox items={items} readOnly defaultValue="seoul" />);

      await screen.getByRole('combobox').click();

      await expect.element(screen.getByRole('option', { name: 'Lisbon' })).toBeInTheDocument();
    });

    it('opens a read-only list from the chevron', async () => {
      const screen = await render(<PlCombobox items={items} readOnly defaultValue="seoul" />);

      await screen.getByRole('button', { name: 'Open' }).click();

      await expect.element(screen.getByRole('option', { name: 'Lisbon' })).toBeInTheDocument();
    });

    it('leaves a read-only value as it was when a row is taken', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} readOnly defaultValue="seoul" onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Open' }).click();
      await screen.getByRole('option', { name: 'Lisbon' }).click();
      // Base UI answers a press on the frame after it, so the row has had its
      // chance to be taken before anything is read.
      await new Promise((resolve) => requestAnimationFrame(() => setTimeout(resolve, 50)));

      expect(onValueChange).not.toHaveBeenCalled();
      expect(screen.getByRole('combobox').element()).toHaveValue('Seoul');
    });

    it('leaves a read-only set of chips as it was when a row is taken', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox
          items={items}
          multiple
          readOnly
          defaultValue={['seoul']}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Open' }).click();
      await screen.getByRole('option', { name: 'Lisbon' }).click();
      await new Promise((resolve) => requestAnimationFrame(() => setTimeout(resolve, 50)));

      expect(onValueChange).not.toHaveBeenCalled();
      expect(screen.getByRole('option', { name: 'Lisbon' }).element()).toHaveAttribute(
        'aria-selected',
        'false'
      );
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

  describe('labelPlacement', () => {
    it("puts the label in the field's edge when notched", async () => {
      const screen = await render(<PlCombobox items={items} label="City" labelPlacement="notch" />);
      const input = screen.getByRole('combobox', { name: 'City' }).element();

      expect(document.querySelector('legend')?.querySelector('label')?.getAttribute('for')).toBe(
        input.id
      );
      expect(document.querySelectorAll('label')).toHaveLength(1);
    });
  });
});
