import { PlProgressLinear } from 'plass-ui';

const colors = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function ProgressLinearColors() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      {colors.map((color) => (
        <PlProgressLinear key={color} color={color} label={color} value={70} />
      ))}
    </div>
  );
}
