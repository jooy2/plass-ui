import { PlAnimateZoom, PlChip } from 'plass-ui';

export default function AnimateZoomFrom() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      {[0.2, 0.4, 1.6].map((from) => (
        <PlAnimateZoom key={from} from={from} duration={1300} repeat="infinite" alternate>
          <PlChip color={from > 1 ? 'warning' : 'primary'}>from={from}</PlChip>
        </PlAnimateZoom>
      ))}
    </div>
  );
}
