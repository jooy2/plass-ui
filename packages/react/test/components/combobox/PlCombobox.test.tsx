import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlCombobox, PlForm, PlModal, type PlComboboxOption, type PlComboboxValue } from 'plass-ui';
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

/**
 * What a server answered for `mario`: rows it matched on a spelling their
 * labels do not have.
 */
const searched: PlComboboxOption[] = [
  { value: 'super-mario', label: '슈퍼 마리오' },
  { value: 'mario-kart', label: '마리오 카트' }
];

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

  describe('naming', () => {
    it('names the input with an `aria-label` when there is no visible label', async () => {
      const screen = await render(<PlCombobox items={items} aria-label="City" />);

      await expect
        .element(screen.getByRole('combobox', { name: 'City', exact: true }))
        .toBeInTheDocument();
    });

    it("names the input with an `aria-label` in a visible label's place", async () => {
      const screen = await render(
        <PlCombobox items={items} label="City" aria-label="Office city" />
      );

      await expect
        .element(screen.getByRole('combobox', { name: 'Office city', exact: true }))
        .toBeInTheDocument();
    });

    it("points the input at the caller's element with an `aria-labelledby`, over a label and an `aria-label`", async () => {
      const screen = await render(
        <>
          <span id="combobox-heading">Office city</span>
          <PlCombobox
            items={items}
            label="City"
            aria-label="Office"
            aria-labelledby="combobox-heading"
          />
        </>
      );

      const input = screen.getByRole('combobox', { name: 'Office city', exact: true });

      await expect.element(input).toHaveAttribute('aria-labelledby', 'combobox-heading');
    });
  });

  describe('choosing', () => {
    it('opens the list and picks an option', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlCombobox items={items} onValueChange={onValueChange} />);

      await screen.getByRole('button', { name: 'Open' }).click();
      await screen.getByRole('option', { name: 'Lisbon' }).click();

      await vi.waitFor(() =>
        expect(onValueChange).toHaveBeenCalledWith(
          'lisbon',
          expect.objectContaining({ reason: 'item-press' })
        )
      );
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

      await vi.waitFor(() =>
        expect(onInputValueChange).toHaveBeenCalledWith(
          'qui',
          expect.objectContaining({ reason: 'input-change' })
        )
      );
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

    it('keeps every row as given when `filter` is `null`', async () => {
      const screen = await render(
        <PlCombobox items={searched} filter={null} allowCustom={false} />
      );

      await screen.getByRole('combobox').fill('mario');

      await vi.waitFor(() => expect(screen.getByRole('option').elements()).toHaveLength(2));
      await expect.element(screen.getByRole('option', { name: '슈퍼 마리오' })).toBeInTheDocument();
    });

    it('keeps every row as given in a `multiple` field, with the row that offers the query after them', async () => {
      const screen = await render(<PlCombobox items={searched} multiple filter={null} />);

      await screen.getByRole('combobox').fill('mario');

      await vi.waitFor(() => expect(screen.getByRole('option').elements()).toHaveLength(3));
      await expect.element(screen.getByRole('option', { name: '마리오 카트' })).toBeInTheDocument();
      await expect.element(screen.getByRole('option', { name: /mario/ })).toBeInTheDocument();
    });

    it('asks a `filter` about each option with the trimmed query, and keeps the row that offers it', async () => {
      const filter = vi.fn((option: PlComboboxOption, query: string) =>
        String(option.value).startsWith(query)
      );
      const screen = await render(<PlCombobox items={items} filter={filter} />);

      await screen.getByRole('combobox').fill(' se ');

      await vi.waitFor(() => expect(screen.getByRole('option').elements()).toHaveLength(2));
      await expect.element(screen.getByRole('option', { name: 'Seoul' })).toBeInTheDocument();
      await expect.element(screen.getByRole('option', { name: /“se”/ })).toBeInTheDocument();
      expect(filter).toHaveBeenCalledWith(items[1], 'se');
    });
  });

  describe('autoHighlight', () => {
    it('lights the first row of a list filled after the query changed, with `always`, and Enter takes it', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox
          items={[]}
          filter={null}
          allowCustom={false}
          autoHighlight="always"
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('combobox').fill('mario');
      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();

      await screen.rerender(
        <PlCombobox
          items={searched}
          filter={null}
          allowCustom={false}
          autoHighlight="always"
          onValueChange={onValueChange}
        />
      );

      await expect
        .element(screen.getByRole('option', { name: '슈퍼 마리오' }))
        .toHaveAttribute('data-highlighted');

      await userEvent.keyboard('{Enter}');

      await vi.waitFor(() =>
        expect(onValueChange).toHaveBeenCalledWith(
          'super-mario',
          expect.objectContaining({ reason: 'item-press' })
        )
      );
    });

    it('lights no row of a list filled after the query changed, by default', async () => {
      const screen = await render(<PlCombobox items={[]} filter={null} allowCustom={false} />);

      await screen.getByRole('combobox').fill('mario');
      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();

      await screen.rerender(<PlCombobox items={searched} filter={null} allowCustom={false} />);

      await expect.element(screen.getByRole('option', { name: '슈퍼 마리오' })).toBeInTheDocument();
      await settle();

      expect(screen.getByRole('option', { name: '슈퍼 마리오' }).element()).not.toHaveAttribute(
        'data-highlighted'
      );
    });

    it('lights the first match as the query changes, by default', async () => {
      const screen = await render(<PlCombobox items={items} allowCustom={false} />);

      await screen.getByRole('combobox').fill('lis');

      await expect
        .element(screen.getByRole('option', { name: 'Lisbon' }))
        .toHaveAttribute('data-highlighted');
    });

    it('lights nothing as the query changes when it is off', async () => {
      const screen = await render(
        <PlCombobox items={items} allowCustom={false} autoHighlight={false} />
      );

      await screen.getByRole('combobox').fill('lis');

      await expect.element(screen.getByRole('option', { name: 'Lisbon' })).toBeInTheDocument();
      await settle();

      expect(screen.getByRole('option', { name: 'Lisbon' }).element()).not.toHaveAttribute(
        'data-highlighted'
      );
    });
  });

  describe('a chosen value the list no longer holds', () => {
    it('keeps the label on its chip', async () => {
      const screen = await render(
        <PlCombobox items={searched} multiple defaultValue={['super-mario']} />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Remove 슈퍼 마리오' }))
        .toBeInTheDocument();

      await screen.rerender(<PlCombobox items={[]} multiple defaultValue={['super-mario']} />);
      await settle();

      expect(screen.getByRole('button', { name: 'Remove 슈퍼 마리오' }).query()).not.toBeNull();
    });

    it('keeps the label of a row taken from a list that a new query empties', async () => {
      function Searching() {
        const [query, setQuery] = React.useState('');

        return (
          <PlCombobox
            items={query === 'mario' ? searched : []}
            multiple
            filter={null}
            allowCustom={false}
            onInputValueChange={setQuery}
          />
        );
      }

      const screen = await render(<Searching />);

      await screen.getByRole('combobox').fill('mario');
      await screen.getByRole('option', { name: '마리오 카트' }).click();

      await expect.element(screen.getByRole('combobox')).toHaveValue('');
      await settle();

      expect(document.querySelector('[aria-label="Remove 마리오 카트"]')).not.toBeNull();
      expect(document.querySelector('[aria-label="Remove mario-kart"]')).toBeNull();
    });

    it('keeps the label in a single field', async () => {
      const screen = await render(<PlCombobox items={searched} defaultValue="super-mario" />);

      await expect.element(screen.getByRole('combobox')).toHaveValue('슈퍼 마리오');

      await screen.rerender(<PlCombobox items={[]} defaultValue="super-mario" />);
      await settle();

      expect(screen.getByRole('combobox').element()).toHaveValue('슈퍼 마리오');
    });

    it('offers no row for its label typed again', async () => {
      const screen = await render(
        <PlCombobox items={searched} multiple defaultValue={['super-mario']} />
      );

      await screen.rerender(<PlCombobox items={[]} multiple defaultValue={['super-mario']} />);
      await screen.getByRole('combobox').fill('슈퍼 마리오');
      await settle();

      expect(screen.getByRole('option').query()).toBeNull();
    });
  });

  describe('Enter on a list with no rows', () => {
    it('keeps the list open and the query in a `multiple` field, and takes the first row once rows arrive', async () => {
      const onValueChange = vi.fn();
      const onOpenChange = vi.fn();
      const field = (rows: PlComboboxOption[]) => (
        <PlCombobox
          items={rows}
          multiple
          filter={null}
          allowCustom={false}
          autoHighlight="always"
          onValueChange={onValueChange}
          onOpenChange={onOpenChange}
        />
      );
      const screen = await render(field([]));

      await screen.getByRole('combobox').fill('mario');
      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();

      await userEvent.keyboard('{Enter}');
      await settle();

      expect(screen.getByRole('listbox').query()).not.toBeNull();
      expect(screen.getByRole('combobox').element()).toHaveValue('mario');
      expect(onOpenChange).not.toHaveBeenCalledWith(false, expect.anything());

      await screen.rerender(field(searched));
      await expect
        .element(screen.getByRole('option', { name: '슈퍼 마리오' }))
        .toHaveAttribute('data-highlighted');

      await userEvent.keyboard('{Enter}');

      await vi.waitFor(() =>
        expect(onValueChange).toHaveBeenCalledWith(['super-mario'], expect.anything())
      );
    });

    it('keeps the list open and the query in a single field', async () => {
      const screen = await render(<PlCombobox items={items} allowCustom={false} />);

      await screen.getByRole('combobox').fill('nowhere');
      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();

      await userEvent.keyboard('{Enter}');
      await settle();

      expect(screen.getByRole('listbox').query()).not.toBeNull();
      expect(screen.getByRole('combobox').element()).toHaveValue('nowhere');
    });

    it('does not send the form round the field', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => event.preventDefault());
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlCombobox items={items} allowCustom={false} />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('combobox').fill('nowhere');
      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();

      await userEvent.keyboard('{Enter}');
      await settle();

      expect(onSubmit).not.toHaveBeenCalled();
    });

    it('still closes a list that has rows and none lit, and lets the form be sent', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => event.preventDefault());
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlCombobox items={items} allowCustom={false} autoHighlight={false} />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('combobox').fill('lis');
      await expect.element(screen.getByRole('option', { name: 'Lisbon' })).toBeInTheDocument();

      await userEvent.keyboard('{Enter}');

      await expect.element(screen.getByRole('listbox')).not.toBeInTheDocument();
      expect(onSubmit).toHaveBeenCalledTimes(1);
    });
  });

  describe('event details', () => {
    it('says the clear button emptied the field', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} defaultValue="seoul" clearable onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      await vi.waitFor(() =>
        expect(onValueChange).toHaveBeenCalledWith(
          null,
          expect.objectContaining({ reason: 'clear-press' })
        )
      );
    });

    it('says what opened the list', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(<PlCombobox items={items} onOpenChange={onOpenChange} />);

      await screen.getByRole('button', { name: 'Open' }).click();

      await vi.waitFor(() =>
        expect(onOpenChange).toHaveBeenCalledWith(
          true,
          expect.objectContaining({ reason: 'trigger-press' })
        )
      );
    });

    it('keeps the chips when the caller cancels the change', async () => {
      const screen = await render(
        <PlCombobox
          items={items}
          multiple
          defaultValue={['seoul']}
          onValueChange={(_, details) => details.cancel()}
        />
      );

      await screen.getByRole('button', { name: 'Open' }).click();
      await screen.getByRole('option', { name: 'Lisbon' }).click();
      await settle();

      // By the × of each chip: the chips are out of the accessibility tree
      // while the list is open.
      expect(document.querySelector('[aria-label="Remove Lisbon"]')).toBeNull();
      expect(document.querySelector('[aria-label="Remove Seoul"]')).not.toBeNull();
    });

    it('offers nothing for text the caller turned away', async () => {
      const screen = await render(
        <PlCombobox items={items} onInputValueChange={(_, details) => details.cancel()} />
      );

      await screen.getByRole('combobox').fill('Osaka');
      await settle();

      expect(screen.getByRole('combobox').element()).toHaveValue('');
      expect(screen.getByRole('option', { name: /Osaka/ }).query()).toBeNull();
    });
  });

  describe('content', () => {
    const archives: PlComboboxOption[] = [
      {
        value: 'mario',
        label: 'Mario',
        content: (
          <span data-testid="mario-row">
            Mario <small>v1.2</small>
          </span>
        )
      },
      { value: 'zelda', label: 'Zelda' }
    ];

    it('draws an option’s content in its row', async () => {
      const screen = await render(<PlCombobox items={archives} />);

      await screen.getByRole('button', { name: 'Open' }).click();

      const row = screen.getByRole('option', { name: 'Mario v1.2' });

      await expect.element(row).toBeInTheDocument();
      expect(row.element().querySelector('[data-testid="mario-row"]')).not.toBeNull();
      await expect.element(screen.getByRole('option', { name: 'Zelda' })).toBeInTheDocument();
    });

    it('writes the label into the input once the row is taken', async () => {
      const screen = await render(<PlCombobox items={archives} />);

      await screen.getByRole('button', { name: 'Open' }).click();
      await screen.getByRole('option', { name: 'Mario v1.2' }).click();

      await expect.element(screen.getByRole('combobox')).toHaveValue('Mario');
    });

    it('puts the label on the chip', async () => {
      const screen = await render(
        <PlCombobox items={archives} multiple defaultValue={['mario']} />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Remove Mario', exact: true }))
        .toBeInTheDocument();
      expect(document.querySelector('[data-testid="mario-row"]')).toBeNull();
    });

    it('filters by the label rather than by the content', async () => {
      const screen = await render(<PlCombobox items={archives} allowCustom={false} />);

      await screen.getByRole('combobox').fill('v1.2');

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
      expect(screen.getByRole('option').query()).toBeNull();
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

      await vi.waitFor(() =>
        expect(onValueChange).toHaveBeenCalledWith(
          'Osaka',
          expect.objectContaining({ reason: 'item-press' })
        )
      );
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

      await vi.waitFor(() =>
        expect(onValueChange).toHaveBeenCalledWith(
          ['seoul'],
          expect.objectContaining({ reason: 'item-press' })
        )
      );
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

      await vi.waitFor(() =>
        expect(onValueChange).toHaveBeenCalledWith(
          ['lisbon'],
          expect.objectContaining({ reason: 'chip-remove-press' })
        )
      );
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
    it('says nothing on Escape with `clearOnEscape` when a combobox holds nothing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} clearOnEscape onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('says nothing on Escape with `clearOnEscape` when a controlled combobox holds nothing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} value={null} clearOnEscape onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('says nothing on Escape with `clearOnEscape` when a `multiple` combobox holds nothing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} multiple clearOnEscape onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('says nothing on Escape with `clearOnEscape` when a controlled `multiple` combobox holds nothing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} multiple value={[]} clearOnEscape onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('keeps a held value on Escape', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} defaultValue="seoul" onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');
      await settle();

      expect(onValueChange).not.toHaveBeenCalled();
      expect(screen.getByRole('combobox').element()).toHaveValue('Seoul');
    });

    it('keeps a held set of chips on Escape', async () => {
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
      await settle();

      expect(onValueChange).not.toHaveBeenCalled();
      expect(screen.getByText('Seoul').query()).not.toBeNull();
      expect(screen.getByText('Lisbon').query()).not.toBeNull();
    });

    it('lets Escape go on to what is round a field that keeps its value', async () => {
      const onKeyDown = vi.fn();
      const screen = await render(
        <div onKeyDown={(event) => onKeyDown(event.key)}>
          <PlCombobox items={items} multiple defaultValue={['seoul']} />
        </div>
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onKeyDown).toHaveBeenCalledWith('Escape');
    });

    it('closes a modal round a field that keeps its value on Escape', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlModal defaultOpen title="Tags" onOpenChange={onOpenChange}>
          <PlCombobox items={items} label="City" multiple defaultValue={['seoul']} />
        </PlModal>
      );

      press(screen.getByRole('combobox', { name: 'City' }).element(), 'Escape');

      await vi.waitFor(() => expect(onOpenChange).toHaveBeenCalledWith(false));
    });

    it('closes an open list on Escape and lets go of the query, keeping the chips', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} multiple defaultValue={['seoul']} onValueChange={onValueChange} />
      );

      await screen.getByRole('combobox').fill('lis');
      await expect.element(screen.getByRole('listbox')).toBeInTheDocument();

      await userEvent.keyboard('{Escape}');

      await expect.element(screen.getByRole('listbox')).not.toBeInTheDocument();
      await expect.element(screen.getByRole('combobox')).toHaveValue('');
      expect(onValueChange).not.toHaveBeenCalled();
      expect(screen.getByText('Seoul').query()).not.toBeNull();
    });

    it('empties a held value on Escape with `clearOnEscape`, and says so once', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox
          items={items}
          defaultValue="seoul"
          clearOnEscape
          onValueChange={onValueChange}
        />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange).toHaveBeenCalledWith(
        null,
        expect.objectContaining({ reason: 'escape-key' })
      );
      await expect.element(screen.getByRole('combobox')).toHaveValue('');
    });

    it('asks a controlled parent to empty its value on Escape with `clearOnEscape`, once', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCombobox items={items} value="seoul" clearOnEscape onValueChange={onValueChange} />
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange).toHaveBeenCalledWith(
        null,
        expect.objectContaining({ reason: 'escape-key' })
      );
    });

    it('empties a held set of chips on Escape with `clearOnEscape`, and says so once', async () => {
      const onValueChange = vi.fn();
      const onKeyDown = vi.fn();
      const screen = await render(
        <div onKeyDown={(event) => onKeyDown(event.key)}>
          <PlCombobox
            items={items}
            multiple
            defaultValue={['seoul', 'lisbon']}
            clearOnEscape
            onValueChange={onValueChange}
          />
        </div>
      );

      press(screen.getByRole('combobox').element(), 'Escape');

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange).toHaveBeenCalledWith(
        [],
        expect.objectContaining({ reason: 'escape-key' })
      );
      // The press emptied something, so it ends at the field.
      expect(onKeyDown).not.toHaveBeenCalled();
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

    it('offers no × on a disabled or read-only field', async () => {
      const screen = await render(
        <PlCombobox items={items} defaultValue="seoul" clearable disabled />
      );

      // A value to clear and a × asked for, so only the lock takes it away.
      await expect.element(screen.getByRole('combobox')).toHaveValue('Seoul');
      expect(screen.getByRole('button', { name: 'Clear' }).query()).toBeNull();

      await screen.rerender(<PlCombobox items={items} defaultValue="seoul" clearable readOnly />);
      await settle();

      expect(screen.getByRole('button', { name: 'Clear' }).query()).toBeNull();

      await screen.rerender(<PlCombobox items={items} defaultValue="seoul" clearable />);

      await expect.element(screen.getByRole('button', { name: 'Clear' })).toBeEnabled();
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
