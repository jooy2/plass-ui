import { PlCodeBlock } from 'plass-ui';

const source = `export function surfaceSlots(color, elevation) {
  return {
    '--p-accent': \`var(--plass-\${color}-accent)\`,
    '--p-soft': \`var(--plass-\${color}-soft)\`,
    '--p-elev': \`var(--plass-shadow-\${elevation})\`
  };
}`;

export default function CodeBlockLines() {
  return (
    <PlCodeBlock
      code={source}
      language="js"
      title="internal/styles.ts"
      lineNumbers
      startLine={551}
      highlightLines="553-555"
      className="w-full"
    />
  );
}
