import { PlPill, PlTypography } from 'plass-ui';

export default function PillVariants() {
  return (
    <div className="flex flex-col items-center gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <div key={variant} className="flex flex-col items-center gap-1">
          <PlTypography level="caption">{variant}</PlTypography>
          <PlPill variant={variant} color="primary" title="Uploading" description="3 of 12" />
        </div>
      ))}
    </div>
  );
}
