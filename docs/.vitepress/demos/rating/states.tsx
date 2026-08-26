import { PlRating, PlTypography } from 'plass-ui';

export default function RatingStates() {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center gap-3">
        <PlRating defaultValue={3} />
        <PlTypography level="caption">interactive</PlTypography>
      </div>
      <div className="flex items-center gap-3">
        <PlRating readOnly value={3.5} />
        <PlTypography level="caption">readOnly</PlTypography>
      </div>
      <div className="flex items-center gap-3">
        <PlRating disabled value={3} />
        <PlTypography level="caption">disabled</PlTypography>
      </div>
    </div>
  );
}
