import { PlTable, type PlTableColumn } from 'plass-ui';

interface Reading {
  at: string;
  sensor: string;
  value: number;
  state: string;
}

const columns: PlTableColumn<Reading>[] = [
  { key: 'at', header: 'Time', width: 90 },
  { key: 'sensor', header: 'Sensor' },
  { key: 'value', header: 'Value', align: 'end', render: (row) => `${row.value.toFixed(1)} °C` },
  { key: 'state', header: 'State' }
];

const sensors = ['Inlet', 'Outlet', 'Ambient', 'Coolant'];

/** Enough rows that the cap is doing something. */
const rows: Reading[] = Array.from({ length: 24 }, (_, index) => ({
  at: `09:${String(index * 2).padStart(2, '0')}`,
  sensor: sensors[index % sensors.length],
  value: 18 + ((index * 7) % 23) / 2,
  state: index % 7 === 3 ? 'Warning' : 'Nominal'
}));

export default function TableScroll() {
  return (
    <PlTable
      columns={columns}
      rows={rows}
      caption="Overnight readings"
      stickyHeader
      maxHeight={280}
      striped
      hoverable
    />
  );
}
