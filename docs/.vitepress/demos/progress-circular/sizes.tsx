import { PlProgressCircular } from 'plass-ui';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ProgressCircularSizes() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      {sizes.map((size) => (
        <PlProgressCircular key={size} size={size} value={65} label={size} />
      ))}
    </div>
  );
}
