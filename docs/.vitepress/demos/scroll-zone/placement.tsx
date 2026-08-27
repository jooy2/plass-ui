import { PlCard, PlScrollZone, PlTypography } from 'plass-ui';

const numbers = Array.from({ length: 12 }, (_, index) => index + 1);

function Strip() {
  return (
    <>
      {numbers.map((number) => (
        <PlCard key={number} size="sm" className="w-28 text-center">
          Item {number}
        </PlCard>
      ))}
    </>
  );
}

export default function ScrollZonePlacement() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div className="flex flex-col gap-1">
        <PlTypography level="caption">buttonPlacement=&quot;overlay&quot;</PlTypography>
        <PlScrollZone label="Overlaid" buttons="always">
          <Strip />
        </PlScrollZone>
      </div>

      <div className="flex flex-col gap-1">
        <PlTypography level="caption">buttonPlacement=&quot;inline&quot;</PlTypography>
        <PlScrollZone label="Beside" buttons="always" buttonPlacement="inline">
          <Strip />
        </PlScrollZone>
      </div>
    </div>
  );
}
