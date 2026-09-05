import { useState } from 'react';
import { PlLineChart, PlSegment, PlSegmentedButton, type PlassChartCurve } from 'plass-ui';

const rate = [{ name: 'Base rate', data: [0.5, 0.5, 1.25, 1.25, 2, 3, 3, 4.25, 5, 5, 4.75, 4.5] }];

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export default function LineChartCurve() {
  const [curve, setCurve] = useState<PlassChartCurve>('step');

  return (
    <div className="flex w-full flex-col gap-4">
      <PlSegmentedButton value={curve} onValueChange={(next) => setCurve(next as PlassChartCurve)}>
        <PlSegment value="linear">linear</PlSegment>
        <PlSegment value="smooth">smooth</PlSegment>
        <PlSegment value="step">step</PlSegment>
      </PlSegmentedButton>

      <PlLineChart
        className="w-full"
        series={rate}
        categories={months}
        curve={curve}
        format={{ style: 'unit', unit: 'percent', maximumFractionDigits: 2 }}
      />
    </div>
  );
}
