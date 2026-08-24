import { PlPagination } from 'plass-ui';

export default function PaginationVariants() {
  return (
    <div className="flex flex-col items-center gap-4">
      {(['ghost', 'glass', 'solid'] as const).map((variant) => (
        <PlPagination key={variant} variant={variant} count={7} defaultPage={3} />
      ))}
    </div>
  );
}
