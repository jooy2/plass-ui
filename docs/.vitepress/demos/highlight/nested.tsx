import { PlHighlight } from 'plass-ui';

export default function HighlightNested() {
  return (
    <p className="w-full max-w-lg text-sm/7 text-(--plass-fg)">
      <PlHighlight query="glass" underline weight="semibold">
        A sheet of <strong>glass</strong> over a page, with the word marked inside the{' '}
        <em>strong</em> that already held it.
      </PlHighlight>
    </p>
  );
}
