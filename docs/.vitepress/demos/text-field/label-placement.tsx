import { PlTextField } from 'plass-ui';

export default function TextFieldLabelPlacement() {
  return (
    <div className="grid w-full max-w-sm gap-5">
      <PlTextField label="Email" labelPlacement="top" placeholder="you@example.com" fullWidth />
      <PlTextField label="Email" labelPlacement="notch" placeholder="you@example.com" fullWidth />
      <PlTextField
        variant="solid"
        label="Password"
        labelPlacement="notch"
        type="password"
        defaultValue="hunter2"
        fullWidth
      />
      <PlTextField
        label="Note"
        labelPlacement="notch"
        multiline
        rows={3}
        description="A notch works the same on a multiline field."
        fullWidth
      />
    </div>
  );
}
