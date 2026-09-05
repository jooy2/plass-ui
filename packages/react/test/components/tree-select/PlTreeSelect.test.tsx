import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTreeSelect, type PlTreeSelectNode } from 'plass-ui';

const items: PlTreeSelectNode[] = [
  {
    id: 'europe',
    label: 'Europe',
    children: [
      { id: 'france', label: 'France' },
      { id: 'spain', label: 'Spain' }
    ]
  },
  {
    id: 'asia',
    label: 'Asia',
    children: [
      { id: 'korea', label: 'South Korea' },
      { id: 'japan', label: 'Japan', disabled: true }
    ]
  },
  { id: 'antarctica', label: 'Antarctica' }
];

const rows = () =>
  Array.from(document.querySelectorAll<HTMLElement>('[role="treeitem"]')).map((node) =>
    node.textContent?.trim()
  );

const row = (label: string) =>
  Array.from(document.querySelectorAll<HTMLElement>('[role="treeitem"]')).find(
    (node) => node.textContent?.trim() === label
  )!;

describe('PlTreeSelect', () => {
  describe('rendering', () => {
    it('renders a trigger', async () => {
      const screen = await render(<PlTreeSelect items={items} label="Region" />);

      await expect.element(screen.getByRole('button', { name: 'Region' })).toBeInTheDocument();
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(<PlTreeSelect items={items} placeholder="Pick a region" />);

      await expect.element(screen.getByText('Pick a region')).toBeInTheDocument();
    });

    it('writes the labels of what is held', async () => {
      const screen = await render(<PlTreeSelect items={items} defaultValue={['france']} />);

      await expect.element(screen.getByRole('button')).toHaveTextContent('France');
    });

    it('joins more than one label with a comma', async () => {
      const screen = await render(
        <PlTreeSelect items={items} multiple defaultValue={['france', 'spain']} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent('France, Spain');
    });

    it('takes a format of its own', async () => {
      const screen = await render(
        <PlTreeSelect
          items={items}
          multiple
          defaultValue={['france', 'spain']}
          format={(chosen) => `${chosen.length} chosen`}
        />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent('2 chosen');
    });

    it('renders the label, the description and the error', async () => {
      const screen = await render(
        <PlTreeSelect
          items={items}
          label="Region"
          description="Where it ships from."
          error="Pick a region."
        />
      );

      await expect.element(screen.getByText('Where it ships from.')).toBeInTheDocument();
      await expect.element(screen.getByText('Pick a region.')).toBeInTheDocument();
    });

    it('marks the trigger invalid when there is an error', async () => {
      const screen = await render(<PlTreeSelect items={items} error="Pick a region." />);

      expect(screen.getByRole('button').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <PlTreeSelect items={items} value={['france']} onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent('France');

      await screen.rerender(
        <PlTreeSelect items={items} value={['spain']} onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent('Spain');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlTreeSelect items={items} className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('the popup', () => {
    it('opens the tree when the trigger is pressed', async () => {
      const screen = await render(<PlTreeSelect items={items} />);

      await screen.getByRole('button').click();

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      expect(rows()).toEqual(['Europe', 'Asia', 'Antarctica']);
    });

    it('opens the branches it was told start open', async () => {
      const screen = await render(
        <PlTreeSelect items={items} defaultOpen defaultExpanded={['europe']} />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      expect(rows()).toContain('France');
    });

    it('does not open while read-only', async () => {
      const screen = await render(<PlTreeSelect items={items} readOnly />);

      await screen.getByRole('button').click();

      expect(screen.getByRole('tree').query()).toBeNull();
    });

    it('reports the open state', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(<PlTreeSelect items={items} onOpenChange={onOpenChange} />);

      await screen.getByRole('button').click();

      expect(onOpenChange).toHaveBeenCalledWith(true);
    });
  });

  describe('choosing', () => {
    it('holds a leaf that was pressed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect
          items={items}
          defaultOpen
          defaultExpanded={['europe']}
          onValueChange={onValueChange}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('France').click();

      expect(onValueChange).toHaveBeenCalledWith(['france']);
    });

    it('closes as soon as a leaf is chosen', async () => {
      const screen = await render(
        <PlTreeSelect items={items} defaultOpen defaultExpanded={['europe']} />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('France').click();

      await expect.poll(() => screen.getByRole('tree').query()).toBeNull();
    });

    it('stays open when `closeOnSelect` says so', async () => {
      const screen = await render(
        <PlTreeSelect
          items={items}
          defaultOpen
          defaultExpanded={['europe']}
          closeOnSelect={false}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('France').click();

      await expect.element(screen.getByRole('button')).toHaveTextContent('France');
      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
    });

    it('replaces what is held unless it is `multiple`', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect
          items={items}
          defaultOpen
          closeOnSelect={false}
          defaultExpanded={['europe']}
          defaultValue={['france']}
          onValueChange={onValueChange}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('Spain').click();

      expect(onValueChange).toHaveBeenLastCalledWith(['spain']);
    });

    it('adds to what is held when it is `multiple`', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect
          items={items}
          multiple
          defaultOpen
          defaultExpanded={['europe']}
          defaultValue={['france']}
          onValueChange={onValueChange}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('Spain').click();

      expect(onValueChange).toHaveBeenLastCalledWith(['france', 'spain']);
    });

    it('takes a chosen node back out when it is pressed again', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect
          items={items}
          multiple
          defaultOpen
          defaultExpanded={['europe']}
          defaultValue={['france']}
          onValueChange={onValueChange}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('France').click();

      expect(onValueChange).toHaveBeenLastCalledWith([]);
    });

    it('leaves a disabled node alone', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect
          items={items}
          defaultOpen
          defaultExpanded={['asia']}
          onValueChange={onValueChange}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('Japan').click();

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('empties the control from the clear button', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect
          items={items}
          clearable
          defaultValue={['france']}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      expect(onValueChange).toHaveBeenCalledWith([]);
    });

    it('submits one hidden input per value', async () => {
      await render(
        <PlTreeSelect items={items} multiple name="region" defaultValue={['france', 'spain']} />
      );

      const values = Array.from(
        document.querySelectorAll<HTMLInputElement>('input[type="hidden"][name="region"]')
      ).map((input) => input.value);

      expect(values).toEqual(['france', 'spain']);
    });
  });

  describe('branches', () => {
    it('opens a branch rather than choosing it', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect items={items} defaultOpen onValueChange={onValueChange} />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('Europe').click();

      expect(onValueChange).not.toHaveBeenCalled();
      await expect.poll(() => rows()).toContain('France');
    });

    it('leaves what is held alone when a branch is pressed', async () => {
      const screen = await render(
        <PlTreeSelect
          items={items}
          defaultOpen
          defaultExpanded={['europe']}
          defaultValue={['france']}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('Asia').click();

      await expect.element(screen.getByRole('button')).toHaveTextContent('France');
    });

    it('chooses a branch when `selectableBranches` says it may', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect
          items={items}
          selectableBranches
          defaultOpen
          closeOnSelect={false}
          onValueChange={onValueChange}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('Europe').click();

      expect(onValueChange).toHaveBeenCalledWith(['europe']);
    });

    it('lets one node override `selectableBranches`', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTreeSelect
          items={[{ ...items[0], selectable: true }, items[1], items[2]]}
          defaultOpen
          closeOnSelect={false}
          onValueChange={onValueChange}
        />
      );

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      row('Europe').click();

      expect(onValueChange).toHaveBeenCalledWith(['europe']);
    });
  });

  describe('searching', () => {
    it('offers no field unless it is searchable', async () => {
      const screen = await render(<PlTreeSelect items={items} defaultOpen />);

      await expect.element(screen.getByRole('tree')).toBeInTheDocument();
      expect(screen.getByRole('textbox').query()).toBeNull();
    });

    it('keeps the matches and every ancestor of one', async () => {
      const screen = await render(<PlTreeSelect items={items} searchable defaultOpen />);

      const field = screen.getByRole('textbox');

      await expect.element(field).toBeInTheDocument();
      await field.fill('france');

      await expect.poll(() => rows()).toEqual(['Europe', 'France']);
    });

    it('folds accents and case away', async () => {
      const screen = await render(
        <PlTreeSelect items={[{ id: 'jose', label: 'José' }, ...items]} searchable defaultOpen />
      );

      const field = screen.getByRole('textbox');

      await expect.element(field).toBeInTheDocument();
      await field.fill('JOSE');

      await expect.poll(() => rows()).toEqual(['José']);
    });

    it('matches a node on its `searchLabel`', async () => {
      const screen = await render(
        <PlTreeSelect
          items={[{ id: 'kr', label: <b>South Korea</b>, searchLabel: 'South Korea' }]}
          searchable
          defaultOpen
        />
      );

      const field = screen.getByRole('textbox');

      await expect.element(field).toBeInTheDocument();
      await field.fill('korea');

      await expect.poll(() => rows()).toEqual(['South Korea']);
    });

    it('says so when nothing matched', async () => {
      const screen = await render(
        <PlTreeSelect items={items} searchable defaultOpen emptyLabel="No such region" />
      );

      const field = screen.getByRole('textbox');

      await expect.element(field).toBeInTheDocument();
      await field.fill('atlantis');

      await expect.element(screen.getByText('No such region')).toBeInTheDocument();
    });

    it('hands the folds back to the reader when the field is emptied', async () => {
      const screen = await render(<PlTreeSelect items={items} searchable defaultOpen />);

      const field = screen.getByRole('textbox');

      await expect.element(field).toBeInTheDocument();
      await field.fill('france');
      await expect.poll(() => rows()).toEqual(['Europe', 'France']);

      await field.fill('');
      await expect.poll(() => rows()).toEqual(['Europe', 'Asia', 'Antarctica']);
    });
  });
});
