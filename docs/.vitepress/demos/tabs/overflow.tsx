import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

const regions = [
  { value: 'seoul', label: 'Seoul', panel: 'Nine racks, all of them warm.' },
  { value: 'tokyo', label: 'Tokyo', panel: 'Two racks, one of them new.' },
  { value: 'sydney', label: 'Sydney', panel: 'A single rack, and a quiet week.' },
  { value: 'mumbai', label: 'Mumbai', panel: 'Four racks, and the busiest queue.' },
  { value: 'frankfurt', label: 'Frankfurt', panel: 'Six racks, and a spare.' },
  { value: 'dublin', label: 'Dublin', panel: 'Three racks, one being replaced.' },
  { value: 'saopaulo', label: 'São Paulo', panel: 'Two racks, both new this month.' },
  { value: 'virginia', label: 'N. Virginia', panel: 'Twelve racks, and the oldest of them.' }
];

export default function TabsOverflow() {
  return (
    <PlTabs defaultValue="seoul" className="w-full max-w-md">
      {regions.map((region) => (
        <PlTab key={region.value} value={region.value}>
          {region.label}
        </PlTab>
      ))}

      {regions.map((region) => (
        <PlTabPanel key={region.value} value={region.value}>
          {region.panel}
        </PlTabPanel>
      ))}
    </PlTabs>
  );
}
