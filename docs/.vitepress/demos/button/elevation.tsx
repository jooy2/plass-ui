import { Button } from 'plass-ui';

export default function ButtonElevation() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button elevation={0}>Flush</Button>
      <Button elevation={1}>Resting</Button>
      <Button elevation={2}>Raised</Button>
      <Button elevation={3}>Floating</Button>
    </div>
  );
}
