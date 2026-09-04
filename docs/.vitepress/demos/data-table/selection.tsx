import { useState } from 'react';
import { PlButton, PlDataTable, type PlDataTableColumn } from 'plass-ui';

interface File {
  id: string;
  name: string;
  size: string;
  locked: boolean;
}

const columns: PlDataTableColumn<File>[] = [
  { key: 'name', header: 'Name' },
  { key: 'size', header: 'Size', align: 'end' }
];

const rows: File[] = [
  { id: '1', name: 'quarterly-report.pdf', size: '2.4 MB', locked: false },
  { id: '2', name: 'logo.svg', size: '18 KB', locked: false },
  { id: '3', name: 'contract-signed.pdf', size: '840 KB', locked: true },
  { id: '4', name: 'notes.md', size: '4 KB', locked: false }
];

export default function DataTableSelection() {
  const [selected, setSelected] = useState<readonly React.Key[]>([]);

  return (
    <PlDataTable
      columns={columns}
      rows={rows}
      getRowKey={(row) => row.id}
      selection="multiple"
      selected={selected}
      onSelectedChange={setSelected}
      // A locked file cannot be chosen, so it is left out of the tick-all too.
      isRowSelectable={(row) => !row.locked}
      toolbar={
        <PlButton size="sm" color="danger" variant="ghost" disabled={selected.length === 0}>
          Delete {selected.length || ''}
        </PlButton>
      }
      footer={`${selected.length} of ${rows.length} chosen`}
    />
  );
}
