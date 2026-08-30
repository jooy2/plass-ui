import { useState } from 'react';
import { PlTransfer, type PlTransferItem } from 'plass-ui';

const columns: PlTransferItem[] = [
  { value: 'name', label: 'Name' },
  { value: 'email', label: 'Email' },
  { value: 'role', label: 'Role' },
  { value: 'team', label: 'Team' },
  { value: 'joined', label: 'Joined' },
  { value: 'status', label: 'Status' },
  { value: 'id', label: 'Identifier', disabled: true }
];

export default function TransferHero() {
  const [value, setValue] = useState<string[]>(['name', 'email']);

  return (
    <PlTransfer
      className="max-w-2xl"
      items={columns}
      value={value}
      onValueChange={setValue}
      sourceLabel="Available columns"
      targetLabel="In the report"
    />
  );
}
