import { useState } from 'react';
import { PlCard, PlTree, PlTypography, type PlTreeNode } from 'plass-ui';

const items: PlTreeNode[] = [
  {
    id: 'src',
    label: 'src',
    children: [
      { id: 'index', label: 'index.ts' },
      {
        id: 'components',
        label: 'components',
        children: [
          { id: 'button', label: 'PlButton.tsx' },
          { id: 'card', label: 'PlCard.tsx' },
          { id: 'tree', label: 'PlTree.tsx' }
        ]
      },
      { id: 'internal', label: 'internal', children: [{ id: 'styles', label: 'styles.ts' }] }
    ]
  },
  { id: 'readme', label: 'README.md' },
  { id: 'lock', label: 'package-lock.json', disabled: true }
];

export default function TreeHero() {
  const [selected, setSelected] = useState<string[]>(['button']);

  return (
    <PlCard className="w-full max-w-sm">
      <PlTree
        items={items}
        defaultExpanded={['src', 'components']}
        selected={selected}
        onSelectedChange={setSelected}
      />
      <PlTypography level="caption" className="mt-3 block text-(--plass-muted-fg)">
        {selected[0] ?? 'Nothing chosen'}
      </PlTypography>
    </PlCard>
  );
}
