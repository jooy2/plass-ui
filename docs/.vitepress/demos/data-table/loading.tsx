import { useEffect, useState } from 'react';
import { PlDataTable, type PlDataTableColumn } from 'plass-ui';

interface Row {
  id: number;
  name: string;
  role: string;
}

const columns: PlDataTableColumn<Row>[] = [
  { key: 'name', header: 'Name' },
  { key: 'role', header: 'Role' }
];

const rows: Row[] = [
  { id: 1, name: 'Ada Lovelace', role: 'Analyst' },
  { id: 2, name: 'Grace Hopper', role: 'Compiler' },
  { id: 3, name: 'Karen Spärck Jones', role: 'Retrieval' }
];

export default function DataTableLoading() {
  const [loading, setLoading] = useState(true);

  // Turns over every few seconds so both states can be seen on one page.
  useEffect(() => {
    const timer = setInterval(() => setLoading((one) => !one), 2400);

    return () => clearInterval(timer);
  }, []);

  return (
    <PlDataTable columns={columns} rows={rows} getRowKey={(row) => row.id} loading={loading} />
  );
}
