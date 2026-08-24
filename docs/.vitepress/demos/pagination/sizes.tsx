import { PlPagination } from 'plass-ui';

export default function PaginationSizes() {
  return (
    <div className="flex flex-col items-center gap-4">
      {(['xs', 'sm', 'md', 'lg'] as const).map((size) => (
        <PlPagination key={size} size={size} count={7} defaultPage={3} />
      ))}
    </div>
  );
}
