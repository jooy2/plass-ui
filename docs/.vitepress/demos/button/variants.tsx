import { PlButton } from 'plass-ui';

export default function ButtonVariants() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton variant="solid">Save</PlButton>
      <PlButton variant="glass">Cancel</PlButton>
      <PlButton variant="glass" color="secondary">
        Dismiss
      </PlButton>
      <PlButton variant="ghost">Details</PlButton>
    </div>
  );
}
