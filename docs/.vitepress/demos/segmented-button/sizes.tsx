import { PlSegment, PlSegmentedButton } from 'plass-ui';

export default function SegmentedButtonSizes() {
  return (
    <div className="flex flex-col items-start gap-3">
      {(['xs', 'sm', 'md', 'lg'] as const).map((size) => (
        <PlSegmentedButton key={size} size={size} aria-label={size} defaultValue="a">
          <PlSegment value="a">First</PlSegment>
          <PlSegment value="b">Second</PlSegment>
        </PlSegmentedButton>
      ))}
    </div>
  );
}
