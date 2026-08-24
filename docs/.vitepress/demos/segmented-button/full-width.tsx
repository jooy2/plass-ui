import { PlSegment, PlSegmentedButton } from 'plass-ui';

export default function SegmentedButtonFullWidth() {
  return (
    <PlSegmentedButton fullWidth aria-label="Delivery" defaultValue="standard" className="max-w-md">
      <PlSegment value="standard">Standard</PlSegment>
      <PlSegment value="express">Express</PlSegment>
      <PlSegment value="pickup">Pick up</PlSegment>
    </PlSegmentedButton>
  );
}
