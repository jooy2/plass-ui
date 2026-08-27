import { PlCard, PlScrollZone, PlTypography } from 'plass-ui';

const shows = [
  { name: 'Aurora', note: 'Documentary' },
  { name: 'Deep Field', note: 'Science' },
  { name: 'The Long Road', note: 'Drama' },
  { name: 'Salt & Stone', note: 'Cooking' },
  { name: 'Night Shift', note: 'Thriller' },
  { name: 'Paper Boats', note: 'Family' },
  { name: 'Signal', note: 'Mystery' }
];

export default function ScrollZoneHero() {
  return (
    <div className="w-full">
      <PlTypography level="h6" className="mb-2">
        Continue watching
      </PlTypography>

      <PlScrollZone label="Continue watching" spacing={3}>
        {shows.map((show) => (
          <PlCard key={show.name} size="sm" className="w-40" title={show.name} subtitle={show.note}>
            <div className="h-16 rounded-(--plass-radius-sm) bg-(--plass-primary-soft)" />
          </PlCard>
        ))}
      </PlScrollZone>
    </div>
  );
}
