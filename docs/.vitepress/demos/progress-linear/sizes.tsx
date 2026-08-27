import { PlProgressLinear } from 'plass-ui';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ProgressLinearSizes() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      {sizes.map((size) => (
        <PlProgressLinear key={size} size={size} label={size} value={60} />
      ))}
    </div>
  );
}
