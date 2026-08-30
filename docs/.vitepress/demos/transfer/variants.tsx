import { PlTransfer, type PlassVariant } from 'plass-ui';

const items = [
  { value: 'a', label: 'Alpha' },
  { value: 'b', label: 'Beta' },
  { value: 'c', label: 'Gamma' }
];

export default function TransferVariants() {
  return (
    <div className="flex w-full flex-col gap-6">
      {(['solid', 'glass', 'ghost'] as PlassVariant[]).map((variant) => (
        <PlTransfer
          key={variant}
          className="max-w-2xl"
          variant={variant}
          size="sm"
          items={items}
          defaultValue={['b']}
          sourceLabel={variant}
          targetLabel="Chosen"
          height={110}
        />
      ))}
    </div>
  );
}
