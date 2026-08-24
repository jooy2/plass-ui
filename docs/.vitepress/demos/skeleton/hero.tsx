import { PlCard, PlSkeleton } from 'plass-ui';

export default function SkeletonHero() {
  return (
    <PlCard className="w-full max-w-md" title={<PlSkeleton width={160} label="Loading the card" />}>
      <div className="flex flex-col gap-4">
        <PlSkeleton shape="rect" height={120} />
        <div className="flex items-center gap-3">
          <PlSkeleton shape="circle" />
          <PlSkeleton lines={2} />
        </div>
      </div>
    </PlCard>
  );
}
