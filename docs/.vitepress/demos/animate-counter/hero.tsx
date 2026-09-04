import { PlAnimateCounter, PlStat } from 'plass-ui';

export default function AnimateCounterHero() {
  return (
    <div className="grid w-full max-w-md grid-cols-3 gap-6">
      <PlStat label="Projects" value={<PlAnimateCounter trigger="mount" value={128} />} />
      <PlStat label="Deploys" value={<PlAnimateCounter trigger="mount" value={4812} />} />
      <PlStat
        label="Uptime"
        value={
          <PlAnimateCounter
            trigger="mount"
            value={0.999}
            format={{ style: 'percent', minimumFractionDigits: 1 }}
          />
        }
      />
    </div>
  );
}
