import { PlAvatar, PlChip } from 'plass-ui';

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" aria-hidden="true">
      <circle cx="8" cy="8" r="4" fill="currentColor" />
    </svg>
  );
}

export default function ChipSlots() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlChip startIcon={<DotIcon />} color="success">
        Deployed
      </PlChip>
      <PlChip startIcon={<PlAvatar size="xs" name="Ada Lovelace" />} color="secondary">
        Ada Lovelace
      </PlChip>
      <PlChip count={12} color="danger">
        Errors
      </PlChip>
      <PlChip variant="solid" count="99+">
        Unread
      </PlChip>
    </div>
  );
}
