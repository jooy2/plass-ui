import { PlSpoiler, PlTypography } from 'plass-ui';

export default function SpoilerClamped() {
  return (
    <PlSpoiler className="w-full max-w-md" maxHeight={120} reversible blur={6}>
      <div className="flex flex-col gap-2">
        {Array.from({ length: 6 }, (_, index) => (
          <PlTypography key={index} level="body">
            Paragraph {index + 1} of the ending, which is longer than a cover has any reason to be.
          </PlTypography>
        ))}
      </div>
    </PlSpoiler>
  );
}
