import { TextField } from 'plass-ui';

export default function TextFieldStates() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <TextField label="Idle" placeholder="Type here" />
      <TextField label="Loading" defaultValue="acme-inc" loading />
      <TextField label="Read-only" defaultValue="acme-inc" readOnly />
      <TextField label="Disabled" defaultValue="acme-inc" disabled />
    </div>
  );
}
