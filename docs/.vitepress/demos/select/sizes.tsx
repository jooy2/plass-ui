import { PlSelect, PlTextField } from 'plass-ui';

const items = [
  { value: 'utc', label: 'UTC' },
  { value: 'kst', label: 'KST' }
];

export default function SelectSizes() {
  return (
    <div className="flex flex-col gap-3">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <div key={size} className="flex flex-wrap items-center gap-3">
          <PlSelect size={size} items={items} defaultValue="utc" />
          <PlTextField size={size} placeholder="Same shell, same height" />
        </div>
      ))}
    </div>
  );
}
