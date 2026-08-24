import { PlSlider } from 'plass-ui';

export default function SliderSizes() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlSlider key={size} size={size} label={size} defaultValue={55} showValue />
      ))}
    </div>
  );
}
