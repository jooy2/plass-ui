import { Button } from 'plass-ui';

export default function ButtonStates() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button>Idle</Button>
      <Button loading>Loading</Button>
      <Button readOnly>Read-only</Button>
      <Button disabled>Disabled</Button>
    </div>
  );
}
