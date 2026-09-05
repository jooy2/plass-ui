import { useState } from 'react';
import { PlTreeSelect, type PlTreeSelectNode } from 'plass-ui';

const items: PlTreeSelectNode[] = [
  {
    id: 'europe',
    label: 'Europe',
    children: [
      { id: 'france', label: 'France' },
      { id: 'germany', label: 'Germany' },
      { id: 'spain', label: 'Spain' }
    ]
  },
  {
    id: 'asia',
    label: 'Asia',
    children: [
      { id: 'korea', label: 'South Korea' },
      { id: 'japan', label: 'Japan' },
      { id: 'singapore', label: 'Singapore' }
    ]
  },
  {
    id: 'americas',
    label: 'Americas',
    children: [
      { id: 'brazil', label: 'Brazil' },
      { id: 'canada', label: 'Canada' }
    ]
  },
  { id: 'antarctica', label: 'Antarctica' }
];

export default function TreeSelectHero() {
  const [value, setValue] = useState<string[]>(['france']);

  return (
    <PlTreeSelect
      items={items}
      label="Region"
      placeholder="Pick a region"
      defaultExpanded={['europe']}
      clearable
      value={value}
      onValueChange={setValue}
    />
  );
}
