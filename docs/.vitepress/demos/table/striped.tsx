import { PlTable, type PlTableColumn } from 'plass-ui';

interface Row {
  region: string;
  q1: number;
  q2: number;
  q3: number;
  q4: number;
}

const columns: PlTableColumn<Row>[] = [
  { key: 'region', header: 'Region' },
  { key: 'q1', header: 'Q1', align: 'end' },
  { key: 'q2', header: 'Q2', align: 'end' },
  { key: 'q3', header: 'Q3', align: 'end' },
  { key: 'q4', header: 'Q4', align: 'end' }
];

const rows: Row[] = [
  { region: 'North', q1: 120, q2: 134, q3: 118, q4: 160 },
  { region: 'South', q1: 96, q2: 101, q3: 130, q4: 122 },
  { region: 'East', q1: 141, q2: 128, q3: 139, q4: 171 },
  { region: 'West', q1: 88, q2: 94, q3: 90, q4: 103 }
];

export default function TableStriped() {
  return <PlTable striped hoverable columns={columns} rows={rows} />;
}
