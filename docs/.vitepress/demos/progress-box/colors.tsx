import { PlProgressBox } from 'plass-ui';

const colors = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function ProgressBoxColors() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      {colors.map((color) => (
        <PlProgressBox key={color} color={color} label={color} value={65} />
      ))}
    </div>
  );
}
