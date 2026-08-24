import { PlBadge } from 'plass-ui';

export default function BadgeColors() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlBadge key={color} color={color} content={9} />
      ))}
    </div>
  );
}
