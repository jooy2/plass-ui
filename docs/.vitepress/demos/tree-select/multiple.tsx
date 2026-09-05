import { PlTreeSelect, type PlTreeSelectNode } from 'plass-ui';

const items: PlTreeSelectNode[] = [
  {
    id: 'design',
    label: 'Design',
    children: [
      { id: 'tokens', label: 'Tokens' },
      { id: 'motion', label: 'Motion' }
    ]
  },
  {
    id: 'engineering',
    label: 'Engineering',
    children: [
      { id: 'web', label: 'Web' },
      { id: 'mobile', label: 'Mobile' },
      { id: 'infra', label: 'Infrastructure' }
    ]
  }
];

export default function TreeSelectMultiple() {
  return (
    <PlTreeSelect
      items={items}
      multiple
      clearable
      label="Teams"
      placeholder="Pick a team or two"
      defaultExpanded={['engineering']}
      defaultValue={['web', 'infra']}
    />
  );
}
