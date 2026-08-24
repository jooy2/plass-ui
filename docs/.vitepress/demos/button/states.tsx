import { PlButton } from 'plass-ui';

export default function ButtonStates() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton>Idle</PlButton>
      <PlButton loading>Loading</PlButton>
      <PlButton readOnly>Read-only</PlButton>
      <PlButton disabled>Disabled</PlButton>
    </div>
  );
}
