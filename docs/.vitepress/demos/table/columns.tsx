import { PlButton, PlTable, type PlTableColumn } from 'plass-ui';

interface Member {
  name: string;
  role: string;
  seats: number;
}

const columns: PlTableColumn<Member>[] = [
  { key: 'name', header: 'Member', width: '45%' },
  { key: 'role', header: 'Role' },
  { key: 'seats', header: 'Seats', align: 'end', width: 80 },
  {
    key: 'actions',
    header: '',
    align: 'end',
    width: 90,
    render: (row) => (
      <PlButton size="xs" variant="ghost" color="secondary">
        Edit {row.name.split(' ')[0]}
      </PlButton>
    )
  }
];

const rows: Member[] = [
  { name: 'Ada Lovelace', role: 'Owner', seats: 3 },
  { name: 'Grace Hopper', role: 'Admin', seats: 1 }
];

export default function TableColumns() {
  return <PlTable columns={columns} rows={rows} />;
}
