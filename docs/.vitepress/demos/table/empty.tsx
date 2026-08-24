import { PlTable, type PlTableColumn } from 'plass-ui';

interface Row {
  id: string;
  customer: string;
}

const columns: PlTableColumn<Row>[] = [
  { key: 'id', header: 'Invoice' },
  { key: 'customer', header: 'Customer' }
];

export default function TableEmpty() {
  return <PlTable columns={columns} rows={[]} empty="No invoices in this period." />;
}
