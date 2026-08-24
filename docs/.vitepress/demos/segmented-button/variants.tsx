import { PlSegment, PlSegmentedButton } from 'plass-ui';

export default function SegmentedButtonVariants() {
  return (
    <div className="flex flex-col items-start gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlSegmentedButton key={variant} variant={variant} aria-label={variant} defaultValue="grid">
          <PlSegment value="grid">Grid</PlSegment>
          <PlSegment value="list">List</PlSegment>
          <PlSegment value="table">Table</PlSegment>
        </PlSegmentedButton>
      ))}
    </div>
  );
}
