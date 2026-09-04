import { PlChip, PlDataTable, type PlDataTableColumn } from 'plass-ui';

interface Invoice {
  id: string;
  customer: string;
  status: 'Paid' | 'Open' | 'Overdue';
  total: number;
}

const tone = { Paid: 'success', Open: 'primary', Overdue: 'danger' } as const;

const columns: PlDataTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice', width: 110, sortable: true },
  { key: 'customer', header: 'Customer', sortable: true },
  {
    key: 'status',
    header: 'Status',
    sortable: true,
    // The cell is a chip, so the sort and the search are told what it stands for.
    value: (row) => row.status,
    render: (row) => (
      <PlChip size="xs" color={tone[row.status]}>
        {row.status}
      </PlChip>
    )
  },
  {
    key: 'total',
    header: 'Total',
    align: 'end',
    sortable: true,
    render: (row) => `$${row.total.toFixed(2)}`
  }
];

const rows: Invoice[] = [
  { id: 'INV-0104', customer: 'Umbrella', status: 'Open', total: 2100 },
  { id: 'INV-0103', customer: 'Soylent', status: 'Paid', total: 640.25 },
  { id: 'INV-0102', customer: 'Acme Inc', status: 'Paid', total: 1240 },
  { id: 'INV-0101', customer: 'Globex', status: 'Open', total: 340.5 },
  { id: 'INV-0100', customer: 'Initech', status: 'Overdue', total: 89 }
];

export default function DataTableHero() {
  return (
    <PlDataTable
      columns={columns}
      rows={rows}
      getRowKey={(row) => row.id}
      caption="Recent invoices"
      searchable
      selection="multiple"
      hoverable
    />
  );
}
