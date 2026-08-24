import { PlHighlight } from 'plass-ui';

export default function HighlightMatching() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3 text-sm/7 text-(--plass-fg)">
      <p>
        <PlHighlight query={['data', 'database']}>
          One database, and the data inside it.
        </PlHighlight>
      </p>
      <p>
        <PlHighlight query="cat" wholeWord>
          A cat that can concatenate.
        </PlHighlight>
      </p>
      <p>
        <PlHighlight query="glass" caseSensitive>
          Glass is not glass when the case matters.
        </PlHighlight>
      </p>
      <p>
        <PlHighlight query={/\d+(\.\d+)?/} color="info">
          The blur is 22px and the duration 150ms.
        </PlHighlight>
      </p>
    </div>
  );
}
