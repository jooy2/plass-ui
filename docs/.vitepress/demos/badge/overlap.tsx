import { PlAvatar, PlBadge } from 'plass-ui';

export default function BadgeOverlap() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <PlBadge dot color="success" label="Online">
        <PlAvatar size="lg" name="Ada Lovelace" />
      </PlBadge>

      <PlBadge dot color="success" overlap="circle" label="Online">
        <PlAvatar size="lg" name="Ada Lovelace" />
      </PlBadge>
    </div>
  );
}
