import { Button } from 'plass-ui';

export default function ButtonVariants() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button variant="solid">Save</Button>
      <Button variant="glass">Cancel</Button>
      <Button variant="glass" color="secondary">
        Dismiss
      </Button>
      <Button variant="ghost">Details</Button>
    </div>
  );
}
