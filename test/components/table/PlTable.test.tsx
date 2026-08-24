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
});
