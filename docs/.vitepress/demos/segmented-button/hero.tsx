import { useState } from 'react';
import { PlSegment, PlSegmentedButton } from 'plass-ui';

export default function SegmentedButtonHero() {
  const [period, setPeriod] = useState<string | number | null>('week');

  return (
    <PlSegmentedButton aria-label="Period" value={period} onValueChange={setPeriod}>
      <PlSegment value="day">Day</PlSegment>
      <PlSegment value="week">Week</PlSegment>
      <PlSegment value="month">Month</PlSegment>
      <PlSegment value="year">Year</PlSegment>
    </PlSegmentedButton>
  );
}
