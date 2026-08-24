import { PlButton } from 'plass-ui';

export default function ButtonFullWidth() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      <PlButton fullWidth>Continue</PlButton>
      <PlButton fullWidth variant="glass">
        Use another account
      </PlButton>
    </div>
  );
}
