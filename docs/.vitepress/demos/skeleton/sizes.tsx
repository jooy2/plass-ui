import { PlSkeleton } from 'plass-ui';

export default function SkeletonSizes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <div key={size} className="flex items-center gap-4">
          <span className="w-8 shrink-0 text-xs text-(--plass-muted-fg)">{size}</span>
          <PlSkeleton size={size} lines={2} />
          <PlSkeleton size={size} shape="circle" />
        </div>
      ))}
    </div>
  );
}
