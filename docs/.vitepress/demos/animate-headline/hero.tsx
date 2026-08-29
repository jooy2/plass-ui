import { PlAnimateHeadline, PlTypography } from 'plass-ui';

const lines = ['ships on Friday', 'reads like prose', 'weighs almost nothing'];

export default function AnimateHeadlineHero() {
  return (
    <div className="flex flex-col items-center gap-1 text-center">
      <PlTypography level="h3">Software that</PlTypography>

      <PlAnimateHeadline interval={2200}>
        {lines.map((line) => (
          <PlTypography key={line} level="h3" className="text-(--p-accent)">
            {line}
          </PlTypography>
        ))}
      </PlAnimateHeadline>
    </div>
  );
}
