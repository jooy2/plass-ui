import { Button } from 'plass-ui';

export default function ButtonHero() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button>Save</Button>
      <Button variant="glass">Cancel</Button>
      <Button variant="ghost">Details</Button>
      <Button color="danger">Delete</Button>
      <Button loading>Saving</Button>
      <Button disabled>Unavailable</Button>
    </div>
  );
}
