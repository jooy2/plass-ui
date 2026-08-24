import { PlTextField } from 'plass-ui';

export default function TextFieldMultiline() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <PlTextField multiline rows={1} label="One row" placeholder="Exactly a single-line field" />
      <PlTextField
        multiline
        label="Release note"
        rows={4}
        description="Markdown is not rendered here."
      />
      <PlTextField
        multiline
        resize="none"
        rows={2}
        label="Fixed"
        defaultValue="Cannot be dragged."
      />
    </div>
  );
}
