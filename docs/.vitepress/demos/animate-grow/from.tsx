import { PlAnimateGrow, PlChip } from 'plass-ui';

export default function AnimateGrowFrom() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      {[0.6, 0.9, 1.25].map((from) => (
        <PlAnimateGrow key={from} from={from} duration={1200} repeat="infinite" alternate>
          <PlChip color={from > 1 ? 'warning' : 'primary'}>from={from}</PlChip>
        </PlAnimateGrow>
      ))}
    </div>
  );
}
