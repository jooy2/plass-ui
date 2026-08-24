import { useState } from 'react';
import { PlHighlight, PlTextField } from 'plass-ui';

const text =
  'A Plass surface is a key of tinted glass resting on a clear sheet. A thing that is pressed is tinted glass; a thing that holds something is clear glass.';

export default function HighlightHero() {
  const [query, setQuery] = useState('glass');

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <PlTextField
        fullWidth
        size="sm"
        label="Search"
        value={query}
        onChange={(event) => setQuery(event.target.value)}
      />
      <p className="text-sm/6 text-(--plass-fg)">
        <PlHighlight query={query}>{text}</PlHighlight>
      </p>
    </div>
  );
}
