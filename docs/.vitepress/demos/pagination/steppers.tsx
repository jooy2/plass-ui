import { PlPagination } from 'plass-ui';

export default function PaginationSteppers() {
  return (
    <div className="flex flex-col items-center gap-4">
      <PlPagination count={9} defaultPage={5} showEdges />
      <PlPagination count={9} defaultPage={5} />
      <PlPagination count={9} defaultPage={5} showArrows={false} />
    </div>
  );
}
