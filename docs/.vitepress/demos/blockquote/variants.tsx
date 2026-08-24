import { PlBlockquote } from 'plass-ui';

export default function BlockquoteVariants() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-5">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlBlockquote key={variant} variant={variant} author={variant}>
          The same quote, three materials deep.
        </PlBlockquote>
      ))}
    </div>
  );
}
