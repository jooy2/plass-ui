import { PlTable, type PlTableColumn } from 'plass-ui';

interface Row {
  key: string;
  value: string;
}

const columns: PlTableColumn<Row>[] = [
  { key: 'key', header: 'Header' },
  { key: 'value', header: 'Value' }
];

const rows: Row[] = [
  { key: 'content-type', value: 'application/json' },
  { key: 'cache-control', value: 'no-store' },
  { key: 'x-request-id', value: '7f2c1a' }
];

export default function TableDensity() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      <PlTable size="sm" columns={columns} rows={rows} caption="default" />
      <PlTable size="sm" density="compact" columns={columns} rows={rows} caption="compact" />
    </div>
  );
}
