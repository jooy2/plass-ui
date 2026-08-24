import { PlBlockquote } from 'plass-ui';

export default function BlockquoteSizes() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlBlockquote key={size} size={size} icon={false} author={size}>
          A quote is set at a heading’s scale with a paragraph’s leading.
        </PlBlockquote>
      ))}
    </div>
  );
}
