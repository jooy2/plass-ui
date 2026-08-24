import { Button } from 'plass-ui';

export default function ButtonFullWidth() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      <Button fullWidth>Continue</Button>
      <Button fullWidth variant="glass">
        Use another account
      </Button>
    </div>
  );
}
