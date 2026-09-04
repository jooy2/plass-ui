import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlDataTable, PlassProvider, type PlDataTableColumn } from 'plass-ui';

interface Invoice {
  id: string;
  customer: string;
  total: number;
}

const columns: PlDataTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice' },
  { key: 'customer', header: 'Customer', sortable: true },
  { key: 'total', header: 'Total', align: 'end', sortable: true, render: (row) => `$${row.total}` }
];

const rows: Invoice[] = [
  { id: 'INV-03', customer: 'Initech', total: 90 },
  { id: 'INV-01', customer: 'Acme', total: 340 },
  { id: 'INV-02', customer: 'Globex', total: 120 }
];

const key = (row: Invoice) => row.id;

/** The customer column, top to bottom, as the reader sees it. */
function customers(): string[] {
  return Array.from(document.querySelectorAll('tbody tr')).map(
    (row) => row.querySelectorAll('td')[1]?.textContent ?? ''
  );
}

/** Every row's first cell, for a table drawn without a tick column. */
function invoices(): string[] {
  return Array.from(document.querySelectorAll('tbody tr')).map(
    (row) => row.querySelectorAll('td')[0]?.textContent ?? ''
  );
}

describe('PlDataTable', () => {
  describe('rendering', () => {
    it('renders a real table with one column header per column', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      await expect.element(screen.getByRole('table')).toBeInTheDocument();
      expect(screen.getByRole('columnheader').elements()).toHaveLength(3);
    });

    it('reads a cell off the row by key and uses `render` where there is one', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      await expect.element(screen.getByRole('cell', { name: 'Globex' })).toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: '$340' })).toBeInTheDocument();
    });

    it('leaves the rows in the order they arrived in until it is asked', async () => {
      await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      expect(customers()).toEqual(['Initech', 'Acme', 'Globex']);
    });

    it('names the table with a caption a screen reader can reach', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} caption="Open invoices" />
      );

      await expect
        .element(screen.getByRole('table', { name: 'Open invoices' }))
        .toBeInTheDocument();
    });

    it('says so when there is nothing to show', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={[]} getRowKey={key} />);

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });
  });

  describe('sorting', () => {
    it('sorts a column ascending on the first press', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      await screen.getByRole('button', { name: /Customer/ }).click();

      expect(customers()).toEqual(['Acme', 'Globex', 'Initech']);
    });

    it('turns it round on the second and puts it back on the third', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);
      const heading = screen.getByRole('button', { name: /Customer/ });

      await heading.click();
      await heading.click();
      expect(customers()).toEqual(['Initech', 'Globex', 'Acme']);

      await heading.click();
      expect(customers()).toEqual(['Initech', 'Acme', 'Globex']);
    });

    it('sorts numbers as numbers rather than as the text `render` drew', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      await screen.getByRole('button', { name: /Total/ }).click();

      // 90 before 120 before 340, which sorting `$90` as a string would not do.
      expect(customers()).toEqual(['Initech', 'Globex', 'Acme']);
    });

    it('announces the direction on the heading rather than on the button', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      await screen.getByRole('button', { name: /Customer/ }).click();

      // A screen reader reads the heading when it enters a cell in the column;
      // a state on the button would only be heard by a reader who landed on it.
      await expect
        .element(screen.getByRole('columnheader', { name: /Customer/ }))
        .toHaveAttribute('aria-sort', 'ascending');
    });

    it('leaves a column that did not ask to be sortable out of it', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      expect(screen.getByRole('button', { name: /Invoice/ }).elements()).toHaveLength(0);
      await expect
        .element(screen.getByRole('columnheader', { name: 'Invoice' }))
        .not.toHaveAttribute('aria-sort');
    });

    it('uses a column comparator when it has one, and reverses what it said', async () => {
      const byLength: PlDataTableColumn<Invoice>[] = [
        {
          key: 'customer',
          header: 'Customer',
          sortable: true,
          compare: (a, b) => a.customer.length - b.customer.length
        }
      ];
      const screen = await render(<PlDataTable columns={byLength} rows={rows} getRowKey={key} />);
      const heading = screen.getByRole('button', { name: /Customer/ });

      await heading.click();
      expect(invoices()).toEqual(['Acme', 'Globex', 'Initech']);

      await heading.click();
      expect(invoices()).toEqual(['Initech', 'Globex', 'Acme']);
    });

    it('reports the sort and draws what it is told when it is controlled', async () => {
      const onSortChange = vi.fn();
      const screen = await render(
        <PlDataTable
          columns={columns}
          rows={rows}
          getRowKey={key}
          sort={{ key: 'customer', direction: 'desc' }}
          onSortChange={onSortChange}
        />
      );

      expect(customers()).toEqual(['Initech', 'Globex', 'Acme']);

      await screen.getByRole('button', { name: /Customer/ }).click();

      expect(onSortChange).toHaveBeenCalledWith(null);
      // Still descending: the sort belongs to whoever passed it.
      expect(customers()).toEqual(['Initech', 'Globex', 'Acme']);
    });

    it('leaves the rows alone when the sort is being done elsewhere', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} manual={['sort']} />
      );

      await screen.getByRole('button', { name: /Customer/ }).click();

      expect(customers()).toEqual(['Initech', 'Acme', 'Globex']);
    });
  });

  describe('search', () => {
    it('narrows the rows to what was typed', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} searchable />
      );

      await screen.getByRole('textbox').fill('glob');

      expect(customers()).toEqual(['Globex']);
    });

    it('ignores case and accents', async () => {
      const screen = await render(
        <PlDataTable
          columns={[{ key: 'customer', header: 'Customer' }]}
          rows={[{ id: '1', customer: 'José', total: 1 }]}
          getRowKey={key}
          searchable
        />
      );

      await screen.getByRole('textbox').fill('JOSE');

      expect(invoices()).toEqual(['José']);
    });

    it('matches a column on its `value` rather than on what was drawn', async () => {
      const screen = await render(
        <PlDataTable
          columns={[
            { key: 'customer', header: 'Customer' },
            { key: 'total', header: 'Total', value: (row) => row.total, render: () => 'paid' }
          ]}
          rows={rows}
          getRowKey={key}
          searchable
        />
      );

      await screen.getByRole('textbox').fill('340');

      expect(invoices()).toEqual(['Acme']);
    });

    it('keeps an unsearchable column out of the match', async () => {
      const screen = await render(
        <PlDataTable
          columns={[
            { key: 'id', header: 'Invoice', unsearchable: true },
            { key: 'customer', header: 'Customer' }
          ]}
          rows={rows}
          getRowKey={key}
          searchable
        />
      );

      await screen.getByRole('textbox').fill('INV-01');

      // The identifier is on the screen and is not what the row is found by.
      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });

    it('says so when nothing matched', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} searchable />
      );

      await screen.getByRole('textbox').fill('nobody');

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });

    it('draws no field at all unless it was asked for', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      expect(screen.getByRole('textbox').elements()).toHaveLength(0);
    });
  });

  describe('selection', () => {
    it('draws no tick column until there is a selection to make', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={rows} getRowKey={key} />);

      expect(screen.getByRole('checkbox').elements()).toHaveLength(0);
    });

    it('ticks a row and hands back its key and its row', async () => {
      const onSelectedChange = vi.fn();
      const screen = await render(
        <PlDataTable
          columns={columns}
          rows={rows}
          getRowKey={key}
          selection="multiple"
          onSelectedChange={onSelectedChange}
        />
      );

      await screen.getByRole('checkbox', { name: 'Select row' }).first().click();

      expect(onSelectedChange).toHaveBeenCalledWith(['INV-03'], [rows[0]]);
    });

    it('says on the row itself which rows are chosen', async () => {
      const screen = await render(
        <PlDataTable
          columns={columns}
          rows={rows}
          getRowKey={key}
          selection="multiple"
          defaultSelected={['INV-01']}
        />
      );

      const chosen = screen.getByRole('row', { selected: true }).elements();

      expect(chosen).toHaveLength(1);
      expect(chosen[0].textContent).toContain('Acme');
    });

    it('keeps one row at a time in single mode', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} selection="single" />
      );
      const ticks = screen.getByRole('checkbox', { name: 'Select row' });

      await ticks.first().click();
      await ticks.nth(1).click();

      expect(screen.getByRole('row', { selected: true }).elements()).toHaveLength(1);
    });

    it('ticks everything from the header, and unticks it again', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} selection="multiple" />
      );
      const all = screen.getByRole('checkbox', { name: 'Select all' });

      await all.click();
      expect(screen.getByRole('row', { selected: true }).elements()).toHaveLength(3);

      await all.click();
      expect(screen.getByRole('row', { selected: true }).elements()).toHaveLength(0);
    });

    it('says the header box is neither ticked nor empty when some rows are', async () => {
      const screen = await render(
        <PlDataTable
          columns={columns}
          rows={rows}
          getRowKey={key}
          selection="multiple"
          defaultSelected={['INV-01']}
        />
      );

      await expect
        .element(screen.getByRole('checkbox', { name: 'Select all' }))
        .toHaveAttribute('data-indeterminate');
    });

    it('leaves a row that cannot be chosen out of the tick-all', async () => {
      const screen = await render(
        <PlDataTable
          columns={columns}
          rows={rows}
          getRowKey={key}
          selection="multiple"
          isRowSelectable={(row) => row.customer !== 'Globex'}
        />
      );

      await screen.getByRole('checkbox', { name: 'Select all' }).click();

      expect(screen.getByRole('row', { selected: true }).elements()).toHaveLength(2);
    });

    it('takes the range between two rows when shift is held', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} selection="multiple" />
      );
      const ticks = screen.getByRole('checkbox', { name: 'Select row' });

      await ticks.first().click();
      // The rows the reader can see, from the one they pressed to this one.
      await ticks.nth(2).click({ modifiers: ['Shift'] });

      expect(screen.getByRole('row', { selected: true }).elements()).toHaveLength(3);
    });

    it('measures the range down the sorted order rather than the original one', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} selection="multiple" />
      );

      await screen.getByRole('button', { name: /Customer/ }).click();

      const ticks = screen.getByRole('checkbox', { name: 'Select row' });

      await ticks.first().click();
      await ticks.nth(1).click({ modifiers: ['Shift'] });

      // Acme and Globex, which are adjacent only once the table is sorted.
      const chosen = screen.getByRole('row', { selected: true }).elements();

      expect(chosen.map((row) => row.textContent)).toEqual([
        expect.stringContaining('Acme'),
        expect.stringContaining('Globex')
      ]);
    });

    it('does not activate the row when the tick is what was pressed', async () => {
      const onRowClick = vi.fn();
      const screen = await render(
        <PlDataTable
          columns={columns}
          rows={rows}
          getRowKey={key}
          selection="multiple"
          onRowClick={onRowClick}
        />
      );

      await screen.getByRole('checkbox', { name: 'Select row' }).first().click();

      expect(onRowClick).not.toHaveBeenCalled();
    });
  });

  describe('paging', () => {
    const many = Array.from({ length: 25 }, (_, index) => ({
      id: `INV-${index}`,
      customer: `Customer ${index}`,
      total: index
    }));

    it('hands out a page at a time', async () => {
      await render(
        <PlDataTable columns={columns} rows={many} getRowKey={key} paging="pages" pageSize={10} />
      );

      expect(customers()).toHaveLength(10);
    });

    it('steps to the next page', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={many} getRowKey={key} paging="pages" pageSize={10} />
      );

      await screen.getByRole('button', { name: 'Page 2' }).click();

      expect(customers()[0]).toBe('Customer 10');
    });

    it('goes back to the first page when the rows underneath change', async () => {
      const screen = await render(
        <PlDataTable
          columns={columns}
          rows={many}
          getRowKey={key}
          paging="pages"
          pageSize={10}
          searchable
        />
      );

      await screen.getByRole('button', { name: 'Page 2' }).click();
      await screen.getByRole('textbox').fill('Customer 1');

      // Page nine of a different set of rows is not where the reader was.
      expect(customers()[0]).toBe('Customer 1');
    });

    it('draws every row and no pager when it is scrolling', async () => {
      const screen = await render(<PlDataTable columns={columns} rows={many} getRowKey={key} />);

      expect(customers()).toHaveLength(25);
      expect(screen.getByRole('navigation').elements()).toHaveLength(0);
    });

    it('counts against `rowCount` when the pages are being cut elsewhere', async () => {
      const screen = await render(
        <PlDataTable
          columns={columns}
          rows={many.slice(0, 10)}
          getRowKey={key}
          paging="pages"
          pageSize={10}
          manual={['pages']}
          rowCount={90}
        />
      );

      // Nine pages from a table holding ten rows: the other eighty are the
      // server's, and the pager has to say they are there.
      await expect.element(screen.getByRole('button', { name: 'Page 9' })).toBeInTheDocument();
    });
  });

  describe('loading', () => {
    it('marks the grid busy and draws bars in place of the rows', async () => {
      const screen = await render(
        <PlDataTable columns={columns} rows={rows} getRowKey={key} loading />
      );

      await expect.element(screen.getByRole('table')).toHaveAttribute('aria-busy', 'true');
      expect(screen.getByRole('cell', { name: 'Acme' }).elements()).toHaveLength(0);
    });
  });

  describe('the provider', () => {
    it('takes its words from the labels in scope', async () => {
      const screen = await render(
        <PlassProvider labels={{ selectAll: '전체 선택' }}>
          <PlDataTable columns={columns} rows={rows} getRowKey={key} selection="multiple" />
        </PlassProvider>
      );

      await expect.element(screen.getByRole('checkbox', { name: '전체 선택' })).toBeInTheDocument();
    });
  });
});
