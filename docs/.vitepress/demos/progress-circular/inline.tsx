import { PlProgressCircular, PlTable } from 'plass-ui';

interface Upload {
  name: string;
  done: number | null;
}

const rows: Upload[] = [
  { name: 'invoice-2026-03.pdf', done: 100 },
  { name: 'annual-report.key', done: 48 },
  { name: 'raw-footage.mov', done: null }
];

export default function ProgressCircularInline() {
  return (
    <PlTable
      className="w-full max-w-md"
      size="sm"
      columns={[
        { key: 'name', header: 'File' },
        {
          key: 'done',
          header: 'Upload',
          align: 'end',
          render: (row: Upload) => (
            <PlProgressCircular
              size="xs"
              value={row.done}
              label={`Uploading ${row.name}`}
              showValue
            />
          )
        }
      ]}
      rows={rows}
      getRowKey={(row: Upload) => row.name}
    />
  );
}
