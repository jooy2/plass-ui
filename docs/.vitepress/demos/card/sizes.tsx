import { PlCard } from 'plass-ui';

export default function CardSizes() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlCard key={size} size={size} title={`size="${size}"`} subtitle="Title, subtitle, body">
          The radius, the type scale and the padding move together.
        </PlCard>
      ))}
    </div>
  );
}
