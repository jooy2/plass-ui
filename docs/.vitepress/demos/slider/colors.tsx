import { PlSlider } from 'plass-ui';

export default function SliderColors() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      {(['primary', 'success', 'warning', 'danger'] as const).map((color) => (
        <PlSlider key={color} color={color} label={color} defaultValue={60} showValue />
      ))}
    </div>
  );
}
