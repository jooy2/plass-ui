import { useState } from 'react';
import { PlBarChart, PlSegment, PlSegmentedButton } from 'plass-ui';

const plans = [
  { name: 'Free', data: [420, 460, 480, 510] },
  { name: 'Pro', data: [180, 220, 260, 310] },
  { name: 'Team', data: [40, 55, 72, 96] }
];

const quarters = ['Q1', 'Q2', 'Q3', 'Q4'];

type Mode = 'grouped' | 'stacked' | 'full';

export default function BarChartStacked() {
  const [mode, setMode] = useState<Mode>('stacked');

  return (
    <div className="flex w-full flex-col gap-4">
      <PlSegmentedButton value={mode} onValueChange={(next) => setMode(next as Mode)}>
        <PlSegment value="grouped">grouped</PlSegment>
        <PlSegment value="stacked">stacked</PlSegment>
        <PlSegment value="full">full</PlSegment>
      </PlSegmentedButton>

      <PlBarChart
        className="w-full"
        series={plans}
        categories={quarters}
        stacked={mode === 'grouped' ? false : mode === 'full' ? 'full' : true}
      />
    </div>
  );
}
