import { PlSelect } from 'plass-ui';

const cities = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' },
  { value: 'quito', label: 'Quito' },
  { value: 'reykjavik', label: 'Reykjavík' }
];

export default function SelectHero() {
  return (
    <PlSelect
      className="w-full max-w-xs"
      fullWidth
      label="City"
      description="Where the team sits."
      placeholder="Pick a city"
      items={cities}
      defaultValue="lisbon"
    />
  );
}
