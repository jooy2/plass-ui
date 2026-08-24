import { TextField } from 'plass-ui';

export default function TextFieldHero() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <TextField label="Workspace" placeholder="acme-inc" description="Used in your URL." />
      <TextField
        label="Email"
        type="email"
        defaultValue="not-an-email"
        error="Enter a valid address."
      />
    </div>
  );
}
