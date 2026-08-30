import { PlTransfer, type PlTransferItem } from 'plass-ui';

const permissions: PlTransferItem[] = [
  { value: 'read', label: 'Read' },
  { value: 'write', label: 'Write' },
  { value: 'admin', label: 'Administer', disabled: true },
  { value: 'billing', label: 'Billing' }
];

export default function TransferStates() {
  return (
    <div className="flex w-full flex-col gap-6">
      <PlTransfer
        className="max-w-2xl"
        size="sm"
        items={permissions}
        defaultValue={['read']}
        height={130}
      />
      <PlTransfer
        className="max-w-2xl"
        size="sm"
        items={permissions}
        defaultValue={['read']}
        height={130}
        disabled
      />
    </div>
  );
}
