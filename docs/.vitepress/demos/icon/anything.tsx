import { PlIcon } from 'plass-ui';

/** Authored in px by whichever set it came from. */
function HeartIcon() {
  return (
    <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor">
      <path d="M12 20.5 4.2 13a4.7 4.7 0 0 1 6.6-6.6l1.2 1.2 1.2-1.2A4.7 4.7 0 1 1 19.8 13Z" />
    </svg>
  );
}

/** Authored in em, the way a font-backed set does it. */
function EmHeartIcon() {
  return (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor">
      <path d="M12 20.5 4.2 13a4.7 4.7 0 0 1 6.6-6.6l1.2 1.2 1.2-1.2A4.7 4.7 0 1 1 19.8 13Z" />
    </svg>
  );
}

export default function IconAnything() {
  return (
    <div className="flex flex-wrap items-center gap-6 text-(--plass-fg)">
      <PlIcon icon={<HeartIcon />} size="lg" />
      <PlIcon icon={<EmHeartIcon />} size="lg" />
      <PlIcon icon="★" size="lg" />
      <PlIcon icon={<img src="/128x128.png" alt="" />} size="lg" />
    </div>
  );
}
