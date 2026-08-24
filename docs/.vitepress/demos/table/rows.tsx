import { useState } from 'react';
import { PlTable, type PlTableColumn } from 'plass-ui';

interface Build {
  id: string;
  branch: string;
  duration: string;
}

const columns: PlTableColumn<Build>[] = [
  { key: 'id', header: 'Build' },
  { key: 'branch', header: 'Branch' },
  { key: 'duration', header: 'Duration', align: 'end' }
];

const rows: Build[] = [
  { id: '#412', branch: 'main', duration: '2m 04s' },
  { id: '#411', branch: 'fix/glass-edge', duration: '1m 58s' },
  { id: '#410', branch: 'main', duration: '2m 11s' }
];

export default function TableRows() {
  const [opened, setOpened] = useState<string | null>(null);

  return (
    <div className="flex w-full flex-col gap-3">
      <PlTable columns={columns} rows={rows} onRowClick={(row) => setOpened(row.id)} />
      <p className="text-xs text-(--plass-muted-fg)">
        {opened ? `Opened build ${opened}.` : 'Click or focus a row and press Enter.'}
      </p>
    </div>
  );
}
