import { PlCodeBlock } from 'plass-ui';

const source = `npm install plass-ui

npm run dev`;

export default function CodeBlockTerminal() {
  return (
    <PlCodeBlock code={source} language="bash" prompt="$" showLanguage={false} className="w-full" />
  );
}
