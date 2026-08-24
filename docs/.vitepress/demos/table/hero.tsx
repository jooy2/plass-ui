import { PlTable, type PlTableColumn } from 'plass-ui';

interface Invoice {
  id: string;
  customer: string;
  status: string;
  total: number;
}

const columns: PlTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice', width: 110 },
  { key: 'customer', header: 'Customer' },
  { key: 'status', header: 'Status' },
  {
    key: 'total',
    header: 'Total',
    align: 'end',
    render: (row) => `$${row.total.toFixed(2)}`
  }
];

const rows: Invoice[] = [
  { id: 'INV-0102', customer: 'Acme Inc', status: 'Paid', total: 1240 },
  { id: 'INV-0101', customer: 'Globex', status: 'Open', total: 340.5 },
  { id: 'INV-0100', customer: 'Initech', status: 'Overdue', total: 89 }
];

export default function TableHero() {
  return <PlTable columns={columns} rows={rows} caption="Recent invoices" hoverable />;
}
