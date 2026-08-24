import { PlBadge, PlButton } from 'plass-ui';

export default function BadgeDot() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <PlBadge dot color="danger" label="Unsaved changes">
        <PlButton variant="glass" color="secondary">
          Draft
        </PlButton>
      </PlBadge>

      <PlBadge dot content={12} color="warning" label="12 items need review">
        <PlButton variant="glass" color="secondary">
          Review queue
        </PlButton>
      </PlBadge>

      <PlBadge dot color="success" />
    </div>
  );
}
