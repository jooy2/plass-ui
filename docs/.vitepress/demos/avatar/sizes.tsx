import { PlAvatar } from 'plass-ui';

export default function AvatarSizes() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlAvatar key={size} size={size} name="Jane Doe" />
      ))}
    </div>
  );
}
