import { PlTextField } from 'plass-ui';

export default function TextFieldVariants() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <PlTextField variant="glass" label="glass" placeholder="A sheet with a hairline" />
      <PlTextField variant="solid" label="solid" placeholder="A well cut into the sheet" />
      <PlTextField variant="ghost" label="ghost" placeholder="No surface until you go near it" />
    </div>
  );
}
