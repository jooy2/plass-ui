import { PlCodeBlock } from 'plass-ui';

const source = `import { PlButton } from 'plass-ui';

export function Save({ busy }: { busy: boolean }) {
  return (
    <PlButton color="primary" loading={busy}>
      Save changes
    </PlButton>
  );
}`;

export default function CodeBlockHero() {
  return <PlCodeBlock code={source} language="tsx" title="src/Save.tsx" className="w-full" />;
}
