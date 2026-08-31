import { PlButton, PlEmpty, PlTable } from 'plass-ui';

interface Row {
  id: string;
  name: string;
}

export default function EmptyTable() {
  return (
    <PlTable<Row>
      className="w-full"
      columns={[
        { key: 'name', header: 'Name' },
        { key: 'id', header: 'Id' }
      ]}
      rows={[]}
      empty={
        <PlEmpty
          size="sm"
          title="Nothing matches that filter"
          description="Clear it to see everything again."
          actions={
            <PlButton size="sm" variant="glass" color="secondary">
              Clear filters
            </PlButton>
          }
        />
      }
    />
  );
}
