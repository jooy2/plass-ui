import { PlAvatar } from 'plass-ui';

export default function AvatarColors() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlAvatar key={color} color={color} name={color} />
      ))}
    </div>
  );
}
