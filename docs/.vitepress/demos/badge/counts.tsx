import { PlBadge, PlButton } from 'plass-ui';

export default function BadgeCounts() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <PlBadge content={0} label="Nothing unread">
        <PlButton variant="glass" color="secondary" size="sm">
          0, hidden
        </PlButton>
      </PlBadge>

      <PlBadge content={0} showZero label="Nothing unread">
        <PlButton variant="glass" color="secondary" size="sm">
          0, shown
        </PlButton>
      </PlBadge>

      <PlBadge content={128} label="128 unread">
        <PlButton variant="glass" color="secondary" size="sm">
          capped
        </PlButton>
      </PlBadge>

      <PlBadge content={128} max={999} label="128 unread">
        <PlButton variant="glass" color="secondary" size="sm">
          max 999
        </PlButton>
      </PlBadge>
    </div>
  );
}
