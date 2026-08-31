import { PlAlert, usePlMediaQuery } from 'plass-ui';

export default function MediaQueryDemo() {
  const coarse = usePlMediaQuery('(pointer: coarse)');
  const wide = usePlMediaQuery('(width >= 48rem)');
  const still = usePlMediaQuery('(prefers-reduced-motion: reduce)');

  return (
    <div className="flex w-full flex-col gap-2">
      <PlAlert size="sm" color={coarse ? 'success' : 'info'}>
        <code>(pointer: coarse)</code> — {String(coarse)}
      </PlAlert>
      <PlAlert size="sm" color={wide ? 'success' : 'info'}>
        <code>(width &gt;= 48rem)</code> — {String(wide)}
      </PlAlert>
      <PlAlert size="sm" color={still ? 'success' : 'info'}>
        <code>(prefers-reduced-motion: reduce)</code> — {String(still)}
      </PlAlert>
    </div>
  );
}
