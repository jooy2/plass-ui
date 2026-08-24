import { PlButton } from 'plass-ui';

export default function ButtonElevation() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton elevation={0}>Flush</PlButton>
      <PlButton elevation={1}>Resting</PlButton>
      <PlButton elevation={2}>Raised</PlButton>
      <PlButton elevation={3}>Floating</PlButton>
    </div>
  );
}
