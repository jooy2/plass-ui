import { PlDataTable, type PlDataTableColumn } from 'plass-ui';

interface Player {
  name: string;
  country: string;
  points: number;
  joined: Date;
}

const columns: PlDataTableColumn<Player>[] = [
  { key: 'name', header: 'Name', sortable: true },
  { key: 'country', header: 'Country', sortable: true },
  { key: 'points', header: 'Points', align: 'end', sortable: true },
  {
    key: 'joined',
    header: 'Joined',
    sortable: true,
    // A date sorts as a date and is drawn as words. Without `value` the sort
    // would be comparing the two strings the cell happened to print.
    value: (row) => row.joined,
    render: (row) => row.joined.toLocaleDateString('en-GB', { month: 'short', year: 'numeric' })
  }
];

const rows: Player[] = [
  { name: 'ólafur', country: 'Iceland', points: 92, joined: new Date(2024, 2, 1) },
  { name: 'Beatriz', country: 'Brazil', points: 140, joined: new Date(2023, 10, 1) },
  { name: 'ahmed', country: 'Egypt', points: 8, joined: new Date(2025, 5, 1) },
  { name: 'Zoë', country: 'Belgium', points: 76, joined: new Date(2022, 0, 1) }
];

export default function DataTableSorting() {
  return (
    <PlDataTable
      columns={columns}
      rows={rows}
      getRowKey={(row) => row.name}
      defaultSort={{ key: 'points', direction: 'desc' }}
    />
  );
}
