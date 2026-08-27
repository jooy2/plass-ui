import { PlProgressBox } from 'plass-ui';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ProgressBoxSizes() {
  return (
    <div className="flex flex-col items-start gap-5">
      {sizes.map((size) => (
        <PlProgressBox key={size} size={size} label={size} value={60} />
      ))}
    </div>
  );
}
