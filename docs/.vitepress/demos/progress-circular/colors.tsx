import { PlProgressCircular } from 'plass-ui';

const colors = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function ProgressCircularColors() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      {colors.map((color) => (
        <PlProgressCircular key={color} color={color} value={70} label={color} />
      ))}
    </div>
  );
}
