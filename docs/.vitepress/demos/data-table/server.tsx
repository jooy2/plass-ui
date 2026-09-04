import { useState } from 'react';
import { PlDataTable, type PlDataTableColumn, type PlDataTableSort } from 'plass-ui';

interface Order {
  id: string;
  city: string;
}

const columns: PlDataTableColumn<Order>[] = [
  { key: 'id', header: 'Order', sortable: true },
  { key: 'city', header: 'City', sortable: true }
];

/** Stands in for a request. A real one would be a fetch with these as query parameters. */
function load(sort: PlDataTableSort | null, page: number) {
  const all = ['Seoul', 'Lisbon', 'Osaka', 'Cairo', 'Oslo', 'Quito'].map((city, index) => ({
    id: `ORD-${100 + index}`,
    city
  }));

  const ordered = sort
    ? [...all].sort(
        (a, b) =>
          String(a[sort.key as keyof Order]).localeCompare(String(b[sort.key as keyof Order])) *
          (sort.direction === 'asc' ? 1 : -1)
      )
    : all;

  return ordered.slice((page - 1) * 3, page * 3);
}

export default function DataTableServer() {
  const [sort, setSort] = useState<PlDataTableSort | null>(null);
  const [page, setPage] = useState(1);

  // The table reports what the reader asked for and draws what it is handed.
  return (
    <PlDataTable
      columns={columns}
      rows={load(sort, page)}
      getRowKey={(row) => row.id}
      manual={['sort', 'pages']}
      rowCount={6}
      paging="pages"
      pageSize={3}
      sort={sort}
      onSortChange={setSort}
      page={page}
      onPageChange={setPage}
    />
  );
}
