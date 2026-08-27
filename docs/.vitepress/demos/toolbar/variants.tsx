import { PlButton, PlToolbar, PlTypography } from 'plass-ui';

export default function ToolbarVariants() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      {(['glass', 'solid', 'ghost'] as const).map((variant) => (
        <PlToolbar
          key={variant}
          variant={variant}
          start={<PlTypography level="caption">{variant}</PlTypography>}
          end={
            <PlButton size="sm" variant="ghost">
              Action
            </PlButton>
          }
        />
      ))}
    </div>
  );
}
