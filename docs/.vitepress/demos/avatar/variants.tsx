import { PlAvatar } from 'plass-ui';

export default function AvatarVariants() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlAvatar key={variant} size="lg" variant={variant} name="Jane Doe" />
      ))}
    </div>
  );
}
