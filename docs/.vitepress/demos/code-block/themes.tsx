import { useState } from 'react';
import { PlCodeBlock, PlSelect, type PlCodeBlockTheme } from 'plass-ui';

const source = `const routes = new Map<string, Handler>();

/** Answers /health, and nothing else. */
export function health(request: Request): Response {
  return new Response('ok', { status: 200 });
}`;

const themes: PlCodeBlockTheme[] = [
  'dark',
  'light',
  'auto',
  'mono',
  'one-dark',
  'dracula',
  'monokai',
  'nord',
  'night-owl',
  'gruvbox',
  'github',
  'solarized-light'
];

export default function CodeBlockThemes() {
  const [theme, setTheme] = useState<PlCodeBlockTheme>('dracula');

  return (
    <div className="flex w-full flex-col gap-3">
      <PlSelect
        label="Theme"
        value={theme}
        onValueChange={(next) => setTheme(next as PlCodeBlockTheme)}
        items={themes.map((name) => ({ value: name, label: name }))}
      />
      <PlCodeBlock code={source} language="ts" theme={theme} />
    </div>
  );
}
