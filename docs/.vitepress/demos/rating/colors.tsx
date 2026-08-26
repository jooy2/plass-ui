import { PlRating } from 'plass-ui';

export default function RatingColors() {
  return (
    <div className="flex flex-col items-start gap-3">
      {(['warning', 'primary', 'danger', 'success'] as const).map((color) => (
        <PlRating key={color} color={color} defaultValue={4} />
      ))}
    </div>
  );
}
