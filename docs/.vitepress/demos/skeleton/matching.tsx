import { useState } from 'react';
import { PlAvatar, PlButton, PlSkeleton, PlTypography } from 'plass-ui';

export default function SkeletonMatching() {
  const [loaded, setLoaded] = useState(false);

  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setLoaded(!loaded)}>
        {loaded ? 'Show the placeholder' : 'Show the real thing'}
      </PlButton>

      <div className="flex items-center gap-3">
        {loaded ? (
          <PlAvatar name="Ada Lovelace" src="/portrait-1.svg" />
        ) : (
          <PlSkeleton shape="circle" />
        )}
        <div className="flex min-w-0 flex-1 flex-col gap-1">
          {loaded ? (
            <>
              <PlTypography weight="semibold">Ada Lovelace</PlTypography>
              <PlTypography level="caption">Wrote the first program</PlTypography>
            </>
          ) : (
            <PlSkeleton lines={2} />
          )}
        </div>
      </div>
    </div>
  );
}
