import { PlButton } from 'plass-ui';

export default function ButtonHero() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton>Save</PlButton>
      <PlButton variant="glass">Cancel</PlButton>
      <PlButton variant="ghost">Details</PlButton>
      <PlButton color="danger">Delete</PlButton>
      <PlButton loading>Saving</PlButton>
      <PlButton disabled>Unavailable</PlButton>
    </div>
  );
}
