import { PlList, PlListItem, PlShow, PlTable } from 'plass-ui';

const columns = [
  { key: 'name', header: 'Service' },
  { key: 'region', header: 'Region' },
  { key: 'status', header: 'Status' }
];

const rows = [
  { name: 'api', region: 'ap-northeast-2', status: 'Healthy' },
  { name: 'worker', region: 'eu-west-1', status: 'Degraded' }
];

export default function ShowLayout() {
  return (
    <div className="w-full">
      <PlShow from="md">
        <PlTable columns={columns} rows={rows} />
      </PlShow>

      <PlShow until="md">
        <PlList dividers>
          {rows.map((row) => (
            <PlListItem key={row.name} description={`${row.region} · ${row.status}`}>
              {row.name}
            </PlListItem>
          ))}
        </PlList>
      </PlShow>
    </div>
  );
}
