import { TextField } from 'plass-ui';

export default function TextFieldVariants() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <TextField variant="glass" label="glass" placeholder="A sheet with a hairline" />
      <TextField variant="solid" label="solid" placeholder="A well cut into the sheet" />
      <TextField variant="ghost" label="ghost" placeholder="No surface until you go near it" />
    </div>
  );
}
