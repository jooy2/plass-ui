import { PlButton, PlToolbar, PlTypography } from 'plass-ui';

export default function ToolbarDensity() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      {(['default', 'compact'] as const).map((density) => (
        <PlToolbar
          key={density}
          density={density}
          start={<PlTypography level="caption">density: {density}</PlTypography>}
          end={
            <PlButton size="sm" density={density}>
              Save
            </PlButton>
          }
        />
      ))}
    </div>
  );
}
