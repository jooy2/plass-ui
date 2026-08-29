import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTable, type PlTableColumn } from 'plass-ui';

interface Invoice {
  id: string;
  customer: string;
  total: number;
}

const columns: PlTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice' },
  { key: 'customer', header: 'Customer' },
  { key: 'total', header: 'Total', align: 'end', render: (row) => `$${row.total}` }
];

const rows: Invoice[] = [
  { id: 'INV-01', customer: 'Acme', total: 120 },
  { id: 'INV-02', customer: 'Globex', total: 340 }
];

describe('PlTable', () => {
  describe('rendering', () => {
    it('renders a real table with one column header per column', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} />);

      await expect.element(screen.getByRole('table')).toBeInTheDocument();
      expect(screen.getByRole('columnheader').elements()).toHaveLength(3);
    });

    it('falls back to the column key when no header is given', async () => {
      const screen = await render(<PlTable columns={[{ key: 'customer' }]} rows={rows} />);

      await expect
        .element(screen.getByRole('columnheader', { name: 'customer' }))
        .toBeInTheDocument();
    });

    it('reads a cell off the row by key', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} />);

      await expect.element(screen.getByRole('cell', { name: 'Globex' })).toBeInTheDocument();
    });

    it('uses `render` for the cell when a column has one', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} />);

      const cell = screen.getByRole('cell', { name: '$340' }).element();

      // The raw `340` never reaches the DOM — only what `render` returned.
      expect(cell.textContent).toBe('$340');
    });

    it('renders one row per item', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} />);

      // Two body rows plus the header row.
      expect(screen.getByRole('row').elements()).toHaveLength(3);
    });

    it('reflects changed rows on re-render', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} />);

      await screen.rerender(
        <PlTable columns={columns} rows={[{ id: 'INV-09', customer: 'Initech', total: 5 }]} />
      );

      await expect.element(screen.getByRole('cell', { name: 'Initech' })).toBeInTheDocument();
      expect(screen.getByRole('cell', { name: 'Globex' }).query()).toBeNull();
    });

    it('renders the caption as the accessible name of the table', async () => {
      const screen = await render(
        <PlTable columns={columns} rows={rows} caption="Open invoices" />
      );

      await expect
        .element(screen.getByRole('table', { name: 'Open invoices' }))
        .toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlTable className="my-own-class" columns={columns} rows={rows} />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('applies a column width to the `<col>` rather than to a cell', async () => {
      await render(
        <PlTable
          className="table-under-test"
          columns={[{ key: 'id', width: 120 }, { key: 'customer' }]}
          rows={rows}
        />
      );
      const col = document.querySelector('.table-under-test col') as HTMLElement;

      expect(col.style.width).toBe('120px');
    });

    it('aligns a column from its `align`', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} />);
      const cell = screen.getByRole('cell', { name: '$120' }).element() as HTMLElement;

      expect(cell.style.textAlign).toBe('end');
    });
  });

  describe('empty state', () => {
    it('shows the default line when there are no rows', async () => {
      const screen = await render(<PlTable columns={columns} rows={[]} />);

      await expect.element(screen.getByText('No data')).toBeInTheDocument();
    });

    it('shows whatever `empty` says instead', async () => {
      const screen = await render(
        <PlTable columns={columns} rows={[]} empty="Nothing billed yet" />
      );

      await expect.element(screen.getByText('Nothing billed yet')).toBeInTheDocument();
      expect(screen.getByText('No data').query()).toBeNull();
    });

    it('spans the empty cell across every column', async () => {
      const screen = await render(<PlTable columns={columns} rows={[]} />);

      expect(screen.getByRole('cell').element()).toHaveAttribute('colspan', '3');
    });
  });

  describe('rows that answer a press', () => {
    it('calls `onRowClick` with the row and its index', async () => {
      const onRowClick = vi.fn();
      const screen = await render(
        <PlTable columns={columns} rows={rows} onRowClick={onRowClick} />
      );

      await screen.getByRole('cell', { name: 'Globex' }).click();

      expect(onRowClick).toHaveBeenCalledWith(rows[1], 1);
    });

    it('puts clickable rows in the tab order', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} onRowClick={() => {}} />);
      const bodyRows = screen.getByRole('row').elements().slice(1);

      expect(bodyRows[0]).toHaveAttribute('tabindex', '0');
    });

    it('leaves rows out of the tab order when there is nothing to press', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} />);
      const bodyRows = screen.getByRole('row').elements().slice(1);

      expect(bodyRows[0]).not.toHaveAttribute('tabindex');
    });

    it('activates a focused row from the keyboard', async () => {
      const onRowClick = vi.fn();
      const screen = await render(
        <PlTable columns={columns} rows={rows} onRowClick={onRowClick} />
      );
      const firstRow = screen.getByRole('row').elements()[1] as HTMLElement;

      firstRow.focus();
      await expect.poll(() => document.activeElement).toBe(firstRow);
      await screen
        .getByRole('row')
        .elements()[1]
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', bubbles: true }));

      expect(onRowClick).toHaveBeenCalledWith(rows[0], 0);
    });

    it('keeps the row a row rather than relabelling it a button', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} onRowClick={() => {}} />);

      expect(screen.getByRole('button').query()).toBeNull();
      expect(screen.getByRole('row').elements()).toHaveLength(3);
    });
  });

  describe('a capped height', () => {
    /** The box between the sheet and the grid — the one that scrolls. */
    const scrollerOf = () =>
      document.querySelector<HTMLElement>('.table-under-test > div:last-child');

    it('does not scroll vertically until it is capped', async () => {
      await render(<PlTable className="table-under-test" columns={columns} rows={rows} />);

      const element = scrollerOf();

      expect(element).not.toHaveClass('overflow-y-auto');
      expect(element?.style.maxHeight).toBe('');
    });

    it('caps the grid and scrolls the rows inside it', async () => {
      await render(
        <PlTable className="table-under-test" columns={columns} rows={rows} maxHeight={200} />
      );

      const element = scrollerOf();

      expect(element).toHaveClass('overflow-y-auto');
      // Kept off the page's own scroll at the ends, which a box with nothing to
      // scroll must not do — hence only when there is a cap.
      expect(element).toHaveClass('overscroll-contain');
      expect(element?.style.maxHeight).toBe('200px');
    });

    it('takes a CSS length as readily as a number', async () => {
      await render(
        <PlTable className="table-under-test" columns={columns} rows={rows} maxHeight="24rem" />
      );

      expect(scrollerOf()?.style.maxHeight).toBe('24rem');
    });

    it('names the table with a `<caption>` rather than an id, so nothing here is a hook', async () => {
      const screen = await render(
        <PlTable className="table-under-test" columns={columns} rows={rows} caption="Invoices" />
      );

      const table = screen.getByRole('table', { name: 'Invoices' }).element();

      // No `aria-labelledby` means no generated id, which means no `useId` —
      // which is what lets a server component render this table with the
      // `render` callbacks its own columns are made of.
      expect(table).not.toHaveAttribute('aria-labelledby');
      expect(table.querySelector('caption')).toBeInTheDocument();
    });

    it('draws the caption once, and reads it once', async () => {
      const screen = await render(
        <PlTable className="table-under-test" columns={columns} rows={rows} caption="Invoices" />
      );

      // The drawn copy is out of the accessibility tree, so the name is not
      // announced twice.
      expect(screen.getByRole('table', { name: 'Invoices' }).element()).toBeInTheDocument();
      expect(
        document.querySelector('.table-under-test > div[aria-hidden="true"]')
      ).toHaveTextContent('Invoices');
    });

    it('leaves the caption above what scrolls', async () => {
      const screen = await render(
        <PlTable
          className="table-under-test"
          columns={columns}
          rows={rows}
          caption="Open invoices"
          maxHeight={200}
        />
      );

      // Still the table's accessible name, and the *drawn* title is still
      // outside the box the rows scroll in: a heading that slid away would take
      // the table's name off the screen with it. What is inside the scroller is
      // the `<caption>` that carries the name, which is never drawn.
      await expect
        .element(screen.getByRole('table', { name: 'Open invoices' }))
        .toBeInTheDocument();
      expect(scrollerOf()?.previousElementSibling).toHaveTextContent('Open invoices');
      expect(scrollerOf()?.querySelector('caption')).toHaveTextContent('Open invoices');
    });
  });

  describe('a pinned header', () => {
    it('sticks the column names to the top of what scrolls', async () => {
      const screen = await render(
        <PlTable columns={columns} rows={rows} stickyHeader maxHeight={200} />
      );

      const element = screen.getByRole('columnheader', { name: 'Invoice' }).element();

      expect(element).toHaveClass('sticky');
      expect(element).toHaveClass('top-0');
    });

    it('carries its own fill, because rows pass underneath it', async () => {
      const screen = await render(
        <PlTable columns={columns} rows={rows} stickyHeader maxHeight={200} />
      );

      const element = screen
        .getByRole('columnheader', { name: 'Invoice' })
        .element() as HTMLElement;

      // Two stacked opaque layers, or the rows show through the names.
      expect(element.style.background).toContain('var(--plass-surface)');
    });

    it('takes its rule as an inset shadow rather than a border', async () => {
      const screen = await render(
        <PlTable columns={columns} rows={rows} stickyHeader maxHeight={200} />
      );

      const pinned = screen.getByRole('columnheader', { name: 'Invoice' }).element() as HTMLElement;

      // `border-collapse: collapse` hands a cell's borders to the table's own
      // border grid, and that grid does not travel with a sticky cell — so a
      // pinned header drawn with a border leaves its underline behind.
      expect(pinned.style.boxShadow).toBe('inset 0 -1px 0 var(--plass-border)');
      // Nothing but the cell's own `border: 0` reset.
      expect(pinned.style.borderBottom).toBe('0px');
    });

    it('draws the rule as a border while it is not pinned', async () => {
      const screen = await render(<PlTable columns={columns} rows={rows} />);

      const element = screen
        .getByRole('columnheader', { name: 'Invoice' })
        .element() as HTMLElement;

      expect(element.style.borderBottom).toBe('1px solid var(--plass-border)');
      expect(element.style.boxShadow).toBe('');
    });
  });
});
