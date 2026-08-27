import { PlSpoiler, PlTypography } from 'plass-ui';

export default function SpoilerVariants() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      {(['glass', 'solid', 'ghost'] as const).map((variant) => (
        <div key={variant} className="flex flex-col gap-1">
          <PlTypography level="caption">{variant}</PlTypography>
          <PlSpoiler variant={variant}>
            <PlTypography level="body">
              The sheet is never dyed, whatever it is made of.
            </PlTypography>
          </PlSpoiler>
        </div>
      ))}
    </div>
  );
}
