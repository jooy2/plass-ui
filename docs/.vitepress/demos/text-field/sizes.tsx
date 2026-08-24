import { PlTextField } from 'plass-ui';

export default function TextFieldSizes() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <PlTextField size="xs" placeholder="Extra small" />
      <PlTextField size="sm" placeholder="Small" />
      <PlTextField size="md" placeholder="Medium" />
      <PlTextField size="lg" placeholder="Large" />
      <PlTextField size="xl" placeholder="Extra large" />
    </div>
  );
}
