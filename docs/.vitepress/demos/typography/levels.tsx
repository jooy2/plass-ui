import { PlTypography } from 'plass-ui';

const levels = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'lead', 'body', 'caption', 'overline'] as const;

export default function TypographyLevels() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      {levels.map((level) => (
        <div key={level} className="flex items-baseline gap-4">
          <span className="w-16 shrink-0 text-xs text-(--plass-muted-fg)">{level}</span>
          <PlTypography level={level}>The quick brown fox</PlTypography>
        </div>
      ))}
    </div>
  );
}
