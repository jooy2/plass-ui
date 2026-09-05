import { PlCard, PlScrollZone, PlTypography } from 'plass-ui';

const shows = [
  { name: 'Aurora', note: 'Documentary', still: 'desert-rocks-milky-way' },
  { name: 'Deep Field', note: 'Science', still: 'lakeside-observatory-blue-hour' },
  { name: 'The Long Road', note: 'Drama', still: 'bicycle-coastal-path' },
  { name: 'Salt & Stone', note: 'Cooking', still: 'artisan-bread-wooden-rack' },
  { name: 'Night Shift', note: 'Thriller', still: 'rainy-city-crosswalk-reflections' },
  { name: 'Paper Boats', note: 'Family', still: 'rowboat-misty-pond-sunrise' },
  { name: 'Signal', note: 'Mystery', still: 'snowy-cabin-frozen-stream' }
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
            <img
              src={`/samples/photos/${show.still}.webp`}
              alt=""
              className="h-16 w-full rounded-(--plass-radius-sm) object-cover"
            />
          </PlCard>
        ))}
      </PlScrollZone>
    </div>
  );
}
