import { PlHeader, type PlassVariant } from 'plass-ui';

export default function HeaderVariants() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['solid', 'glass', 'ghost'] as PlassVariant[]).map((variant) => (
        <PlHeader
          key={variant}
          position="static"
          size="sm"
          variant={variant}
          brand={<span className="font-semibold">{variant}</span>}
          actions={<span className="text-sm text-(--plass-muted-fg)">Account</span>}
        />
      ))}
    </div>
  );
}
