import { TextField } from 'plass-ui';

export default function TextFieldSizes() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <TextField size="xs" placeholder="Extra small" />
      <TextField size="sm" placeholder="Small" />
      <TextField size="md" placeholder="Medium" />
      <TextField size="lg" placeholder="Large" />
      <TextField size="xl" placeholder="Extra large" />
    </div>
  );
}
