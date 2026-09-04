import { PlDataTable, type PlDataTableColumn } from 'plass-ui';

interface Entry {
  id: number;
  event: string;
  at: string;
}

const columns: PlDataTableColumn<Entry>[] = [
  { key: 'id', header: '#', width: 64, align: 'end' },
  { key: 'event', header: 'Event' },
  { key: 'at', header: 'When' }
];

const events = ['Signed in', 'Changed password', 'Exported a report', 'Invited a colleague'];

const rows: Entry[] = Array.from({ length: 23 }, (_, index) => ({
  id: 23 - index,
  event: events[index % events.length],
  at: `${index + 1} day${index === 0 ? '' : 's'} ago`
}));

export default function DataTablePaging() {
  return (
    <PlDataTable
      columns={columns}
      rows={rows}
      getRowKey={(row) => row.id}
      paging="pages"
      pageSize={6}
      searchable
    />
  );
}
