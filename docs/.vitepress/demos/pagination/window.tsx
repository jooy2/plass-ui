import { useState } from 'react';
import { PlPagination } from 'plass-ui';

export default function PaginationWindow() {
  const [page, setPage] = useState(10);

  return (
    <div className="flex w-full flex-col items-center gap-5">
      {(
        [
          { siblingCount: 0, boundaryCount: 1 },
          { siblingCount: 1, boundaryCount: 1 },
          { siblingCount: 2, boundaryCount: 2 }
        ] as const
      ).map((shape) => (
        <div
          key={`${shape.siblingCount}-${shape.boundaryCount}`}
          className="flex flex-col items-center gap-1"
        >
          <p className="text-xs text-(--plass-muted-fg)">
            siblingCount={shape.siblingCount} · boundaryCount={shape.boundaryCount}
          </p>
          <PlPagination
            count={20}
            page={page}
            onPageChange={setPage}
            siblingCount={shape.siblingCount}
            boundaryCount={shape.boundaryCount}
          />
        </div>
      ))}
    </div>
  );
}
