import { PlTable, type PlTableColumn } from 'plass-ui';

interface Row {
  metric: string;
  value: string;
}

const columns: PlTableColumn<Row>[] = [
  { key: 'metric', header: 'Metric' },
  { key: 'value', header: 'Value', align: 'end' }
];

const rows: Row[] = [
  { metric: 'Requests', value: '12.4k' },
  { metric: 'Errors', value: '18' }
];

export default function TableVariants() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlTable key={variant} variant={variant} size="sm" columns={columns} rows={rows} />
      ))}
    </div>
  );
}
