import { PlAvatar } from 'plass-ui';

export default function AvatarFallback() {
  return (
    <div className="flex flex-wrap items-center gap-6 text-center">
      <div className="flex flex-col items-center gap-2">
        <PlAvatar name="Nadia Rowan" src="/samples/avatars/nadia-rowan.webp" />
        <span className="text-xs text-(--plass-muted-fg)">picture</span>
      </div>
      <div className="flex flex-col items-center gap-2">
        <PlAvatar name="Nadia Rowan" src="https://example.invalid/missing.png" />
        <span className="text-xs text-(--plass-muted-fg)">initials</span>
      </div>
      <div className="flex flex-col items-center gap-2">
        <PlAvatar name="Nadia Rowan" initials="NR!" />
        <span className="text-xs text-(--plass-muted-fg)">initials, written</span>
      </div>
      <div className="flex flex-col items-center gap-2">
        <PlAvatar name="Cat">🐈</PlAvatar>
        <span className="text-xs text-(--plass-muted-fg)">children</span>
      </div>
      <div className="flex flex-col items-center gap-2">
        <PlAvatar />
        <span className="text-xs text-(--plass-muted-fg)">silhouette</span>
      </div>
    </div>
  );
}
