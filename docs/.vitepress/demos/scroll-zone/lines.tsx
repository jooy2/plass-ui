import { PlChip, PlScrollZone } from 'plass-ui';

const teams = [
  'Design',
  'Engineering',
  'Research',
  'Marketing',
  'Support',
  'Finance',
  'Legal',
  'People',
  'Security',
  'Data',
  'Sales',
  'Operations'
];

export default function ScrollZoneLines() {
  return (
    <div className="flex w-full flex-col gap-6">
      <PlScrollZone label="Teams, one line" spacing={2}>
        {teams.map((team) => (
          <PlChip key={team}>{team}</PlChip>
        ))}
      </PlScrollZone>

      <PlScrollZone label="Teams, two lines" lines={2} spacing={2}>
        {teams.map((team) => (
          <PlChip key={team} color="secondary">
            {team}
          </PlChip>
        ))}
      </PlScrollZone>
    </div>
  );
}
