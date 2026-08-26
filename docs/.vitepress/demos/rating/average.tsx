import { PlRating, PlTypography } from 'plass-ui';

export default function RatingAverage() {
  return (
    <div className="flex flex-col gap-3">
      {[4.3, 2.5, 0].map((score) => (
        <div key={score} className="flex items-center gap-3">
          <PlRating readOnly value={score} />
          <PlTypography level="caption">value={score}</PlTypography>
        </div>
      ))}
    </div>
  );
}
