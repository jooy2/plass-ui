import { PlTreeSelect, type PlTreeSelectNode } from 'plass-ui';

const items: PlTreeSelectNode[] = [
  {
    id: 'clothing',
    label: 'Clothing',
    children: [
      { id: 'coats', label: 'Coats' },
      { id: 'shirts', label: 'Shirts' }
    ]
  },
  {
    id: 'home',
    label: 'Home',
    // Chosen on its own even though the rest of the branches cannot be.
    selectable: true,
    children: [
      { id: 'lighting', label: 'Lighting' },
      { id: 'kitchen', label: 'Kitchen' }
    ]
  }
];

export default function TreeSelectBranches() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <PlTreeSelect
        items={items}
        label="Leaves only"
        placeholder="Pick a category"
        defaultExpanded={['clothing']}
      />
      <PlTreeSelect
        items={items}
        selectableBranches
        label="Branches too"
        placeholder="Pick a category"
        defaultExpanded={['clothing']}
      />
    </div>
  );
}
