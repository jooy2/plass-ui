import { useState } from 'react';
import { PlFilePicker } from 'plass-ui';

export default function FilePickerHero() {
  const [files, setFiles] = useState<File[]>([]);

  return (
    <PlFilePicker
      className="max-w-md"
      label="Attachments"
      multiple
      maxFiles={4}
      hint="Up to four files, 5 MB each"
      value={files}
      onFilesChange={setFiles}
      maxSize={5_000_000}
    />
  );
}
