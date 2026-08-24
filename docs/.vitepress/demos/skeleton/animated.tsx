import { PlSkeleton } from 'plass-ui';

export default function SkeletonAnimated() {
  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      <PlSkeleton lines={2} />
      <PlSkeleton lines={2} animated={false} />
      <PlSkeleton shape="rect" height={56} color="primary" />
    </div>
  );
}
