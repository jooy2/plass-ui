import { useState } from 'react';
import { PlPagination } from 'plass-ui';

export default function PaginationHero() {
  const [page, setPage] = useState(4);

  return <PlPagination count={12} page={page} onPageChange={setPage} showEdges />;
}
