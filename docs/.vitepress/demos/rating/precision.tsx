import { PlRating, PlTypography } from 'plass-ui';

export default function RatingPrecision() {
  return (
    <div className="flex flex-col gap-3">
      {[1, 0.5, 0.25].map((precision) => (
        <div key={precision} className="flex items-center gap-3">
          <PlRating precision={precision} defaultValue={3} />
          <PlTypography level="caption">precision={precision}</PlTypography>
        </div>
      ))}
    </div>
  );
}
