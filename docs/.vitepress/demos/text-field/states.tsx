import { PlTextField } from 'plass-ui';

export default function TextFieldStates() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <PlTextField label="Idle" placeholder="Type here" />
      <PlTextField label="Loading" defaultValue="acme-inc" loading />
      <PlTextField label="Read-only" defaultValue="acme-inc" readOnly />
      <PlTextField label="Disabled" defaultValue="acme-inc" disabled />
    </div>
  );
}
