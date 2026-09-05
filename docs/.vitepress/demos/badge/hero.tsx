import { PlAvatar, PlBadge, PlButton } from 'plass-ui';

function BellIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <path d="M18 8a6 6 0 1 0-12 0c0 6-2 7-2 7h16s-2-1-2-7" strokeLinejoin="round" />
      <path d="M13.7 20a2 2 0 0 1-3.4 0" strokeLinecap="round" />
    </svg>
  );
}

export default function BadgeHero() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <PlBadge content={4} label="4 unread notifications">
        <PlButton variant="glass" color="secondary" aria-label="Notifications">
          <BellIcon />
        </PlButton>
      </PlBadge>

      <PlBadge dot color="success" overlap="circle" label="Online">
        <PlAvatar name="Nadia Rowan" src="/samples/avatars/nadia-rowan.webp" />
      </PlBadge>

      <PlBadge content="Beta" variant="ghost" color="info" />
    </div>
  );
}
