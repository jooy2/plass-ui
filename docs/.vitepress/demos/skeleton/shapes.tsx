import { PlSkeleton } from 'plass-ui';

export default function SkeletonShapes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-6">
      <PlSkeleton />
      <PlSkeleton lines={4} />
      <PlSkeleton shape="rect" />
      <PlSkeleton shape="circle" />
    </div>
  );
}
