import { PlTreeSelect, type PlTreeSelectNode } from 'plass-ui';

const items: PlTreeSelectNode[] = [
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
          { id: 'tree-select', label: 'PlTreeSelect.tsx' }
        ]
      },
      {
        id: 'internal',
        label: 'internal',
        children: [
          { id: 'styles', label: 'styles.ts' },
          { id: 'search', label: 'search.ts' }
        ]
      }
    ]
  },
  { id: 'readme', label: 'README.md' }
];

export default function TreeSelectSearchable() {
  return (
    <PlTreeSelect
      items={items}
      searchable
      label="File"
      placeholder="Pick a file"
      defaultExpanded={['src']}
    />
  );
}
