import { PlCard, PlStat } from 'plass-ui';

export default function StatHero() {
  return (
    <div className="grid w-full max-w-2xl gap-4 sm:grid-cols-3">
      <PlCard>
        <PlStat label="Revenue" value="£48,120" change={12.4} description="vs last month" />
      </PlCard>
      <PlCard>
        <PlStat label="Sign-ups" value="1,204" change={8.1} description="vs last month" />
      </PlCard>
      <PlCard>
        <PlStat
          label="Churn"
          value="4.2%"
          change={2.6}
          improvesWhen="down"
          description="vs last month"
        />
      </PlCard>
    </div>
  );
}
