import { useState } from 'react';
import { PlCard, PlTree, PlTypography, type PlTreeNode } from 'plass-ui';

const items: PlTreeNode[] = [
  {
    id: 'design',
    label: 'Design',
    children: [
      { id: 'colour', label: 'Colour' },
      { id: 'type', label: 'Typography' }
    ]
  },
  {
    id: 'engineering',
    label: 'Engineering',
    children: [
      { id: 'web', label: 'Web' },
      { id: 'mobile', label: 'Mobile' }
    ]
  }
];

export default function TreeSelection() {
  const [selected, setSelected] = useState<string[]>(['colour', 'web']);

  return (
    <PlCard className="w-full max-w-sm">
      <PlTree
        items={items}
        selection="multiple"
        defaultExpanded={['design', 'engineering']}
        selected={selected}
        onSelectedChange={setSelected}
      />
      <PlTypography level="caption" className="mt-3 block text-(--plass-muted-fg)">
        {selected.length} chosen
      </PlTypography>
    </PlCard>
  );
}
