import { PlAvatar, PlScrollZone, PlTypography } from 'plass-ui';

const people = ['Ada', 'Bo', 'Cai', 'Dana', 'Eun', 'Fen', 'Gus', 'Hana', 'Ivo', 'Jun'];

export default function ScrollZoneButtons() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div className="flex flex-col gap-1">
        <PlTypography level="caption">buttons=&quot;always&quot;</PlTypography>
        <PlScrollZone label="Always" buttons="always" spacing={3}>
          {people.map((name) => (
            <PlAvatar key={name} name={name} size="lg" />
          ))}
        </PlScrollZone>
      </div>

      <div className="flex flex-col gap-1">
        <PlTypography level="caption">buttons=&quot;none&quot; · snap</PlTypography>
        <PlScrollZone label="None" buttons="none" snap spacing={3}>
          {people.map((name) => (
            <PlAvatar key={name} name={name} size="lg" color="secondary" />
          ))}
        </PlScrollZone>
      </div>
    </div>
  );
}
