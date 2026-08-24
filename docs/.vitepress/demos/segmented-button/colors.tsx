import { PlSegment, PlSegmentedButton } from 'plass-ui';

export default function SegmentedButtonColors() {
  return (
    <div className="flex flex-col items-start gap-3">
      {(['primary', 'success', 'warning', 'danger'] as const).map((color) => (
        <PlSegmentedButton
          key={color}
          variant="solid"
          color={color}
          size="sm"
          aria-label={color}
          defaultValue="on"
        >
          <PlSegment value="on">On</PlSegment>
          <PlSegment value="auto">Auto</PlSegment>
          <PlSegment value="off">Off</PlSegment>
        </PlSegmentedButton>
      ))}
    </div>
  );
}
