import { PlRating } from 'plass-ui';

export default function RatingSizes() {
  return (
    <div className="flex flex-col items-start gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlRating key={size} size={size} defaultValue={4} />
      ))}
    </div>
  );
}
