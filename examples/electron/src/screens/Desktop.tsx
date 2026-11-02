import { useState } from 'react';
import { PlCard, PlCodeBlock, PlFilePicker, PlHotKeys, PlTextLink } from 'plass-ui';

const source = `import { PlButton } from 'plass-ui';

export function Save({ busy }: { busy: boolean }) {
  return <PlButton loading={busy}>Save changes</PlButton>;
}`;

const python = `def greet(name: str) -> str:
    return f"Hello, {name}"`;

/** What a desktop app does that a page in a browser tab does not. */
export function Desktop() {
  const [files, setFiles] = useState<File[]>([]);

  return (
    <div className="flex flex-col gap-4">
      <PlCard title="Files from the disk">
        <PlFilePicker
          label="Attachments"
          multiple
          hint="Drop files from Finder or Explorer"
          value={files}
          onFilesChange={setFiles}
        />
        <ul className="mt-3 text-sm text-(--plass-muted-fg)">
          {files.map((file) => (
            <li key={file.name}>{window.desktop?.pathForFile(file) || file.name}</li>
          ))}
        </ul>
      </PlCard>

      <PlCard title="Code, highlighted from a chunk loaded on demand">
        <div className="flex flex-col gap-3">
          <PlCodeBlock code={source} language="tsx" title="src/Save.tsx" />
          <PlCodeBlock code={python} language="python" title="greet.py" />
        </div>
      </PlCard>

      <PlCard title="Keys and links">
        <p className="flex items-center gap-2">
          Open the palette with <PlHotKeys keys="Mod+K" />
        </p>
        <p className="mt-2">
          <PlTextLink href="https://plass.cdget.com" target="_blank" rel="noreferrer">
            Opens in the browser
          </PlTextLink>
        </p>
      </PlCard>
    </div>
  );
}
