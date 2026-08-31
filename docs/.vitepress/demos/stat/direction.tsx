import { PlCard, PlStat } from 'plass-ui';

export default function StatDirection() {
  return (
    <div className="grid w-full max-w-lg gap-4 sm:grid-cols-2">
      <PlCard>
        <PlStat label="Revenue" value="£48,120" change={12.4} description="up is good" />
      </PlCard>
      <PlCard>
        <PlStat
          label="p95 latency"
          value="182ms"
          change={12.4}
          improvesWhen="down"
          description="the same number, down is good"
        />
      </PlCard>
    </div>
  );
}
